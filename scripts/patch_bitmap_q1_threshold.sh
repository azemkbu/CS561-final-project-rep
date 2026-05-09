#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <right_days_value>" >&2
  echo "Examples:" >&2
  echo "  $0 8336   # 1992-10-28" >&2
  echo "  $0 9298   # 1995-06-17" >&2
  echo "  $0 10261  # 1998-02-04" >&2
  exit 1
fi

RIGHT_DAYS_VAL="$1"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
TARGET_FILE="$PROJECT_ROOT/extension/debit/execution/tpch/query/Q1.cpp"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "Could not find Q1.cpp at: $TARGET_FILE" >&2
  echo "Run this script from the original CS561-Access-Path-Selection repository or set PROJECT_ROOT." >&2
  exit 1
fi

echo "Before patch:"
grep -n "right_days" "$TARGET_FILE" || true

sed -i "s/int right_days = [0-9]\+;/int right_days = ${RIGHT_DAYS_VAL};/" "$TARGET_FILE"

echo "After patch:"
grep -n "right_days" "$TARGET_FILE" || true

echo "Recompile the project with: make"
