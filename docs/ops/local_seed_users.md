# Local seed users (QA login)

Use these accounts after running the MVP seed script against your Firebase project.

## Test accounts (`seed:mvp`)

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin.qa@localtransport.test` | `Admin123!@#` |
| Manager | `manager.qa@localtransport.test` | `Manager123!@#` |
| Driver 1 | `driver1.qa@localtransport.test` | `Driver123!@#` |
| Driver 2 | `driver2.qa@localtransport.test` | `Driver123!@#` |
| Client 1 | `cliente1.qa@localtransport.test` | `Cliente123!@#` |
| Client 2 | `cliente2.qa@localtransport.test` | `Cliente123!@#` |

For quick client testing, use **Client 1**.

## Minimal admin bootstrap (`seed:admin`)

| Email | Default password |
|-------|------------------|
| `admin@admin.com` | Set `ADMIN_PASSWORD` env var, or the script prints a generated password when the user is first created |

## Seed against **dev cloud** (`local-transport-482015`)

1. Firebase Console → **local-transport-dev** (`local-transport-482015`) → Project settings → **Service accounts** → **Generate new private key**.
2. Save the JSON as:

   `functions/secrets/firebase-service-account.json`

   (This path is gitignored.)

3. From repo root:

   ```powershell
   $env:FIREBASE_PROJECT_ID = "local-transport-482015"
   npm --prefix functions run seed:mvp
   ```

4. Run the app (dev flavor):

   ```powershell
   flutter run --flavor dev
   ```

5. Log in with any account from the table above.

## Seed with **Firebase emulators** (no service account)

```powershell
$env:FIREBASE_PROJECT_ID = "demo-local-transport"
firebase emulators:exec --only auth,firestore,database --project demo-local-transport "npm --prefix functions run seed:mvp"
```

Then run the app against emulators (physical device needs your PC LAN IP, not `127.0.0.1`):

```powershell
flutter run --flavor dev `
  --dart-define=USE_FIREBASE_EMULATORS=true `
  --dart-define=FIREBASE_EMULATOR_HOST=192.168.x.x `
  --dart-define=SKIP_FIREBASE_APP_CHECK=true
```

Replace `192.168.x.x` with your computer's IPv4 address on the same Wi‑Fi as the phone.

## App Check note

On **cloud dev**, login may fail with App Check `403` until you register a debug token:

1. Run the app once in debug.
2. Copy the App Check debug token from logcat / `flutter run` output.
3. Firebase Console → App Check → Manage debug tokens → add the token.

See `README.md` → **App Check debug setup**.
