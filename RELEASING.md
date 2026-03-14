# Releasing

## Standard Flow

1. Ensure `main` contains the code you want to ship.
2. Ensure the working tree is clean.
3. Run:

```bash
./Scripts/release_tag.sh vX.Y.Z
```

4. Wait for GitHub Actions `Release` workflow to finish.
5. Verify the GitHub Release contains:
   - `UtilizationDetail-vX.Y.Z-macos-arm64.zip`
   - `UtilizationDetail-vX.Y.Z-macos-arm64.zip.sha256`

## What The Workflow Does

- Builds the macOS app bundle on GitHub Actions
- Creates a ZIP asset from `Utilization Detail.app`
- Generates a SHA-256 checksum file
- Creates or updates the GitHub Release for that tag

## Manual Local Build

```bash
./Scripts/build_app.sh
```

This builds:

- `Build/Utilization Detail.app`

## Notes

- Current automated release target is Apple Silicon macOS.
- The app is not notarized.
- First launch on another Mac may require right-click > Open.
