import { test } from 'node:test';
import assert from 'node:assert';
import { addChart } from '../../src/commands/add-chart.js';
import { Errors } from '../../src/utils/errors.js';

const validTableHTML = `
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

test('addChart - throws when table not found', () => {
  assert.throws(
    () => addChart({ html: '<div>no table</div>', chart: 'fleet', version: '1.0.0', owner: '@user' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.tableNotFound());
      return true;
    }
  );
});

test('addChart - throws when duplicate chart exists', () => {
  const htmlWithChart = `
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

  assert.throws(
    () => addChart({ html: htmlWithChart, chart: 'fleet', version: '1.0.0', owner: '@user' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.chartAlreadyExists('fleet', '1.0.0'));
      return true;
    }
  );
});

test('addChart - throws when END marker missing', () => {
  const htmlNoMarker = `
<table>
<tr>
  <th>Chart</th>
</tr>
<!-- BEGIN: CHART_DATA -->
</table>
`;

  assert.throws(
    () => addChart({ html: htmlNoMarker, chart: 'fleet', version: '1.0.0', owner: '@user' }),
    (err: Error) => {
      assert.strictEqual(err.message, Errors.markerNotFound());
      return true;
    }
  );
});

test('addChart - adds chart row successfully', () => {
  const result = addChart({
    html: validTableHTML,
    chart: 'fleet',
    version: '110.0.0+up0.16.0',
    owner: '@thardeck'
  });

  assert.ok(result.includes('data-chart="fleet"'));
  assert.ok(result.includes('data-version="110.0.0+up0.16.0"'));
  assert.ok(result.includes('data-owner="@thardeck"'));
  assert.ok(result.includes('id="chart-row-1"'));
  assert.ok(result.includes('<!-- END: CHART_DATA -->'));
});

test('addChart - increments row number correctly', () => {
  const htmlWithOneRow = `
<table>
<!-- BEGIN: CHART_DATA -->
<tr id="chart-row-1" data-chart="longhorn" data-version="1.0.0" data-team="" data-owner="@user1" data-qa="false" data-unrc="false">
  <td class="chart">longhorn</td>
  <td class="version">1.0.0</td>
  <td class="team"></td>
  <td class="owner">@user1</td>
  <td class="qa"></td>
  <td class="unrc"></td>
</tr>
<!-- END: CHART_DATA -->
</table>
`;

  const result = addChart({
    html: htmlWithOneRow,
    chart: 'fleet',
    version: '1.0.0',
    owner: '@user2'
  });

  assert.ok(result.includes('id="chart-row-2"'));
  assert.ok(result.includes('data-chart="fleet"'));
});
