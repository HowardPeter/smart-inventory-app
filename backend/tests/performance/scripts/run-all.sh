#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNNER="$ROOT_DIR/scripts/run-phase1.sh"

SCENARIOS=(
  baseline
  load_100
  load_200
  load_500
  load_1000
  rps_100
  rps_200
  rps_500
  rps_1000
  sustained
)

for scenario in "${SCENARIOS[@]}"; do
  echo
  echo "=========================================="
  echo "Running: $scenario"
  echo "=========================================="
  "$RUNNER" "$scenario"
done
