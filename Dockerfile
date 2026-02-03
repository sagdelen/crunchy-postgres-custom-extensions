FROM registry.developers.crunchydata.com/crunchydata/crunchy-postgres:ubi8-17.2-2

USER root

RUN microdnf install -y pg_partman_17 && \
    microdnf clean all && \
    rm -rf /var/cache/yum

USER postgres
