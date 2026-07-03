#!/usr/bin/env node
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { runCommand } from '../src/cli.js';

// Test harness - file-based I/O for local testing
// Use output.md if exists (for chaining commands), else use fixture
const OUTPUT_FILE = 'test/output.md';
let INPUT_FILE = 'test/fixtures/issue-body.md';

if (existsSync(OUTPUT_FILE)) {
  INPUT_FILE = OUTPUT_FILE;
}

const args = process.argv.slice(2);
const command = args[0];
const commandArgs = args.slice(1);

const input = readFileSync(INPUT_FILE, 'utf-8');
const result = runCommand(command, input, commandArgs);

writeFileSync(OUTPUT_FILE, result);
console.log(`Updated ${OUTPUT_FILE}`);
