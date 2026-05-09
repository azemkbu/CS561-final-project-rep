#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <quantity_threshold>" >&2
  echo "Example: $0 10" >&2
  echo "Example: $0 24" >&2
  echo "Example: $0 41" >&2
  exit 1
fi

QUANTITY_VAL="$1"
Q6_CPP="${Q6_CPP:-extension/debit/execution/tpch/query/Q6.cpp}"

if [[ ! -f "$Q6_CPP" ]]; then
  echo "Q6.cpp not found: $Q6_CPP" >&2
  echo "Run this script from the root of the original CS561-Access-Path-Selection repository." >&2
  exit 1
fi

echo "Current Q6 quantity threshold lines:"
grep -n "quantity" "$Q6_CPP" || true

# The bitmap Q6 implementation uses an integer threshold for l_quantity.
# The default TPC-H Q6 predicate is l_quantity < 24.
# This replacement updates lines such as: int quantity = 24;
if ! grep -q "int quantity = [0-9]\+;" "$Q6_CPP"; then
  echo >&2
  echo "Could not find a line matching: int quantity = <number>;" >&2
  echo "Please inspect Q6.cpp manually with:" >&2
  echo "  grep -n "quantity" $Q6_CPP" >&2
  exit 1
fi

sed -i "s/int quantity = [0-9]\+;/int quantity = ${QUANTITY_VAL};/" "$Q6_CPP"

echo
echo "Updated Q6 quantity threshold lines:"
grep -n "quantity" "$Q6_CPP" || true

echo
echo "Recompile the project before running the bitmap benchmark:"
echo "make"
