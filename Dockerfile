ARG BASE_IMAGE_TAG=ubi8-17.2-2
FROM registry.developers.crunchydata.com/crunchydata/crunchy-postgres:${BASE_IMAGE_TAG}

USER root

# Extract PG major version from BASE_IMAGE_TAG (e.g., ubi8-17.2-2 -> 17, ubi9-18.1-2550 -> 18)
ARG BASE_IMAGE_TAG
RUN PG_MAJOR=$(echo "${BASE_IMAGE_TAG}" | sed -E 's/ubi[89]-([0-9]+)\..*/\1/') && \
    echo "Installing pg_partman for PostgreSQL ${PG_MAJOR}" && \
    microdnf install -y pg_partman_${PG_MAJOR} && \
    microdnf clean all && \
    rm -rf /var/cache/yum

USER 26
