import { readFileSync, writeFileSync, readdirSync } from 'fs';
import * as yaml from 'js-yaml';

/**
 * Chart version info from Chart.yaml
 */
export interface ChartVersion {
  chart: string;
  version: string;
}

/**
 * Release YAML structure
 */
export interface ReleaseYAML {
  [chart: string]: {
    [version: string]: {
      QA: boolean;
      UnRC: boolean;
      Released: boolean;
    };
  };
}

/**
 * Parse Chart.yaml content
 *
 * @param content - Raw Chart.yaml file content
 * @returns Chart name and version
 * @throws Error if name or version not found
 */
export function parseChartYaml(content: string): ChartVersion {
  const parsed = yaml.load(content) as { name?: string; version?: string };

  if (!parsed.name || !parsed.version) {
    throw new Error('Invalid Chart.yaml: missing name or version');
  }

  return { chart: parsed.name, version: parsed.version };
}

/**
 * Read release tracking YAML file
 */
export function readReleaseTrackingYaml(filepath: string): ReleaseYAML {
  const content = readFileSync(filepath, 'utf-8');
  const parsed = yaml.load(content);
  return parsed as ReleaseYAML;
}

/**
 * Write release YAML file
 */
export function writeReleaseYAML(filepath: string, data: ReleaseYAML): void {
  const content = yaml.dump(data, {
    lineWidth: -1,
    noRefs: true,
    sortKeys: true
  });
  writeFileSync(filepath, content, 'utf-8');
}

/**
 * Parse dev branch release.yaml
 *
 * Format:
 *   chart-name:
 *     - version1
 *     - version2
 *
 * @param content - Raw release.yaml content from dev branch
 * @returns Flattened array of chart versions
 */
export function parseDevReleaseYaml(content: string): ChartVersion[] {
  const parsed = yaml.load(content) as Record<string, string[]>;
  const results: ChartVersion[] = [];

  for (const [chart, versions] of Object.entries(parsed)) {
    for (const version of versions) {
      results.push({ chart, version });
    }
  }

  return results;
}

/**
 * Parse index.yaml from release branch
 *
 * Format:
 *   entries:
 *     chart-name:
 *       - name: chart-name
 *         version: X.Y.Z
 *       - name: chart-name
 *         version: A.B.C
 *
 * @param content - Raw index.yaml content
 * @returns Flattened array of chart versions
 */
export function parseIndexYaml(content: string): ChartVersion[] {
  const parsed = yaml.load(content) as {
    entries: Record<string, Array<{ name: string; version: string }>>;
  };

  const results: ChartVersion[] = [];

  for (const [chart, entries] of Object.entries(parsed.entries)) {
    for (const entry of entries) {
      results.push({ chart, version: entry.version });
    }
  }

  return results;
}

/**
 * Find release YAML file for minor version
 *
 * Scans release/ directory for X.Y.Z.yaml matching minor version.
 * Errors if 0 or >1 files found.
 *
 * @param minorVersion - Minor version (e.g., "2.14")
 * @returns YAML path and full release version
 * @throws Error if validation fails or file not found
 */
export function findReleaseYaml(minorVersion: string): { yamlPath: string; releaseVersion: string } {
  // Validate format
  if (!minorVersion.match(/^\d+\.\d+$/)) {
    throw new Error(`Invalid minor version format: ${minorVersion}. Expected format: X.Y (e.g., 2.14)`);
  }

  // Find matching YAML file
  const pattern = new RegExp(`^${minorVersion.replace('.', '\\.')}\\.\\d+\\.yaml$`);
  const yamlFiles = readdirSync('release').filter(f => pattern.test(f));

  if (yamlFiles.length === 0) {
    throw new Error(`No release YAML found matching ${minorVersion}.X.yaml in release/`);
  }

  if (yamlFiles.length > 1) {
    throw new Error(`Multiple YAML files found for ${minorVersion}: ${yamlFiles.join(', ')}. Expected exactly one.`);
  }

  return {
    yamlPath: `release/${yamlFiles[0]}`,
    releaseVersion: yamlFiles[0].replace('.yaml', '')
  };
}
