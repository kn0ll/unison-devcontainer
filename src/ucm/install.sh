#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------------------
# Copyright (c) The Dev Container Feature Authors. All rights reserved.
# Licensed under the MIT License. See LICENSE for license information.
#-------------------------------------------------------------------------------------------------------------------------
#
# Docs: https://www.unison-lang.org/docs/install-instructions/
# Maintainer: Dev Container Feature Contributors
#
# Syntax: ./install.sh

set -e

UCM_VERSION="${VERSION:-"latest"}"
UCM_HOME="${UCM_HOME:-"/usr/local/share/unison"}"

# Logging functions
echo_log() { echo -e "\e[32m[unison-ucm]\e[0m $1"; }
echo_error() { echo -e "\e[31m[unison-ucm] ERROR:\e[0m $1" >&2; }

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo_error 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Detect architecture
architecture="$(uname -m)"
case "${architecture}" in
    x86_64) arch="x64" ;;
    aarch64 | arm64) arch="arm64" ;;
    *)
        echo_error "Unsupported architecture: ${architecture}. UCM supports x64 and arm64 only."
        exit 1
        ;;
esac

# Detect OS
os="$(uname -s)"
case "${os}" in
    Linux) os_name="linux" ;;
    Darwin) os_name="macos" ;;
    *)
        echo_error "Unsupported OS: ${os}. UCM supports Linux and macOS only."
        exit 1
        ;;
esac

# Determine package manager and install dependencies
apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        echo_log "Running apt-get update..."
        apt-get update -y
    fi
}

check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

install_debian_dependencies() {
    echo_log "Installing dependencies for Debian/Ubuntu..."
    check_packages curl ca-certificates tar gzip
}

install_rhel_dependencies() {
    echo_log "Installing dependencies for RHEL/Fedora..."
    if command -v dnf > /dev/null 2>&1; then
        dnf install -y curl ca-certificates tar gzip
    elif command -v yum > /dev/null 2>&1; then
        yum install -y curl ca-certificates tar gzip
    elif command -v microdnf > /dev/null 2>&1; then
        microdnf install -y curl ca-certificates tar gzip
    fi
}

install_alpine_dependencies() {
    echo_log "Installing dependencies for Alpine..."
    apk add --no-cache curl ca-certificates tar gzip libc6-compat
}

# Detect distro and install dependencies
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "${ID}" in
        debian | ubuntu | linuxmint | pop) install_debian_dependencies ;;
        rhel | centos | fedora | rocky | alma | ol) install_rhel_dependencies ;;
        alpine) install_alpine_dependencies ;;
        *)
            echo_log "Unknown distro: ${ID}. Attempting Debian-style dependency installation..."
            install_debian_dependencies || true
            ;;
    esac
elif [ "${os_name}" = "darwin" ]; then
    echo_log "Running on macOS - dependencies should be available."
else
    echo_log "Could not detect OS. Attempting to continue..."
fi

# Create UCM home directory
mkdir -p "${UCM_HOME}"
mkdir -p /usr/local/bin

# Resolve version to download
get_latest_version() {
    local latest_release
    latest_release=$(curl -fsSL "https://api.github.com/repos/unisonweb/unison/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    # Remove 'release/' prefix if present
    echo "${latest_release}" | sed 's|release/||'
}

if [ "${UCM_VERSION}" = "latest" ]; then
    echo_log "Fetching latest UCM version..."
    UCM_VERSION=$(get_latest_version)
    echo_log "Latest version is: ${UCM_VERSION}"
fi

# Construct download URL
# Unison releases follow the pattern: ucm-<os>-<arch>.tar.gz
# https://github.com/unisonweb/unison/releases/download/release%2F<version>/ucm-<os>-<arch>.tar.gz
DOWNLOAD_URL="https://github.com/unisonweb/unison/releases/download/release%2F${UCM_VERSION}/ucm-${os_name}-${arch}.tar.gz"

echo_log "Downloading UCM ${UCM_VERSION} for ${os_name}-${arch}..."
echo_log "Download URL: ${DOWNLOAD_URL}"

# Download and extract
TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

if ! curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/ucm.tar.gz"; then
    echo_error "Failed to download UCM. Please check if version ${UCM_VERSION} exists for ${os_name}-${arch}."
    echo_error "Available releases can be found at: https://github.com/unisonweb/unison/releases"
    exit 1
fi

echo_log "Extracting UCM..."
tar -xzf "${TMP_DIR}/ucm.tar.gz" -C "${TMP_DIR}"

# Debug: show archive contents
echo_log "Archive contents:"
find "${TMP_DIR}" -type f | head -20

# The UCM archive structure:
# - unison/unison (the main binary)
# - ui/ (web UI assets)
# We need to copy everything to /usr/local/bin/ preserving the structure

# Create the installation directory
mkdir -p /usr/local/bin/unison
mkdir -p "${UCM_HOME}"

# Copy all extracted contents to /usr/local/bin/
# The archive extracts to TMP_DIR with unison/ and ui/ subdirectories
echo_log "Installing UCM files..."

# Copy the unison directory (contains the main binary)
if [ -d "${TMP_DIR}/unison" ]; then
    cp -r "${TMP_DIR}/unison"/* /usr/local/bin/unison/
    echo_log "Copied unison binary to /usr/local/bin/unison/"
fi

# Copy the ui directory if present
if [ -d "${TMP_DIR}/ui" ]; then
    mkdir -p /usr/local/bin/ui
    cp -r "${TMP_DIR}/ui"/* /usr/local/bin/ui/
    echo_log "Copied UI assets to /usr/local/bin/ui/"
fi

# Make binaries executable
chmod +x /usr/local/bin/unison/unison 2>/dev/null || true

# Create the ucm command as a symlink to the unison binary
if [ -f "/usr/local/bin/unison/unison" ]; then
    ln -sf /usr/local/bin/unison/unison /usr/local/bin/ucm
    echo_log "Created symlink /usr/local/bin/ucm -> /usr/local/bin/unison/unison"
else
    echo_error "Unison binary not found in extracted contents"
    echo_log "Contents of /usr/local/bin/unison:"
    ls -la /usr/local/bin/unison/
    exit 1
fi

# Also copy to UCM_HOME for consistency
cp -r /usr/local/bin/unison/* "${UCM_HOME}/" 2>/dev/null || true
if [ -d "/usr/local/bin/ui" ]; then
    cp -r /usr/local/bin/ui "${UCM_HOME}/" 2>/dev/null || true
fi# Also copy to UCM_HOME for consistency
cp -r /usr/local/bin/unison/* "${UCM_HOME}/" 2>/dev/null || true

# Verify installation
if command -v ucm > /dev/null 2>&1; then
    echo_log "UCM installed successfully!"
    ucm version 2>/dev/null || ucm --version 2>/dev/null || echo_log "UCM is installed (version check may require different arguments)"
else
    echo_error "UCM installation failed - binary not found in PATH."
    exit 1
fi

echo_log "Installation complete. UCM is available at: $(which ucm)"
echo_log "UCM home directory: ${UCM_HOME}"
