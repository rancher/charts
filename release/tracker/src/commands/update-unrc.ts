import { validateCommonInputs } from './validation.js';

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
 * @throws Error if chart not found in table
 */
export function updateUnRC(options: {
  html: string;
  chart: string;
  version: string;
}): string {
  validateCommonInputs(options.html, options.chart, options.version);

  // TODO: Parse HTML with cheerio
  // TODO: Find row by data-chart and data-version
  // TODO: Set data-unrc="true"
  // TODO: Update td.unrc text to "yes"
  // TODO: Return updated HTML

  return options.html;
}
