ARG BASE_IMAGE_TAG=ubi8-17.2-2
FROM registry.developers.crunchydata.com/crunchydata/crunchy-postgres:${BASE_IMAGE_TAG}

USER root

RUN microdnf install -y pg_partman_17 && \
    microdnf clean all && \
    rm -rf /var/cache/yum

USER 26
