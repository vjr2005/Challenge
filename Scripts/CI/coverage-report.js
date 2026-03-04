// Generates a JSON coverage report from xcresult coverage data.
//
// Input (environment variables):
//   MERGE_OK             — "true" or "false"
//   THRESHOLD            — minimum coverage percentage (e.g., "80")
//   COVERAGE_FILE        — path to merged coverage.json (when MERGE_OK=true)
//   UNIT_COVERAGE_FILE   — path to unit-coverage.json (when MERGE_OK=false)
//   UI_COVERAGE_FILE     — path to ui-coverage.json (when MERGE_OK=false)
//   DOWNLOAD_URL_MERGED  — artifact URL for merged xcresult
//   DOWNLOAD_URL_UNIT    — artifact URL for unit xcresult
//   DOWNLOAD_URL_UI      — artifact URL for UI xcresult
//
// Output: JSON to stdout with fields: body (markdown), total (string), passed (boolean).

const fs = require('fs');

const THRESHOLD = parseInt(process.env.THRESHOLD, 10);
const mergeOk = process.env.MERGE_OK === 'true';

// --- Load coverage targets ---
let targets;
if (mergeOk) {
    const report = JSON.parse(fs.readFileSync(process.env.COVERAGE_FILE, 'utf8'));
    targets = report.targets;
} else {
    // Merge coverage at file level from both reports
    const unitReport = JSON.parse(fs.readFileSync(process.env.UNIT_COVERAGE_FILE, 'utf8'));
    const uiReport = JSON.parse(fs.readFileSync(process.env.UI_COVERAGE_FILE, 'utf8'));

    const targetMap = new Map();
    for (const report of [unitReport, uiReport]) {
        for (const target of report.targets) {
            if (!targetMap.has(target.name)) {
                targetMap.set(target.name, new Map());
            }
            const fileMap = targetMap.get(target.name);
            for (const file of (target.files || [])) {
                const key = file.path || file.name;
                const existing = fileMap.get(key);
                if (!existing || file.coveredLines > existing.coveredLines) {
                    fileMap.set(key, {
                        coveredLines: file.coveredLines,
                        executableLines: file.executableLines,
                    });
                }
            }
        }
    }

    targets = [];
    for (const [name, fileMap] of targetMap) {
        let coveredLines = 0;
        let executableLines = 0;
        for (const f of fileMap.values()) {
            coveredLines += f.coveredLines;
            executableLines += f.executableLines;
        }
        const lineCoverage = executableLines > 0 ? coveredLines / executableLines : 0;
        targets.push({ name, coveredLines, executableLines, lineCoverage });
    }
}

// --- Filter targets ---
const filtered = targets.filter(t => {
    const name = t.name.replace(/\.(framework|app|o)$/, '');
    return !name.includes('Mock') &&
        !name.includes('Test') &&
        !name.includes('SnapshotTestKit') &&
        name !== 'SnapshotTesting';
});

let totalCovered = 0;
let totalExecutable = 0;

const rows = filtered
    .sort((a, b) => a.name.localeCompare(b.name))
    .map(t => {
        totalCovered += t.coveredLines;
        totalExecutable += t.executableLines;
        const pct = (t.lineCoverage * 100).toFixed(1);
        const icon = parseFloat(pct) >= THRESHOLD ? ':white_check_mark:' : ':x:';
        const name = t.name.replace(/\.(framework|app|o)$/, '');
        return `| ${icon} | ${name} | ${t.coveredLines} / ${t.executableLines} | ${pct}% |`;
    });

const totalPct = totalExecutable > 0
    ? (totalCovered / totalExecutable * 100)
    : 0;
const totalIcon = totalPct >= THRESHOLD ? ':white_check_mark:' : ':x:';

// --- Download links ---
let downloadSection;
if (mergeOk) {
    downloadSection = `:package: [Download xcresult](${process.env.DOWNLOAD_URL_MERGED})`;
} else {
    downloadSection = [
        `:package: [Unit+Snapshot xcresult](${process.env.DOWNLOAD_URL_UNIT})`,
        `:package: [UI Tests xcresult](${process.env.DOWNLOAD_URL_UI})`,
    ].join('\n');
}

const body = [
    '## Code Coverage',
    '',
    '| | Module | Lines | Coverage |',
    '|---|--------|-------|----------|',
    ...rows,
    `| **${totalIcon}** | **Total** | **${totalCovered} / ${totalExecutable}** | **${totalPct.toFixed(1)}%** |`,
    '',
    `Minimum required: ${THRESHOLD}%`,
    '',
    downloadSection,
].join('\n');

const result = JSON.stringify({
    body,
    total: totalPct.toFixed(1),
    passed: totalPct >= THRESHOLD
});

process.stdout.write(result);
