#!/bin/zsh

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ./Scripts/package_release.sh v0.1.1" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TAG_NAME="$1"
VERSION="${TAG_NAME#v}"
BUILD_ROOT="${ROOT_DIR}/Build"
APP_PATH="${BUILD_ROOT}/Utilization Detail.app"
RELEASE_DIR="${ROOT_DIR}/ReleaseAssets"
ARCH="$(uname -m)"
ZIP_PATH="${RELEASE_DIR}/UtilizationDetail-${TAG_NAME}-macos-${ARCH}.zip"
SHA_PATH="${ZIP_PATH}.sha256"
ENABLE_NOTARIZATION="${ENABLE_NOTARIZATION:-0}"
NOTARY_KEY_PATH="${APPLE_NOTARY_KEY_PATH:-}"
NOTARY_KEY_ID="${APPLE_NOTARY_KEY_ID:-}"
NOTARY_ISSUER_ID="${APPLE_NOTARY_ISSUER_ID:-}"

mkdir -p "${RELEASE_DIR}"

cd "${ROOT_DIR}"

APP_VERSION="${VERSION}" \
APP_BUILD_NUMBER="${GITHUB_RUN_NUMBER:-1}" \
./Scripts/build_app.sh >/dev/null

if [[ "${ENABLE_NOTARIZATION}" == "1" ]]; then
  if [[ -z "${CODESIGN_IDENTITY:-}" ]]; then
    echo "CODESIGN_IDENTITY is required when notarization is enabled." >&2
    exit 1
  fi

  if [[ -z "${NOTARY_KEY_PATH}" || -z "${NOTARY_KEY_ID}" || -z "${NOTARY_ISSUER_ID}" ]]; then
    echo "Apple notary credentials are required when notarization is enabled." >&2
    exit 1
  fi

  TEMP_ZIP="${RELEASE_DIR}/pre-notarize-${TAG_NAME}-${ARCH}.zip"
  ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${TEMP_ZIP}"

  xcrun notarytool submit "${TEMP_ZIP}" \
    --key "${NOTARY_KEY_PATH}" \
    --key-id "${NOTARY_KEY_ID}" \
    --issuer "${NOTARY_ISSUER_ID}" \
    --wait

  xcrun stapler staple "${APP_PATH}"
  xcrun stapler validate "${APP_PATH}"
fi

ditto -c -k --sequesterRsrc --keepParent "${APP_PATH}" "${ZIP_PATH}"
shasum -a 256 "${ZIP_PATH}" > "${SHA_PATH}"

echo "Created release assets:"
echo "${ZIP_PATH}"
echo "${SHA_PATH}"
