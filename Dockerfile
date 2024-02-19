# registry.gitlab.com/meltano/meltano:latest is also available in GitLab Registry
ARG MELTANO_IMAGE=meltano/meltano:latest
FROM $MELTANO_IMAGE

WORKDIR /project

# Install curl
RUN apt-get update && apt-get install -y curl

# Copy over Meltano project directory
COPY . .
RUN meltano install

# Don't allow changes to containerized project files
ENV MELTANO_PROJECT_READONLY 1
ENV DBT_TARGET_PATH ../docs

# Expose default port used by `meltano ui`
EXPOSE 5000

ENTRYPOINT ["meltano"]
