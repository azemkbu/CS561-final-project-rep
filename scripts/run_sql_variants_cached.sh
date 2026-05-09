#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <experiment_label> <query_directory>" >&2
  echo "Example: $0 column_sketch_q1_cached queries/tpch1_shipdate" >&2
  exit 1
fi

EXPERIMENT_LABEL="$1"
QUERY_DIR="$2"
DUCKDB_BIN="${DUCKDB_BIN:-./build/release/duckdb}"
DB_FILE="${DB_FILE:-benchmark.db}"
RUNS="${RUNS:-3}"
OUT_DIR="${OUT_DIR:-results/logs/${EXPERIMENT_LABEL}}"

mkdir -p "$OUT_DIR"

if [[ ! -x "$DUCKDB_BIN" ]]; then
  echo "DuckDB binary not found or not executable: $DUCKDB_BIN" >&2
  exit 1
fi

for query_file in "$QUERY_DIR"/*.sql; do
  query_name="$(basename "$query_file" .sql)"
  log_file="$OUT_DIR/${query_name}_cached.log"
  echo "Running cached $EXPERIMENT_LABEL / $query_name"

  {
    echo ".timer on"
    echo "SET threads TO 1;"
    for run in $(seq 1 "$RUNS"); do
      echo "-- Run $run"
      cat "$query_file"
    done
  } | "$DUCKDB_BIN" "$DB_FILE" 2>&1 | tee "$log_file"
done
