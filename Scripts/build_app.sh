#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="Utilization Detail"
EXECUTABLE_NAME="UtilizationDetailApp"
BUNDLE_NAME="${APP_NAME}.app"
BUILD_ROOT="${ROOT_DIR}/Build"
APP_DIR="${BUILD_ROOT}/${BUNDLE_NAME}"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
PLIST_PATH="${CONTENTS_DIR}/Info.plist"
APP_VERSION="${APP_VERSION:-0.1.0}"
APP_BUILD_NUMBER="${APP_BUILD_NUMBER:-1}"
CODE_SIGN_IDENTITY="${CODESIGN_IDENTITY:-}"

cd "${ROOT_DIR}"

swift Scripts/GenerateAppIcon.swift >/dev/null
swift build -c release >/dev/null

BIN_DIR="$(swift build -c release --show-bin-path)"
EXECUTABLE_PATH="${BIN_DIR}/${EXECUTABLE_NAME}"
RESOURCE_BUNDLE_PATH="${BIN_DIR}/UtilizationDetail_UtilizationDetailApp.bundle"
ICON_PATH="${BUILD_ROOT}/AppIcon.icns"

if [[ ! -f "${EXECUTABLE_PATH}" ]]; then
  echo "Missing executable at ${EXECUTABLE_PATH}" >&2
  exit 1
fi

if [[ ! -d "${RESOURCE_BUNDLE_PATH}" ]]; then
  echo "Missing resource bundle at ${RESOURCE_BUNDLE_PATH}" >&2
  exit 1
fi

mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp "${EXECUTABLE_PATH}" "${MACOS_DIR}/${EXECUTABLE_NAME}"
cp -R "${RESOURCE_BUNDLE_PATH}" "${RESOURCES_DIR}/"
cp "${ICON_PATH}" "${RESOURCES_DIR}/AppIcon.icns"

cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>UtilizationDetailApp</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.codemilli.utilizationdetail</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Utilization Detail</string>
    <key>CFBundleDisplayName</key>
    <string>Utilization Detail</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${APP_BUILD_NUMBER}</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

chmod +x "${MACOS_DIR}/${EXECUTABLE_NAME}"

if [[ -n "${CODE_SIGN_IDENTITY}" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "${CODE_SIGN_IDENTITY}" "${APP_DIR}"
else
  codesign --force --deep --sign - "${APP_DIR}"
fi

codesign --verify --deep --strict --verbose=2 "${APP_DIR}"

echo "Built app bundle:"
echo "${APP_DIR}"
