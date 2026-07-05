# Data Dictionary

This dictionary documents the Phase 2 database contract. It is written before backend implementation so API work can follow stable table boundaries.

## Shared Conventions

- Primary keys use `uuid` with `gen_random_uuid()` unless the row maps to `auth.users`.
- Timestamps use `timestamptz`.
- Soft-delete capable tables use `deleted_at`.
- User-facing currency defaults to `TRY` but stays explicit.
- Trust fields use text checks instead of PostgreSQL enums to keep early migrations simple.
- RLS policies are ownership-based through `vehicle_ownerships`.

## `profiles`

Application profile for a Supabase Auth user.

| Column         | Type        | Required | Notes                         |
| -------------- | ----------- | -------- | ----------------------------- |
| `id`           | uuid        | Yes      | References `auth.users(id)`   |
| `display_name` | text        | No       | User-visible name             |
| `phone_number` | text        | No       | Optional contact field        |
| `avatar_url`   | text        | No       | Optional profile image URL    |
| `locale`       | text        | Yes      | Defaults to `tr-TR`           |
| `timezone`     | text        | Yes      | Defaults to `Europe/Istanbul` |
| `created_at`   | timestamptz | Yes      | Defaults to `now()`           |
| `updated_at`   | timestamptz | Yes      | Maintained by trigger         |

## `vehicles`

Core vehicle identity.

| Column         | Type        | Required | Notes                         |
| -------------- | ----------- | -------- | ----------------------------- |
| `id`           | uuid        | Yes      | Primary key                   |
| `created_by`   | uuid        | Yes      | References `profiles(id)`     |
| `plate_number` | citext      | No       | Case-insensitive plate        |
| `brand`        | text        | Yes      | Vehicle make                  |
| `model`        | text        | Yes      | Vehicle model                 |
| `model_year`   | smallint    | No       | Checked between 1900 and 2100 |
| `vin`          | citext      | No       | Vehicle identification number |
| `color`        | text        | No       | Optional user-entered color   |
| `notes`        | text        | No       | General vehicle note          |
| `deleted_at`   | timestamptz | No       | Soft delete marker            |
| `created_at`   | timestamptz | Yes      | Defaults to `now()`           |
| `updated_at`   | timestamptz | Yes      | Maintained by trigger         |

Indexes:

- `vehicles_created_by_idx`
- `vehicles_plate_number_idx`
- `vehicles_vin_idx`

## `vehicle_ownerships`

Bridge between users and vehicles.

| Column       | Type        | Required | Notes                                  |
| ------------ | ----------- | -------- | -------------------------------------- |
| `id`         | uuid        | Yes      | Primary key                            |
| `vehicle_id` | uuid        | Yes      | References `vehicles(id)`              |
| `user_id`    | uuid        | Yes      | References `profiles(id)`              |
| `role`       | text        | Yes      | `owner`, `manager`, or `viewer`        |
| `status`     | text        | Yes      | `active`, `archived`, or `transferred` |
| `started_on` | date        | Yes      | Defaults to current date               |
| `ended_on`   | date        | No       | Required when ownership ends           |
| `created_at` | timestamptz | Yes      | Defaults to `now()`                    |
| `updated_at` | timestamptz | Yes      | Maintained by trigger                  |

Indexes:

- `vehicle_ownerships_vehicle_id_idx`
- `vehicle_ownerships_user_id_idx`
- Unique active membership on `(vehicle_id, user_id)` where active.

## `maintenance_records`

Service and repair memory.

| Column          | Type          | Required | Notes                               |
| --------------- | ------------- | -------- | ----------------------------------- |
| `id`            | uuid          | Yes      | Primary key                         |
| `vehicle_id`    | uuid          | Yes      | References `vehicles(id)`           |
| `created_by`    | uuid          | Yes      | References `profiles(id)`           |
| `title`         | text          | Yes      | User-friendly record title          |
| `category`      | text          | No       | Oil, tire, inspection, repair, etc. |
| `service_date`  | date          | Yes      | Date of service                     |
| `mileage_km`    | integer       | No       | Non-negative                        |
| `provider_name` | text          | No       | Service provider name               |
| `cost_amount`   | numeric(12,2) | No       | Non-negative                        |
| `currency`      | char(3)       | Yes      | Defaults to `TRY`                   |
| `notes`         | text          | No       | Additional context                  |
| `trust_source`  | text          | Yes      | Defaults to `user_entered`          |
| `deleted_at`    | timestamptz   | No       | Soft delete marker                  |
| `created_at`    | timestamptz   | Yes      | Defaults to `now()`                 |
| `updated_at`    | timestamptz   | Yes      | Maintained by trigger               |

## `vehicle_documents`

Metadata for uploaded vehicle documents. The file itself lives in Supabase Storage.

| Column            | Type        | Required | Notes                                                                 |
| ----------------- | ----------- | -------- | --------------------------------------------------------------------- |
| `id`              | uuid        | Yes      | Primary key                                                           |
| `vehicle_id`      | uuid        | Yes      | References `vehicles(id)`                                             |
| `uploaded_by`     | uuid        | Yes      | References `profiles(id)`                                             |
| `document_type`   | text        | Yes      | `insurance`, `inspection`, `service_receipt`, `registration`, `other` |
| `title`           | text        | Yes      | User-facing title                                                     |
| `storage_bucket`  | text        | Yes      | Defaults to `vehicle-documents`                                       |
| `storage_path`    | text        | Yes      | Starts with vehicle id                                                |
| `mime_type`       | text        | No       | Uploaded file MIME type                                               |
| `file_size_bytes` | bigint      | No       | Non-negative                                                          |
| `issued_on`       | date        | No       | Document issue date                                                   |
| `expires_on`      | date        | No       | Document expiry date                                                  |
| `notes`           | text        | No       | Optional context                                                      |
| `trust_source`    | text        | Yes      | Defaults to `user_uploaded`                                           |
| `deleted_at`      | timestamptz | No       | Soft delete marker                                                    |
| `created_at`      | timestamptz | Yes      | Defaults to `now()`                                                   |
| `updated_at`      | timestamptz | Yes      | Maintained by trigger                                                 |

Path convention:

```text
{vehicle_id}/{document_id}/{filename}
```

## `mileage_records`

Mileage snapshots independent from maintenance records.

| Column        | Type        | Required | Notes                      |
| ------------- | ----------- | -------- | -------------------------- |
| `id`          | uuid        | Yes      | Primary key                |
| `vehicle_id`  | uuid        | Yes      | References `vehicles(id)`  |
| `recorded_by` | uuid        | Yes      | References `profiles(id)`  |
| `recorded_on` | date        | Yes      | Defaults to current date   |
| `mileage_km`  | integer     | Yes      | Non-negative               |
| `source`      | text        | Yes      | Defaults to `user_entered` |
| `notes`       | text        | No       | Optional context           |
| `created_at`  | timestamptz | Yes      | Defaults to `now()`        |
| `updated_at`  | timestamptz | Yes      | Maintained by trigger      |

## `vehicle_notes`

Freeform vehicle memory notes.

| Column         | Type        | Required | Notes                      |
| -------------- | ----------- | -------- | -------------------------- |
| `id`           | uuid        | Yes      | Primary key                |
| `vehicle_id`   | uuid        | Yes      | References `vehicles(id)`  |
| `created_by`   | uuid        | Yes      | References `profiles(id)`  |
| `title`        | text        | Yes      | Note title                 |
| `body`         | text        | Yes      | Note body                  |
| `trust_source` | text        | Yes      | Defaults to `user_entered` |
| `deleted_at`   | timestamptz | No       | Soft delete marker         |
| `created_at`   | timestamptz | Yes      | Defaults to `now()`        |
| `updated_at`   | timestamptz | Yes      | Maintained by trigger      |

## `fuel_logs`

Fuel history. Included for schema continuity, but not required in the first MVP loop.

| Column              | Type          | Required | Notes                     |
| ------------------- | ------------- | -------- | ------------------------- |
| `id`                | uuid          | Yes      | Primary key               |
| `vehicle_id`        | uuid          | Yes      | References `vehicles(id)` |
| `created_by`        | uuid          | Yes      | References `profiles(id)` |
| `fueled_on`         | date          | Yes      | Fuel date                 |
| `odometer_km`       | integer       | No       | Non-negative              |
| `volume_liters`     | numeric(10,2) | No       | Non-negative              |
| `unit_price_amount` | numeric(12,2) | No       | Non-negative              |
| `total_amount`      | numeric(12,2) | No       | Non-negative              |
| `currency`          | char(3)       | Yes      | Defaults to `TRY`         |
| `station_name`      | text          | No       | Optional station name     |
| `notes`             | text          | No       | Optional context          |
| `created_at`        | timestamptz   | Yes      | Defaults to `now()`       |
| `updated_at`        | timestamptz   | Yes      | Maintained by trigger     |

## `reminders`

Date-based prompts for vehicle actions.

| Column          | Type        | Required | Notes                                                                          |
| --------------- | ----------- | -------- | ------------------------------------------------------------------------------ |
| `id`            | uuid        | Yes      | Primary key                                                                    |
| `vehicle_id`    | uuid        | Yes      | References `vehicles(id)`                                                      |
| `user_id`       | uuid        | Yes      | References `profiles(id)`                                                      |
| `reminder_type` | text        | Yes      | `manual`, `inspection`, `insurance`, `maintenance`, `document`, `missing_data` |
| `title`         | text        | Yes      | User-facing reminder title                                                     |
| `due_on`        | date        | Yes      | Due date                                                                       |
| `status`        | text        | Yes      | `pending`, `done`, or `dismissed`                                              |
| `source`        | text        | Yes      | `user_entered` or `system_derived`                                             |
| `completed_at`  | timestamptz | No       | Set when done                                                                  |
| `created_at`    | timestamptz | Yes      | Defaults to `now()`                                                            |
| `updated_at`    | timestamptz | Yes      | Maintained by trigger                                                          |

## `notification_preferences`

User-level reminder delivery settings.

| Column               | Type        | Required | Notes                              |
| -------------------- | ----------- | -------- | ---------------------------------- |
| `id`                 | uuid        | Yes      | Primary key                        |
| `user_id`            | uuid        | Yes      | Unique reference to `profiles(id)` |
| `email_enabled`      | boolean     | Yes      | Defaults to true                   |
| `push_enabled`       | boolean     | Yes      | Defaults to true                   |
| `reminder_lead_days` | integer[]   | Yes      | Defaults to `{7,1}`                |
| `timezone`           | text        | Yes      | Defaults to `Europe/Istanbul`      |
| `created_at`         | timestamptz | Yes      | Defaults to `now()`                |
| `updated_at`         | timestamptz | Yes      | Maintained by trigger              |
