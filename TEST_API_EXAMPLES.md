# Test API Examples

To test the update dialog immediately, you need to update your API at:
`https://c24-s60348.github.io/api/celiktafsir/version.json`

## Why No Popup?

The popup might not show because:
1. **24-hour cache**: App only checks once per day automatically
2. **Version is same**: Your API version matches your app version
3. **Already dismissed**: You clicked "Abaikan" before

**Solution**: Use the "Semak Kemas Kini" button in Settings!

## Test Case 1: Version Update (Will Show Immediately)

```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "force_version": "999.0.0",
      "title": "Test Update Available",
      "message": "This is a test update. If you see this, the system works!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3"
    },
    {
      "name": "ios",
      "type": "update",
      "force_version": "999.0.0",
      "title": "Test Update Available",
      "message": "This is a test update. If you see this, the system works!",
      "link": "https://apps.apple.com/my/app/celik-tafsir-pro/id1522969729"
    },
    {
      "name": "web",
      "type": "update",
      "force_version": "999.0.0",
      "title": "Test Update Available",
      "message": "This is a test update. If you see this, the system works!",
      "link": "https://c24-s60348.github.io/celiktafsirv4/"
    }
  ]
}
```

## Test Case 2: News/Announcement (Always Shows)

```json
{
  "data": [
    {
      "name": "android",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Hi There",
      "message": "We improvise speed and performance, etc. This is a test news announcement!",
      "link": "https://celiktafsir.net"
    },
    {
      "name": "ios",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Hi There",
      "message": "We improvise speed and performance, etc. This is a test news announcement!",
      "link": "https://celiktafsir.net"
    },
    {
      "name": "web",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Hi There",
      "message": "We improvise speed and performance, etc. This is a test news announcement!",
      "link": "https://celiktafsir.net"
    }
  ]
}
```

## Test Case 3: Seasonal Greeting

```json
{
  "data": [
    {
      "name": "android",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Selamat Hari Raya!",
      "message": "Maaf Zahir & Batin dari seluruh team Celik Tafsir. Semoga amal ibadah kita diterima Allah SWT. 🌙✨",
      "link": ""
    }
  ]
}
```

## How to Test

### Method 1: Use the "Semak Kemas Kini" Button ⭐ RECOMMENDED
1. Open the app
2. Go to **Pengaturan** (Settings)
3. Click **"Semak Kemas Kini"** button
4. This will:
   - ✅ Bypass the 24-hour cache
   - ✅ Clear dismissed versions
   - ✅ Show the dialog immediately

### Method 2: Clear App Data (Android)
1. Go to phone Settings → Apps → Celik Tafsir
2. Click "Storage" → "Clear Data"
3. Reopen the app

### Method 3: Reinstall (iOS/Web)
- Uninstall and reinstall the app

### Method 4: Debug (Developer)
```dart
// In lib/views/mainpage.dart, temporarily comment out the delay:
// await Future.delayed(Duration(seconds: 2)); // Comment this

// Or change the cache duration in lib/services/version_checker.dart:
if (now - lastCheck < 60000) { // 1 minute instead of 24 hours (86400000)
```

## Current Production Format

Your production API should look like this:

```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "force_version": "1.0.20",
      "title": "Versi Terkini Tersedia",
      "message": "Kami telah menambah baik kelajuan dan prestasi aplikasi. Kemas kini sekarang!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3",
      "release_date": "2024-12-27"
    },
    {
      "name": "ios",
      "type": "update",
      "force_version": "1.0.15",
      "title": "Versi Terkini Tersedia",
      "message": "Kami telah menambah baik kelajuan dan prestasi aplikasi. Kemas kini sekarang!",
      "link": "https://apps.apple.com/my/app/celik-tafsir-pro/id1522969729",
      "release_date": "2024-12-27"
    },
    {
      "name": "web",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Terima Kasih!",
      "message": "Terima kasih kerana menggunakan versi web Celik Tafsir. Jangan lupa download app kami!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3"
    }
  ]
}
```

## Quick Test Workflow

1. **Update your API** to use Test Case 1 or 2
2. **Open app** → Go to Settings
3. **Click "Semak Kemas Kini"**
4. **See the popup!** 🎉

## Troubleshooting

### "Anda sudah menggunakan versi terkini!" Message
- Your API version is not higher than app version
- Solution: Use `force_version: "999.0.0"` in test

### Dialog Doesn't Show After "Semak Kemas Kini"
- Check console/logs for errors
- Make sure API URL is correct
- Check internet connection
- Verify JSON format is valid

### Button Shows But Nothing Happens
- Check if API is accessible
- Open: https://c24-s60348.github.io/api/celiktafsir/version.json
- Should return valid JSON

## Features Summary

✅ **Automatic Check**: On app start (once per 24 hours)
✅ **Manual Check**: "Semak Kemas Kini" button in Settings
✅ **Version Updates**: Shows when server version > app version
✅ **News/Announcements**: Shows regardless of version
✅ **Smart Caching**: Don't annoy users with frequent checks
✅ **Dismissible**: Users can ignore updates
✅ **Platform Specific**: Different messages for Android/iOS/Web
✅ **Beautiful UI**: Orange gradient, matches design

