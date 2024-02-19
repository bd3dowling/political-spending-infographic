# registry.gitlab.com/meltano/meltano:latest is also available in GitLab Registry
ARG MELTANO_IMAGE=meltano/meltano:latest
FROM $MELTANO_IMAGE

WORKDIR /project

# Install curl
RUN apt-get update && apt-get install -y curl

# Install R
RUN apt-get install -y --no-install-recommends r-cran-tidyverse

# Install R packages
RUN R -e "install.packages('languageserver', dependencies=TRUE)"
RUN R -e "install.packages('duckdb', dependencies=TRUE)"
RUN R -e "install.packages('here', dependencies=TRUE)"
RUN R -e "install.packages('ggthemes', dependencies=TRUE)"
RUN R -e "install.packages('ggrepel', dependencies=TRUE)"

# Copy over project directory
COPY . .

# Don't allow changes to containerized project files
ENV MELTANO_PROJECT_READONLY 1
ENV DBT_TARGET_PATH ../docs

# Expose default port used by `meltano ui`
EXPOSE 5000

ENTRYPOINT ["meltano"]
