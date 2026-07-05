# Phase 2: Database

Phase 2 designs the data foundation before backend or feature implementation. The goal is to make vehicle memory trustworthy, portable, and protected by default.

## Scope

- PostgreSQL schema for the MVP domain.
- Supabase migration files.
- Row Level Security policies.
- Storage bucket and object access rules for vehicle documents.
- ER diagram.
- Data dictionary.
- Seed and validation plan.

## Domains

- Users and profiles
- Vehicles
- Vehicle ownership
- Maintenance records
- Documents and storage metadata
- Mileage records
- Notes
- Fuel logs
- Reminders
- Notification preferences

## Completion Criteria

- Database tables are documented.
- Relationships are shown in an ER diagram.
- Data dictionary explains columns, keys, indexes, and trust source fields.
- Supabase migration creates schema, indexes, triggers, RLS policies, and storage policies.
- Migration can be applied to a PostgreSQL validation database with Supabase-compatible mock schemas.
- Seed plan defines safe local sample data order.
- Phase 2 decision review records whether Phase 3 Backend can start.

## Local Validation

Run these before opening or merging Phase 2 changes:

```bash
npm run format:check
npm run lint
npm test
npm run typecheck
npm run audit:moderate
./scripts/validate-supabase-migrations.sh
```

## Design Decisions

- Supabase Auth owns authentication; `public.profiles` stores application profile fields.
- `public.vehicle_ownerships` is the authorization bridge between users and vehicles.
- Vehicle memory tables reference `vehicles` and record the acting user for auditability.
- Deletion should start as soft deletion with `deleted_at` for vehicles and memory records.
- AI and system-derived outputs are not part of Phase 2 storage unless they cite existing records.
- Fuel logs are included in the schema as a later Phase 6 capability, but they are not required for the first MVP loop.

## Seed Plan

Seed data should be local-only and should follow this order:

1. Create a Supabase Auth test user.
2. Create the matching `profiles` row.
3. Create one vehicle with `created_by` set to the profile id.
4. Create an active owner row in `vehicle_ownerships`.
5. Add maintenance, mileage, note, document metadata, reminder, and notification preference rows.

Do not seed real vehicle plates, real documents, or production user data.

## Decision Review

Phase 2 is complete when the migration and documentation are accepted. Phase 3 Backend should use this schema through API/business logic boundaries instead of coupling mobile screens directly to database tables.
