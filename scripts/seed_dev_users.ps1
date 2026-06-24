# Seeds QA users into the dev Firebase project (local-transport-482015).
# Requires: functions/secrets/firebase-service-account.json
# See docs/ops/local_seed_users.md for login credentials.

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$serviceAccountPath = Join-Path $repoRoot "functions\secrets\firebase-service-account.json"

if (-not (Test-Path $serviceAccountPath)) {
    Write-Host ""
    Write-Host "Missing service account key:" -ForegroundColor Red
    Write-Host "  $serviceAccountPath"
    Write-Host ""
    Write-Host "1. Firebase Console -> local-transport-482015"
    Write-Host "2. Project settings -> Service accounts -> Generate new private key"
    Write-Host "3. Save JSON to the path above"
    Write-Host ""
    Write-Host "Then run this script again."
    Write-Host "Full guide: docs/ops/local_seed_users.md"
    exit 1
}

$env:GOOGLE_APPLICATION_CREDENTIALS = $serviceAccountPath
$env:FIREBASE_PROJECT_ID = "local-transport-482015"

Push-Location $repoRoot
try {
    npm --prefix functions run seed:mvp
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    Write-Host ""
    Write-Host "Seed complete. Example client login:" -ForegroundColor Green
    Write-Host "  Email:    cliente1.qa@localtransport.test"
    Write-Host "  Password: Cliente123!@#"
    Write-Host ""
    Write-Host "All accounts: docs/ops/local_seed_users.md"
}
finally {
    Pop-Location
}
