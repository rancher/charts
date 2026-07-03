import { parseIssueBody, findChartRow } from '../adapters/html.js';
import { validateCommonInputs } from '../utils/validation.js';
import { Errors } from '../utils/errors.js';

/**
 * Marks Un-RC complete for a chart
 *
 * Finds chart row by chart+version, sets data-unrc="true" attribute,
 * and updates <td class="unrc"> cell text to "yes".
 *
 * @param options - UnRC update options
 * @param options.html - Issue body HTML containing table
 * @param options.chart - Chart name to update
 * @param options.version - Chart version to match
 * @returns Updated HTML with UnRC marked
 * @throws Error if validation fails or chart not found
 */
export function updateUnRC(options: {
  html: string;
  chart: string;
  version: string;
}): string {
  // Validate inputs
  validateCommonInputs(options.html, options.chart, options.version);

  const $ = parseIssueBody(options.html);

  // Check table exists
  const table = $('table');
  if (table.length === 0) {
    throw new Error(Errors.tableNotFound());
  }

  // Find chart row
  const row = findChartRow($, options.chart, options.version);
  if (row.length === 0) {
    throw new Error(Errors.chartNotFound(options.chart, options.version));
  }

  // Update UnRC status
  row.attr('data-unrc', 'true');
  row.find('td.unrc').text('yes');

  return $.html();
}
