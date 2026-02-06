# Continuous Integration

The project uses [GitHub Actions](https://github.com/features/actions) to run quality checks on every pull request targeting `main` and on-demand via manual trigger.

## Workflow Overview

### Triggers

| Trigger | When |
|---------|------|
| `pull_request` | Automatically on every PR targeting `main` |
| `workflow_dispatch` | Manually from **Actions** > **Quality Checks** > **Run workflow** |

### Jobs

The CI workflow (`.github/workflows/quality-checks.yml`) runs three jobs in parallel:

| Job | Runner | Description |
|-----|--------|-------------|
| **Unit & Snapshot Tests** | `macos-15` | Runs unit and snapshot tests, then Periphery dead code detection |
| **UI Tests** | `macos-15` | Runs UI tests with SwiftMockServer |
| **Quality Gate** | `macos-15` | Verifies both test jobs passed, merges coverage data, enforces coverage threshold |

Unit & Snapshot Tests and UI Tests run **in parallel** on separate macOS runners. The Quality Gate job waits for both to complete before reporting the final status.

### Composite Actions

Both test jobs share common steps extracted into reusable composite actions:

| Action | Path | Description |
|--------|------|-------------|
| **Setup** | `.github/actions/setup/` | Select Xcode, install mise tools, cache and install SPM dependencies, generate Xcode project, boot simulator |
| **Test Report** | `.github/actions/test-report/` | Upload `.xcresult` artifact, parse failures into markdown summary, comment on PR |

### Unit & Snapshot Tests Steps

| Step | Description |
|------|-------------|
| Checkout | Clone the repository |
| Setup environment | Composite action: Xcode, mise, caching, SPM, project generation, simulator boot |
| Run unit and snapshot tests | `mise x -- tuist test "Challenge (Dev)"` (15 min timeout) |
| Upload coverage data | Uploads `.xcresult` bundle as artifact for coverage merging (1-day retention) |
| Test report | On failure: composite action that uploads artifact, generates summary, and comments on PR |
| Detect dead code | `mise x -- periphery scan --skip-build` reusing the test build index (informational, never blocks CI) |
| Periphery summary | Parses Periphery output and writes markdown to Actions Summary |
| Comment PR (Periphery) | PR only: posts the Periphery summary as a PR comment |

### UI Tests Steps

| Step | Description |
|------|-------------|
| Checkout | Clone the repository |
| Setup environment | Composite action: Xcode, mise, caching, SPM, project generation, simulator boot |
| Run UI tests | `mise x -- tuist test "ChallengeUITests"` (25 min timeout) |
| Upload coverage data | Uploads `.xcresult` bundle as artifact for coverage merging (1-day retention) |
| Test report | On failure: composite action that uploads artifact, generates summary, and comments on PR |

### Quality Gate

The Quality Gate job runs on `macos-15` (requires Xcode tools for coverage merging) and:

1. **Verifies** both test jobs succeeded
2. **Downloads** coverage artifacts from both test jobs
3. **Merges** the `.xcresult` bundles using `xcrun xcresulttool merge`
4. **Extracts** coverage data using `xcrun xccov view --report --json`
5. **Generates** a coverage report table (per module + total)
6. **Writes** to `GITHUB_STEP_SUMMARY` (visible on every run, including manual triggers)
7. **Comments on PR** (PR trigger only) with the same coverage table
8. **Enforces** a minimum coverage threshold (80%) — the job fails if total coverage is below

This is the required status check for branch protection.

## Feedback Output

Test failures, Periphery results, and code coverage are always written to **`GITHUB_STEP_SUMMARY`**, which is visible in the **Actions** > run > **Summary** tab regardless of the trigger. When the workflow is triggered by a pull request, the same content is also posted as a PR comment.

| Output | Trigger | Where |
|--------|---------|-------|
| `GITHUB_STEP_SUMMARY` | PR + Manual | Actions > run > Summary |
| PR comment | PR only | Pull request conversation |

## Code Coverage

Coverage data is collected from both test jobs and merged in the Quality Gate job to produce a unified report. The report includes per-module line coverage and a total. Only source framework targets are included (test bundles and mocks are excluded).

The minimum coverage threshold is **80%**. If total coverage falls below this value, the Quality Gate fails and the PR cannot be merged.

| Config | Value |
|--------|-------|
| Threshold | 80% (configurable via `COVERAGE_THRESHOLD` env var in workflow) |
| Merge tool | `xcrun xcresulttool merge` |
| Report tool | `xcrun xccov view --report --json` |
| Included targets | `*.framework` (excluding `*Mock*`, `*Test*`) |

## Test Failure Artifacts

When tests fail, the corresponding job:

1. **Uploads the `.xcresult` bundle** as a GitHub artifact (`unit-snapshot-results` or `ui-test-results`), retained for 7 days
2. **Writes a summary** to the Actions Summary tab with a table of failed tests and a download link
3. **Posts a PR comment** (PR trigger only) with the same content

<img src="screenshots/test-failure-comment.png" width="100%">

The artifact uploads the `test_output` directory (not the bundle itself) so that the `.xcresult` directory name is preserved when extracted from the zip. To inspect failures, download the artifact, extract it, and open the `.xcresult` file in Xcode.

## Periphery Results

Periphery runs with `continue-on-error: true` in the Unit & Snapshot Tests job so it never blocks the pipeline. After execution, the workflow parses the output and writes a summary to the Actions Summary tab with:

- A table of unused code occurrences (file, line, description)
- If no issues are found, a success message

When triggered by a PR, the same summary is posted as a PR comment.

<img src="screenshots/periphery-comment.png" width="100%">

## GitHub Configuration

After pushing the workflow file, configure the repository:

### 1. Workflow Permissions (required for private repos)

1. Go to **Settings** > **Actions** > **General**
2. Under **Workflow permissions**, select **Read and write permissions**
3. Save

### 2. Branch Ruleset

1. Go to **Settings** > **Rules** > **Rulesets**
2. Click **New ruleset** > **New branch ruleset**
3. Configure:

| Field | Value |
|-------|-------|
| Ruleset name | `Protect main` |
| Enforcement status | `Active` |
| Target branches | **Add a target** > **Include default branch** |

4. Enable the following rules:

| Rule | Setting |
|------|---------|
| **Restrict deletions** | Enabled |
| **Require a pull request before merging** | Enabled |
| -- Required approvals | `1` |
| -- Dismiss stale approvals on new commits | Enabled |
| -- Require conversation resolution | Enabled |
| **Require status checks to pass** | Enabled |
| -- Status check | `Quality Gate` (type the name and click **+**) |
| -- Require branches to be up to date | Enabled |
| **Block force pushes** | Enabled |

5. Click **Create**

> **Note:** The `Quality Gate` status check will only appear after the workflow has run at least once. Create a test PR to trigger the first execution before configuring the ruleset.

## Design Decisions

- **Composite actions**: Shared setup steps (Xcode selection, mise, caching, SPM dependencies, project generation, simulator boot) and test reporting steps (artifact upload, failure summary, PR comment) are extracted into reusable composite actions (`.github/actions/setup/` and `.github/actions/test-report/`). This eliminates duplication between the unit+snapshot and UI test jobs. The `if: failure()` condition is applied to the step that invokes the test-report action in the workflow, since composite action steps inherit the job's failure state.
- **Parallel jobs**: Unit+snapshot tests and UI tests run in separate macOS jobs to reduce total CI time. Total time = `max(unit+snapshot, UI)` instead of `sum()`.
- **Quality Gate**: A `macos-15` job aggregates results from both test jobs, merges coverage data, and enforces the coverage threshold. It uses macOS because `xcresulttool merge` and `xccov` require Xcode tools. This is the single required status check for branch protection.
- **Coverage merging**: Both test jobs upload their `.xcresult` bundles as artifacts (1-day retention). The Quality Gate downloads and merges them with `xcresulttool merge` to produce accurate line-level coverage union, then extracts the report with `xccov`.
- **Periphery in unit tests job**: Periphery reuses the index store from the test build, so it runs in the same job as unit+snapshot tests.
- **Concurrency group**: Concurrent runs on the same branch are cancelled automatically, saving CI minutes.
- **Step summaries**: Test failures and Periphery results write to `GITHUB_STEP_SUMMARY` so feedback is visible on every run. PR comment steps reuse the summary output instead of duplicating markdown generation logic.
- **Manual trigger**: `workflow_dispatch` allows running the full pipeline without creating a PR. PR-specific steps (comments) are skipped automatically.
- **Test timeout**: Unit+snapshot tests have a 15-minute timeout; UI tests have a 25-minute timeout to prevent frozen tests from blocking the pipeline.
- **Simulator preparation**: The target simulator is shut down and re-booted before tests to prevent "Application failed preflight checks" errors caused by stale simulator state. For local development, if the simulator becomes corrupted, use `./reset-simulators.sh` (see [Scripts](Scripts.md#reset-simulators-script)).
