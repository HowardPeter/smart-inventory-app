#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   $0 --start <ISO8601> --end <ISO8601> --output <directory>

# Example:
#   $0 \\
#     --start "2026-09-22T13:13:02Z" \\
#     --end "2026-09-22T13:15:02Z" \\
#     --output "./results/realistic-10-20260922-201302"

# Environment variables:
#   AWS_REGION
#   LAMBDA_FUNCTION
#   API_ID
#   API_STAGE
#   CLOUDWATCH_PERIOD
#   CLOUDWATCH_BUFFER_SECONDS

REGION="${AWS_REGION:-ap-southeast-1}"

LAMBDA_FUNCTION="${LAMBDA_FUNCTION:-storix-staging-lambda-function-api}"

API_ID="${API_ID:-qzze2vy50c}"
API_STAGE="${API_STAGE:-\$default}"

PERIOD="${CLOUDWATCH_PERIOD:-60}"

# Buffer around test window to avoid CloudWatch period-boundary issues.
BUFFER_SECONDS="${CLOUDWATCH_BUFFER_SECONDS:-60}"

# Parse arguments
START_TIME=""
END_TIME=""
OUTPUT_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --start)
      START_TIME="$2"
      shift 2
      ;;

    --end)
      END_TIME="$2"
      shift 2
      ;;

    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;

    *)
      echo "ERROR: Unknown argument: $1"
      echo
      exit 1
      ;;
  esac
done

# Validate arguments
if [[ -z "$START_TIME" || -z "$END_TIME" || -z "$OUTPUT_DIR" ]]; then
  echo "ERROR: --start, --end and --output are required."
  echo
  exit 1
fi

# Prepare output directories
LAMBDA_DIR="$OUTPUT_DIR/cloudwatch/lambda"
APIGW_DIR="$OUTPUT_DIR/cloudwatch/apigateway"

mkdir -p "$LAMBDA_DIR"
mkdir -p "$APIGW_DIR"

# Calculate buffered time window
BUFFERED_START="$(
  date \
    -d "$START_TIME - $BUFFER_SECONDS seconds" \
    -u \
    '+%Y-%m-%dT%H:%M:%SZ'
)"

BUFFERED_END="$(
  date \
    -d "$END_TIME + $BUFFER_SECONDS seconds" \
    -u \
    '+%Y-%m-%dT%H:%M:%SZ'
)"

# Metadata
cat > "$OUTPUT_DIR/cloudwatch/metadata.json" <<EOF
{
  "region": "$REGION",
  "lambdaFunction": "$LAMBDA_FUNCTION",
  "apiId": "$API_ID",
  "apiStage": "$API_STAGE",
  "periodSeconds": $PERIOD,
  "bufferSeconds": $BUFFER_SECONDS,
  "requestedWindow": {
    "start": "$START_TIME",
    "end": "$END_TIME"
  },
  "queryWindow": {
    "start": "$BUFFERED_START",
    "end": "$BUFFERED_END"
  },
  "collectedAt": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
}
EOF

# Helper
collect_lambda_metric() {
  local metric_name="$1"
  local statistics="$2"
  local output_file="$3"

  echo "Collecting Lambda/$metric_name..."

  aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name "$metric_name" \
    --dimensions \
      Name=FunctionName,Value="$LAMBDA_FUNCTION" \
    --start-time "$BUFFERED_START" \
    --end-time "$BUFFERED_END" \
    --period "$PERIOD" \
    --statistics $statistics \
    --region "$REGION" \
    --output json \
    | tee "$output_file"
}

collect_apigw_metric() {
  local metric_name="$1"
  local statistics="$2"
  local output_file="$3"

  echo "Collecting API Gateway/$metric_name..."

  aws cloudwatch get-metric-statistics \
    --namespace AWS/ApiGateway \
    --metric-name "$metric_name" \
    --dimensions \
      Name=ApiId,Value="$API_ID" \
      Name=Stage,Value="$API_STAGE" \
    --start-time "$BUFFERED_START" \
    --end-time "$BUFFERED_END" \
    --period "$PERIOD" \
    --statistics $statistics \
    --region "$REGION" \
    --output json \
    | tee "$output_file"
}

# Lambda metrics
echo
echo "========================================"
echo "Lambda Metrics"
echo "========================================"

collect_lambda_metric \
  "Invocations" \
  "Sum" \
  "$LAMBDA_DIR/invocations.json"

collect_lambda_metric \
  "Errors" \
  "Sum" \
  "$LAMBDA_DIR/errors.json"

collect_lambda_metric \
  "Throttles" \
  "Sum" \
  "$LAMBDA_DIR/throttles.json"

collect_lambda_metric \
  "Duration" \
  "Average Maximum" \
  "$LAMBDA_DIR/duration.json"

collect_lambda_metric \
  "ConcurrentExecutions" \
  "Maximum" \
  "$LAMBDA_DIR/concurrency.json"

# API Gateway metrics
echo
echo "========================================"
echo "API Gateway Metrics"
echo "========================================"

collect_apigw_metric \
  "Count" \
  "Sum" \
  "$APIGW_DIR/count.json"

collect_apigw_metric \
  "4XXError" \
  "Sum" \
  "$APIGW_DIR/4xx.json"

collect_apigw_metric \
  "5XXError" \
  "Sum" \
  "$APIGW_DIR/5xx.json"

collect_apigw_metric \
  "Latency" \
  "Average Maximum" \
  "$APIGW_DIR/latency.json"

collect_apigw_metric \
  "IntegrationLatency" \
  "Average Maximum" \
  "$APIGW_DIR/integration-latency.json"

# Finished
echo
echo "========================================"
echo "CloudWatch collection completed"
echo "========================================"
echo "Output:"
echo "  $OUTPUT_DIR/cloudwatch/"
echo
echo "Lambda:"
echo "  $LAMBDA_DIR/"
echo
echo "API Gateway:"
echo "  $APIGW_DIR/"
echo
