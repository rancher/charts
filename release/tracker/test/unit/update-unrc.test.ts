import { test } from 'node:test';
import assert from 'node:assert';
import { updateUnRC } from '../../src/commands/update-unrc.js';
import { Errors } from '../../src/commands/errors.js';

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

test('updateUnRC - throws when table not found', () => {
  assert.throws(
    () => updateUnRC({ html: '<div>no table</div>', chart: 'fleet', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.tableNotFound());
      return true;
    }
  );
});

test('updateUnRC - throws when chart not found in empty table', () => {
  assert.throws(
    () => updateUnRC({ html: emptyTableHTML, chart: 'fleet', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('fleet', '1.0.0'));
      return true;
    }
  );
});

test('updateUnRC - throws when chart not found (wrong name)', () => {
  assert.throws(
    () => updateUnRC({ html: tableWithChart, chart: 'longhorn', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('longhorn', '1.0.0'));
      return true;
    }
  );
});

test('updateUnRC - throws when chart not found (wrong version)', () => {
  assert.throws(
    () => updateUnRC({ html: tableWithChart, chart: 'fleet', version: '2.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('fleet', '2.0.0'));
      return true;
    }
  );
});

test('updateUnRC - updates UnRC status successfully', () => {
  const result = updateUnRC({
    html: tableWithChart,
    chart: 'fleet',
    version: '1.0.0'
  });

  assert.ok(result.includes('data-unrc="true"'));
  assert.ok(result.includes('<td class="unrc">yes</td>'));
});

test('updateUnRC - does not modify other attributes', () => {
  const result = updateUnRC({
    html: tableWithChart,
    chart: 'fleet',
    version: '1.0.0'
  });

  // Other attributes should remain unchanged
  assert.ok(result.includes('data-chart="fleet"'));
  assert.ok(result.includes('data-version="1.0.0"'));
  assert.ok(result.includes('data-qa="false"'));
  assert.ok(result.includes('chart-row-1'));
});
