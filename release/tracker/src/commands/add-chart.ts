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
  // TODO: Parse HTML with cheerio
  // TODO: Get next row number
  // TODO: Create new <tr> with data attributes
  // TODO: Insert before <!-- END: CHART_DATA -->
  // TODO: Return updated HTML

  console.log({ options })
  return options.html;
}
