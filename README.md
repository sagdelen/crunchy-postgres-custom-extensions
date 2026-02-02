# Crunchy PostgreSQL Custom Extensions

This repository builds custom [Crunchy PostgreSQL](https://www.crunchydata.com/products/crunchy-postgresql-for-kubernetes/) container images with additional PostgreSQL extensions pre-installed.

## Included Extensions

### pg_partman_bgw

[pg_partman](https://github.com/pgpartman/pg_partman) is a partition management extension for PostgreSQL. The `pg_partman_bgw` background worker enables automated partition maintenance without requiring an external scheduler (cron, etc).

**Note:** The pg_partman extension itself is already included in the base Crunchy image. This custom image adds the background worker component (`pg_partman_bgw`) for automated maintenance.

## Image Details

| Property           | Value                                                                          |
| ------------------ | ------------------------------------------------------------------------------ |
| Base Image         | `registry.developers.crunchydata.com/crunchydata/crunchy-postgres:ubi8-17.2-2` |
| PostgreSQL Version | 17.2                                                                           |
| OS                 | Red Hat UBI 8                                                                  |

## Using with Crunchy PostgreSQL Operator v5.7

To use this custom image with the Crunchy PostgreSQL Operator (PGO) v5.7:

1. Configure image pull secrets for your Docker Hub repository
2. Reference the custom image in your PostgresCluster manifest
3. Enable `pg_partman_bgw` in `shared_preload_libraries`

### Example PostgresCluster Manifest

```yaml
apiVersion: postgres-operator.crunchydata.com/v1beta1
kind: PostgresCluster
metadata:
  name: my-cluster
spec:
  postgresVersion: 17

  # Reference your custom image
  image: docker.io/YOUR_DOCKERHUB_USERNAME/crunchy-postgres-custom:ubi8-17.2-2

  # Configure image pull secrets for private registry
  imagePullSecrets:
    - name: dockerhub-credentials

  # Enable pg_partman background worker
  patroni:
    dynamicConfiguration:
      postgresql:
        parameters:
          shared_preload_libraries: pg_partman_bgw
          pg_partman_bgw.dbname: your_database
          pg_partman_bgw.interval: 3600
          pg_partman_bgw.role: postgres

  instances:
    - name: instance1
      replicas: 2
      dataVolumeClaimSpec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 10Gi

  backups:
    pgbackrest:
      repos:
        - name: repo1
          volume:
            volumeClaimSpec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 10Gi
```

### Creating the Image Pull Secret

Create a Kubernetes secret with your Docker Hub credentials:

```bash
kubectl create secret docker-registry dockerhub-credentials \
  --docker-server=docker.io \
  --docker-username=YOUR_DOCKERHUB_USERNAME \
  --docker-password=YOUR_DOCKERHUB_TOKEN \
  --namespace=your-namespace
```

### Creating the pg_partman Extension

After deploying your cluster, connect to the database and create the extension:

```sql
-- Create a dedicated schema for pg_partman (recommended)
CREATE SCHEMA IF NOT EXISTS partman;

-- Create the extension
CREATE EXTENSION pg_partman SCHEMA partman;

-- Verify installation
SELECT * FROM pg_extension WHERE extname = 'pg_partman';
```

## Adding More Extensions

To add additional extensions to this image:

1. **Edit the Dockerfile** to install additional packages:

   ```dockerfile
   USER root

   RUN dnf install -y \
       pg_partman_17 \
       pgaudit17 \
       your_new_extension17 \
       && dnf clean all \
       && rm -rf /var/cache/dnf

   USER postgres
   ```

2. **Update this README** to document the new extension

3. **Commit and push** to trigger a new build

### Finding Available Extensions

To list available PostgreSQL 17 packages:

```bash
docker run --rm -it --user root \
  registry.developers.crunchydata.com/crunchydata/crunchy-postgres:ubi8-17.2-2 \
  dnf search postgresql17
```

## Building Locally

Build the image locally for testing:

```bash
docker build -t crunchy-postgres-custom:local .
```

Test pg_partman_bgw is available:

```bash
docker run --rm crunchy-postgres-custom:local \
  ls -la /usr/pgsql-17/lib/pg_partman_bgw.so
```

## CI/CD

This repository uses GitHub Actions to automatically build and push images to Docker Hub when changes are pushed to the `main` branch.

### Required Repository Secrets

Configure these secrets in your GitHub repository settings (Settings > Secrets and variables > Actions):

| Secret               | Description                                                                           |
| -------------------- | ------------------------------------------------------------------------------------- |
| `DOCKERHUB_USERNAME` | Your Docker Hub username                                                              |
| `DOCKERHUB_TOKEN`    | Docker Hub access token ([create one here](https://hub.docker.com/settings/security)) |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

- [Crunchy PostgreSQL Operator v5.7 Documentation](https://access.crunchydata.com/documentation/postgres-operator/5.7/)
- [pg_partman Documentation](https://github.com/pgpartman/pg_partman)
- [PGDG YUM Repository](https://yum.postgresql.org/)
