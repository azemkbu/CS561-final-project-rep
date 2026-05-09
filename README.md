# CS561 Final Project Benchmarking Scripts

This repository contains the benchmark automation scripts, SQL query variants, bitmap helper scripts, and average timing results used for our CS561 final project on **access path selection in a modern DuckDB-based analytical DBMS**.

The experiments were run using the original project repository:

https://github.com/junchangwang/CS561-Access-Path-Selection


## Project Goal

The goal of the experiments was to compare three access path strategies under a modern vectorized analytical DBMS setting:

- **Column Sketches**
- **Zone Maps**
- **Bitmap Indexes**

The comparison focuses on how performance changes with:

- predicate selectivity,
- column cardinality,
- data clustering / sortedness,
- and whether the access path is a good match for the column.

The final report focuses on TPC-H Q1, TPC-H Q6, and one custom Q6-style query.

## Repository Structure

```text
.
├── README.md
├── queries/
│   ├── tpch1_shipdate/
│   ├── tpch6_quantity/
│   ├── tpch6_discount/
│   └── tpch6_extendedprice/
├── scripts/
│   ├── run_sql_variants_uncached.sh
│   ├── run_sql_variants_cached.sh
│   ├── run_bitmap_q1.sh
│   ├── run_bitmap_q6.sh
│   ├── patch_bitmap_q1_threshold.sh
│   ├── patch_bitmap_q6_discount_range.sh
│   ├── patch_bitmap_q6_quantity_threshold.sh
│   ├── parse_duckdb_timer.py
│   └── summarize_results.py
├── results/
│   ├── average_timings.csv
│   └── average_timings.md
└── docs/
    ├── experiment_summary.md
    └── run_on_server.md
```

## Branches Used

The same logical query variants were used across access paths when the implementation supported the target column. However, the benchmarks had to be run under different branches of the original repository depending on the access path.

| Access path | Branch used | How it was tested |
|---|---|---|
| Column Sketches | `Experiments` | Run the SQL query variants under the Column Sketch implementation |
| Zone Maps | `BitmapIndexing` | Run the normal SQL query variants directly; DuckDB uses Zone Map pruning automatically |
| Bitmap Indexes | `BitmapIndexing` | Explicitly load bitmap indexes with `PRAGMA load_bitmap(...)`, then run `PRAGMA bm_tpch(...)` |

Important distinction:

```text
Column Sketches → run SQL query variants under Experiments
Zone Maps       → run normal SQL query variants under BitmapIndexing
Bitmap Indexes  → load required bitmap indexes, then run bitmap-specific PRAGMA commands
```

## Experimental Setup

The experiments used TPC-H with scale factor 10:

```sql
CALL dbgen(sf=10);
SET threads TO 1;
.timer on
```

All reported results use single-threaded execution to keep comparisons consistent across access paths.

Hardware used:

```text
Intel Xeon Platinum 8576C
16 logical CPUs @ 2500 MHz
AVX-512 support
```

## Experiments Included

The final report focuses on four benchmark groups:

| Experiment                    | Query | Column | Access paths compared |
|-------------------------------|---|---|---|
| TPC-H Q1 shipdate             | Q1 | `l_shipdate` | Column Sketches, Zone Maps, Bitmap Indexes |
| TPC-H Q6 quantity             | Q6 | `l_quantity` | Column Sketches, Zone Maps, Bitmap Indexes |
| TPC-H Q6 discount             | Q6 | `l_discount` | Column Sketches, Zone Maps, Bitmap Indexes |
| Custom query on extendedprice | Custom Q6 | `l_extendedprice` | Column Sketches, Zone Maps |

Bitmap Index support was not available for `l_extendedprice`, so the `l_extendedprice` experiment compares only Column Sketches and Zone Maps.

## Selectivity Variants

### TPC-H Q1: `l_shipdate`

| Variant | Predicate |
|---|---|
| High selectivity | `l_shipdate <= DATE '1992-10-28'` |
| Medium selectivity | `l_shipdate <= DATE '1995-06-17'` |
| Low selectivity | `l_shipdate <= DATE '1998-02-04'` |

Internal day values used for Bitmap Q1 patching:

| Date | Internal day value |
|---|---:|
| 1992-10-28 | 8336 |
| 1995-06-17 | 9298 |
| 1998-02-04 | 10261 |

### TPC-H Q6: `l_quantity`

| Variant | Predicate |
|---|---|
| High selectivity | `l_quantity < 10` |
| Medium selectivity | `l_quantity < 24` |
| Low selectivity | `l_quantity < 41` |

### TPC-H Q6: `l_discount`

| Variant | Predicate |
|---|---|
| High selectivity | `l_discount BETWEEN 0.01 AND 0.02` |
| Medium selectivity | `l_discount BETWEEN 0.01 AND 0.06` |
| Low selectivity | `l_discount BETWEEN 0.01 AND 0.09` |

### Custom Q6-style Query: `l_extendedprice`

| Variant | Predicate |
|---|---|
| High selectivity | `l_extendedprice < 7887.68` |
| Medium selectivity | `l_extendedprice < 36715.00` |
| Low selectivity | `l_extendedprice < 71002.68` |

The custom query has the following structure:

```sql
SELECT sum(l_extendedprice * l_discount) AS revenue
FROM lineitem
WHERE l_shipdate >= CAST('1993-01-01' AS date)
  AND l_shipdate < CAST('1995-01-01' AS date)
  AND l_discount BETWEEN 0.05 AND 0.07
  AND l_extendedprice < XXXXX;
```

## Cached vs. Process-Isolated Runs

For cached runs, the same query was executed multiple times in the same DuckDB process.

For process-isolated runs, DuckDB was restarted for each run while reusing the same generated database file. This was used to reduce the effect of process-level cache reuse.

All results reported in the paper represent **process-isolated runs**. The `results/` directory only reports final averages, not every repeated raw run.

## Running Column Sketch Benchmarks

Column Sketch benchmarks were run using the `Experiments` branch of the original repository.

From the original repository:

```bash
git checkout Experiments
make release
./build/release/duckdb sketches.db
```

Inside DuckDB, generate data once:

```sql
CALL dbgen(sf=10);
SET threads TO 1;
.timer on
```

Then, from this benchmark repository, run one query group at a time.

Example for TPC-H Q1 `l_shipdate`:

```bash
DUCKDB_BIN=/path/to/CS561-Access-Path-Selection/build/release/duckdb \
DB_FILE=/path/to/CS561-Access-Path-Selection/sketches.db \
./scripts/run_sql_variants_uncached.sh column_sketch_q1 queries/tpch1_shipdate
```

Other Column Sketch query groups can be run similarly:

```bash
./scripts/run_sql_variants_uncached.sh column_sketch_q6_quantity queries/tpch6_quantity
./scripts/run_sql_variants_uncached.sh column_sketch_q6_discount queries/tpch6_discount
./scripts/run_sql_variants_uncached.sh column_sketch_extendedprice queries/tpch6_extendedprice
```

## Running Zone Map Benchmarks

Zone Map benchmarks were run using the `BitmapIndexing` branch of the original repository.

From the original repository:

```bash
git checkout BitmapIndexing
make release
./build/release/duckdb bitmap.db
```

Inside DuckDB, generate data once:

```sql
CALL dbgen(sf=10);
SET threads TO 1;
.timer on
```

Zone Maps do not require a separate index creation step. They are maintained and used automatically by DuckDB during normal SQL query execution.

To collect Zone Map timings, run the SQL query variants directly under the `BitmapIndexing` branch build.

Example for TPC-H Q1 `l_shipdate`:

```bash
DUCKDB_BIN=/path/to/CS561-Access-Path-Selection/build/release/duckdb \
DB_FILE=/path/to/CS561-Access-Path-Selection/bitmap.db \
./scripts/run_sql_variants_uncached.sh zonemap_q1 queries/tpch1_shipdate
```

The same approach was used for:

```bash
./scripts/run_sql_variants_uncached.sh zonemap_q6_quantity queries/tpch6_quantity
./scripts/run_sql_variants_uncached.sh zonemap_q6_discount queries/tpch6_discount
./scripts/run_sql_variants_uncached.sh zonemap_extendedprice queries/tpch6_extendedprice
```

## Running Bitmap Index Benchmarks

Bitmap Index benchmarks were run using the `BitmapIndexing` branch of the original repository.

Unlike Zone Maps, Bitmap Index benchmarks require explicitly loading the required bitmap indexes before running the bitmap-specific TPC-H benchmark command.

From the original repository:

```bash
git checkout BitmapIndexing
make release
./build/release/duckdb bitmap.db
```

Inside DuckDB:

```sql
SET threads TO 1;
.timer on
```

### Bitmap TPC-H Q1: `l_shipdate`

For TPC-H Q1, load the bitmap indexes used by the bitmap implementation:

```sql
PRAGMA load_bitmap(shipdate, linestatus, returnflag);
PRAGMA bm_tpch(1);
```

For the selectivity variants on `l_shipdate`, the implementation required modifying the internal `right_days` value in:

```text
extension/debit/execution/tpch/query/Q1.cpp
```

A helper script is included:

```bash
./scripts/patch_bitmap_q1_threshold.sh 8336
make
```

After each threshold update, the project was recompiled and `PRAGMA bm_tpch(1);` was run again.

The threshold values are:

| Date | Internal day value |
|---|---:|
| 1992-10-28 | 8336 |
| 1995-06-17 | 9298 |
| 1998-02-04 | 10261 |

### Bitmap TPC-H Q6: `l_quantity` and `l_discount`

For TPC-H Q6, the bitmap benchmark first loads the bitmap indexes required by the implementation and then runs the bitmap-specific TPC-H Q6 path:

```sql
PRAGMA load_bitmap(shipdate_GE_364, discount, quantity);
PRAGMA bm_tpch(6);
```

The helper script `scripts/run_bitmap_q6.sh` runs those commands automatically:

```bash
./scripts/run_bitmap_q6.sh
```

#### Bitmap Q6 quantity selectivity variants

For the `l_quantity` bitmap experiments, the quantity predicate threshold is controlled inside:

```text
extension/debit/execution/tpch/query/Q6.cpp
```

The relevant variable is expected to be similar to:

```cpp
int quantity = 24;
```

The original/default value corresponds to the standard TPC-H Q6 quantity predicate:

```sql
l_quantity < 24
```

To run the quantity selectivity variants used in the report, patch the internal threshold, recompile, reload the bitmap indexes, and run `PRAGMA bm_tpch(6);` again.

A helper script is included. Run it from the root of the original `CS561-Access-Path-Selection` repository so that the relative path to `Q6.cpp` resolves correctly:

```bash
# from CS561-Access-Path-Selection/
/path/to/this-benchmark-repo/scripts/patch_bitmap_q6_quantity_threshold.sh 10
make
/path/to/this-benchmark-repo/scripts/run_bitmap_q6.sh
```

If the benchmark scripts were copied into the original repository root, the shorter form also works:

```bash
./scripts/patch_bitmap_q6_quantity_threshold.sh 10
make
./scripts/run_bitmap_q6.sh
```

The quantity variants are:

| Variant | SQL-level predicate | Internal value |
|---|---|---:|
| High selectivity | `l_quantity < 10` | `quantity = 10` |
| Medium selectivity | `l_quantity < 24` | `quantity = 24` |
| Low selectivity | `l_quantity < 41` | `quantity = 41` |

Manual patching can also be done with:

```bash
grep -n "quantity" extension/debit/execution/tpch/query/Q6.cpp

QUANTITY_VAL=10

sed -i "s/int quantity = [0-9]\+;/int quantity = ${QUANTITY_VAL};/" extension/debit/execution/tpch/query/Q6.cpp

grep -n "quantity" extension/debit/execution/tpch/query/Q6.cpp
make
```

Always verify the `grep` output before recompiling. For example, the high-selectivity quantity variant should show `quantity = 10`.

After recompilation, run:

```sql
SET threads TO 1;
.timer on
PRAGMA load_bitmap(shipdate_GE_364, discount, quantity);
PRAGMA bm_tpch(6);
```

#### Bitmap Q6 discount selectivity variants

For the `l_discount` bitmap experiments, the predicate bounds are controlled inside:

```text
extension/debit/execution/tpch/query/Q6.cpp
```

The relevant variables are:

```cpp
int lower_discount = 5;
int upper_discount = 7;
```

The original/default values correspond to the standard TPC-H Q6 discount predicate:

```sql
l_discount BETWEEN 0.05 AND 0.07
```

To run the discount selectivity variants used in the report, patch the internal bounds, recompile, reload the bitmap indexes, and run `PRAGMA bm_tpch(6);` again.

A helper script is included. Run it from the root of the original `CS561-Access-Path-Selection` repository so that the relative path to `Q6.cpp` resolves correctly:

```bash
# from CS561-Access-Path-Selection/
/path/to/this-benchmark-repo/scripts/patch_bitmap_q6_discount_range.sh 1 2
make
/path/to/this-benchmark-repo/scripts/run_bitmap_q6.sh
```

If the benchmark scripts were copied into the original repository root, the shorter form also works:

```bash
./scripts/patch_bitmap_q6_discount_range.sh 1 2
make
./scripts/run_bitmap_q6.sh
```

The discount variants are:

| Variant | SQL-level predicate | Internal lower/upper values |
|---|---|---|
| High selectivity | `l_discount BETWEEN 0.01 AND 0.02` | `lower_discount = 1`, `upper_discount = 2` |
| Medium selectivity | `l_discount BETWEEN 0.01 AND 0.06` | `lower_discount = 1`, `upper_discount = 6` |
| Low selectivity | `l_discount BETWEEN 0.01 AND 0.09` | `lower_discount = 1`, `upper_discount = 9` |

Manual patching can also be done with:

```bash
grep -n "lower_discount\|upper_discount" extension/debit/execution/tpch/query/Q6.cpp

LOWER_DISCOUNT_VAL=1
UPPER_DISCOUNT_VAL=2

sed -i "s/int lower_discount = [0-9]\+;/int lower_discount = ${LOWER_DISCOUNT_VAL};/" extension/debit/execution/tpch/query/Q6.cpp
sed -i "s/int upper_discount = [0-9]\+;/int upper_discount = ${UPPER_DISCOUNT_VAL};/" extension/debit/execution/tpch/query/Q6.cpp

grep -n "lower_discount\|upper_discount" extension/debit/execution/tpch/query/Q6.cpp
make
```

Always verify the `grep` output before recompiling. For example, the high-selectivity discount variant should show `lower_discount = 1` and `upper_discount = 2`.

After recompilation, run:

```sql
SET threads TO 1;
.timer on
PRAGMA load_bitmap(shipdate_GE_364, discount, quantity);
PRAGMA bm_tpch(6);
```

The Q6 bitmap path was used for the `l_quantity` and `l_discount` experiments.

Bitmap indexes were not available for `l_extendedprice`, so no Bitmap Index result is reported for the custom `l_extendedprice` query.

## Reported Average Results

Average timing results are stored in:

```text
results/average_timings.csv
```

A Markdown version is also included:

```text
results/average_timings.md
```

The result file contains one average execution time per access path, query, column, and predicate variant.

A formatted summary can be regenerated with:

```bash
python3 scripts/summarize_results.py results/average_timings.csv
```

## High-Level Findings Represented by the Results

The benchmark results support the following observations:

- **Bitmap Indexes** perform best on low-cardinality columns such as `l_quantity` and `l_discount`.
- **Zone Maps** perform best when data is naturally clustered or near-sorted, as with `l_shipdate`.
- **Column Sketches** are competitive on high-cardinality numeric columns and performed best on the unsorted high-cardinality `l_extendedprice` custom query.
- Hardware acceleration and vectorized execution improve absolute performance, but the best access path still depends primarily on column properties such as cardinality and sortedness.

## Notes

This repository is a reproducibility and benchmarking package. It provides the scripts and organized query variants used to run the experiments, collect DuckDB `.timer` output, and summarize final average timings.
