#!/usr/bin/env python3
"""Print average timing results grouped by benchmark and column."""

import csv
import sys
from collections import defaultdict
from pathlib import Path


def main():
    if len(sys.argv) != 2:
        print("Usage: summarize_results.py <average_timings.csv>", file=sys.stderr)
        return 1

    path = Path(sys.argv[1])
    rows = list(csv.DictReader(path.open()))
    groups = defaultdict(list)

    for row in rows:
        key = (row["benchmark"], row["column"])
        groups[key].append(row)

    for (benchmark, column), group_rows in sorted(groups.items()):
        print(f"\n## {benchmark} / {column}")
        print("access_path,variant,predicate,average_seconds")
        for row in group_rows:
            print(
                f"{row['access_path']},{row['variant']},"
                f"{row['predicate']},{row['average_seconds']}"
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
