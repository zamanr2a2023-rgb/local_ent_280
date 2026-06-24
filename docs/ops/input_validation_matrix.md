# Input Validation Matrix

## Scope
- Included: transactional and operational forms with submit actions.
- Excluded: search and filter fields without submit (`place_selection`, audit/report filters, picker search inputs).

## Auth
- `login_screen.dart`
  - `email`: required, basic email format.
  - `password`: required.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `forgot_password_screen.dart`
  - `email`: required, basic email format.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.

## Admin
- `admin_user_form_sheet.dart`
  - `name`: required, trim, min 2, max 120.
  - `email`: required on create; optional on edit but validated when present.
  - `password` (create): required, min 6.
  - `phone`: optional, light format and digit length check.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `admin_vehicle_form_sheet.dart`
  - `plate`: required, light plate regex, min/max length.
  - `model`: required, min 2, max 120.
  - `capacity`: integer only, range `1..100`.
  - `notes`: max 500.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `admin_transport_type_form_sheet.dart`
  - `id`: required, slug formatter, max 40.
  - `name`: required, min 2, max 120.
  - `description`: max 500.
  - `multiplier`: localized decimal input, range `0.50..10.00`.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `admin_events_screen.dart`
  - `title`: required, max 120.
  - `message`: required, max 500.
  - `driver target`: required when target mode is `driver`.
  - Reminder input enforces integer-only formatter and range `1..60`.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `admin_balance_adjustment_sheet.dart`
  - `amount`: localized money input, positive amount, currency-aware minor-unit validation.
  - `reason`: required, min 3, max 240.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `admin_currency_settings_screen.dart`
  - `cveToEur`: localized decimal, required, range `(0, 1)`.
  - `cveToUsd`: localized decimal, required, range `(0, 1)`.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `admin_tariffs_screen.dart`
  - Decimal fields now use localized decimal formatter (`.`/`,` accepted, single separator).
  - Existing save-time server/domain-safe validations preserved (money parse, tier checks, overlap checks, multiplier bounds).

## Client
- `client_reservation_form_screen.dart`
  - Recurring series name: required when recurrence active, min 2, max 80.
  - Reminder offsets in recurrence are write-limited to `1..60`.
  - Legacy offsets `>60` are shown explicitly and block submit until removed.
  - Submit disabled when draft is invalid.
  - First invalid field receives focus on submit.
- `client_dashboard_screen.dart` (custom extension dialog)
  - `minutes`: integer only, range `5..60`.
  - Submit disabled when invalid.
  - First invalid field receives focus on submit.
- `client_trip_detail_screen.dart`
  - Rating feedback now bounded with max length `500`.

## Driver
- `driver_active_trip_screen.dart`
  - Cancel reason: required, min 3, max 240.
  - Surcharge amount: localized money input, positive required.
  - Surcharge reason: required, min 3, max 240.
  - Submit buttons disabled when invalid.
  - First invalid field receives focus on submit.

## Manager
- `manager_trip_detail_screen.dart`
  - Support status: required, max 120.
  - Support note: max 500.
  - Cancel reason: required, min 3, max 240.
  - Submit buttons disabled when invalid.
  - First invalid field receives focus on submit.

## Shared Validation Infrastructure
- `lib/core/presentation/validators/app_validators.dart`
- `lib/core/presentation/validators/app_input_formatters.dart`
- `lib/core/presentation/validators/time_range_validators.dart`
- `lib/core/presentation/validators/form_focus_helper.dart`
- `lib/core/presentation/validators/validation_limits.dart`

## Notes
- Client-side validation improves UX only; server-side guards in use cases, validators, and Firestore rules remain authoritative.
- Time range overlap and overnight semantics remain enforced by existing domain/service checks and dedicated validator utilities.
