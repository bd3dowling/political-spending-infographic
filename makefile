# NOTE: The query-params at end are required for drop-box...
URL := https://www.dropbox.com/scl/fi/hxj358n0bnef8qo9vz7wt/contribDB_2022.csv.gz\?rlkey\=y6bv0bcnhe8roxid62cckaipz\&e\=1
GZ_FILE := ./data/source/dime_2022_raw.csv.gz
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

# TODO: Add script invocation
run:
	meltano invoke dbt-duckdb build

clean:
	rm -f $(CSV_FILE)

.PHONY: all fetch build run clean
