#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <lower_discount> <upper_discount>" >&2
  echo "Example: $0 1 2" >&2
  echo "Example: $0 1 6" >&2
  echo "Example: $0 1 9" >&2
  exit 1
fi

LOWER_DISCOUNT_VAL="$1"
UPPER_DISCOUNT_VAL="$2"
Q6_CPP="${Q6_CPP:-extension/debit/execution/tpch/query/Q6.cpp}"

if [[ ! -f "$Q6_CPP" ]]; then
  echo "Q6.cpp not found: $Q6_CPP" >&2
  echo "Run this script from the root of the original CS561-Access-Path-Selection repository." >&2
  exit 1
fi

echo "Current Q6 discount bounds:"
grep -n "lower_discount\|upper_discount" "$Q6_CPP"

sed -i "s/int lower_discount = [0-9]\+;/int lower_discount = ${LOWER_DISCOUNT_VAL};/" "$Q6_CPP"
sed -i "s/int upper_discount = [0-9]\+;/int upper_discount = ${UPPER_DISCOUNT_VAL};/" "$Q6_CPP"

echo
echo "Updated Q6 discount bounds:"
grep -n "lower_discount\|upper_discount" "$Q6_CPP"

echo
echo "Recompile the project before running the bitmap benchmark:"
echo "make"
