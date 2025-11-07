# BCR Presubmit Action

This GitHub Action runs presubmit tests from a `.bcr/presubmit.yml` or `.bazelci/presubmit.yml` file in your repository. It wraps the `bazelci.py` runner to execute the test tasks defined in your presubmit configuration.

## Usage

### Basic Example

Create a workflow file (e.g., `.github/workflows/presubmit.yml`) in your repository:

```yaml
name: Presubmit Tests

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  presubmit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run presubmit tests
        uses: bazelbuild/continuous-integration/actions/bcr-presubmit@master
```

### With Custom Presubmit File

If your presubmit file is in a different location:

```yaml
- name: Run presubmit tests
  uses: bazelbuild/continuous-integration/actions/bcr-presubmit@master
  with:
    presubmit_file: .bcr/presubmit.yml
```

### Running a Specific Task

To run only a specific task from your presubmit.yml:

```yaml
- name: Run presubmit tests
  uses: bazelbuild/continuous-integration/actions/bcr-presubmit@master
  with:
    task: ubuntu2004
```

### Overriding Bazel Version

To use a specific Bazel version (overrides the version in presubmit.yml):

```yaml
- name: Run presubmit tests
  uses: bazelbuild/continuous-integration/actions/bcr-presubmit@master
  with:
    bazel_version: 7.0.0
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|-----------|---------|
| `presubmit_file` | Path to presubmit.yml file | No | Auto-detects `.bcr/presubmit.yml` or `.bazelci/presubmit.yml` |
| `task` | Specific task to run (runs all tasks if not specified) | No | - |
| `bazel_version` | Bazel version to use (overrides presubmit.yml) | No | - |
| `working_directory` | Working directory | No | `.` (repository root) |

## Presubmit File Format

The action expects a presubmit.yml file in YAML format with a `tasks` section. Example:

```yaml
tasks:
  ubuntu2004:
    platform: ubuntu2004
    build_targets:
      - "..."
    test_targets:
      - "..."
  
  macos:
    platform: macos
    build_targets:
      - "..."
```

See the [Bazel CI documentation](https://github.com/bazelbuild/continuous-integration/blob/master/README.md) for the full presubmit.yml format.

## How It Works

1. The action checks out your repository
2. It looks for a presubmit.yml file in this order:
   - The path specified in `presubmit_file` input
   - `.bcr/presubmit.yml`
   - `.bazelci/presubmit.yml`
3. It runs `bazelci.py runner` with the presubmit configuration
4. All tasks in the presubmit.yml are executed (or just the specified task if `task` is provided)

## Requirements

- Your repository must have a `.bcr/presubmit.yml` or `.bazelci/presubmit.yml` file
- The presubmit.yml must follow the Bazel CI configuration format
- Python 3.10+ (automatically set up by the action)

## Using in Your Own Repository

To use this action in your own repository:

1. **Option 1: Reference from this repository** (if it's public)
   ```yaml
   uses: bazelbuild/continuous-integration/actions/bcr-presubmit@master
   ```

2. **Option 2: Copy the action to your repository**
   - Copy the `actions/bcr-presubmit` directory to your repository (e.g., `.github/actions/bcr-presubmit`)
   - Reference it locally:
   ```yaml
   uses: ./.github/actions/bcr-presubmit
   ```

3. **Option 3: Publish as a separate action**
   - Create a new repository for the action
   - Copy the files and publish it
   - Reference it from the new repository

## Differences from BCR Presubmit

This action is a simplified version designed for single ruleset repositories:

- **No module detection**: It doesn't scan for changed modules in a `modules/` directory
- **Direct presubmit.yml execution**: It directly runs the presubmit.yml file from your repository
- **No BCR-specific logic**: It doesn't handle BCR module structure or metadata

If you need the full BCR presubmit functionality (for testing modules in bazel-central-registry), use the original `bcr_presubmit.py` script in Buildkite.

