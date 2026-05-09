# Average Timing Results

All times are in seconds. Raw repeated runs are not included here; this file only reports averages used for the final results.

## tpch1 / `l_shipdate`

| Access path | Variant | Predicate | Average seconds |
|---|---|---|---:|
| bitmap_index | high_selectivity | `l_shipdate <= 1992-10-28` | 2.704 |
| zonemap | high_selectivity | `l_shipdate <= 1992-10-28` | 1.082 |
| column_sketch | high_selectivity | `l_shipdate <= 1992-10-28` | 1.070 |
| bitmap_index | medium_selectivity | `l_shipdate <= 1995-06-17` | 2.653 |
| zonemap | medium_selectivity | `l_shipdate <= 1995-06-17` | 1.525 |
| column_sketch | medium_selectivity | `l_shipdate <= 1995-06-17` | 1.699 |
| bitmap_index | low_selectivity | `l_shipdate <= 1998-02-04` | 2.617 |
| zonemap | low_selectivity | `l_shipdate <= 1998-02-04` | 1.942 |
| column_sketch | low_selectivity | `l_shipdate <= 1998-02-04` | 2.193 |

## tpch6 / `l_quantity`

| Access path | Variant | Predicate | Average seconds |
|---|---|---|---:|
| bitmap_index | high_selectivity | `l_quantity < 10` | 0.309 |
| zonemap | high_selectivity | `l_quantity < 10` | 0.698 |
| column_sketch | high_selectivity | `l_quantity < 10` | 1.006 |
| bitmap_index | medium_selectivity | `l_quantity < 24` | 0.380 |
| zonemap | medium_selectivity | `l_quantity < 24` | 0.723 |
| column_sketch | medium_selectivity | `l_quantity < 24` | 0.922 |
| bitmap_index | low_selectivity | `l_quantity < 41` | 0.462 |
| zonemap | low_selectivity | `l_quantity < 41` | 0.728 |
| column_sketch | low_selectivity | `l_quantity < 41` | 1.014 |

## tpch6 / `l_discount`

| Access path | Variant | Predicate | Average seconds |
|---|---|---|---:|
| zonemap | high_selectivity | `l_discount BETWEEN 0.01 AND 0.02` | 0.730 |
| zonemap | medium_selectivity | `l_discount BETWEEN 0.01 AND 0.06` | 0.734 |
| zonemap | low_selectivity | `l_discount BETWEEN 0.01 AND 0.09` | 0.736 |
| bitmap_index | high_selectivity | `l_discount BETWEEN 0.01 AND 0.02` | 0.364 |
| bitmap_index | medium_selectivity | `l_discount BETWEEN 0.01 AND 0.06` | 0.415 |
| bitmap_index | low_selectivity | `l_discount BETWEEN 0.01 AND 0.09` | 0.446 |
| column_sketch | high_selectivity | `l_discount BETWEEN 0.01 AND 0.02` | 0.962 |
| column_sketch | medium_selectivity | `l_discount BETWEEN 0.01 AND 0.06` | 0.973 |
| column_sketch | low_selectivity | `l_discount BETWEEN 0.01 AND 0.09` | 0.975 |

## custom_q6 / `l_extendedprice`

| Access path | Variant | Predicate | Average seconds |
|---|---|---|---:|
| column_sketch | high_selectivity | `l_extendedprice < 7887.68` | 0.560 |
| zonemap | high_selectivity | `l_extendedprice < 7887.68` | 1.106 |
| column_sketch | medium_selectivity | `l_extendedprice < 36715.00` | 0.600 |
| zonemap | medium_selectivity | `l_extendedprice < 36715.00` | 1.002 |
| column_sketch | low_selectivity | `l_extendedprice < 71002.68` | 0.604 |
| zonemap | low_selectivity | `l_extendedprice < 71002.68` | 0.966 |
