# Correct API Format

## Your API Format (Fixed)

Your JSON had missing commas. Here's the corrected version:

```json
{
  "data": [
    {
      "name": "android",
      "title": "Versi baharu tersedia!",
      "message": "Muat turun versi baharu aplikasi Celik Tafsir Pro",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3",
      "latest_version": "1.0.21",
      "type": "update"
    },
    {
      "name": "android",
      "title": "Berita",
      "message": "Jom download aplikasi Hadis 40 Imam Nawawi!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.hadis40&hl=ms",
      "type": "news"
    }
  ]
}
```

**Changes Made:**
- ✅ Added missing commas after `"title"`
- ✅ Both notifications will show (update first, then news)

## How It Works Now

### Scenario 1: App v1.0.20 (Your Current Version)
With your API above:
1. ✅ Shows "Versi baharu tersedia!" (because 1.0.21 > 1.0.20)
2. ✅ Then shows "Berita" (Hadis 40 app)

### Scenario 2: App v1.0.21 (After Update)
With your API above:
1. ❌ No update popup (because 1.0.21 = 1.0.21)
2. ✅ Shows "Berita" only (Hadis 40 app)

### Scenario 3: No News, Already Updated
```json
{
  "data": [
    {
      "name": "android",
      "title": "Versi baharu tersedia!",
      "message": "Muat turun versi baharu",
      "link": "https://play.google.com/...",
      "latest_version": "1.0.20",
      "type": "update"
    }
  ]
}
```
Result: Nothing shows (app is already 1.0.20)

## Field Names Supported

The app now supports multiple field names for version:
- `latest_version` ✅ (your format)
- `force_version` ✅ (alternative)
- `current_version` ✅ (alternative)

So all these work:
```json
"latest_version": "1.0.21"
"force_version": "1.0.21"
"current_version": "1.0.21"
```

## Multiple Notifications

You can have multiple entries for the same platform:
```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "latest_version": "1.0.21",
      "title": "Update Available",
      "message": "Bug fixes",
      "link": "https://play.google.com/..."
    },
    {
      "name": "android",
      "type": "news",
      "title": "New App Released!",
      "message": "Check out our new Hadis app!",
      "link": "https://play.google.com/..."
    },
    {
      "name": "android",
      "type": "news",
      "title": "Ramadan Kareem",
      "message": "Selamat berpuasa!",
      "link": ""
    }
  ]
}
```

**Order:**
1. Update dialog shown first (if version is newer)
2. Then all news dialogs (in order)

## Test Your API

1. Go to Settings → "Semak Kemas Kini"
2. Should show:
   - First: "Versi baharu tersedia!" (Update)
   - Second: "Berita" (Hadis 40 app)

## All Platforms Example

```json
{
  "data": [
    {
      "name": "android",
      "title": "Versi baharu tersedia!",
      "message": "Muat turun versi baharu aplikasi Celik Tafsir Pro",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3",
      "latest_version": "1.0.21",
      "type": "update"
    },
    {
      "name": "android",
      "title": "Berita",
      "message": "Jom download aplikasi Hadis 40 Imam Nawawi!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.hadis40&hl=ms",
      "type": "news"
    },
    {
      "name": "ios",
      "title": "Update Available",
      "message": "New version with bug fixes",
      "link": "https://apps.apple.com/my/app/celik-tafsir-pro/id1522969729",
      "latest_version": "1.0.15",
      "type": "update"
    },
    {
      "name": "web",
      "title": "Welcome",
      "message": "Try our mobile app for better experience!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3",
      "type": "news"
    }
  ]
}
```

## Summary

✅ **Fixed**: Added missing commas in JSON
✅ **Feature**: Multiple notifications support
✅ **Feature**: Shows update first, then news (in order)
✅ **Feature**: Supports `latest_version` field name
✅ **Behavior**: If no update and no news → nothing shows
✅ **Behavior**: If updated but have news → only news shows
✅ **Behavior**: If update available → shows update, then any news

Your API is now ready to use! 🎉

