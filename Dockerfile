FROM registry.developers.crunchydata.com/crunchydata/crunchy-postgres:ubi8-17.2-2

USER root

RUN dnf install -y pg_partman_17 && \
    dnf clean all && \
    rm -rf /var/cache/dnf

USER postgres
