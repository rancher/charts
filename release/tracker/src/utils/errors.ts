/**
 * User-facing error messages for release tracking commands
 *
 * These errors are displayed in GitHub issue comment replies,
 * so they must be clear, actionable, and non-technical.
 */

export const Errors = {
  tableNotFound: () => `Could not find release tracking table.
This issue may not be set up correctly.

Please contact @rancher/release-team`,

  chartNotFound: (chart: string, version: string) => `Chart "${chart}" version "${version}" is not in the release table.

Check the chart name and version are correct.
If you made a typo in your comment, please post a new comment with the correct values.`,

  chartAlreadyExists: (chart: string, version: string) => `Chart "${chart}" version "${version}" already exists in table.

To update this chart, use QA:, UnRC:, etc.
To remove and re-add, first use: Remove: ${chart} ${version}`,

  markerNotFound: () => `Chart data END marker not found in table.
This issue may not be set up correctly.

Please contact @rancher/release-team`,
};
