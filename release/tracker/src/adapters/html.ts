import * as cheerio from 'cheerio';

/**
 * Parses HTML issue body into cheerio DOM
 *
 * Loads HTML fragment without wrapping in <html><body> tags.
 * Preserves markdown+HTML structure from GitHub issues.
 *
 * @param html - Raw HTML from issue body
 * @returns Cheerio API instance for DOM manipulation
 */
export function parseIssueBody(html: string) {
  // Use _useHtmlParser2=true to prevent wrapping fragments in <html><body>
  return cheerio.load(html, null, false);
}

/**
 * Finds chart row in table by chart name and version
 *
 * Uses data attributes to locate exact chart+version match.
 *
 * @param $ - Cheerio API instance
 * @param chart - Chart name to find
 * @param version - Chart version to match
 * @returns Cheerio selection (empty if not found)
 */
export function findChartRow($: cheerio.CheerioAPI, chart: string, version: string) {
  return $(`tr[data-chart="${chart}"][data-version="${version}"]`);
}

/**
 * Gets next available row number for new chart entry
 *
 * Scans existing chart-row-* IDs and returns max + 1.
 * Returns 1 if no rows exist.
 *
 * @param $ - Cheerio API instance
 * @returns Next row number to use
 */
export function getNextRowNumber($: cheerio.CheerioAPI): number {
  const rows = $('tr[id^="chart-row-"]');
  if (rows.length === 0) return 1;

  const maxId = Math.max(...rows.map((_, el) => {
    const id = $(el).attr('id') || '';
    const num = parseInt(id.replace('chart-row-', ''), 10);
    return isNaN(num) ? 0 : num;
  }).get());

  return maxId + 1;
}
