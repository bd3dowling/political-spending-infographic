# political-spending-infographic

An assignment for the Data Science module as a part of my MSc in Statistics.
This provides a modern, fully extensible and portable modern data stack-in-a-box
proof-of-concept / template for producing consistent, reproducible, and principled data workflows,
namely for the production of reports, charts, and infographics.

The project is setup with one [example infographic](./output/1980_senate_contributions_infographic.pdf)
to generate which shows some charts relating to the US Federal Senate elections in 1980.

To generate the infographic, we suggest running it through docker (via the Dockerfile) or, if on
VSCode, by opening the project in a [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers).
Once in the container, the infographic can be run with just `make`.
(**Note**: Installation of the `arrow` package can take a while; it's not unexpected for image building
to take over 10 minutes as a result since it compiles it from source!).

Alternatively, if you create a `python` virtual environment (and maybe you'd like to do the same for `R`),
if you manually install in `R` the `tidyverse`, `arrow`, `here`, and `ggthemes` packages, and
manually install in `python` `meltano`, then you should be able to just run `make` from the root
of the project directory also (you can also install `meltano` via `pipx` if preferred)!

## Stack

We follow an approach akin to that shown in
[Modern data stack-in-a-box](https://duckdb.org/2022/10/12/modern-data-stack-in-a-box.html).
That is, we use the following tools:

- [Meltano](https://meltano.com/): ELT orchestrator.
- [DBT](https://www.getdbt.com/): Transformation orchestrator.
- [DuckDB](https://duckdb.org/): Local analytical database.
- [R](https://www.r-project.org/): Analysis and infographic generation (via [ggplot2](https://ggplot2.tidyverse.org/index.html)).

I recommend consulting each of the above's (in particular first 2) documentation to get a gist for
what they do and how so that the project structure isn't too foreign!

## Structure

The structure of the project mirrors both that of the above article (essentially a standard Meltano
project) and the recommended DBT [best-practices](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview).
Each of the below has their own `README`, but roughly their contents are as follows:

- `analyze`: Where analysis tools and scripts live.
- `data`: Where non-extract data lives.
- `extract`: Where data is extracted to and from.
- `output`: Where analysis outputs live.
- `plugins`: Meltano plugins directory.
- `transform`: Where the DBT project lives. The project is fully documented with several data tests.
  Once in a container (or otherwise) and having built the project, you can run `dbt docs generate && dbt docs serve`
  to generate a full documentation site with a complete DAG representation.

## Style

To _enforce_ code-style and standards, we use:

- [YAMLlint](https://github.com/adrienverge/yamllint)
- [SQLFluff](https://github.com/sqlfluff/sqlfluff)
- [LintR](https://lintr.r-lib.org/)

If using as a template adapt the associated `.` files as required! We follow the SQL style as
[recommended](https://docs.getdbt.com/best-practices/how-we-style/2-how-we-style-our-sql) by DBT.

## Data

- The current setup example is for the 1980 contributions extract from the
  [DIME](https://data.stanford.edu/dime) database. In principle, the pipeline should work on any
  year/cycle, though the later years are very significantly larger in row count.
- Constructed a state lookup seed using: https://en.wikipedia.org/wiki/List_of_U.S._state_and_territory_abbreviations
  (adding CZ as (Panama) Canal Zone)
- https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview
- https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects

## Potential improvements

- We could replace `meltano` and just rely on the `duckdb` adapter for `dbt` for reading in extracted
  files. The downside to this is the loss of flexibility that `meltano` gives in being able to handle
  different data-sources. Furthermore, if you wanted to setup further orchestration (e.g. scheduled
  refreshes, etc.), then `meltano` provides an immediate solution, giving better extensibility.
- We _should_ have specified a schema for the CSVs. This was something I discovered too late but
  this substantially improves ingestion speeds.
- We could easily add on [evidence](evidence.dev) (hence my preference `meltano`) or some other
  BI tool at the end of the pipeline for more interactive exploration.
- We _should_ have used the SQLite3 database on DIME; the issue is that this database is nearly
  1 TB in size which didn't fit on my local machine during development. It would be worth exploring
  cloud/remote-server approaches that could be taken, especially considering this project is
  already dockerized.
- There's some bug with the `duckdb` R package which was preventing directly reading from the database
  in the analysis script, hence why we materialized the analysis models to `.parquet` files and
  rely on `arrow`. It would be extremely nice to _not_ have to do this, and just use `dbplyr` (or
  otherwise) to directly query the analysis tables from the `duckdb` database for use in the plots,
  especially for later years where the data volume can become challenging to load fully into memory.
