#!/usr/bin/env bash
set -euo pipefail

DUCKDB_BIN="${DUCKDB_BIN:-./build/release/duckdb}"
DB_FILE="${DB_FILE:-bitmap.db}"
OUT_FILE="${OUT_FILE:-results/logs/bitmap_q1.log}"
mkdir -p "$(dirname "$OUT_FILE")"

{
  echo ".timer on"
  echo "SET threads TO 1;"
  echo "PRAGMA load_bitmap(shipdate, linestatus, returnflag);"
  echo "PRAGMA bm_tpch(1);"
} | "$DUCKDB_BIN" "$DB_FILE" 2>&1 | tee "$OUT_FILE"
