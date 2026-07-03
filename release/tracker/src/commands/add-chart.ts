import { parseIssueBody, getNextRowNumber, findChartRow } from '../adapters/html.js';
import { validateCommonInputs, validateOwner } from './validation.js';
import { Errors } from './errors.js';
import { lookupTeam } from '../adapters/codeowners.js';

/**
 * Adds chart row to release tracking table
 *
 * Parses HTML table, generates new row with unique ID, inserts before
 * <!-- END: CHART_DATA --> marker. Sets data attributes for chart metadata.
 *
 * @param options - Chart add options
 * @param options.html - Issue body HTML containing table
 * @param options.chart - Chart name (e.g. "fleet", "longhorn")
 * @param options.version - Chart version (e.g. "110.0.0+up0.16.0")
 * @param options.owner - GitHub username (e.g. "@thardeck")
 * @returns Updated HTML with new chart row
 * @throws Error if validation fails or table structure invalid
 */
export function addChart(options: {
  html: string;
  chart: string;
  version: string;
  owner: string;
}): string {
  // Validate inputs
  validateCommonInputs(options.html, options.chart, options.version);
  validateOwner(options.owner);

  const $ = parseIssueBody(options.html);

  // Check table exists
  const table = $('table');
  if (table.length === 0) {
    throw new Error(Errors.tableNotFound());
  }

  // Check for duplicates
  const existing = findChartRow($, options.chart, options.version);
  if (existing.length > 0) {
    throw new Error(Errors.chartAlreadyExists(options.chart, options.version));
  }

  const rowNumber = getNextRowNumber($);
  const team = lookupTeam(options.chart);

  const newRow = `
<tr id="chart-row-${rowNumber}" data-chart="${options.chart}" data-version="${options.version}" data-team="${team}" data-owner="${options.owner}" data-qa="false" data-unrc="false">
  <td class="chart">${options.chart}</td>
  <td class="version">${options.version}</td>
  <td class="team">${team}</td>
  <td class="owner">${options.owner}</td>
  <td class="qa"></td>
  <td class="unrc"></td>
</tr>
`;

  // Verify marker exists
  const currentHTML = table.html() || '';
  if (!currentHTML.includes('<!-- END: CHART_DATA -->')) {
    throw new Error(Errors.markerNotFound());
  }

  // Insert row before END marker
  const updatedHTML = currentHTML.replace(
    /<!-- END: CHART_DATA -->/,
    `${newRow}<!-- END: CHART_DATA -->`
  );
  table.html(updatedHTML);

  return $.html();
}
