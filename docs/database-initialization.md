# Database Initialization Strategy

PETPLAT-24 uses Spring Boot SQL initialization for the shared RDS MySQL database.

## Approach

The RDS module creates one database named `petclinic`. The three database-backed
services share this database because `visits.pet_id` has a foreign key to
`pets.id`, which is created by the customers service schema.

Schemas are initialized by the applications on first startup with the `mysql`
profile and `spring.sql.init.mode=always`. Deployment order must ensure the
customers service starts before the visits service.

## Schema Order

1. Customers service:
   `spring-petclinic-customers-service/src/main/resources/db/mysql/schema.sql`
   creates `owners`, `pets`, and `types`.
2. Vets service:
   `spring-petclinic-vets-service/src/main/resources/db/mysql/schema.sql`
   creates `vets`, `specialties`, and `vet_specialties`.
3. Visits service:
   `spring-petclinic-visits-service/src/main/resources/db/mysql/schema.sql`
   creates `visits`, which references `pets.id`.

## Kubernetes Connection Configuration

ConfigMaps should provide the JDBC URL in this format:

```text
jdbc:mysql://{rds-endpoint}:3306/petclinic
```

The RDS module also outputs `rds_jdbc_url` for each environment.

External Secrets should read credentials from:

```text
petclinic/{env}/rds-credentials
```

The JSON secret contains `username` and `password` keys.

## Verification

After deployment, verify from an EKS debug pod that:

1. The endpoint accepts connections on port `3306`.
2. Credentials from Secrets Manager can authenticate.
3. The shared `petclinic` database contains all seven expected tables:
   `owners`, `pets`, `types`, `vets`, `specialties`, `vet_specialties`, and
   `visits`.
