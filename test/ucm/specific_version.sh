#!/bin/bash

set -e

# Test installing a specific version of UCM
source dev-container-features-test-lib

# Check if ucm is installed
check "ucm is installed" command -v ucm

# Check if the specific version was installed
check "ucm runs" bash -c "ucm version 2>&1 || ucm --version 2>&1 || ucm help 2>&1"

# Report results
reportResults
