# Utilization Detail

Native macOS CPU utilization monitor for Apple Silicon.

## What It Does

- Shows per-core utilization in a native SwiftUI dashboard
- Groups cores by tier
- Builds as a standalone `.app` bundle
- Publishes signed and notarized GitHub Releases through a tag-driven workflow

## Project Structure

- `Sources/UtilizationDetailApp`
  - app entry, models, telemetry, views
- `Scripts`
  - icon generation, app bundle build, release packaging, release tagging
- `.github/workflows/release.yml`
  - automated GitHub Release pipeline

## Local Development

Run tests:

```bash
swift test
```

Build the local app bundle:

```bash
./Scripts/build_app.sh
```

Run the built app bundle:

```bash
./Scripts/run_app_bundle.sh
```

This produces:

- `Build/Utilization Detail.app`

## Install

Copy the built app into `Applications`:

```bash
cp -R "Build/Utilization Detail.app" /Applications/
```

Or install for the current user:

```bash
mkdir -p ~/Applications
cp -R "Build/Utilization Detail.app" ~/Applications/
```

## Release Flow

Standard release flow is tag-driven.

Create a release tag:

```bash
./Scripts/release_tag.sh v0.1.1
```

That tag triggers GitHub Actions to:

- build the macOS app bundle
- sign with Developer ID
- notarize with Apple notary service
- staple the notarization ticket
- create a ZIP asset
- generate a SHA-256 checksum
- create or update the GitHub Release

## GitHub Secrets For Release

Configure these repository secrets before using automated notarized releases:

- `APPLE_SIGNING_CERT_BASE64`
- `APPLE_SIGNING_CERT_PASSWORD`
- `APPLE_DEVELOPER_IDENTITY`
- `APPLE_NOTARY_API_KEY_BASE64`
- `APPLE_NOTARY_KEY_ID`
- `APPLE_NOTARY_ISSUER_ID`

## Docs

- Human release procedure: [RELEASING.md](./RELEASING.md)
- Agent rules: [AGENTS.md](./AGENTS.md)

## Notes

- Current automated release target is Apple Silicon macOS.
- Signed/notarized releases require Apple Developer credentials to be configured in GitHub secrets.
