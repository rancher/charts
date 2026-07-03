import { test } from 'node:test';
import assert from 'node:assert';
import { updateQA } from '../../src/commands/update-qa.js';
import { Errors } from '../../src/utils/errors.js';

const emptyTableHTML = `
<table>
<tr>
  <th>Chart</th>
  <th>Version</th>
  <th>Team</th>
  <th>Chart Owner</th>
  <th>QA</th>
  <th>UnRC</th>
</tr>
<!-- BEGIN: CHART_DATA -->

<!-- END: CHART_DATA -->
</table>
`;

const tableWithChart = `
<table>
<!-- BEGIN: CHART_DATA -->
<tr id="chart-row-1" data-chart="fleet" data-version="1.0.0" data-team="" data-owner="@user" data-qa="false" data-unrc="false">
  <td class="chart">fleet</td>
  <td class="version">1.0.0</td>
  <td class="team"></td>
  <td class="owner">@user</td>
  <td class="qa"></td>
  <td class="unrc"></td>
</tr>
<!-- END: CHART_DATA -->
</table>
`;

test('updateQA - throws when table not found', () => {
  assert.throws(
    () => updateQA({ html: '<div>no table</div>', chart: 'fleet', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.tableNotFound());
      return true;
    }
  );
});

test('updateQA - throws when chart not found in empty table', () => {
  assert.throws(
    () => updateQA({ html: emptyTableHTML, chart: 'fleet', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('fleet', '1.0.0'));
      return true;
    }
  );
});

test('updateQA - throws when chart not found (wrong name)', () => {
  assert.throws(
    () => updateQA({ html: tableWithChart, chart: 'longhorn', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('longhorn', '1.0.0'));
      return true;
    }
  );
});

test('updateQA - throws when chart not found (wrong version)', () => {
  assert.throws(
    () => updateQA({ html: tableWithChart, chart: 'fleet', version: '2.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('fleet', '2.0.0'));
      return true;
    }
  );
});

test('updateQA - updates QA status successfully', () => {
  const result = updateQA({
    html: tableWithChart,
    chart: 'fleet',
    version: '1.0.0'
  });

  assert.ok(result.includes('data-qa="true"'));
  assert.ok(result.includes('<td class="qa">yes</td>'));
});

test('updateQA - does not modify other attributes', () => {
  const result = updateQA({
    html: tableWithChart,
    chart: 'fleet',
    version: '1.0.0'
  });

  // Other attributes should remain unchanged
  assert.ok(result.includes('data-chart="fleet"'));
  assert.ok(result.includes('data-version="1.0.0"'));
  assert.ok(result.includes('data-unrc="false"'));
  assert.ok(result.includes('chart-row-1'));
});
