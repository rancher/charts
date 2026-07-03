import { test } from 'node:test';
import assert from 'node:assert';
import { removeChart } from '../../src/commands/remove-chart.js';
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

const tableWithOneChart = `
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

const tableWithTwoCharts = `
<table>
<!-- BEGIN: CHART_DATA -->
<tr id="chart-row-1" data-chart="fleet" data-version="1.0.0" data-team="" data-owner="@user1" data-qa="false" data-unrc="false">
  <td class="chart">fleet</td>
  <td class="version">1.0.0</td>
  <td class="team"></td>
  <td class="owner">@user1</td>
  <td class="qa"></td>
  <td class="unrc"></td>
</tr>
<tr id="chart-row-2" data-chart="longhorn" data-version="2.0.0" data-team="" data-owner="@user2" data-qa="false" data-unrc="false">
  <td class="chart">longhorn</td>
  <td class="version">2.0.0</td>
  <td class="team"></td>
  <td class="owner">@user2</td>
  <td class="qa"></td>
  <td class="unrc"></td>
</tr>
<!-- END: CHART_DATA -->
</table>
`;

test('removeChart - throws when table not found', () => {
  assert.throws(
    () => removeChart({ html: '<div>no table</div>', chart: 'fleet', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.tableNotFound());
      return true;
    }
  );
});

test('removeChart - throws when chart not found in empty table', () => {
  assert.throws(
    () => removeChart({ html: emptyTableHTML, chart: 'fleet', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('fleet', '1.0.0'));
      return true;
    }
  );
});

test('removeChart - throws when chart not found (wrong name)', () => {
  assert.throws(
    () => removeChart({ html: tableWithOneChart, chart: 'longhorn', version: '1.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('longhorn', '1.0.0'));
      return true;
    }
  );
});

test('removeChart - throws when chart not found (wrong version)', () => {
  assert.throws(
    () => removeChart({ html: tableWithOneChart, chart: 'fleet', version: '2.0.0' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartNotFound('fleet', '2.0.0'));
      return true;
    }
  );
});

test('removeChart - removes chart successfully', () => {
  const result = removeChart({
    html: tableWithOneChart,
    chart: 'fleet',
    version: '1.0.0'
  });

  assert.ok(!result.includes('data-chart="fleet"'));
  assert.ok(!result.includes('chart-row-1'));
  assert.ok(result.includes('<!-- END: CHART_DATA -->'));
});

test('removeChart - removes correct chart from table with multiple rows', () => {
  const result = removeChart({
    html: tableWithTwoCharts,
    chart: 'fleet',
    version: '1.0.0'
  });

  // fleet should be gone
  assert.ok(!result.includes('data-chart="fleet"'));
  assert.ok(!result.includes('chart-row-1'));

  // longhorn should still exist
  assert.ok(result.includes('data-chart="longhorn"'));
  assert.ok(result.includes('chart-row-2'));
});
