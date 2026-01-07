# Version Checker - How It Works

## ✅ Current Version Source

**IMPORTANT**: The `currentVersion` shown in the dialog is **ALWAYS** from your Flutter app's `pubspec.yaml`, **NOT** from the API.

### Code Flow

```dart
// Step 1: Get version from app (pubspec.yaml)
final currentVersion = await getCurrentVersion(); // e.g., "1.0.20"

// Step 2: Get server version from API
final serverVersion = platformData['latest_version']; // e.g., "1.0.21"

// Step 3: Compare
if (_isNewerVersion(serverVersion, currentVersion)) {
  // Show update dialog with:
  // - currentVersion: 1.0.20 (from app)
  // - latestVersion: 1.0.21 (from API)
}
```

## 📝 Example

### Your App Version (pubspec.yaml)
```yaml
version: 1.0.20+20
```

### Your API
```json
{
  "data": [
    {
      "name": "android",
      "latest_version": "1.0.21",
      "message": "Update available"
    }
  ]
}
```

### Result in Dialog
```
┌─────────────────────────────────────┐
│         🚀 Rocket Icon              │
│                                     │
│  ┌─────────────────────────────┐  │
│  │  Versi Baharu Tersedia        │  │
│  │                               │  │
│  │  Update available             │  │
│  │                               │  │
│  │  1.0.20 → 1.0.21             │  │
│  │   ↑         ↑                 │  │
│  │  App     API                  │  │
│  └─────────────────────────────┘  │
└─────────────────────────────────────┘
```

## ⚠️ Common Confusion

### ❌ WRONG: "API controls current version"
```json
{
  "current_version": "1.0.20"  // This does NOT override app version!
}
```

### ✅ CORRECT: "App controls current version"
- App version comes from `pubspec.yaml`
- API only provides the **latest** version
- The field names `latest_version`, `force_version`, `current_version` in API all mean the **same thing**: the server's latest version

## 🔍 Why Multiple Field Names?

For backward compatibility and flexibility:
```dart
// All these mean "server's latest version":
final serverVersion = platformData['latest_version'] ??    // Preferred
                     platformData['force_version'] ??      // Alternative 1
                     platformData['current_version'] ??    // Alternative 2
                     '1.0.0';                             // Fallback
```

## 📊 Version Comparison Logic

```dart
App Version (pubspec.yaml): 1.0.20
API latest_version: 1.0.21

Compare:
1.0.21 > 1.0.20? YES ✅
→ Show update dialog

After user updates to 1.0.21:
1.0.21 > 1.0.21? NO ❌
→ Don't show update dialog
```

## 🎯 Summary

| Field | Source | Can Change? | Purpose |
|-------|--------|-------------|---------|
| `currentVersion` | `pubspec.yaml` (app) | Only by rebuilding app | Show user's current version |
| `latestVersion` | API JSON | Yes, anytime | Show available version on server |

**Key Point**: When user clicks "Abaikan", they're dismissing the **latest version from API** (e.g., "1.0.21"), not changing their app version. Their app version stays the same until they actually update the app from Play Store/App Store.

## 🧪 Test Scenarios

### Scenario 1: Fresh Install
- App: `1.0.20` (from pubspec.yaml)
- API: `latest_version: "1.0.21"`
- Result: ✅ Shows update (1.0.20 → 1.0.21)

### Scenario 2: After Clicking "Abaikan"
- App: `1.0.20` (unchanged)
- API: `latest_version: "1.0.21"` (unchanged)
- Result: ❌ Doesn't show (dismissed)
- Clear dismiss: Click "Semak Kemas Kini" button

### Scenario 3: After Updating App
- App: `1.0.21` (updated via Play Store)
- API: `latest_version: "1.0.21"`
- Result: ❌ Doesn't show (already updated)

### Scenario 4: New Version Released
- App: `1.0.21` (from previous update)
- API: `latest_version: "1.0.22"` (new release)
- Result: ✅ Shows update (1.0.21 → 1.0.22)

## 💡 API Best Practices

### ✅ Good API Structure
```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "latest_version": "1.0.21",
      "title": "Update Available",
      "message": "Bug fixes and improvements",
      "link": "https://play.google.com/..."
    }
  ]
}
```

### ❌ Don't Do This
```json
{
  "data": [
    {
      "name": "android",
      "current_version": "1.0.20",  // ❌ This doesn't control user's version
      "latest_version": "1.0.21"    // ✅ This is what matters
    }
  ]
}
```

The app **always** gets its current version from `pubspec.yaml`, never from the API!

