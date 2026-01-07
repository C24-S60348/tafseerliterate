# Version Checker Implementation

## Overview
The version checker automatically checks for app updates from your API and shows a dialog to users when a new version is available.

## Features
- ✅ Automatic version checking on app startup
- ✅ Platform-specific updates (Android, iOS, Web)
- ✅ Optional force update for critical versions
- ✅ Beautiful Malay-language update dialog
- ✅ Rate limiting (checks once per day)
- ✅ User can dismiss non-critical updates
- ✅ Direct links to download new version

## API Format

### Current API (Working)
Your current API at `https://c24-s60348.github.io/api/celiktafsir/version.json` works fine.

### Recommended API Improvements
```json
{
  "data": [
    {
      "name": "android",
      "current_version": "1.0.4",
      "minimum_version": "1.0.3",
      "force_update": false,
      "message": "Versi baharu tersedia dengan pembaikan bug!",
      "release_notes": "- Pembaikan bug bacaan terakhir\n- Penambahbaikan UI\n- Prestasi lebih pantas",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3",
      "release_date": "2024-12-27"
    },
    {
      "name": "ios",
      "current_version": "1.0.2",
      "minimum_version": "1.0.0",
      "force_update": false,
      "message": "Celik Tafsir Pro kini dengan ciri-ciri baharu!",
      "release_notes": "- Sokongan Dark Mode\n- Bookmark lebih baik\n- Bug fixes",
      "link": "https://apps.apple.com/my/app/celik-tafsir-pro/id6754980616",
      "release_date": "2024-12-27"
    },
    {
      "name": "web",
      "current_version": "1.0.1",
      "minimum_version": "1.0.0",
      "force_update": false,
      "message": "Versi web baharu dengan UI yang lebih cantik!",
      "release_notes": "- Responsive design\n- Loading screen baharu\n- Performance optimization",
      "link": "https://c24-s60348.github.io/celiktafsirv4/",
      "release_date": "2024-12-27"
    }
  ]
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | ✅ Yes | Platform: "android", "ios", or "web" |
| `current_version` | string | ✅ Yes | Latest available version (e.g., "1.0.4") |
| `minimum_version` | string | ⚠️ Optional | Minimum required version (for force updates) |
| `force_update` | boolean | ⚠️ Optional | Whether update is mandatory |
| `message` | string | ✅ Yes | Update message to show users |
| `release_notes` | string | ⚠️ Optional | What's new in this version |
| `link` | string | ✅ Yes | Download link (Play Store, App Store, or web URL) |
| `release_date` | string | ⚠️ Optional | Release date (YYYY-MM-DD format) |

**Note**: The code also supports your current format with `force_version` field for backward compatibility.

## How It Works

### 1. Version Checking
- Checks once per day (rate limited)
- Compares app version with server version
- Supports semantic versioning (e.g., 1.2.3)

### 2. Update Types

#### Optional Update
- User can click "Kemudian" to dismiss
- Won't show again for this version if dismissed
- Shows nice "Update Available" message

#### Force Update (Mandatory)
- User cannot dismiss the dialog
- Must update to continue using app
- Shows warning message
- Triggered when `force_update: true` OR when current version < `minimum_version`

### 3. Platform Detection
- Automatically detects if running on Android, iOS, or Web
- Fetches appropriate version info from API

## How to Update Your App Version

1. **Open `pubspec.yaml`**
2. **Update version number**:
   ```yaml
   version: 1.0.4+4  # Format: version+buildNumber
   ```

3. **Update version in version_checker.dart**:
   ```dart
   static const String currentVersion = '1.0.4';
   ```

4. **Update your API**:
   - Edit `version.json`
   - Change `current_version` to new version
   - Add release notes
   - If mandatory, set `force_update: true` or increase `minimum_version`

## Testing

### Test Optional Update
```json
{
  "name": "android",
  "current_version": "1.0.5",
  "force_update": false,
  "message": "Test update available!",
  "link": "https://example.com"
}
```

### Test Force Update
```json
{
  "name": "android",
  "current_version": "2.0.0",
  "minimum_version": "2.0.0",
  "force_update": true,
  "message": "Critical update required!",
  "link": "https://example.com"
}
```

### Clear Cached Check (for testing)
The app caches the last check time. To force a new check:
1. Uninstall and reinstall the app, OR
2. Clear app data, OR
3. Wait 24 hours

## Deployment Checklist

- [ ] Update `currentVersion` in `version_checker.dart`
- [ ] Update `version` in `pubspec.yaml`
- [ ] Update API `version.json` with new version info
- [ ] Test update dialog appears correctly
- [ ] Test download links work
- [ ] Deploy to Play Store / App Store / Web

## Customization

### Change Check Frequency
In `version_checker.dart`, line ~24:
```dart
if (now - lastCheck < 86400000) { // 24 hours in milliseconds
```

Change to:
- 1 hour: `3600000`
- 12 hours: `43200000`
- 1 week: `604800000`

### Change Dialog Appearance
Edit `lib/widgets/update_dialog.dart` to customize:
- Colors
- Text
- Button labels
- Layout

### Disable Version Checking
In `mainpage.dart`, comment out:
```dart
// _checkForUpdates();
```

## Notes

- Version checking happens 2 seconds after app launch
- No internet = no crash (fails silently)
- Updates are checked once per platform, per day
- Users can dismiss optional updates
- Force updates cannot be dismissed

