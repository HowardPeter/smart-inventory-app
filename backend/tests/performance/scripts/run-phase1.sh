#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   export TEST_TOKEN='...'
#   ./scripts/run-phase1.sh baseline
#   ./scripts/run-phase1.sh load_100
#   ./scripts/run-phase1.sh load_200
#   ./scripts/run-phase1.sh load_500
#   ./scripts/run-phase1.sh load_1000
#   ./scripts/run-phase1.sh sustained
#   ./scripts/run-phase1.sh rps_100
#   ./scripts/run-phase1.sh rps_200
#   ./scripts/run-phase1.sh rps_500
#   ./scripts/run-phase1.sh rps_1000

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULT_ROOT="$ROOT_DIR/results"

SCENARIO="${1:-}"
TOKEN="${TEST_TOKEN:-}"

PROTOCOL="${TEST_PROTOCOL:-https}"
HOST="${TEST_HOST:-qzze2vy50c.execute-api.ap-southeast-1.amazonaws.com}"
ENDPOINT="${TEST_ENDPOINT:-/api/inventories}"

THINK_TIME_MIN="${THINK_TIME_MIN:-10000}"
THINK_TIME_RANDOM="${THINK_TIME_RANDOM:-5000}"
THINK_TIME=$((($THINK_TIME_MIN + $THINK_TIME_RANDOM)/1000))

if [[ -z "$SCENARIO" ]]; then
  echo "Usage: $0 <scenario>"
  exit 1
fi

if [[ -z "$TOKEN" ]]; then
  echo "TEST_TOKEN is not set."
  echo "Example: export TEST_TOKEN='your-staging-token'"
  exit 1
fi

case "$SCENARIO" in
  baseline)
    USERS=10; RAMPUP=30; DURATION=120; MODE="users"
    ;;
  load_100)
    USERS=100; RAMPUP=60; DURATION=300; MODE="users"
    ;;
  load_200)
    USERS=200; RAMPUP=120; DURATION=300; MODE="users"
    ;;
  load_500)
    USERS=500; RAMPUP=180; DURATION=300; MODE="users"
    ;;
  load_1000)
    USERS=1000; RAMPUP=300; DURATION=300; MODE="users"
    ;;
  sustained)
    USERS=300; RAMPUP=180; DURATION=1800; MODE="users"
    ;;
  rps_100)
    USERS=100; RAMPUP=60; DURATION=300; TARGET_RPS=100; MODE="rps"
    ;;
  rps_200)
    USERS=200; RAMPUP=120; DURATION=300; TARGET_RPS=200; MODE="rps"
    ;;
  rps_500)
    USERS=500; RAMPUP=180; DURATION=300; TARGET_RPS=500; MODE="rps"
    ;;
  rps_1000)
    USERS=1000; RAMPUP=300; DURATION=300; TARGET_RPS=1000; MODE="rps"
    ;;
  *)
    echo "Unknown scenario: $SCENARIO"
    exit 1
    ;;
esac

START_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$RESULT_ROOT/$SCENARIO/$TIMESTAMP"
mkdir -p "$OUT_DIR"

if [[ "$MODE" == "users" ]]; then
  JMX="$ROOT_DIR/jmeter/read-only-load.jmx"
else
  JMX="$ROOT_DIR/jmeter/rps-load.jmx"
fi

echo "=========================================="
echo "SIS Phase 1 Load & Availability"
echo "Scenario : $SCENARIO"
echo "Target   : $PROTOCOL://$HOST$ENDPOINT"
echo "Users    : $USERS"
echo "Ramp-up  : ${RAMPUP}s"
echo "Duration : ${DURATION}s"
echo "Think time: ${THINK_TIME}s"
[[ "$MODE" == "rps" ]] && echo "Target RPS: $TARGET_RPS"
echo "Output   : $OUT_DIR"
echo "=========================================="

COMMON_ARGS=(
  -n
  -t "$JMX"
  -Jprotocol="$PROTOCOL"
  -Jhost="$HOST"
  -Jendpoint="$ENDPOINT"
  -Jtoken="$TOKEN"
  -Jusers="$USERS"
  -Jrampup="$RAMPUP"
  -Jduration="$DURATION"
  -Jthink_min="$THINK_TIME_MIN"
  -Jthink_random="$THINK_TIME_RANDOM"
  -l "$OUT_DIR/results.jtl"
  -e
  -o "$OUT_DIR/html-report"
)

if [[ "$MODE" == "rps" ]]; then
  COMMON_ARGS+=(-Jtarget_rps="$TARGET_RPS")
fi

jmeter "${COMMON_ARGS[@]}"

cat > "$OUT_DIR/metadata.txt" <<EOF
scenario=$SCENARIO
protocol=$PROTOCOL
host=$HOST
endpoint=$ENDPOINT
users=$USERS
ramp_up_seconds=$RAMPUP
duration_seconds=$DURATION
think_time_seconds=$THINK_TIME
mode=$MODE
$( [[ "$MODE" == "rps" ]] && echo "target_rps=$TARGET_RPS" )
timestamp=$TIMESTAMP
EOF

echo
END_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "Test completed."
echo "HTML report: $OUT_DIR/html-report/index.html"
echo "Raw results: $OUT_DIR/results.jtl"
printf './scripts/collect-cloudwatch.sh --start "%s" --end "%s" --output "%s"\n' \
  "$START_TIME" "$END_TIME" "$OUT_DIR/cloudwatch-metrics"
