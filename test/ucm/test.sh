#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]

# Check if ucm is installed and accessible
check "ucm is installed" command -v ucm

# Check ucm version (this also verifies it runs correctly)
check "ucm runs" bash -c "ucm version 2>&1 || ucm --version 2>&1 || ucm help 2>&1"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
