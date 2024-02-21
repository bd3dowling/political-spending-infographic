# NOTE: The query-params at end are required for drop-box...
URL := "https://www.dropbox.com/scl/fi/gdvpzggkb0in9yruircpi/contribDB_1980.csv.gz?rlkey=rs07632m813k3g85ndek1z16g&e=1"
GZ_FILE := ./extract/dime_contributions_1980_raw.csv.gz
CSV_FILE := $(GZ_FILE:.gz=)

all: fetch build load transform infographic

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

load:
	meltano run --full-refresh tap-csv target-duckdb
	rm -f $(CSV_FILE)

transform:
	meltano invoke dbt-duckdb build --full-refresh

infographic:
	Rscript analyze/r_scripts/1980_senate_contributions_infographic.R
	open output/1980_senate_contributions_infographic.pdf

.PHONY: all fetch build load transform infographic
