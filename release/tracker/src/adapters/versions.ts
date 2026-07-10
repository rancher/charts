import { ChartVersion } from './yaml.js';

/**
 * Filter out prerelease versions (-rc, -alpha, -beta)
 *
 * Excludes any version containing prerelease markers.
 * Keeps versions with -rancher suffix (valid, not prerelease).
 *
 * Examples:
 *   [{chart: "fleet", version: "100.0.0-rc.1"}, {chart: "fleet", version: "100.0.0"}]
 *   -> [{chart: "fleet", version: "100.0.0"}]
 *
 *   [{chart: "foo", version: "109.0.3+up80.9.1-rancher.14"}]
 *   -> [{chart: "foo", version: "109.0.3+up80.9.1-rancher.14"}]
 *
 * @param chartVersions - Array of chart versions
 * @returns Array excluding prerelease versions
 */
export function excludePrereleaseVersions(chartVersions: ChartVersion[]): ChartVersion[] {
  return chartVersions.filter(({ version }) => {
    return !version.includes('-rc') &&
           !version.includes('-alpha') &&
           !version.includes('-beta');
  });
}

/**
 * Filter ChartVersion array to stable versions
 *
 * Extracts base versions from chart versions, deduplicates per chart.
 *
 * Examples:
 *   [{chart: "fleet", version: "100.0.0-rc.1"}, {chart: "fleet", version: "100.0.0"}]
 *   -> [{chart: "fleet", version: "100.0.0"}]
 *
 * @param chartVersions - Array of chart versions
 * @returns Array of chart versions with stable versions only
 */
export function filterChartVersionsToStable(chartVersions: ChartVersion[]): ChartVersion[] {
    // Group by chart
    const chartMap = new Map<string, string[]>();

    for (const { chart, version } of chartVersions) {
        if (!chartMap.has(chart)) {
            chartMap.set(chart, []);
        }
        chartMap.get(chart)!.push(version);
    }

    // Filter each chart's versions to stable
    const results: ChartVersion[] = [];

    for (const [chart, versions] of chartMap.entries()) {
        const stableVersions = filterToStableVersions(versions);
        for (const version of stableVersions) {
            results.push({ chart, version });
        }
    }

    return results;
}

/**
 * Find charts in dev not present in release
 *
 * Compares two ChartVersion arrays and returns versions that exist in dev
 * but not in release (new versions to bump).
 *
 * @param devCharts - Charts from dev branch
 * @param releaseCharts - Charts from release branch
 * @returns Charts that need to be added to release
 */
export function findNewCharts(devCharts: ChartVersion[], releaseCharts: ChartVersion[]): ChartVersion[] {
    // Create set of chart@version strings from release
    const releaseSet = new Set<string>();
    for (const { chart, version } of releaseCharts) {
        releaseSet.add(`${chart}@${version}`);
    }

    // Filter dev charts not in release
    const newCharts: ChartVersion[] = [];
    for (const devChart of devCharts) {
        const key = `${devChart.chart}@${devChart.version}`;
        if (!releaseSet.has(key)) {
            newCharts.push(devChart);
        }
    }

    return newCharts;
}


/**
 * Filter to stable versions only
 *
 * Extracts base versions from all input versions (including RCs).
 * Returns unique base versions.
 *
 * Examples:
 *   ["100.0.0", "100.0.0-rc.1", "100.0.1-rc.2"]
 *   -> ["100.0.0", "100.0.1"]
 *
 * @param versions - Array of version strings
 * @returns Array of unique base versions
 */
export function filterToStableVersions(versions: string[]): string[] {
    const baseVersions = new Set<string>();

    for (const version of versions) {
        const base = getBaseVersion(version);
        baseVersions.add(base);
    }

    return Array.from(baseVersions).sort();
}


/**
 * Extract base version from version string
 *
 * Strips prerelease markers (-rc, -alpha, -beta) but preserves:
 * - -rancher suffix (valid, not a prerelease marker)
 * - +up metadata and everything after it
 *
 * Examples:
 *   100.0.0 -> 100.0.0
 *   100.0.0-rc.1 -> 100.0.0
 *   100.0.1-alpha.2 -> 100.0.1
 *   100.0.2-beta -> 100.0.2
 *   109.0.3+up80.9.1-rancher.14 -> 109.0.3+up80.9.1-rancher.14 (unchanged)
 *   109.0.1-rc.1+up4.10.0-rancher.24 -> 109.0.1+up4.10.0-rancher.24 (strips -rc.1, keeps +up onwards)
 *
 * @param version - Version string
 * @returns Base version without prerelease markers
 */
function getBaseVersion(version: string): string {
  // Split at +up to separate version and metadata
  const upIndex = version.indexOf('+up');
  const versionPart = upIndex !== -1 ? version.substring(0, upIndex) : version;
  const upMetadata = upIndex !== -1 ? version.substring(upIndex) : '';

  // Strip prerelease markers from version part
  const versionBase = stripPrereleaseMarkers(versionPart);

  // Strip prerelease markers from +up metadata part
  const upBase = upMetadata ? stripPrereleaseMarkers(upMetadata) : '';

  return versionBase;
}

/**
 * Strip prerelease markers from string
 */
function stripPrereleaseMarkers(str: string): string {
  const rcIndex = str.indexOf('-rc');
  const alphaIndex = str.indexOf('-alpha');
  const betaIndex = str.indexOf('-beta');

  const indices = [rcIndex, alphaIndex, betaIndex].filter(i => i !== -1);

  if (indices.length === 0) {
    return str;
  }

  const cutIndex = Math.min(...indices);
  return str.substring(0, cutIndex);
}

/**
 * Extract base version AND +up metadata (both with RC markers stripped)
 *
 * Examples:
 *   109.0.3+up0.15.5-rc.1 -> 109.0.3+up0.15.5
 *   109.0.2-rc.1+up0.15.3-rc.2 -> 109.0.2+up0.15.3
 *   109.0.5 -> 109.0.5
 *
 * @param version - Version string
 * @returns Full version with RC markers stripped from both parts
 */
function getBaseAndUpVersion(version: string): string {
  const upIndex = version.indexOf('+up');
  const versionPart = upIndex !== -1 ? version.substring(0, upIndex) : version;
  const upMetadata = upIndex !== -1 ? version.substring(upIndex) : '';

  const versionBase = stripPrereleaseMarkers(versionPart);
  const upBase = upMetadata ? stripPrereleaseMarkers(upMetadata) : '';

  return versionBase + upBase;
}

/**
 * Find highest version from array
 *
 * Assumes all versions have SAME base version.
 * Compares +up metadata part, returns highest with RC markers stripped.
 *
 * @param versions - Array of version strings (same base, may include -rc/-alpha/-beta)
 * @returns Highest version with prerelease markers stripped, or null if empty
 */
export function getHighestVersion(versions: string[]): string | null {
  if (versions.length === 0) return null;

  const fullVersions = versions.map(v => getBaseAndUpVersion(v));
  const unique = Array.from(new Set(fullVersions));

  unique.sort((a, b) => compareFullVersions(b, a));

  return unique[0];
}

/**
 * Compare full versions (base+up)
 */
function compareFullVersions(a: string, b: string): number {
  const [aBase, aUp] = a.split('+up');
  const [bBase, bUp] = b.split('+up');

  // Compare base
  const baseComp = compareParts(aBase, bBase);
  if (baseComp !== 0) return baseComp;

  // Compare +up part
  if (aUp && bUp) return compareParts(aUp, bUp);
  if (aUp) return 1;
  if (bUp) return -1;
  return 0;
}

/**
 * Compare version parts
 */
function compareParts(a: string, b: string): number {
  const aParts = a.split(/[.-]/).filter(Boolean);
  const bParts = b.split(/[.-]/).filter(Boolean);

  const len = Math.max(aParts.length, bParts.length);

  for (let i = 0; i < len; i++) {
    const aNum = parseInt(aParts[i] || '0', 10);
    const bNum = parseInt(bParts[i] || '0', 10);

    if (aNum > bNum) return 1;
    if (aNum < bNum) return -1;
  }

  return 0;
}

