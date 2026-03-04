// Generates a Markdown summary from Periphery dead code detection output.
//
// Input (environment variables):
//   PERIPHERY_OUTPUT  — raw Periphery output (may contain ANSI escape codes)
//
// Output: Markdown body written to stdout.

const raw = process.env.PERIPHERY_OUTPUT || '';
const output = raw.replace(/\x1b\[[0-9;]*m/g, '');

const diagnosticRegex = /^(.+?):(\d+):(\d+):\s+warning:\s+(.+)$/gm;
const findings = [];
let match;
while ((match = diagnosticRegex.exec(output)) !== null) {
    findings.push({
        file: match[1],
        line: match[2],
        description: match[4]
    });
}

let body;
if (findings.length === 0) {
    body = [
        '## Periphery \u2014 Dead code detection',
        '',
        ':white_check_mark: No unused code detected.'
    ].join('\n');
} else {
    const rows = findings.map(f => {
        const shortFile = f.file.replace(/^.*?(?=Features\/|Sources\/|Tests\/)/, '');
        return `| :warning: | \`${shortFile}\` | ${f.line} | ${f.description} |`;
    });

    body = [
        '## Periphery \u2014 Dead code detection',
        '',
        `Found **${findings.length}** unused code occurrence(s):`,
        '',
        '| | File | Line | Description |',
        '|---|------|------|-------------|',
        ...rows
    ].join('\n');
}

process.stdout.write(body);
