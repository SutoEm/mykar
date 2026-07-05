# UI Flow

This flow defines product direction only. It is not an implementation plan.

## MVP Flow

```text
Splash
  -> Login / Register
  -> Garage
  -> Add Vehicle
  -> Vehicle Overview
  -> Vehicle Memory Timeline
  -> Add Memory Item
  -> Reminder / Missing Data Prompt
```

## Authentication Flow

```text
Splash
  -> Login
     -> Garage
  -> Register
     -> Profile Setup
     -> Garage
  -> Forgot Password
     -> Reset Confirmation
     -> Login
```

## Vehicle Core Flow

```text
Garage
  -> Empty State
     -> Add Vehicle
  -> Vehicle Card
     -> Vehicle Overview
        -> Edit Vehicle
        -> Delete Vehicle
```

## Vehicle Memory Flow

```text
Vehicle Overview
  -> Timeline
  -> Maintenance
  -> Documents
  -> Notes
  -> Mileage
  -> Add Memory Item
```

## Navigation Rules

- Garage is the primary home after authentication.
- Vehicle Overview is the primary detail surface.
- Timeline is the default memory view.
- Add flows should be short and phase-specific.
- AI surfaces should not appear before enough vehicle memory exists.
