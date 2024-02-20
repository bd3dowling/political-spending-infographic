# NOTE: The query-params at end are required for drop-box...
URL := https://www.dropbox.com/scl/fi/hxj358n0bnef8qo9vz7wt/contribDB_2022.csv.gz\?rlkey\=y6bv0bcnhe8roxid62cckaipz\&e\=1
GZ_FILE := ./extract/dime_contributions_2022_raw.csv.gz
CSV_FILE := $(GZ_FILE:.gz=)

all: fetch build run

# Rule to download the file and rename it
$(GZ_FILE):
	curl -L ${URL} -o $@

# Rule to decompress the gzipped file to CSV
$(CSV_FILE): $(GZ_FILE)
	gunzip $<

fetch: $(CSV_FILE)

build:
	meltano install
	meltano invoke dbt-duckdb deps

load: fetch build
	meltano run tap-csv target-duckdb
	rm -f $(CSV_FILE)

transform: load
	meltano invoke dbt-duckdb run

# TODO: Add script invocation
run: fetch build
	meltano run --full-refresh tap-csv target-duckdb dbt-duckdb:run

infographic: run
	echo 'running R script'

.PHONY: all fetch build load transform run infographic
