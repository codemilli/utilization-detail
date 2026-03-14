# UtilizationDetail

## Release Rules

- Do not create GitHub Releases manually from local build artifacts unless the user explicitly requests a one-off manual release.
- Standard release flow is tag-driven via GitHub Actions and should produce a signed, notarized, stapled app when Apple credentials are configured.
- To publish a release, ensure the working tree is clean, then run:
  - `./Scripts/release_tag.sh vX.Y.Z`
- Do not upload files from `Build/` or `ReleaseAssets/` directly when the automated workflow can produce the same release.
- If release automation changes, update:
  - `.github/workflows/release.yml`
  - `Scripts/package_release.sh`
  - `Scripts/release_tag.sh`
  - `RELEASING.md`

## Build Rules

- Local app bundle build:
  - `./Scripts/build_app.sh`
- Local signed/notarized release package:
  - `./Scripts/package_release.sh vX.Y.Z`
- Local app bundle run:
  - `./Scripts/run_app_bundle.sh`
- Treat `Build/`, `ReleaseAssets/`, and `.build/` as generated artifacts.
