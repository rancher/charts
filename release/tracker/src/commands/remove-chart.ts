import { parseIssueBody, findChartRow } from '../adapters/html.js';
import { validateCommonInputs } from './validation.js';
import { Errors } from './errors.js';

/**
 * Removes chart row from release tracking table
 *
 * Finds chart row by chart+version and removes entire <tr> element.
 * Used for correcting typos or removing charts from release scope.
 *
 * @param options - Remove chart options
 * @param options.html - Issue body HTML containing table
 * @param options.chart - Chart name to remove
 * @param options.version - Chart version to match
 * @returns Updated HTML with chart row removed
 * @throws Error if validation fails or chart not found
 */
export function removeChart(options: {
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

  // Remove row
  row.remove();

  return $.html();
}
