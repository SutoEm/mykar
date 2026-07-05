# Supabase Seed Plan

Seed files are for local development and validation only. They must not contain real user data, real vehicle plates, or real documents.

## Order

1. Create a test user through Supabase Auth tooling.
2. Insert the matching `public.profiles` row.
3. Insert a test vehicle.
4. Insert an active `vehicle_ownerships` row.
5. Insert sample vehicle memory rows:
   - `maintenance_records`
   - `vehicle_documents`
   - `mileage_records`
   - `vehicle_notes`
   - `reminders`
   - `notification_preferences`

## Sample Values

- Use fictional plate values such as `TEST-001`.
- Use document paths under the test vehicle id.
- Use placeholder file metadata only.
- Keep fuel logs optional until the product enters the relevant Phase 6 workflow.

## Rule

If a seed row requires private or real-world data, do not seed it.
