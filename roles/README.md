# Firebase rules — how to publish

> **Canonical deploy files** are at the project root: `firestore.rules`, `storage.rules`, `database.rules.json`, `firestore.indexes.json`.  
> The `roles/` copies are kept in sync. Prefer `firebase deploy` (see root `README.md`).

**Driver Firebase map:** [`driver-firebase-collections.md`](driver-firebase-collections.md)  
**Admin Firebase map:** [`admin-firebase-collections.md`](admin-firebase-collections.md)

## Current status (from your app logs)

| Feature | Status | Firebase service |
|---------|--------|------------------|
| **Edit name** | Working (e.g. "shahedd") | Firestore rules OK |
| **Upload photo** | Blocked (`403 Permission denied`) | **Storage rules NOT published** |

---

## Fix photo upload — publish Storage rules

This is a **different** place in Firebase Console than Firestore.

1. Open `roles/storage.rules` in this project.
2. Select all and copy (entire file).
3. Go to [Firebase Console](https://console.firebase.google.com) → project **local-transport-482015**
4. Left menu → **Storage** (not Firestore)
5. Tab **Rules**
6. Delete old rules → paste → **Publish**

### Rules you must publish (copy from `roles/storage.rules`)

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwnImageUpload(userId) {
      return isSignedIn()
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && (
          request.resource.contentType == null
          || request.resource.contentType.matches('image/.*')
        );
    }

    match /users/{userId}/{fileName} {
      allow read: if isSignedIn();
      allow write: if isOwnImageUpload(userId);
    }

    match /profile_photos/{fileName} {
      allow read: if isSignedIn();
      allow write: if isSignedIn()
        && fileName == request.auth.uid + '.jpg'
        && request.resource.size < 5 * 1024 * 1024
        && (
          request.resource.contentType == null
          || request.resource.contentType.matches('image/.*')
        );
    }

    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

7. Hot restart the app and try photo upload again.

Photo saves to: `users/{your-uid}/profile.jpg`  
Then `photoUrl` is written to Firestore `users/{your-uid}`.

---

## Firestore rules (name + photoUrl) — already working for name

If name edit fails again, publish `roles/firestore.rules` under **Firestore Database → Rules**.

Must include `isSelfProfileUpdateAllowed()` under `match /users/{uid}`.

---

## Common mistake

| Wrong | Right |
|-------|-------|
| Paste Storage rules into **Firestore** Rules | Storage rules → **Storage → Rules** |
| Paste Firestore rules into **Storage** Rules | Firestore rules → **Firestore → Rules** |
| Paste markdown/README into Console | Only paste `.rules` file content |

---

## Optional: deploy from terminal

```bash
cd local_ent_280
firebase deploy --only storage --project local-transport-482015
```

Requires Firebase CLI login with deploy permission on the project.
