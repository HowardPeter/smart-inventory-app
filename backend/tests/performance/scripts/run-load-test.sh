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
THINK_TIME_RANDOM="${THINK_TIME_RANDOM:-15000}"
THINK_TIME="$(($THINK_TIME_MIN / 1000))-$((($THINK_TIME_MIN + $THINK_TIME_RANDOM)/1000))"

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
    USERS=100; RAMPUP=120; DURATION=300; MODE="users"
    ;;
  load_200)
    USERS=200; RAMPUP=120; DURATION=300; MODE="users"
    ;;
  load_500)
    USERS=500; RAMPUP=180; DURATION=300; MODE="users"
    ;;
  load_1000)
    USERS=1000; RAMPUP=300; DURATION=360; MODE="users"
    ;;
  sustained)
    USERS=20; RAMPUP=120; DURATION=1800; MODE="users"
    ;;
  rps_20)
    USERS=500; RAMPUP=180; DURATION=300; TPM=1200; MODE="rps"
    ;;
  rps_40)
    USERS=500; RAMPUP=180; DURATION=300; TPM=2400; MODE="rps"
    ;;
  rps_45)
    USERS=500; RAMPUP=180; DURATION=300; TPM=2700; MODE="rps"
    ;;
  rps_50)
    USERS=500; RAMPUP=180; DURATION=300; TPM=3000; MODE="rps"
    ;;
  rps_60)
    USERS=500; RAMPUP=180; DURATION=300; TPM=3600; MODE="rps"
    ;;
  rps_70)
    USERS=500; RAMPUP=180; DURATION=300; TPM=4200; MODE="rps"
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
echo "Load & Availability Test"
echo "Scenario : $SCENARIO"
echo "Target   : $PROTOCOL://$HOST$ENDPOINT"
echo "Users    : $USERS"
echo "Ramp-up  : ${RAMPUP}s"
echo "Duration : ${DURATION}s"
[[ "$MODE" == "rps" ]] && echo "Target RPS: $(($TPM / 60))"
[[ "$MODE" == "users" ]] && echo "Think time: ${THINK_TIME}s"
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
  -l "$OUT_DIR/results.jtl"
  -e
  -o "$OUT_DIR/html-report"
)

if [[ "$MODE" == "rps" ]]; then
  COMMON_ARGS+=(-Jthroughput_per_minute="$TPM")
else
  COMMON_ARGS+=(-Jthink_min="$THINK_TIME_MIN")
  COMMON_ARGS+=(-Jthink_random="$THINK_TIME_RANDOM")
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
mode=$MODE
$( [[ "$MODE" == "rps" ]] && echo "throughput_per_minute=$TPM" )
$( [[ "$MODE" == "users" ]] && echo "think_time_seconds=$THINK_TIME" )
timestamp=$TIMESTAMP
EOF

END_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo
echo "Test completed."
echo "HTML report: $OUT_DIR/html-report/index.html"
echo "Raw results: $OUT_DIR/results.jtl"
printf './scripts/collect-cloudwatch.sh --start "%s" --end "%s" --output "%s"\n' \
  "$START_TIME" "$END_TIME" "$OUT_DIR"
