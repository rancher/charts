import { ChartVersion } from '../adapters/yaml.js';

/**
 * Build map of chart → set of versions from release
 *
 * @param releaseCharts - Chart versions from release
 * @returns Map of chart name to set of versions
 */
export function buildReleaseVersionMap(releaseCharts: ChartVersion[]): Map<string, Set<string>> {
  const releaseMap = new Map<string, Set<string>>();
  for (const { chart, version } of releaseCharts) {
    if (!releaseMap.has(chart)) {
      releaseMap.set(chart, new Set());
    }
    releaseMap.get(chart)!.add(version);
  }
  return releaseMap;
}

/**
 * Filter dev charts that are not in release
 *
 * @param devCharts - All chart versions from dev
 * @param releaseMap - Map of chart → versions in release
 * @returns Charts in dev but not in release (including RCs)
 */
export function filterChartsNotInRelease(
  devCharts: ChartVersion[],
  releaseMap: Map<string, Set<string>>
): ChartVersion[] {
  const result: ChartVersion[] = [];
  for (const devChart of devCharts) {
    const versions = releaseMap.get(devChart.chart);

    // If chart doesn't exist in release, or version doesn't exist, add it
    if (!versions || !versions.has(devChart.version)) {
      result.push(devChart);
    }
  }
  return result;
}

/**
 * Build map of chart → array of versions
 *
 * @param charts - Chart versions
 * @returns Map of chart name to array of versions
 */
export function buildChartVersionMap(charts: ChartVersion[]): Map<string, string[]> {
  const map = new Map<string, string[]>();
  for (const { chart, version } of charts) {
    if (!map.has(chart)) {
      map.set(chart, []);
    }
    map.get(chart)!.push(version);
  }
  return map;
}

/**
 * Build map of chart → map of base version → actual versions
 *
 * Groups actual versions by their base version for each chart.
 *
 * Example:
 *   Input: [{chart: "fleet", version: "109.0.3+up0.15.3-rc.1"}]
 *   Base versions: [{chart: "fleet", version: "109.0.3"}]
 *   Output: Map("fleet" → Map("109.0.3" → ["109.0.3+up0.15.3-rc.1"]))
 *
 * @param actualVersions - Actual chart versions (may include RCs)
 * @param baseVersions - Base versions to group by
 * @returns Nested map structure
 */
export function buildBaseVersionMap(
  actualVersions: ChartVersion[],
  baseVersions: ChartVersion[]
): Map<string, Map<string, string[]>> {
  const baseMap = new Map<string, Map<string, string[]>>();

  // Initialize map structure
  for (const { chart } of actualVersions) {
    if (!baseMap.has(chart)) {
      baseMap.set(chart, new Map());
    }
  }

  // Group actual versions by base
  for (const baseEntry of baseVersions) {
    const innerMap = baseMap.get(baseEntry.chart);
    if (!innerMap) continue;

    innerMap.set(baseEntry.version, []);

    for (const actualVersion of actualVersions) {
      if (actualVersion.chart === baseEntry.chart) {
        if (actualVersion.version.startsWith(baseEntry.version)) {
          innerMap.get(baseEntry.version)!.push(actualVersion.version);
        }
      }
    }
  }

  return baseMap;
}

/**
 * Find chart versions to release from base version map
 *
 * For each base version:
 * 1. Check if already released (base exists in release)
 * 2. If not released, pick highest actual version
 * 3. Add to release map
 *
 * @param baseVersionMap - Map of chart → base version → actual versions
 * @param releaseMap - Map of chart → released versions
 * @param existingNewCharts - Map of chart → versions already identified (non-RC)
 * @param getHighestVersion - Function to pick highest version from array
 * @returns Updated map with RC-based releases added
 */
export function addRCBasedReleases(
  baseVersionMap: Map<string, Map<string, string[]>>,
  releaseMap: Map<string, Set<string>>,
  existingNewCharts: Map<string, string[]>,
  getHighestVersion: (versions: string[]) => string | null
): Map<string, string[]> {
  const result = new Map(existingNewCharts);

  baseVersionMap.forEach((inDevVersionMap, chart) => {
    inDevVersionMap.forEach((versions, base) => {
      const releasedVersions = releaseMap.get(chart);
      let found = false;

      releasedVersions?.forEach((releasedVersion) => {
        if (releasedVersion.startsWith(base)) {
          found = true;
        }
      });

      if (!found) {
        const toReleaseVersion = getHighestVersion(versions);
        if (toReleaseVersion) {
          if (!result.has(chart)) {
            result.set(chart, []);
          }
          result.get(chart)!.push(toReleaseVersion);
        }
      }
    });
  });

  return result;
}
