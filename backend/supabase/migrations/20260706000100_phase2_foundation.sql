create extension if not exists pgcrypto;
create extension if not exists citext;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  phone_number text,
  avatar_url text,
  locale text not null default 'tr-TR',
  timezone text not null default 'Europe/Istanbul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles(id) on delete restrict,
  plate_number citext,
  brand text not null,
  model text not null,
  model_year smallint check (model_year is null or (model_year >= 1900 and model_year <= 2100)),
  vin citext,
  color text,
  notes text,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vehicle_ownerships (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'owner' check (role in ('owner', 'manager', 'viewer')),
  status text not null default 'active' check (status in ('active', 'archived', 'transferred')),
  started_on date not null default current_date,
  ended_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (ended_on is null or ended_on >= started_on)
);

create table public.maintenance_records (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  created_by uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  category text,
  service_date date not null,
  mileage_km integer check (mileage_km is null or mileage_km >= 0),
  provider_name text,
  cost_amount numeric(12,2) check (cost_amount is null or cost_amount >= 0),
  currency char(3) not null default 'TRY',
  notes text,
  trust_source text not null default 'user_entered' check (trust_source in ('user_entered', 'user_uploaded', 'system_derived', 'verified_external')),
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vehicle_documents (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  uploaded_by uuid not null references public.profiles(id) on delete restrict,
  document_type text not null check (document_type in ('insurance', 'inspection', 'service_receipt', 'registration', 'other')),
  title text not null,
  storage_bucket text not null default 'vehicle-documents',
  storage_path text not null,
  mime_type text,
  file_size_bytes bigint check (file_size_bytes is null or file_size_bytes >= 0),
  issued_on date,
  expires_on date,
  notes text,
  trust_source text not null default 'user_uploaded' check (trust_source in ('user_entered', 'user_uploaded', 'system_derived', 'verified_external')),
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (expires_on is null or issued_on is null or expires_on >= issued_on)
);

create table public.mileage_records (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  recorded_by uuid not null references public.profiles(id) on delete restrict,
  recorded_on date not null default current_date,
  mileage_km integer not null check (mileage_km >= 0),
  source text not null default 'user_entered' check (source in ('user_entered', 'user_uploaded', 'system_derived', 'verified_external')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.vehicle_notes (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  created_by uuid not null references public.profiles(id) on delete restrict,
  title text not null,
  body text not null,
  trust_source text not null default 'user_entered' check (trust_source in ('user_entered', 'user_uploaded', 'system_derived', 'verified_external')),
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.fuel_logs (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  created_by uuid not null references public.profiles(id) on delete restrict,
  fueled_on date not null,
  odometer_km integer check (odometer_km is null or odometer_km >= 0),
  volume_liters numeric(10,2) check (volume_liters is null or volume_liters >= 0),
  unit_price_amount numeric(12,2) check (unit_price_amount is null or unit_price_amount >= 0),
  total_amount numeric(12,2) check (total_amount is null or total_amount >= 0),
  currency char(3) not null default 'TRY',
  station_name text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  reminder_type text not null check (reminder_type in ('manual', 'inspection', 'insurance', 'maintenance', 'document', 'missing_data')),
  title text not null,
  due_on date not null,
  status text not null default 'pending' check (status in ('pending', 'done', 'dismissed')),
  source text not null default 'user_entered' check (source in ('user_entered', 'system_derived')),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check ((status = 'done' and completed_at is not null) or (status <> 'done'))
);

create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.profiles(id) on delete cascade,
  email_enabled boolean not null default true,
  push_enabled boolean not null default true,
  reminder_lead_days integer[] not null default array[7,1],
  timezone text not null default 'Europe/Istanbul',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index vehicle_ownerships_active_unique_idx
  on public.vehicle_ownerships(vehicle_id, user_id)
  where status = 'active' and ended_on is null;

create index vehicles_created_by_idx on public.vehicles(created_by);
create index vehicles_plate_number_idx on public.vehicles(plate_number);
create index vehicles_vin_idx on public.vehicles(vin);
create index vehicle_ownerships_vehicle_id_idx on public.vehicle_ownerships(vehicle_id);
create index vehicle_ownerships_user_id_idx on public.vehicle_ownerships(user_id);
create index maintenance_records_vehicle_date_idx on public.maintenance_records(vehicle_id, service_date desc);
create index vehicle_documents_vehicle_type_idx on public.vehicle_documents(vehicle_id, document_type);
create unique index vehicle_documents_storage_path_unique_idx on public.vehicle_documents(storage_bucket, storage_path);
create index mileage_records_vehicle_date_idx on public.mileage_records(vehicle_id, recorded_on desc);
create index vehicle_notes_vehicle_created_idx on public.vehicle_notes(vehicle_id, created_at desc);
create index fuel_logs_vehicle_date_idx on public.fuel_logs(vehicle_id, fueled_on desc);
create index reminders_user_due_idx on public.reminders(user_id, due_on, status);
create index reminders_vehicle_due_idx on public.reminders(vehicle_id, due_on, status);

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger set_vehicles_updated_at
  before update on public.vehicles
  for each row execute function public.set_updated_at();

create trigger set_vehicle_ownerships_updated_at
  before update on public.vehicle_ownerships
  for each row execute function public.set_updated_at();

create trigger set_maintenance_records_updated_at
  before update on public.maintenance_records
  for each row execute function public.set_updated_at();

create trigger set_vehicle_documents_updated_at
  before update on public.vehicle_documents
  for each row execute function public.set_updated_at();

create trigger set_mileage_records_updated_at
  before update on public.mileage_records
  for each row execute function public.set_updated_at();

create trigger set_vehicle_notes_updated_at
  before update on public.vehicle_notes
  for each row execute function public.set_updated_at();

create trigger set_fuel_logs_updated_at
  before update on public.fuel_logs
  for each row execute function public.set_updated_at();

create trigger set_reminders_updated_at
  before update on public.reminders
  for each row execute function public.set_updated_at();

create trigger set_notification_preferences_updated_at
  before update on public.notification_preferences
  for each row execute function public.set_updated_at();

create or replace function public.user_created_vehicle(target_vehicle_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.vehicles
    where id = target_vehicle_id
      and created_by = auth.uid()
      and deleted_at is null
  );
$$;

create or replace function public.user_can_access_vehicle(target_vehicle_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.user_created_vehicle(target_vehicle_id)
    or exists (
      select 1
      from public.vehicle_ownerships
      where vehicle_id = target_vehicle_id
        and user_id = auth.uid()
        and status = 'active'
        and ended_on is null
    );
$$;

create or replace function public.user_can_access_vehicle_storage_path(object_name text)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  target_vehicle_id uuid;
begin
  if object_name !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/' then
    return false;
  end if;

  target_vehicle_id := split_part(object_name, '/', 1)::uuid;
  return public.user_can_access_vehicle(target_vehicle_id);
end;
$$;

alter table public.profiles enable row level security;
alter table public.vehicles enable row level security;
alter table public.vehicle_ownerships enable row level security;
alter table public.maintenance_records enable row level security;
alter table public.vehicle_documents enable row level security;
alter table public.mileage_records enable row level security;
alter table public.vehicle_notes enable row level security;
alter table public.fuel_logs enable row level security;
alter table public.reminders enable row level security;
alter table public.notification_preferences enable row level security;

create policy profiles_select_own
  on public.profiles for select
  to authenticated
  using (id = auth.uid());

create policy profiles_insert_own
  on public.profiles for insert
  to authenticated
  with check (id = auth.uid());

create policy profiles_update_own
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy vehicles_select_member
  on public.vehicles for select
  to authenticated
  using (deleted_at is null and public.user_can_access_vehicle(id));

create policy vehicles_insert_creator
  on public.vehicles for insert
  to authenticated
  with check (created_by = auth.uid());

create policy vehicles_update_member
  on public.vehicles for update
  to authenticated
  using (public.user_can_access_vehicle(id))
  with check (public.user_can_access_vehicle(id));

create policy vehicle_ownerships_select_related
  on public.vehicle_ownerships for select
  to authenticated
  using (user_id = auth.uid() or public.user_created_vehicle(vehicle_id));

create policy vehicle_ownerships_insert_creator
  on public.vehicle_ownerships for insert
  to authenticated
  with check (user_id = auth.uid() and public.user_created_vehicle(vehicle_id));

create policy vehicle_ownerships_update_creator
  on public.vehicle_ownerships for update
  to authenticated
  using (public.user_created_vehicle(vehicle_id))
  with check (public.user_created_vehicle(vehicle_id));

create policy maintenance_records_select_member
  on public.maintenance_records for select
  to authenticated
  using (deleted_at is null and public.user_can_access_vehicle(vehicle_id));

create policy maintenance_records_insert_member
  on public.maintenance_records for insert
  to authenticated
  with check (created_by = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy maintenance_records_update_member
  on public.maintenance_records for update
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id))
  with check (public.user_can_access_vehicle(vehicle_id));

create policy vehicle_documents_select_member
  on public.vehicle_documents for select
  to authenticated
  using (deleted_at is null and public.user_can_access_vehicle(vehicle_id));

create policy vehicle_documents_insert_member
  on public.vehicle_documents for insert
  to authenticated
  with check (uploaded_by = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy vehicle_documents_update_member
  on public.vehicle_documents for update
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id))
  with check (public.user_can_access_vehicle(vehicle_id));

create policy mileage_records_select_member
  on public.mileage_records for select
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id));

create policy mileage_records_insert_member
  on public.mileage_records for insert
  to authenticated
  with check (recorded_by = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy mileage_records_update_member
  on public.mileage_records for update
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id))
  with check (public.user_can_access_vehicle(vehicle_id));

create policy vehicle_notes_select_member
  on public.vehicle_notes for select
  to authenticated
  using (deleted_at is null and public.user_can_access_vehicle(vehicle_id));

create policy vehicle_notes_insert_member
  on public.vehicle_notes for insert
  to authenticated
  with check (created_by = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy vehicle_notes_update_member
  on public.vehicle_notes for update
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id))
  with check (public.user_can_access_vehicle(vehicle_id));

create policy fuel_logs_select_member
  on public.fuel_logs for select
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id));

create policy fuel_logs_insert_member
  on public.fuel_logs for insert
  to authenticated
  with check (created_by = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy fuel_logs_update_member
  on public.fuel_logs for update
  to authenticated
  using (public.user_can_access_vehicle(vehicle_id))
  with check (public.user_can_access_vehicle(vehicle_id));

create policy reminders_select_own_vehicle
  on public.reminders for select
  to authenticated
  using (user_id = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy reminders_insert_own_vehicle
  on public.reminders for insert
  to authenticated
  with check (user_id = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy reminders_update_own_vehicle
  on public.reminders for update
  to authenticated
  using (user_id = auth.uid() and public.user_can_access_vehicle(vehicle_id))
  with check (user_id = auth.uid() and public.user_can_access_vehicle(vehicle_id));

create policy notification_preferences_select_own
  on public.notification_preferences for select
  to authenticated
  using (user_id = auth.uid());

create policy notification_preferences_insert_own
  on public.notification_preferences for insert
  to authenticated
  with check (user_id = auth.uid());

create policy notification_preferences_update_own
  on public.notification_preferences for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'vehicle-documents',
  'vehicle-documents',
  false,
  10485760,
  array['application/pdf', 'image/jpeg', 'image/png', 'image/heic']
)
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

alter table storage.objects enable row level security;

create policy vehicle_documents_storage_select
  on storage.objects for select
  to authenticated
  using (bucket_id = 'vehicle-documents' and public.user_can_access_vehicle_storage_path(name));

create policy vehicle_documents_storage_insert
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'vehicle-documents' and public.user_can_access_vehicle_storage_path(name));

create policy vehicle_documents_storage_update
  on storage.objects for update
  to authenticated
  using (bucket_id = 'vehicle-documents' and public.user_can_access_vehicle_storage_path(name))
  with check (bucket_id = 'vehicle-documents' and public.user_can_access_vehicle_storage_path(name));

create policy vehicle_documents_storage_delete
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'vehicle-documents' and public.user_can_access_vehicle_storage_path(name));
