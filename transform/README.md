# transform

This is where the `dbt` project lives.
All transformation is handled by `dbt` (using the `duckdb` adapter).

To manually run the `dbt` transformation step/pipeline, you can run `make transform`.
Alternatively, you can run arbitrary `dbt` commands via:

```sh
meltano invoke dbt-duckdb [CMD] [-ARGS] [--KWARGS]
```
