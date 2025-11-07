#!/bin/bash
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAZELCI_SCRIPT="${ACTION_PATH:-$SCRIPT_DIR}/.bcr-scripts/bazelci.py"

# Ensure we're in the working directory
cd "${WORKING_DIR:-.}"

# Find presubmit.yml file
if [ -n "${PRESUBMIT_FILE:-}" ]; then
    PRESUBMIT_PATH="${PRESUBMIT_FILE}"
elif [ -f ".bcr/presubmit.yml" ]; then
    PRESUBMIT_PATH=".bcr/presubmit.yml"
elif [ -f ".bazelci/presubmit.yml" ]; then
    PRESUBMIT_PATH=".bazelci/presubmit.yml"
else
    echo "::error::No presubmit.yml file found. Expected .bcr/presubmit.yml or .bazelci/presubmit.yml"
    exit 1
fi

echo "::group::Running presubmit tests"
echo "Using presubmit file: ${PRESUBMIT_PATH}"
echo "Working directory: $(pwd)"

# Build bazelci command
BAZELCI_ARGS=(
    "runner"
    "--file_config=${PRESUBMIT_PATH}"
    "--repo_location=$(pwd)"
)

if [ -n "${TASK:-}" ]; then
    BAZELCI_ARGS+=("--task=${TASK}")
fi

if [ -n "${BAZEL_VERSION:-}" ]; then
    BAZELCI_ARGS+=("--overwrite_bazel_version=${BAZEL_VERSION}")
fi

echo "Running: python3 ${BAZELCI_SCRIPT} ${BAZELCI_ARGS[*]}"

# Run the tests
if python3 "${BAZELCI_SCRIPT}" "${BAZELCI_ARGS[@]}"; then
    echo "::endgroup::"
    echo "✅ Presubmit tests passed"
    exit 0
else
    echo "::endgroup::"
    echo "::error::Presubmit tests failed"
    exit 1
fi
