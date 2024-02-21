# data

This is where the `duckdb` databse lives (after being loaded by `meltano`).
Once generated, the database (/ tables within) can be queried in scripts or with the `duckdb` CLI via:

```sh
duck data/warehouse.duckdb
```

To manually generate the database you can (via `docker` or otherwise) run `make load`.
Consult the `transform` [README](../transform/README.md) for instructions on running the transformations
on the loaded data.

**NOTE**: There are some bugs in the `duckdb` package which sadly prevented the direct use of the
`.duckdb` file. As such, analysis models are exported to the parquets directory for use in the
analysis scripts.
