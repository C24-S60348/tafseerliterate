# Simplified Update API Format

## Current Simplified Implementation

The update dialog is now **always optional** - users can always dismiss it. The dialog is simpler and cleaner.

## API Format

### Basic Format (All You Need)
```json
{
  "data": [
    {
      "name": "android",
      "force_version": "1.0.21",
      "message": "Versi baharu tersedia dengan pembaikan bug!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3"
    }
  ]
}
```

### With Optional Custom Title
You can include a custom title in the message by using a colon:
```json
{
  "data": [
    {
      "name": "android",
      "force_version": "1.0.21",
      "message": "Kemas Kini Penting: Versi baharu memperbaiki bug kritikal. Sila kemas kini sekarang.",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3"
    }
  ]
}
```
Result:
- Title: "Kemas Kini Penting"
- Message: "Versi baharu memperbaiki bug kritikal. Sila kemas kini sekarang."

### All Platforms Example
```json
{
  "data": [
    {
      "name": "android",
      "force_version": "1.0.21",
      "message": "Versi baharu dengan ciri-ciri menarik!",
      "link": "https://play.google.com/store/apps/details?id=com.af1productions.celiktafsirv3",
      "release_date": "2024-12-27"
    },
    {
      "name": "ios",
      "force_version": "1.0.10",
      "message": "Celik Tafsir Pro kini lebih pantas!",
      "link": "https://apps.apple.com/my/app/celik-tafsir-pro/id6754980616",
      "release_date": "2024-12-27"
    },
    {
      "name": "web",
      "force_version": "1.0.5",
      "message": "Versi web dengan UI baharu!",
      "link": "https://c24-s60348.github.io/celiktafsirv4/",
      "release_date": "2024-12-27"
    }
  ]
}
```

## Fields

| Field | Required | Description | Example |
|-------|----------|-------------|---------|
| `name` | ✅ Yes | Platform name | `"android"`, `"ios"`, `"web"` |
| `force_version` | ✅ Yes | Latest version number | `"1.0.21"` |
| `message` | ✅ Yes | Update message (can include title with colon) | `"Versi baharu tersedia!"` |
| `link` | ✅ Yes | Download link | `"https://play.google.com/..."` |
| `release_date` | ⚠️ Optional | Release date | `"2024-12-27"` |

**Note:** Also supports `current_version` field for compatibility.

## Dialog Features

### User Experience
- ✅ Always optional - user can dismiss
- ✅ Shows current version → new version
- ✅ Clean, simple design
- ✅ Can tap outside to dismiss
- ✅ Won't show again if dismissed (until next version)

### Buttons
1. **"Saya Akan Kemas Kini Nanti"** (grey) - Dismisses dialog
2. **"Kemas Kini"** (purple) - Opens download link

### Title Logic
- **Default**: "Versi Terkini Tersedia"
- **Custom**: Use colon in message: `"Custom Title: Message here"`
  - Before colon = Title
  - After colon = Message

## Examples

### Example 1: Simple Update
```json
{
  "name": "android",
  "force_version": "1.0.21",
  "message": "Pembaikan bug dan penambahbaikan prestasi.",
  "link": "https://play.google.com/store/apps/details?id=..."
}
```
**Result:**
- Title: "Versi Terkini Tersedia"
- Message: "Pembaikan bug dan penambahbaikan prestasi."

### Example 2: Custom Title
```json
{
  "name": "android",
  "force_version": "1.0.21",
  "message": "Ciri Baharu Ditambah: Bookmark kini lebih pantas dan mudah digunakan!",
  "link": "https://play.google.com/store/apps/details?id=..."
}
```
**Result:**
- Title: "Ciri Baharu Ditambah"
- Message: "Bookmark kini lebih pantas dan mudah digunakan!"

### Example 3: Urgent Update
```json
{
  "name": "android",
  "force_version": "1.0.21",
  "message": "Kemas Kini Segera: Pembaikan keselamatan penting. Sila kemas kini aplikasi anda.",
  "link": "https://play.google.com/store/apps/details?id=..."
}
```
**Result:**
- Title: "Kemas Kini Segera"
- Message: "Pembaikan keselamatan penting. Sila kemas kini aplikasi anda."

## Testing

### Test Your API
1. Create a test version.json
2. Set `force_version` higher than your app version
3. Open app and wait 2 seconds
4. Dialog should appear

### Clear Dismissed Updates
To test again after dismissing:
- Uninstall and reinstall app, OR
- Clear app data, OR
- Increment version number in API

## Migration from Old Format

If you were using the complex format with `force_update`, `minimum_version`, etc., the new format still works:

**Old Format (Still Works):**
```json
{
  "name": "android",
  "current_version": "1.0.21",
  "minimum_version": "1.0.20",
  "force_update": false,
  "message": "...",
  "release_notes": "...",
  "link": "..."
}
```

**New Simplified Format (Recommended):**
```json
{
  "name": "android",
  "force_version": "1.0.21",
  "message": "...",
  "link": "..."
}
```

Both work, but the simplified format is cleaner and easier to maintain.

