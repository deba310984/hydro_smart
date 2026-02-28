#!/usr/bin/env python3
"""
Update version script for HydroSmart app
Use this script to update the app version in backend before deploying
"""

import json
import sys
from datetime import datetime


def update_version(version, build_number, download_url, release_notes, is_forced=False):
    """Update the version constants in app.py"""
    
    # Read the current app.py file
    with open('app.py', 'r') as file:
        content = file.read()
    
    # Create new version configuration
    new_version_config = f'''CURRENT_APP_VERSION = {{
    "version": "{version}",
    "buildNumber": {build_number},
    "downloadUrl": "{download_url}",
    "releaseDate": "{datetime.now().isoformat()}Z",
    "releaseNotes": "{release_notes}",
    "isForced": {str(is_forced).lower()},
    "minSupportedVersion": "1.0.0"
}}'''
    
    # Find and replace the version configuration
    start_marker = "CURRENT_APP_VERSION = {"
    end_marker = "}"
    
    start_index = content.find(start_marker)
    if start_index == -1:
        print("Error: Could not find version configuration in app.py")
        return False
    
    # Find the end of the configuration block
    brace_count = 0
    end_index = start_index
    for i in range(start_index, len(content)):
        if content[i] == '{':
            brace_count += 1
        elif content[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end_index = i + 1
                break
    
    # Replace the configuration
    updated_content = content[:start_index] + new_version_config + content[end_index:]
    
    # Write back to file
    with open('app.py', 'w') as file:
        file.write(updated_content)
    
    print(f"✅ Updated app version to {version} build {build_number}")
    return True


def main():
    if len(sys.argv) < 4:
        print("Usage: python update_version.py <version> <build_number> <download_url> [release_notes] [--forced]")
        print("Example: python update_version.py 1.0.1 2 'https://github.com/user/repo/releases/download/v1.0.1/app.apk' 'Bug fixes and improvements'")
        sys.exit(1)
    
    version = sys.argv[1]
    build_number = int(sys.argv[2])
    download_url = sys.argv[3]
    release_notes = sys.argv[4] if len(sys.argv) > 4 and not sys.argv[4].startswith('--') else "New version available"
    is_forced = '--forced' in sys.argv
    
    success = update_version(version, build_number, download_url, release_notes, is_forced)
    
    if success:
        print("\n🚀 Ready to deploy to Render!")
        print("   git add .")
        print("   git commit -m 'Update app version to v" + version + "'")
        print("   git push origin main")
        print("\nℹ️  Users will be notified of this update within 24 hours.")
        if is_forced:
            print("⚠️  This is a FORCED update - users must install it to continue using the app.")


if __name__ == "__main__":
    main()