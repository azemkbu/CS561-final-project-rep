#!/usr/bin/env python3
"""Extract DuckDB .timer runtimes from log files.

Usage:
    python3 scripts/parse_duckdb_timer.py results/logs/column_sketch_q1/*.log
"""

import re
import sys
from pathlib import Path

PATTERNS = [
    re.compile(r"Run Time \(s\):\s*real\s*([0-9.]+)"),
    re.compile(r"real\s+([0-9.]+)"),
]


def extract_times(text: str):
    values = []
    for pattern in PATTERNS:
        values.extend(float(match.group(1)) for match in pattern.finditer(text))
    return values


def main():
    if len(sys.argv) < 2:
        print("Usage: parse_duckdb_timer.py <log1> [<log2> ...]", file=sys.stderr)
        return 1

    print("file,time_seconds")
    for arg in sys.argv[1:]:
        path = Path(arg)
        text = path.read_text(errors="replace")
        for value in extract_times(text):
            print(f"{path},{value:.6f}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
