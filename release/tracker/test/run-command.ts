#!/usr/bin/env node
import { readFileSync, existsSync } from 'fs';
import { execSync } from 'child_process';

// Test harness - simulates GHA comment-driven workflow locally
// Usage: npm run dev "ToRelease: fleet 110.0.0"

const OUTPUT_FILE = 'test/output.md';
let INPUT_FILE = 'test/fixtures/issue-body.md';

if (existsSync(OUTPUT_FILE)) {
  INPUT_FILE = OUTPUT_FILE;
}

const args = process.argv.slice(2);
const commentBody = args[0];

if (!commentBody) {
  console.error('Usage: npm run dev "<comment-body>"');
  console.error('Examples:');
  console.error('  npm run dev "ToRelease: fleet 110.0.0"');
  console.error('  npm run dev "QA: fleet 110.0.0"');
  console.error('  npm run dev "UnRC: fleet 110.0.0"');
  process.exit(1);
}

const issueBody = readFileSync(INPUT_FILE, 'utf-8');

// Call CLI with flags
execSync(`npx tsx src/cli.ts --issue-body "${issueBody.replace(/"/g, '\\"')}" --comment-body "${commentBody}" --comment-user "testuser"`, {
  stdio: 'inherit',
  cwd: process.cwd()
});
