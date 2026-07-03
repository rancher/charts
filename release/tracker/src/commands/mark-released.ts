/**
 * Marks chart as released
 *
 * Finds chart row by chart+version, sets data-released="true" attribute,
 * and updates <td class="released"> cell text to "yes".
 *
 * @param options - Released update options
 * @param options.html - Issue body HTML containing table
 * @param options.chart - Chart name to update
 * @param options.version - Chart version to match
 * @returns Updated HTML with released marked
 * @throws Error if chart not found in table
 */
export function markReleased(options: {
  html: string;
  chart: string;
  version: string;
}): string {
  // TODO: Parse HTML with cheerio
  // TODO: Find row by data-chart and data-version
  // TODO: Set data-released="true"
  // TODO: Update td.released text to "yes"
  // TODO: Return updated HTML

  console.log({ options });
  return options.html;
}
