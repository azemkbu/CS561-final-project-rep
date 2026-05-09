# Running on the Project Server

The benchmarks were run on the course/project server. Login credentials were provided separately and are intentionally not included in this repository.
The detailed Run workflow is described in README.md

## General Workflow

1. Log in to the server.
2. Clone or open the original project repository.
3. Check out the correct branch for the target access path.
4. Build DuckDB using `make release`.
5. Generate TPC-H data at scale factor 10.
6. Run the benchmark query or bitmap-specific PRAGMA command.
7. Record execution time with DuckDB `.timer on`.

## Important Branch Mapping

- Column Sketches: `Experiments` branch, normal SQL query variants.
- Zone Maps: `BitmapIndexing` branch, normal SQL query execution.
- Bitmap Indexes: `BitmapIndexing` branch, `PRAGMA load_bitmap(...)` followed by `PRAGMA bm_tpch(...)`.

## Bitmap TPC-H Q1

For Q1, load the bitmap indexes required by the implementation:

```sql
SET threads TO 1;
.timer on
PRAGMA load_bitmap(shipdate, linestatus, returnflag);
PRAGMA bm_tpch(1);
```

For Q1 selectivity variants, patch `right_days` in:

```text
extension/debit/execution/tpch/query/Q1.cpp
```

Example:

```bash
./scripts/patch_bitmap_q1_threshold.sh 8336
make
```

## Bitmap TPC-H Q6

For Q6, load the bitmap indexes required by the implementation:

```sql
SET threads TO 1;
.timer on
PRAGMA load_bitmap(shipdate_GE_364, discount, quantity);
PRAGMA bm_tpch(6);
```

For Q6 quantity selectivity variants, patch the quantity threshold in:

```text
extension/debit/execution/tpch/query/Q6.cpp
```

Examples:

```bash
./scripts/patch_bitmap_q6_quantity_threshold.sh 10
make
./scripts/run_bitmap_q6.sh

./scripts/patch_bitmap_q6_quantity_threshold.sh 24
make
./scripts/run_bitmap_q6.sh

./scripts/patch_bitmap_q6_quantity_threshold.sh 41
make
./scripts/run_bitmap_q6.sh
```

For Q6 discount selectivity variants, patch `lower_discount` and `upper_discount` in:

```text
extension/debit/execution/tpch/query/Q6.cpp
```

Examples:

```bash
./scripts/patch_bitmap_q6_discount_range.sh 1 2
make
./scripts/run_bitmap_q6.sh

./scripts/patch_bitmap_q6_discount_range.sh 1 6
make
./scripts/run_bitmap_q6.sh

./scripts/patch_bitmap_q6_discount_range.sh 1 9
make
./scripts/run_bitmap_q6.sh
```
