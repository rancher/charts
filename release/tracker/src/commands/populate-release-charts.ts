import { readReleaseTrackingYaml, writeReleaseYAML, parseDevReleaseYaml, parseIndexYaml, ChartVersion } from '../adapters/yaml.js';
import { showReleaseYamlFromBranch, showIndexYamlFromBranch } from '../adapters/git.js';
import { excludePrereleaseVersions, filterChartVersionsToStable, getHighestVersion } from '../adapters/versions.js';
import { buildReleaseVersionMap, filterChartsNotInRelease, buildChartVersionMap, buildBaseVersionMap, addRCBasedReleases } from '../domain/chart-comparison.js';

/**
 * Populate release YAML with charts from dev branch
 *
 * Compares dev branch vs release branch to find new/updated charts.
 * Replaces <version> placeholder with actual version from dev branch.
 *
 * @param options - Population options
 * @param options.releaseVersion - Release version (e.g., "2.14.4")
 * @param options.yamlPath - Path to release YAML file
 * @param options.devBranch - Dev branch to read from (e.g., "dev-v2.14")
 * @param options.releaseBranch - Release branch to compare against (e.g., "release-v2.14")
 * @returns Summary of changes
 */
export async function populateReleaseCharts(options: {
  releaseVersion: string;
  yamlPath: string;
  devBranch: string;
  releaseBranch: string;
}): Promise<{ added: number; charts: string[] }> {
  // Find new charts by comparing dev-v2.X <-> releaes-v2.X
  const newCharts = await findNewCharts(options.devBranch, options.releaseBranch);

  // Read existing YAML
  const data = readReleaseTrackingYaml(options.yamlPath);
  const added: string[] = [];

  for (const { chart, version } of newCharts) {
    // Chart must exist in tracking YAML - if not, data integrity issue
    if (!data[chart]) {
      throw new Error(`Chart "${chart}" found in comparison but missing from tracking YAML at ${options.yamlPath}`);
    }

    // Skip if version already exists
    if (data[chart][version]) {
      continue;
    }

    // Case 1: Charts Exists && Not Populated -> Replace placeholder with actual version
    if (data[chart]['<version>']) {
      data[chart][version] = data[chart]['<version>'];
      delete data[chart]['<version>'];
      added.push(`${chart}@${version}`);
      continue;
    }

    // Case 2: Add new version (multi-version scenario like CVE fix)
    data[chart][version] = {
      QA: false,
      UnRC: false,
      Released: false
    };
    added.push(`${chart}@${version} (multi-version)`);
  }

  // Write updated YAML
  writeReleaseYAML(options.yamlPath, data);

  return {
    added: added.length,
    charts: added
  };
}

/**
 * Find charts in dev branch not in release branch
 */
async function findNewCharts(devBranch: string, releaseBranch: string): Promise<ChartVersion[]> {
  // Get base versions from release.yaml (source of truth for "what we intend to release")
  const devReleaseYamlBaseVersions = filterChartVersionsToStable(await readReleaseYamlVersions(devBranch));

  // Get all actual versions from dev index (includes RCs - these are release candidates)
  const devCharts = await readIndexYamlVersions(devBranch);

  // Get already-shipped versions from release branch (comparison baseline)
  const releaseCharts = await readIndexYamlVersions(releaseBranch);

  return findChartsToRelease(devCharts, devReleaseYamlBaseVersions, releaseCharts);
}

/**
 * Read and parse release.yaml from a git branch
 *
 * release.yaml = source of truth for "what we intend to release"
 * Format: chart name → array of version strings
 *
 * @param branch - Git branch name (e.g., "dev-v2.14")
 * @returns Parsed chart versions from release.yaml
 */
async function readReleaseYamlVersions(branch: string): Promise<ChartVersion[]> {
  const content = await showReleaseYamlFromBranch(branch);
  return parseDevReleaseYaml(content);
}

/**
 * Read and parse index.yaml from a git branch
 *
 * index.yaml = Helm chart index containing all published versions
 * Format: Helm standard index with entries per chart
 *
 * @param branch - Git branch name (e.g., "release-v2.14")
 * @returns Parsed chart versions from index.yaml
 */
async function readIndexYamlVersions(branch: string): Promise<ChartVersion[]> {
  const content = await showIndexYamlFromBranch(branch);
  return parseIndexYaml(content);
}

/**
 * Find versions in dev that need to be released
 *
  The Business Problem:

  release.yaml on dev branch = source of truth for "what we intend to release"

  But it contains old RC versions that never shipped (bugs, got replaced by newer RCs). Can't delete them - needed for old Rancher dev versions.

  Example:
  release.yaml:
    rancher-webhook:
      - 109.0.2+up0.10.5-rc.5  # buggy, never released
      - 109.0.2+up0.10.5-rc.4  # buggy, never released
      - 109.0.2+up0.10.6-rc.1  # current, ready to release

  The Logic:

  1. Easy case - stable version in dev, not in release → add it
    - filterChartsNotInRelease + excludePrereleaseVersions
  2. Hard case - only RCs in release.yaml, base version not yet released → pick highest RC
    - Extract bases from release.yaml ("109.0.2")
    - Group actual dev versions by base ("109.0.2" → [rc.1, rc.4, rc.5])
    - Check if base already in release branch (startsWith check)
    - If NOT → highest RC is "blessed" for release
    - buildBaseVersionMap + addRCBasedReleases

  Why base comparison?
  release.yaml tracks version families ("109.0.2"), not exact RCs.
  If ANY "109.0.2*" version shipped, family is done.
  If none shipped, we need latest RC from that family.

 *
 * @param devCharts - Stable chart versions from dev branch
 * @param releasedCharts - All chart versions from release-v2.X index
 * @returns Chart versions that need to be added to release
 */
export function findChartsToRelease(devCharts: ChartVersion[], inDevBaseVersions: ChartVersion[], releasedCharts: ChartVersion[]): ChartVersion[] {
  // Build fast lookup structure for "already released?" checks (Set.has = O(1))
  const releasedChartsMap = buildReleaseVersionMap(releasedCharts);

  // Get everything in dev index that hasn't shipped to release yet (includes RCs for later processing)
  const devNewChartsWithRCs = filterChartsNotInRelease(devCharts, releasedChartsMap);

  // Extract stable versions - these definitely go to release (easy case from docstring)
  const stableCharts = excludePrereleaseVersions(devNewChartsWithRCs);

  // Group stable charts by chart name for merging with RC-based releases
  const stableChartsMap = buildChartVersionMap(stableCharts);

  // Base version = chart version before +up metadata (e.g., "109.0.2" from "109.0.2+up0.15.7-rc.17")
  // Why: release.yaml tracks version families, not exact RCs. If only RCs exist for a base,
  // we need to pick the highest RC from that family. This map groups all RCs by their base.
  // Example: "109.0.2" → ["109.0.2+up0.15.7-rc.1", "109.0.2+up0.15.7-rc.5", "109.0.2+up0.15.7-rc.8"]
  const baseVersionMap = buildBaseVersionMap(devNewChartsWithRCs, inDevBaseVersions);

  // Merge stable charts with RC-based releases (checks which base versions aren't yet released)
  const chartsToReleaseMap = addRCBasedReleases(baseVersionMap, releasedChartsMap, stableChartsMap, getHighestVersion);

  // Convert map back to array format
  const toReleaseCharts = Array.from(chartsToReleaseMap.entries()).flatMap(([chart, versions]) =>
    versions.map(version => ({chart, version}))
  )

  // Deduplicate chart@version combinations (stable path + RC path can overlap)
  const seen = new Set<string>();
  return toReleaseCharts.filter(cv => {
    const key = `${cv.chart}@${cv.version}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}


