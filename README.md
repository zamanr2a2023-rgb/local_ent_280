# local_ent_280 — Local Transport (Flutter + Firebase)

Production Flutter client for **Local Transport** (`local-transport-482015`), with the full Firebase backend toolchain ported from `local_transport`.

## Project layout

| Path | Purpose |
|------|---------|
| `lib/` | Flutter UI (client, driver, admin) |
| `functions/` | Cloud Functions (59 callables/triggers, TypeScript) |
| `docs/` | Source-of-truth documentation, ADRs, ops runbooks |
| `rules-test/` | Firestore + RTDB + Storage security rules tests (37 tests) |
| `integration_test/` | Emulator E2E + mocked app-flow tests |
| `test/` | Flutter unit/widget tests for this app |
| `test_transport/` | Reference tests from `local_transport` (porting backlog) |
| `scripts/` | Quality gates, seed wrappers, parity checks |
| `contracts/` | Shared contracts (trip state machine, pricing) |
| `roles/` | Firebase collection maps + mirror of rules (see root for deploy) |
| `firestore.rules` | **Canonical** Firestore rules (deploy + rules-test) |
| `firestore.indexes.json` | **Canonical** indexes (54 composite + overrides) |
| `storage.rules` | Storage rules |
| `database.rules.json` | Realtime Database rules |
| `firebase.json` | Full Firebase config (functions, emulators, rules, indexes) |
| `.firebaserc` | Projects: dev `local-transport-482015`, prod `local-transport-prod` |
| `.github/workflows/` | CI: quality gates, rules CI, backend deploy, emulator E2E |

## Quick start (Flutter)

```bash
flutter pub get
flutter run
```

## Firebase backend

### Deploy (requires Firebase/GCP permissions)

```bash
cd functions && npm ci && npm run build && cd ..
firebase deploy --only firestore,database,storage,functions --project local-transport-482015
```

### Seed dev data

1. Download service account JSON → `functions/secrets/firebase-service-account.json`
2. Run:

```bash
npm --prefix functions run seed:mvp
```

Or on Windows: `.\scripts\seed_dev_users.ps1`

### Run security rules tests

```bash
cd rules-test && npm ci && npm test
```

### Run Cloud Functions unit tests

```bash
cd functions && npm ci && npm test
```

## CI workflows

| Workflow | What it runs |
|----------|----------------|
| `quality-gates.yml` | `flutter analyze`, `flutter test`, rules tests, functions lint/build/test |
| `security-rules-ci.yml` | Rules tests on rules changes |
| `firebase-backend-deploy.yml` | Deploy backend to dev/prod (needs GCP secrets) |
| `emulator-e2e.yml` | Android emulator + Firebase emulators E2E |
| `android-app-distribution.yml` | APK build + App Distribution |

## Documentation

- **Domain source of truth:** `docs/source_of_truth/` (trips, pricing, admin, chat, …)
- **Admin screens map:** `docs/admin-firebase-screens.md`
- **Collection maps:** `roles/admin-firebase-collections.md`, `roles/driver-firebase-collections.md`
- **Rules publish guide:** `roles/README.md`

## Relationship to `local_transport`

`local_transport` was the original full-stack reference app. This repo now includes the same backend assets (functions, docs, indexes, rules tests, CI, seed scripts). The Flutter UI in `lib/` is the new design; `test_transport/` holds legacy tests for gradual porting.

## Test accounts (after `seed:mvp`)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin.qa@localtransport.test | Admin123!@# |
| Driver | driver1.qa@localtransport.test | Driver123!@# |
| Client | cliente1.qa@localtransport.test | Cliente123!@# |
