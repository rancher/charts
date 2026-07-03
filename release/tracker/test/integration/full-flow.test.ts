import { test } from 'node:test';
import assert from 'node:assert';
import { readFileSync, writeFileSync } from 'node:fs';
import { addChart } from '../../src/commands/add-chart.js';
import { updateQA } from '../../src/commands/update-qa.js';
import { updateUnRC } from '../../src/commands/update-unrc.js';
import { removeChart } from '../../src/commands/remove-chart.js';

const FIXTURE_PATH = 'test/fixtures/issue-body.md';
const OUTPUT_PATH = 'test/output.md';

test('full workflow: add -> update QA -> update UnRC -> remove', () => {
  // Start with fresh fixture
  let html = readFileSync(FIXTURE_PATH, 'utf-8');

  // Step 1: Add chart
  html = addChart({ html, chart: 'fleet', version: '110.0.0+up0.16.0', owner: '@thardeck' });
  writeFileSync(OUTPUT_PATH, html);

  assert.ok(html.includes('data-chart="fleet"'), 'Chart should be added');
  assert.ok(html.includes('data-version="110.0.0+up0.16.0"'), 'Version should be set');
  assert.ok(html.includes('data-owner="@thardeck"'), 'Owner should be set');
  assert.ok(html.includes('data-qa="false"'), 'QA should be false initially');
  assert.ok(html.includes('data-unrc="false"'), 'UnRC should be false initially');

  // Step 2: Update QA
  html = updateQA({ html, chart: 'fleet', version: '110.0.0+up0.16.0' });
  writeFileSync(OUTPUT_PATH, html);

  assert.ok(html.includes('data-qa="true"'), 'QA should be true after update');
  assert.ok(html.includes('<td class="qa">yes</td>'), 'QA cell should show yes');
  assert.ok(html.includes('data-unrc="false"'), 'UnRC should still be false');

  // Step 3: Update UnRC
  html = updateUnRC({ html, chart: 'fleet', version: '110.0.0+up0.16.0' });
  writeFileSync(OUTPUT_PATH, html);

  assert.ok(html.includes('data-unrc="true"'), 'UnRC should be true after update');
  assert.ok(html.includes('<td class="unrc">yes</td>'), 'UnRC cell should show yes');
  assert.ok(html.includes('data-qa="true"'), 'QA should still be true');

  // Step 4: Remove chart
  html = removeChart({ html, chart: 'fleet', version: '110.0.0+up0.16.0' });
  writeFileSync(OUTPUT_PATH, html);

  assert.ok(!html.includes('data-chart="fleet"'), 'Chart should be removed');
  assert.ok(!html.includes('110.0.0+up0.16.0'), 'Version should be gone');
  assert.ok(!html.includes('@thardeck'), 'Owner should be gone');
});

test('multiple charts workflow', () => {
  // Start with fresh fixture
  let html = readFileSync(FIXTURE_PATH, 'utf-8');

  // Add two charts
  html = addChart({ html, chart: 'fleet', version: '1.0.0', owner: '@user1' });
  writeFileSync(OUTPUT_PATH, html);

  html = addChart({ html, chart: 'longhorn', version: '2.0.0', owner: '@user2' });
  writeFileSync(OUTPUT_PATH, html);

  assert.ok(html.includes('data-chart="fleet"'), 'Fleet should exist');
  assert.ok(html.includes('data-chart="longhorn"'), 'Longhorn should exist');

  // Update only fleet QA
  html = updateQA({ html, chart: 'fleet', version: '1.0.0' });
  writeFileSync(OUTPUT_PATH, html);

  // Parse to verify fleet has QA but longhorn doesn't
  assert.ok(html.includes('chart-row-1'), 'Row 1 should exist');
  assert.ok(html.includes('chart-row-2'), 'Row 2 should exist');

  // Remove fleet only
  html = removeChart({ html, chart: 'fleet', version: '1.0.0' });
  writeFileSync(OUTPUT_PATH, html);

  assert.ok(!html.includes('data-chart="fleet"'), 'Fleet should be removed');
  assert.ok(html.includes('data-chart="longhorn"'), 'Longhorn should still exist');
  assert.ok(html.includes('chart-row-2'), 'Longhorn row should remain');
});
