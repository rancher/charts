import {readFileSync} from 'fs';
import {parseReleaseTrackingYaml, ReleaseYAML} from '../adapters/yaml.js';
import {readFileFromGit} from '../adapters/git.js';
import {loadChartFamilies, loadDispatchTargets} from '../adapters/charts.js';
import {findQAFlagChanges, resolveFamily} from '../domain/chart-comparison.js';

export interface QADoneResult {
    dispatch: Array<{ chart: string; version: string; family: string; repo: string; workflow: string; }>;
    skipped: Array<{ family: string; chart: string }>;
}

/**
 * Detect chart versions whose QA flag became true across the given
 * release YAML files, and resolve each to its dispatch target.
 * New content comes from head and old content from baseRef
 */
export async function detectQaDone(
    baseRef: string,
    files: string[],
    chartFamiliesPath = 'config/chart-families.yaml',
    dispatchTargetsPath = 'config/unrc-dispatch-targets.yaml'
): Promise<QADoneResult> {
    const families = loadChartFamilies(chartFamiliesPath);
    const targets = loadDispatchTargets(dispatchTargetsPath);

    const activationsPerFile = await Promise.all(
        files.map(async file => {
            const oldReleaseYAML = await readOldReleaseYaml(baseRef, file);
            const newReleaseYaml = parseReleaseTrackingYaml(readFileSync(file, 'utf-8'));
            return findQAFlagChanges(oldReleaseYAML, newReleaseYaml);
        })
    );

    const dispatchByFamily = new Map<string, QADoneResult['dispatch'][number]>();
    const skippedFamilies = new Map<string, string>();

    for (const {chart, version} of activationsPerFile.flat()) {
        const family = resolveFamily(families, chart);
        const target = targets[family];

        if (!target) {
            if (!skippedFamilies.has(family)) skippedFamilies.set(family, chart);
            continue;
        }

        if (!dispatchByFamily.has(family)) {
            dispatchByFamily.set(family, {chart, version, family, ...target});
        }
    }

    const dispatch = Array.from(dispatchByFamily.values());
    const skipped = Array.from(skippedFamilies, ([family, chart]) => ({family, chart}));
    return {dispatch, skipped};
}

async function readOldReleaseYaml(baseRef: string, file: string): Promise<ReleaseYAML> {
    try {
        return parseReleaseTrackingYaml(await readFileFromGit(baseRef, file));
    } catch {
        // File didn't exist before this change.
        return {};
    }
}
