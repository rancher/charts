/**
 * Validates common inputs required by all commands
 *
 * @param html - HTML issue body content
 * @param chart - Chart name
 * @param version - Chart version
 * @throws Error if validation fails
 */
export function validateCommonInputs(html: string, chart: string, version: string): void {
  if (!html || html.trim() === '') {
    throw new Error(`HTML input is required - got: "${html}"`);
  }

  if (!chart || chart.trim() === '') {
    throw new Error(`{chart} is required - got: "${chart}"`);
  }

  if (!version || version.trim() === '') {
    throw new Error(`{version} is required - got: "${version}"`);
  }
}

/**
 * Validates chart owner input
 *
 * Used only by add-chart command.
 *
 * @param owner - GitHub username
 * @throws Error if validation fails
 */
export function validateOwner(owner: string): void {
  if (!owner || owner.trim() === '') {
    throw new Error(`owner is required - got: "${owner}"`);
  }
}
