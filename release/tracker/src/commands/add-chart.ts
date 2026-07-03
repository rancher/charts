import { parseIssueBody, getNextRowNumber } from '../parser.js';

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
 */
export function addChart(options: {
  html: string;
  chart: string;
  version: string;
  owner: string;
}): string {
  const $ = parseIssueBody(options.html);
  const rowNumber = getNextRowNumber($);

  const newRow = `
<tr id="chart-row-${rowNumber}" data-chart="${options.chart}" data-version="${options.version}" data-team="" data-owner="${options.owner}" data-qa="false" data-unrc="false">
  <td class="chart">${options.chart}</td>
  <td class="version">${options.version}</td>
  <td class="team"></td>
  <td class="owner">${options.owner}</td>
  <td class="qa"></td>
  <td class="unrc"></td>
</tr>
`;

  // Find table and insert row before END marker
  const table = $('table');
  const currentHTML = table.html() || '';
  const updatedHTML = currentHTML.replace(
    /<!-- END: CHART_DATA -->/,
    `${newRow}<!-- END: CHART_DATA -->`
  );
  table.html(updatedHTML);

  return $.html();
}
