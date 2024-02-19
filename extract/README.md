# extract

This is where the [DIME](https://data.stanford.edu/dime) CSV is downloaded and unzipped (via
`make fetch`). After the file is downloaded, `meltano` handles extracting and loading the CSV into a
`duckdb` database, located in the [data](../data/) directory.

To manually download the CSV you can run `make fetch`.
Consult the `data` [README](../data/README.md) for instructions on extracting and loading.
Running `make load` will automatically handle the downloading, unzipping, extraction, loading, and
clean-up (deletion of the CSV).
