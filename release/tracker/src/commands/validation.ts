/**
 * Validates common command inputs
 *
 * @param options - Input options to validate
 * @param options.html - HTML content
 * @param options.chart - Chart name
 * @param options.version - Chart version
 * @param options.owner - Chart owner (optional for update commands)
 * @throws Error if validation fails
 */
export function validateInputs(options: {
  html?: string;
  chart?: string;
  version?: string;
  owner?: string;
}): void {
  if (options.html !== undefined && (!options.html || options.html.trim() === '')) {
    throw new Error(`HTML input is required - got: "${options.html}"`);
  }

  if (options.chart !== undefined && (!options.chart || options.chart.trim() === '')) {
    throw new Error(`{chart} is required - got: "${options.chart}"`);
  }

  if (options.version !== undefined && (!options.version || options.version.trim() === '')) {
    throw new Error(`{version} is required - got: "${options.version}"`);
  }

  if (options.owner !== undefined && (!options.owner || options.owner.trim() === '')) {
    throw new Error(`owner is required - got: "${options.owner}"`);
  }
}
