import { parseIssueBody, findChartRow } from '../parser.js';
import { validateCommonInputs } from './validation.js';
import { Errors } from './errors.js';

/**
 * Marks QA sign-off complete for a chart
 *
 * Finds chart row by chart+version, sets data-qa="true" attribute,
 * and updates <td class="qa"> cell text to "yes".
 *
 * @param options - QA update options
 * @param options.html - Issue body HTML containing table
 * @param options.chart - Chart name to update
 * @param options.version - Chart version to match
 * @returns Updated HTML with QA marked
 * @throws Error if validation fails or chart not found
 */
export function updateQA(options: {
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

  // Update QA status
  row.attr('data-qa', 'true');
  row.find('td.qa').text('yes');

  return $.html();
}
