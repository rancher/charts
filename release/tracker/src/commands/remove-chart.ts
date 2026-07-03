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
 * @throws Error if chart not found in table
 */
export function removeChart(options: {
  html: string;
  chart: string;
  version: string;
}): string {
  // TODO: Parse HTML with cheerio
  // TODO: Find row by data-chart and data-version
  // TODO: Remove entire <tr> element
  // TODO: Return updated HTML

  console.log({ options });
  return options.html;
}
