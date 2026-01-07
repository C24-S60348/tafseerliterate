# Auto-Check Not Working - Troubleshooting

## Why Auto-Check Might Not Show Dialog

When you open the app, it **does** check for updates, but the dialog might not show for these reasons:

### 1. ✅ Already Dismissed
**Most Common Reason**

If you clicked "Abaikan" before, the app remembers and won't show that version again.

**Check Console Logs:**
```
🔄 Auto-checking for updates on app start...
📬 Found 1 notification(s)
🔍 Checking if notification was dismissed: 1.0.21
⏭️  Notification already dismissed by user, skipping  ← This means you dismissed it
```

**Solution:**
- Use "Semak Kemas Kini" button (it clears dismissed flag)
- Or clear app data

### 2. ⏰ 24-Hour Cache
The app only checks once per 24 hours to avoid annoying users.

**Check Console Logs:**
```
🔄 Auto-checking for updates on app start...
Version check skipped - checked recently  ← Checked within last 24 hours
📬 Found 0 notification(s)
```

**Solution:**
- Wait 24 hours
- Or use "Semak Kemas Kini" button (bypasses cache)

### 3. ✅ Already Updated
Your app version matches the API version.

**Check Console Logs:**
```
🔄 Auto-checking for updates on app start...
📱 App version from package_info_plus: 1.0.21
🔍 Current app version: 1.0.21
📬 Found 0 notification(s)  ← No update needed
```

**Solution:**
- No action needed, you're up to date!
- To test, increase version in API to `1.0.22`

### 4. 🌐 Network Error
Can't reach the API.

**Check Console Logs:**
```
🔄 Auto-checking for updates on app start...
❌ Error checking for updates: SocketException: Failed host lookup
```

**Solution:**
- Check internet connection
- Verify API URL is accessible: https://c24-s60348.github.io/api/celiktafsir/version.json

### 5. 📱 Wrong Platform
API doesn't have entry for your platform.

**Check Console Logs:**
```
🔄 Auto-checking for updates on app start...
Checking for app updates...
📬 Found 0 notification(s)  ← No matching platform in API
```

**Solution:**
- Make sure API has entry for your platform (`android`, `ios`, or `web`)

## How to Debug

### Step 1: Check Console Logs

When you open the app, look for these logs:

```
🔄 Auto-checking for updates on app start...
📱 PackageInfo - version: 1.0.20, buildNumber: 20
🔍 Current app version: 1.0.20
Checking for app updates...
📬 Found 1 notification(s)
📢 Showing notification 1/1: Versi baharu tersedia!
🔍 Checking if notification was dismissed: 1.0.21
✅ Showing dialog for: 1.0.21
```

### Step 2: Identify the Issue

| Log Message | Meaning | Solution |
|------------|---------|----------|
| `Version check skipped - checked recently` | 24-hour cache active | Wait or use manual check |
| `Found 0 notification(s)` | No updates available | Check API or already updated |
| `Notification already dismissed` | You clicked "Abaikan" | Use manual check button |
| `Error checking for updates` | Network/API error | Check connection/API |

### Step 3: Test Auto-Check

To force a fresh check:

1. **Clear dismissed updates:**
   - Go to Settings → "Semak Kemas Kini"
   - This clears the dismissed flag

2. **Clear app data (Android):**
   ```
   Settings → Apps → Celik Tafsir → Storage → Clear Data
   ```

3. **Reinstall app (iOS/Web):**
   - Uninstall and reinstall

4. **Or wait 24 hours**

## Comparison: Auto vs Manual Check

| Feature | Auto-Check (App Start) | Manual Check (Button) |
|---------|----------------------|----------------------|
| **When** | Every app start | When button clicked |
| **Rate Limit** | Once per 24 hours | Always checks |
| **Respects "Abaikan"** | ✅ Yes | ❌ No (clears it) |
| **Delay** | 2 seconds after start | Immediate |
| **Use Case** | Normal users | Testing/Debugging |

## Expected Behavior

### Scenario 1: First Time User
```
Day 1, 9:00 AM - Open app
→ ✅ Shows update dialog

Day 1, 2:00 PM - Open app again
→ ❌ No dialog (checked within 24h)

Day 2, 10:00 AM - Open app
→ ✅ Shows dialog (if not dismissed)
```

### Scenario 2: User Dismissed Update
```
Day 1 - Open app → Shows dialog → Click "Abaikan"
Day 2 - Open app → ❌ No dialog (dismissed)
Day 3 - Open app → ❌ No dialog (still dismissed)

Click "Semak Kemas Kini" → ✅ Shows dialog (cleared dismiss)
```

### Scenario 3: New Version Released
```
App v1.0.20, API v1.0.20
→ ❌ No dialog (up to date)

API updated to v1.0.21
→ ✅ Shows dialog (new version available)

User updates app to v1.0.21
→ ❌ No dialog (up to date again)
```

## Quick Tests

### Test 1: Is Auto-Check Running?
1. Close app completely
2. Open app
3. Check console for: `🔄 Auto-checking for updates on app start...`
4. ✅ If you see it, auto-check is working

### Test 2: Is API Reachable?
1. Open browser
2. Go to: https://c24-s60348.github.io/api/celiktafsir/version.json
3. ✅ Should see JSON response

### Test 3: Is Version Comparison Working?
1. Check console for: `🔍 Current app version: X.X.X`
2. Check API for: `"latest_version": "X.X.X"`
3. If API version > app version → Should show dialog

### Test 4: Is Dismiss Working?
1. Open app → See dialog → Click "Abaikan"
2. Close and reopen app
3. ❌ Should NOT show dialog (dismissed)
4. Click "Semak Kemas Kini"
5. ✅ Should show dialog (cleared)

## Summary

**Auto-check IS working**, but it respects:
- ✅ 24-hour rate limit (to avoid annoying users)
- ✅ User's "Abaikan" choice (to respect user preference)
- ✅ Already up-to-date status (no need to show)

**To test immediately:**
- Use "Semak Kemas Kini" button
- It bypasses all these protections

**For production:**
- Auto-check works perfectly
- Users won't be annoyed by constant popups
- They can manually check anytime via Settings

The system is working as designed! 🎉

