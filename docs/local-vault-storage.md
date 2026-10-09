# Local Vault Storage — Architecture Decision

> **Feature:** "Locally Saved" vault (Saved Vault screen → Locally Saved tab)
> **Decision:** Copy files into app-private sandboxed storage (Option A)
> **Status:** Approved, not yet implemented

---

## 1. The Problem

A student has a PDF (e.g. a PYQ or notes file) already sitting somewhere on
their phone's storage. Semester Forge needs to let them "save" that file into
their personal vault, tag it with a subject, and reliably open it again
later — offline, any time, without the file silently disappearing.

There were two candidate approaches.

---

## 2. Option A — Copy the file into the app's own storage

The app reads the picked file's bytes once and writes its own private copy
into a directory only Semester Forge can access. The database only stores
**metadata** (subject, title, size, date, local path) — never a path into
someone else's storage.

```text
User picks PDF
      ↓
file_picker returns bytes / a readable handle
      ↓
Copy bytes → app's private documents directory
      ↓
Save metadata row (subjectId, title, localPath, sizeBytes, addedAt)
      ↓
Vault screen reads from local DB + local file, always
```

### Why this is the reliable choice

1. **No permission expiry.** The app's own sandboxed directory
   (`getApplicationDocumentsDirectory()` via `path_provider`) is always
   readable/writable by the app — no OS permission can be revoked out from
   under it after a restart, an OS update, or a storage-permission change.
2. **Survives the source file being deleted or moved.** Once copied, the
   original file in Downloads/WhatsApp/wherever is irrelevant. The user
   could delete it five minutes later and the vault copy is unaffected.
3. **Works identically on Android and iOS.** iOS sandboxing means an app
   generally *cannot* keep a durable reference into another app's storage
   at all without a security-scoped bookmark — and even those can silently
   expire. A private copy sidesteps the whole problem.
4. **Scoped Storage safe.** On Android 10+, file pickers commonly hand back
   a `content://` URI, not a real filesystem path. Reading it once (to copy
   the bytes) is fine; treating it as a stable path to re-read later is not.
5. **Matches how the file is actually used.** The vault needs to *open* the
   PDF offline, reliably, potentially months later — that's a durability
   guarantee only a private copy can give.

### Trade-off (accepted)

- Uses roughly double the storage temporarily (original + copy) until the
  user removes the source file, and permanently keeps one copy inside the
  app. This is the same trade every offline-vault app (WhatsApp media,
  Google Drive offline files, Notion offline pages) makes, and is why the
  Saved Vault screen already shows a **Storage Used** meter with a
  **Manage & Clear Cache** action — the user stays in control of that cost.

---

## 3. Option B — Store only a path/URI reference (rejected)

The app would store the picked file's path/URI in the database and read
directly from that location every time it's needed, instead of copying.

### Why this breaks in practice

1. **Android Scoped Storage (10+):** a file-picker result is very often a
   `content://` URI, not a plain filesystem path. Treating it as a durable
   string to store and reopen later is not guaranteed to work at all.
2. **Permission expiry:** persistent access to a picked URI requires
   explicitly calling `takePersistableUriPermission()` — an Android-only
   API. Without it, the grant can silently die on app restart. iOS has no
   equivalent; security-scoped bookmarks exist but are notoriously fragile
   and can expire without warning.
3. **User can delete/move/rename the source file** at any time outside the
   app's control (clear Downloads, uninstall WhatsApp, move to SD card,
   etc.) — the vault entry becomes a dead link with no recovery.
4. **Storing the path in the backend database has no real value** — a path
   or content URI is only meaningful on the exact device/app-install that
   produced it. It doesn't survive reinstall, a new device, or backup
   restore, so "next time I'll fetch it from your local storage" doesn't
   hold up beyond that one app session.

**Conclusion:** Option B looks lighter on storage but is not reliable
enough for a feature whose entire point is "this file will still be here
when I need it."

---

## 4. Chosen Design (Option A) — Implementation Sketch

### Packages

| Package | Purpose |
|---|---|
| `file_picker` | Let the user pick a PDF from device storage |
| `path_provider` | Get the app's private documents directory |
| `drift` or `sqflite` | Local metadata database |
| `permission_handler` | Storage/media permission prompts where required |

### Storage layout

```text
<app documents dir>/
└── vault/
    └── <subjectId>/
        └── <fileId>.pdf
```

### Local metadata table (`saved_resources`)

| Column | Type | Notes |
|---|---|---|
| `id` | text (uuid) | primary key |
| `subjectId` | text | links the file to a subject — powers the subject filter chips on the Saved Vault screen |
| `title` | text | display title |
| `localPath` | text | path inside the app's private `vault/` directory |
| `sizeBytes` | int | shown in the Storage Used meter |
| `type` | text | `PYQ` / `NOTES` / `LAB_MANUAL` / etc. — drives the `StatusChip` variant |
| `addedAt` | datetime | sort order, "Locally Saved" listing |

### Flow

```text
Tap "Add" (upload) → pick a PDF
      ↓
Read file bytes from the picked source (one-time read)
      ↓
Write bytes to vault/<subjectId>/<fileId>.pdf
      ↓
Insert row into saved_resources (local DB)
      ↓
Saved Vault → Locally Saved tab reads from saved_resources + opens localPath
```

### Optional future extension — backend sync

If cross-device access is ever needed, the *metadata* (not raw bytes) can
sync to the backend the same way other resources already do — but that is
a separate, later feature from this offline-first local vault, and should
not block or complicate this implementation.

### Storage management

The existing **Vault Storage Used** card (Saved Vault screen) with its
**Manage & Clear Cache** action is the natural place to let the user delete
locally-copied files to reclaim space — deleting the row + the file at
`localPath` is enough; nothing else references it.

---

## 5. Summary

| | Option A (copy) | Option B (reference only) |
|---|---|---|
| Survives source file deletion | ✅ | ❌ |
| Works reliably on Android 10+ | ✅ | ⚠️ requires persistable URI permission, Android-only |
| Works reliably on iOS | ✅ | ❌ sandboxing blocks durable external paths |
| Extra storage used | One copy | None |
| Backend metadata sync is meaningful | ✅ | ❌ path is device-local only |

**Decision: Option A.**
