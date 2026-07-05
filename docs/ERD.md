# ER Diagram

Phase 2 database design starts with an ownership-centered model. A user can own vehicles through `vehicle_ownerships`, and all vehicle memory records attach to a vehicle.

```mermaid
erDiagram
  auth_users ||--|| profiles : "has profile"
  profiles ||--o{ vehicle_ownerships : "owns"
  vehicles ||--o{ vehicle_ownerships : "has owners"
  vehicles ||--o{ maintenance_records : "has"
  vehicles ||--o{ vehicle_documents : "has"
  vehicles ||--o{ mileage_records : "has"
  vehicles ||--o{ vehicle_notes : "has"
  vehicles ||--o{ fuel_logs : "has"
  vehicles ||--o{ reminders : "has"
  profiles ||--|| notification_preferences : "sets"
  profiles ||--o{ maintenance_records : "creates"
  profiles ||--o{ vehicle_documents : "uploads"
  profiles ||--o{ mileage_records : "records"
  profiles ||--o{ vehicle_notes : "writes"
  profiles ||--o{ fuel_logs : "creates"
  profiles ||--o{ reminders : "receives"

  auth_users {
    uuid id PK
    text email
  }

  profiles {
    uuid id PK
    text display_name
    text phone_number
    text locale
    text timezone
    timestamptz created_at
    timestamptz updated_at
  }

  vehicles {
    uuid id PK
    uuid created_by FK
    citext plate_number
    text brand
    text model
    smallint model_year
    text vin
    text color
    text notes
    timestamptz deleted_at
    timestamptz created_at
    timestamptz updated_at
  }

  vehicle_ownerships {
    uuid id PK
    uuid vehicle_id FK
    uuid user_id FK
    text role
    text status
    date started_on
    date ended_on
    timestamptz created_at
    timestamptz updated_at
  }

  maintenance_records {
    uuid id PK
    uuid vehicle_id FK
    uuid created_by FK
    text title
    text category
    date service_date
    integer mileage_km
    text provider_name
    numeric cost_amount
    char currency
    text trust_source
    timestamptz deleted_at
  }

  vehicle_documents {
    uuid id PK
    uuid vehicle_id FK
    uuid uploaded_by FK
    text document_type
    text title
    text storage_bucket
    text storage_path
    text mime_type
    bigint file_size_bytes
    date issued_on
    date expires_on
    text trust_source
    timestamptz deleted_at
  }

  mileage_records {
    uuid id PK
    uuid vehicle_id FK
    uuid recorded_by FK
    date recorded_on
    integer mileage_km
    text source
  }

  vehicle_notes {
    uuid id PK
    uuid vehicle_id FK
    uuid created_by FK
    text title
    text body
    text trust_source
    timestamptz deleted_at
  }

  fuel_logs {
    uuid id PK
    uuid vehicle_id FK
    uuid created_by FK
    date fueled_on
    integer odometer_km
    numeric volume_liters
    numeric total_amount
    char currency
  }

  reminders {
    uuid id PK
    uuid vehicle_id FK
    uuid user_id FK
    text reminder_type
    text title
    date due_on
    text status
    timestamptz completed_at
  }

  notification_preferences {
    uuid id PK
    uuid user_id FK
    boolean email_enabled
    boolean push_enabled
    integer reminder_lead_days
    text timezone
  }
```

## Authorization Rule

The core authorization rule is:

```text
auth.uid() -> profiles.id -> vehicle_ownerships.user_id -> vehicles.id -> vehicle memory
```

If the user is not an active owner/member of a vehicle, they should not see or mutate that vehicle's memory records.
