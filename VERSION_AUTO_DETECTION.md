# Version Auto-Detection Update

## Changes Made

### 1. **Added `package_info_plus` Package**
- Added to `pubspec.yaml` 
- Automatically reads version from `pubspec.yaml`
- No more manual version updates in code!

### 2. **Updated Version Checker** (`lib/services/version_checker.dart`)
- ✅ Removed hardcoded version string
- ✅ Added `getCurrentVersion()` method that reads from `pubspec.yaml`
- ✅ Version check now happens **only once per 24 hours** (cached)
- ✅ Added console logs to debug version checking

### 3. **Updated Information Page** (`lib/views/information.dart`)
- ✅ Changed from `StatelessWidget` to `StatefulWidget`
- ✅ Automatically displays version from `pubspec.yaml`
- ✅ Shows both version and build number: "Versi: 1.0.20 (20)"
- ✅ No more hardcoded version number!

## How It Works

### Version Update Flow:
1. You update version in `pubspec.yaml` only:
   ```yaml
   version: 1.0.21+21
   ```

2. App automatically:
   - Shows "Versi: 1.0.21 (21)" in Information page
   - Compares with server version from API
   - Shows update dialog if new version available

### Version Check Frequency:
- ✅ **First app launch**: Checks immediately (after 2 seconds)
- ✅ **Subsequent launches**: Only checks once per 24 hours
- ✅ **Cache prevents**: Repeated API calls every time mainpage opens
- ✅ **Manual reset**: Uninstall/reinstall app or clear data to force check

## How to Update Your App

### Step 1: Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.21+21
```
Format: `MAJOR.MINOR.PATCH+BUILD_NUMBER`

### Step 2: Update API
Edit your `version.json`:
```json
{
  "data": [
    {
      "name": "android",
      "current_version": "1.0.21",
      "force_version": "1.0.21",
      "message": "Kemas kini baharu tersedia!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3"
    }
  ]
}
```

### Step 3: Build & Deploy
```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release

# For Web
flutter build web --release
```

## Testing Version Check

### Force a Version Check (for testing):
1. Clear app data or uninstall app
2. Reinstall and open app
3. Wait 2 seconds - update dialog should appear

### Check Console Logs:
Look for these messages:
```
Checking for app updates...
Version check skipped - checked recently
Current version: 1.0.20
Server version: 1.0.21
```

## Benefits

✅ **Single Source of Truth**: Version only in `pubspec.yaml`
✅ **No Manual Updates**: Information page auto-updates
✅ **No Spam**: Checks only once per day
✅ **Smart Caching**: Reduces API calls
✅ **Better UX**: Users not annoyed by constant checks

## Debugging

### If version check not working:

1. **Check console logs**:
   - Look for "Checking for app updates..."
   - If you see "Version check skipped", it's working (cached)

2. **Force a new check**:
   - Clear app data
   - Or wait 24 hours
   - Or modify the check time in code

3. **Check API response**:
   - Visit https://c24-s60348.github.io/api/celiktafsir/version.json
   - Ensure format is correct
   - Verify version numbers match

4. **Check package info**:
   ```dart
   final info = await PackageInfo.fromPlatform();
   print('Version: ${info.version}');
   print('Build: ${info.buildNumber}');
   ```

## Current Status

- ✅ Version: **1.0.20** (from pubspec.yaml)
- ✅ Auto-detection: **Enabled**
- ✅ Information page: **Shows dynamic version**
- ✅ Version checker: **Checks once per day**
- ✅ Update dialog: **Shows when new version available**

