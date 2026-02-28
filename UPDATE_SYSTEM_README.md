# 📱 HydroSmart OTA Update System

This system provides Over-The-Air (OTA) updates for your HydroSmart Flutter app through your Render backend.

## 🏗️ How It Works

1. **App checks backend** - Every 24 hours, the app automatically checks your Render backend for updates
2. **Version comparison** - Backend compares current app version with latest available version
3. **Download & install** - If update is available, user can download and install the new APK
4. **Forced updates** - Critical updates can be marked as forced, requiring immediate installation

## 🚀 Deployment Workflow

### 1. Build New APK
```bash
cd hydro_smart
flutter build apk --release
```

### 2. Upload APK to GitHub Releases
1. Go to your GitHub repository
2. Create a new release (e.g., `v1.0.1`)
3. Upload the built APK file
4. Copy the download URL

### 3. Update Backend Version
```bash
cd backend
python update_version.py 1.0.1 2 "https://github.com/username/hydro_smart/releases/download/v1.0.1/app-release.apk" "Bug fixes and new features"
```

### 4. Deploy to Render
```bash
git add .
git commit -m "Update app version to v1.0.1"
git push origin main
```

Render will automatically redeploy your backend with the new version info.

## 📋 Update Script Usage

```bash
python update_version.py <version> <build_number> <download_url> [release_notes] [--forced]
```

### Examples

**Regular Update:**
```bash
python update_version.py 1.0.1 2 "https://github.com/user/repo/releases/download/v1.0.1/app.apk" "Bug fixes and improvements"
```

**Forced Update (Critical):**
```bash
python update_version.py 1.0.2 3 "https://github.com/user/repo/releases/download/v1.0.2/app.apk" "Critical security update" --forced
```

## 🔧 Backend Endpoints

Your Render backend now includes these endpoints:

- `GET /api/app/version` - Check for app updates
- `GET /api/app/config` - Get app configuration  
- `POST /api/app/update-status` - Report installation status
- `GET /api/app/download` - Get download information

## 📱 App Features

### For Users:
- **Automatic checks** - App checks for updates every 24 hours
- **Smart notifications** - Unobtrusive update notifications
- **One-tap updates** - Easy download and installation
- **Background downloads** - Updates download in background
- **Forced updates** - Critical updates require immediate installation

### For Developers:
- **Version control** - Manage versions through backend
- **Release notes** - Provide detailed update information
- **Update analytics** - Track installation success rates
- **Forced updates** - Push critical security updates
- **Gradual rollout** - Control update availability

## 🛡️ Security Features

- **HTTPS only** - All update checks use secure connections
- **APK verification** - Apps verify download integrity
- **Permission handling** - Proper Android install permissions
- **Cleanup** - Old APK files are automatically removed

## 📊 Monitoring

Check your Render dashboard to monitor:
- Update check requests
- Download statistics
- Installation success rates
- Error logs

## 🔧 Configuration

Update the configuration in `backend/app.py`:

```python
CURRENT_APP_VERSION = {
    "version": "1.0.1",
    "buildNumber": 2,
    "downloadUrl": "your-apk-url",
    "isForced": False,  # Set to True for forced updates
    # ... other settings
}
```

## 🚨 Emergency Updates

For critical security updates:

1. Build and upload APK immediately
2. Update backend with `--forced` flag
3. Push to Render
4. All users will be forced to update

## 📝 Version Numbering

Follow semantic versioning:
- **Major**: 1.x.x (Breaking changes)
- **Minor**: x.1.x (New features)  
- **Patch**: x.x.1 (Bug fixes)

Build numbers should increment with each release.

## 🛠️ Troubleshooting

**Update check fails:**
- Verify Render backend is running
- Check network connectivity
- Review backend logs

**Download fails:**
- Verify GitHub release URL
- Check APK file accessibility
- Review download permissions

**Installation fails:**
- Ensure install permissions granted
- Check APK file integrity
- Review device storage space

---

Your users will now receive automatic update notifications whenever you deploy a new version! 🎉