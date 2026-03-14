# Releasing

## Standard Flow

1. Configure required GitHub repository secrets:
   - `APPLE_SIGNING_CERT_BASE64`
   - `APPLE_SIGNING_CERT_PASSWORD`
   - `APPLE_DEVELOPER_IDENTITY`
   - `APPLE_NOTARY_API_KEY_BASE64`
   - `APPLE_NOTARY_KEY_ID`
   - `APPLE_NOTARY_ISSUER_ID`
2. Ensure `main` contains the code you want to ship.
3. Ensure the working tree is clean.
4. Run:

```bash
./Scripts/release_tag.sh vX.Y.Z
```

5. Wait for GitHub Actions `Release` workflow to finish.
6. Verify the GitHub Release contains:
   - `UtilizationDetail-vX.Y.Z-macos-<arch>.zip`
   - `UtilizationDetail-vX.Y.Z-macos-<arch>.zip.sha256`

## What The Workflow Does

- Builds the macOS app bundle on GitHub Actions
- Signs the app bundle with Developer ID
- Submits the zipped app to Apple notarization
- Staples the notarization ticket back onto the app bundle
- Creates a ZIP asset from `Utilization Detail.app`
- Generates a SHA-256 checksum file
- Creates or updates the GitHub Release for that tag

## Manual Local Build

```bash
./Scripts/build_app.sh
```

This builds:

- `Build/Utilization Detail.app`

## Local Signed Package

```bash
ENABLE_NOTARIZATION=1 \
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
APPLE_NOTARY_KEY_PATH="/path/to/AuthKey_XXXX.p8" \
APPLE_NOTARY_KEY_ID="XXXX" \
APPLE_NOTARY_ISSUER_ID="YYYY" \
./Scripts/package_release.sh vX.Y.Z
```

## Notes

- Current automated release target depends on the GitHub macOS runner architecture.
- For notarization, Apple recommends `notarytool submit --wait` and stapling the app after acceptance.
- Signed/notarized releases depend on valid Apple Developer credentials and a Developer ID Application certificate being available in GitHub Actions.
