# News & Update API Documentation

## Overview

The dialog now supports two types of notifications:
1. **Version Updates** - Shows when there's a new app version
2. **News/Announcements** - Shows regardless of version (for announcements, events, etc.)

## Dialog Design

The new dialog matches your design with:
- 🚀 Orange gradient background with rocket/announcement icon
- 📝 White content card
- 🎯 Centered title and message
- ✅ Two buttons: "Abaikan" (ignore) and "Update/OK"

## API Formats

### 1. Version Update (Normal)
Shows when there's a new version available:

```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "force_version": "1.0.21",
      "title": "Versi Terkini Tersedia",
      "message": "We improvise speed and performance, etc.",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3"
    }
  ]
}
```

### 2. News/Announcement
Shows regardless of version (for announcements, promotions, etc.):

```json
{
  "data": [
    {
      "name": "android",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Hi There",
      "message": "Jom sertai kelas tafsir percuma kami! Daftar sekarang di website kami.",
      "link": "https://celiktafsir.net/events"
    }
  ]
}
```

### 3. News Without Link (Just Announcement)
For announcements that don't need a link:

```json
{
  "data": [
    {
      "name": "android",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Selamat Hari Raya!",
      "message": "Maaf Zahir & Batin dari seluruh team Celik Tafsir. Semoga amal ibadah kita diterima Allah SWT.",
      "link": ""
    }
  ]
}
```

## Field Reference

| Field | Required | Type | Description | Example |
|-------|----------|------|-------------|---------|
| `name` | ✅ Yes | string | Platform identifier | `"android"`, `"ios"`, `"web"` |
| `type` | ⚠️ Optional | string | Notification type | `"update"` or `"news"` (default: update) |
| `force_version` | ✅ Yes | string | Version to compare | `"1.0.21"` |
| `title` | ⚠️ Optional | string | Dialog title | `"Hi There"` (default: "Versi Terkini Tersedia") |
| `message` | ✅ Yes | string | Main message content | `"We improvise speed and performance..."` |
| `link` | ⚠️ Optional | string | Action link | `"https://..."` (empty for no link) |
| `release_date` | ⚠️ Optional | string | Date (for logging) | `"2024-12-27"` |

## Usage Examples

### Example 1: App Update
```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "force_version": "1.0.21",
      "title": "Kemas Kini Tersedia",
      "message": "Versi baharu dengan ciri-ciri menarik dan pembaikan bug!",
      "link": "https://play.google.com/store/apps/details?id=..."
    }
  ]
}
```

**Result:**
- Icon: 🚀 Rocket
- Title: "Kemas Kini Tersedia"
- Shows version: 1.0.20 → 1.0.21
- Buttons: [Abaikan] [Update]
- Update button opens Play Store

### Example 2: Event Announcement
```json
{
  "data": [
    {
      "name": "android",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Kelas Tafsir Percuma!",
      "message": "Sertai kelas tafsir online percuma kami setiap Ahad jam 2 petang. Daftar sekarang!",
      "link": "https://celiktafsir.net/register"
    }
  ]
}
```

**Result:**
- Icon: 📢 Announcement
- Title: "Kelas Tafsir Percuma!"
- No version shown
- Buttons: [Abaikan] [Update]
- Update button opens registration link

### Example 3: Simple Greeting
```json
{
  "data": [
    {
      "name": "android",
      "type": "news",
      "force_version": "1.0.0",
      "title": "Selamat Hari Raya Aidilfitri",
      "message": "Maaf Zahir & Batin dari seluruh team Celik Tafsir. 🌙✨",
      "link": ""
    }
  ]
}
```

**Result:**
- Icon: 📢 Announcement
- Title: "Selamat Hari Raya Aidilfitri"
- No version shown
- Buttons: [Abaikan] [OK]
- OK button just closes dialog

### Example 4: All Platforms
```json
{
  "data": [
    {
      "name": "android",
      "type": "update",
      "force_version": "1.0.21",
      "title": "Update Available",
      "message": "Bug fixes and performance improvements.",
      "link": "https://play.google.com/store/apps/details?id=..."
    },
    {
      "name": "ios",
      "type": "update",
      "force_version": "1.0.15",
      "title": "Update Available",
      "message": "Bug fixes and performance improvements.",
      "link": "https://apps.apple.com/my/app/celik-tafsir-pro/..."
    },
    {
      "name": "web",
      "type": "news",
      "force_version": "1.0.0",
      "title": "New Feature Available",
      "message": "Try our new dark mode! Toggle it in settings.",
      "link": ""
    }
  ]
}
```

## Dialog Behavior

### Version Update (`type: "update"`)
- ✅ Shows only if server version > app version
- ✅ Displays version comparison (1.0.20 → 1.0.21)
- ✅ Rocket icon 🚀
- ✅ Once dismissed, won't show again for that version
- ✅ "Update" button opens link

### News/Announcement (`type: "news"`)
- ✅ Shows regardless of app version
- ✅ No version comparison shown
- ✅ Announcement icon 📢
- ✅ Once dismissed, won't show again for that message
- ✅ Button text is "Update" (if link) or "OK" (if no link)

## Button Logic

| Scenario | Left Button | Right Button |
|----------|-------------|--------------|
| Update with link | "Abaikan" (dismiss) | "Update" (open link) |
| News with link | "Abaikan" (dismiss) | "Update" (open link) |
| News without link | "Abaikan" (dismiss) | "OK" (close dialog) |

## Testing

### Test Update Dialog
```json
{
  "name": "android",
  "type": "update",
  "force_version": "999.0.0",
  "title": "Test Update",
  "message": "This is a test update notification",
  "link": "https://google.com"
}
```

### Test News Dialog
```json
{
  "name": "android",
  "type": "news",
  "force_version": "1.0.0",
  "title": "Test News",
  "message": "This is a test news notification",
  "link": ""
}
```

## Tips

### 1. Seasonal Greetings
Use `type: "news"` for:
- Hari Raya greetings
- Ramadan reminders
- New Year messages
- App anniversaries

### 2. Promotions
Use `type: "news"` for:
- Special events
- New features announcement
- Community updates
- Surveys or feedback requests

### 3. Critical Updates
Use `type: "update"` with high version number for:
- Security patches
- Critical bug fixes
- Major new versions

### 4. A/B Testing
You can show different messages to different platforms:
- Android: Play Store link
- iOS: App Store link
- Web: Feature announcement

## Migration Guide

### Old Format (Still Works)
```json
{
  "name": "android",
  "force_version": "1.0.21",
  "message": "New version available",
  "link": "https://..."
}
```

### New Format (Recommended)
```json
{
  "name": "android",
  "type": "update",
  "force_version": "1.0.21",
  "title": "Update Available",
  "message": "New version with bug fixes",
  "link": "https://..."
}
```

If you don't specify `type`, it defaults to `"update"` (version check).
If you don't specify `title`, it uses default based on type.

## Current Defaults

- **Update Type**: `"Versi Terkini Tersedia"`
- **News Type**: `"Hi There"`
- **No Link**: Button shows "OK" instead of "Update"

## Visual Preview

```
┌─────────────────────────────────────┐
│                                     │
│         [Orange Gradient]           │
│                                     │
│          🚀 or 📢                  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │                               │  │
│  │  [Title - Bold, Centered]     │  │
│  │                               │  │
│  │  [Message - Grey, Centered]   │  │
│  │                               │  │
│  │  [1.0.20 → 1.0.21]           │  │  ← Only for updates
│  │                               │  │
│  │  [Abaikan]  [Update/OK]      │  │
│  │                               │  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

Matches the design you showed perfectly! 🎨

