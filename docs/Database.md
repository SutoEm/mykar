# Database

The MVP backend uses Supabase PostgreSQL. Phase 2 defines the database before backend or UI implementation.

## Goals

- Preserve a trusted vehicle memory.
- Keep authorization centered on vehicle ownership.
- Support the MVP core loop: account, vehicle, maintenance, document, mileage, note, reminder.
- Keep later capabilities possible without adding early architecture complexity.

## Schema Files

- ER diagram: `docs/ERD.md`
- Data dictionary: `docs/DataDictionary.md`
- Supabase migration: `backend/supabase/migrations/20260706000100_phase2_foundation.sql`
- Seed plan: `backend/supabase/seed/README.md`

## Tables

| Table                      | Purpose                                      |
| -------------------------- | -------------------------------------------- |
| `profiles`                 | Application profile for a Supabase Auth user |
| `vehicles`                 | Vehicle identity and basic details           |
| `vehicle_ownerships`       | User-to-vehicle authorization bridge         |
| `maintenance_records`      | Service and repair history                   |
| `vehicle_documents`        | Metadata for uploaded documents              |
| `mileage_records`          | Mileage snapshots                            |
| `vehicle_notes`            | Freeform vehicle memory notes                |
| `fuel_logs`                | Fuel history for later Phase 6 use           |
| `reminders`                | Manual and system-derived due-date prompts   |
| `notification_preferences` | User-level reminder delivery settings        |

## Relationship Model

```text
auth.users
  -> profiles
  -> vehicle_ownerships
  -> vehicles
  -> vehicle memory tables
```

The user must be an active vehicle member to access vehicle memory.

## Trust Model Mapping

| Data Class        | Stored In                                                                          | Trust Field                             |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------- |
| User-entered      | `vehicles`, `maintenance_records`, `mileage_records`, `vehicle_notes`, `fuel_logs` | `trust_source` or `source`              |
| User-uploaded     | `vehicle_documents` and Supabase Storage                                           | `trust_source = user_uploaded`          |
| System-derived    | `reminders`                                                                        | `source = system_derived`               |
| AI-generated      | Not stored in Phase 2                                                              | Requires later citation model           |
| Verified external | Not stored in Phase 2                                                              | Requires later integration source model |

## Storage

Vehicle documents use the `vehicle-documents` Supabase Storage bucket.

Path convention:

```text
{vehicle_id}/{document_id}/{filename}
```

The storage object policy parses the first path segment as the vehicle id and requires active vehicle membership.

## Row Level Security

RLS is enabled for all public application tables.

Rules:

- A user can select and update their own profile.
- A user can insert their own profile.
- A user can create a vehicle with `created_by = auth.uid()`.
- A user can access a vehicle if they created it or have active ownership.
- A user can access vehicle memory only through active vehicle ownership.
- A user can access reminders only when `user_id = auth.uid()` and they can access the vehicle.
- A user can access notification preferences only for their own profile.

## Migration Validation

Validate migrations locally with:

```bash
./scripts/validate-supabase-migrations.sh
```

The script starts a temporary PostgreSQL database, creates minimal Supabase-compatible `auth` and `storage` schemas, applies migrations, and exits on SQL errors.
