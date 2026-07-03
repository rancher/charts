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
 * @throws Error if chart not found in table
 */
export function updateQA(options: {
  html: string;
  chart: string;
  version: string;
}): string {
  // TODO: Parse HTML with cheerio
  // TODO: Find row by data-chart and data-version
  // TODO: Set data-qa="true"
  // TODO: Update td.qa text to "yes"
  // TODO: Return updated HTML

  console.log({ options });
  return options.html;
}
