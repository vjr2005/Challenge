#!/usr/bin/env python3

# Generates a Markdown summary from xcresult test results.
#
# Input (environment variables):
#   RESULT_BUNDLE_PATH  — path to .xcresult bundle (required)
#   REPORT_TITLE        — markdown heading (required)
#   XCRESULT_URL        — download URL for the artifact (optional)
#
# Output: Markdown body written to stdout. Empty if no failures or retries.

import json
import os
import subprocess
import sys

result_bundle = os.environ['RESULT_BUNDLE_PATH']
xcresult_url = os.environ.get('XCRESULT_URL', '')
title = os.environ['REPORT_TITLE']

if not os.path.isdir(result_bundle):
    sys.exit(0)

result = subprocess.run(
    ['xcrun', 'xcresulttool', 'get', 'test-results', 'tests',
     '--path', result_bundle],
    capture_output=True, text=True
)
if result.returncode != 0:
    sys.exit(0)

data = json.loads(result.stdout)
failures = []
retried = []


def walk(node, parts):
    name = node.get('name', '')
    node_type = node.get('nodeType', '')

    if node_type in ('Test Plan', 'Unit test bundle', 'UI test bundle'):
        for child in node.get('children', []):
            walk(child, [])
        return

    if node_type == 'Test Suite':
        for child in node.get('children', []):
            walk(child, parts + [name] if name else parts)
        return

    current = parts + [name] if name else parts

    if node_type == 'Test Case':
        children = node.get('children', [])
        runs = [c for c in children if c.get('result') in ('Passed', 'Failed')]
        if runs:
            failed_runs = [r for r in runs if r.get('result') == 'Failed']
            if failed_runs:
                retried.append({
                    'test': '/'.join(current),
                    'attempts': len(runs),
                    'failed_attempts': len(failed_runs),
                    'final_result': node.get('result', 'Unknown')
                })
        if node.get('result') == 'Failed':
            failures.append('/'.join(current))
        return

    for child in node.get('children', []):
        walk(child, current)


for node in data.get('testNodes', []):
    walk(node, [])

if not failures and not retried:
    sys.exit(0)

lines = [f'## {title}', '']

if failures:
    lines += [':x: **Tests failed.**', '', '| | Test |', '|---|------|']
    lines += [f'| :x: | `{f}` |' for f in failures]
    lines.append('')

if retried:
    if failures:
        lines.append('### Retried Tests')
        lines.append('')
    lines += [
        f':warning: **{len(retried)} test(s) required retry:**',
        '',
        '| | Test | Attempts | Result |',
        '|---|------|----------|--------|'
    ]
    for r in retried:
        icon = ':white_check_mark:' if r['final_result'] == 'Passed' else ':x:'
        lines.append(f"| {icon} | `{r['test']}` | {r['attempts']} | {r['final_result']} |")
    lines += ['', '_These tests failed initially and were retried via `-retry-tests-on-failure`._']

if xcresult_url:
    lines += ['', f':package: [Download xcresult]({xcresult_url})', '',
              '_Open the `.xcresult` file in Xcode to inspect failures._']

body = '\n'.join(lines)
print(body, end='')
