import { describe, it } from 'node:test';
import assert from 'node:assert';
import { buildReleaseVersionMap, filterChartsNotInRelease, buildChartVersionMap, buildBaseVersionMap } from '../../src/domain/chart-comparison.js';
import { ChartVersion } from '../../src/adapters/yaml.js';

describe('buildReleaseVersionMap', () => {
  it('builds map with single chart and version', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' }
    ];

    const result = buildReleaseVersionMap(input);

    assert.strictEqual(result.size, 1);
    assert.ok(result.has('fleet'));
    assert.deepStrictEqual(Array.from(result.get('fleet')!), ['109.0.0']);
  });

  it('builds map with multiple versions for same chart', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'fleet', version: '109.0.2' }
    ];

    const result = buildReleaseVersionMap(input);

    assert.strictEqual(result.size, 1);
    assert.strictEqual(result.get('fleet')!.size, 3);
    assert.ok(result.get('fleet')!.has('109.0.0'));
    assert.ok(result.get('fleet')!.has('109.0.1'));
    assert.ok(result.get('fleet')!.has('109.0.2'));
  });

  it('builds map with multiple charts', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'longhorn', version: '103.5.0' },
      { chart: 'neuvector', version: '103.0.0' }
    ];

    const result = buildReleaseVersionMap(input);

    assert.strictEqual(result.size, 3);
    assert.ok(result.has('fleet'));
    assert.ok(result.has('longhorn'));
    assert.ok(result.has('neuvector'));
  });

  it('handles empty array', () => {
    const result = buildReleaseVersionMap([]);
    assert.strictEqual(result.size, 0);
  });

  it('deduplicates versions automatically (Set behavior)', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'fleet', version: '109.0.0' }
    ];

    const result = buildReleaseVersionMap(input);

    assert.strictEqual(result.get('fleet')!.size, 1);
  });
});

describe('filterChartsNotInRelease', () => {
  it('returns charts not in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'longhorn', version: '103.5.0' }
    ];

    const releaseMap = new Map<string, Set<string>>();
    releaseMap.set('fleet', new Set(['109.0.0']));

    const result = filterChartsNotInRelease(devCharts, releaseMap);

    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'longhorn', version: '103.5.0' }
    ]);
  });

  it('returns empty when all dev charts in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' }
    ];

    const releaseMap = new Map<string, Set<string>>();
    releaseMap.set('fleet', new Set(['109.0.0']));

    const result = filterChartsNotInRelease(devCharts, releaseMap);

    assert.deepStrictEqual(result, []);
  });

  it('includes RC versions not in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.1-rc.1' },
      { chart: 'fleet', version: '109.0.1' }
    ];

    const releaseMap = new Map<string, Set<string>>();
    releaseMap.set('fleet', new Set(['109.0.0']));

    const result = filterChartsNotInRelease(devCharts, releaseMap);

    assert.strictEqual(result.length, 2);
    assert.ok(result.some(r => r.version === '109.0.1-rc.1'));
    assert.ok(result.some(r => r.version === '109.0.1'));
  });

  it('filters out versions that exist in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'fleet', version: '109.0.2' }
    ];

    const releaseMap = new Map<string, Set<string>>();
    releaseMap.set('fleet', new Set(['109.0.0', '109.0.2']));

    const result = filterChartsNotInRelease(devCharts, releaseMap);

    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.1' }
    ]);
  });

  it('handles empty dev charts', () => {
    const releaseMap = new Map<string, Set<string>>();
    releaseMap.set('fleet', new Set(['109.0.0']));

    const result = filterChartsNotInRelease([], releaseMap);

    assert.deepStrictEqual(result, []);
  });

  it('handles empty release map', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' }
    ];

    const result = filterChartsNotInRelease(devCharts, new Map());

    assert.deepStrictEqual(result, devCharts);
  });
});

describe('buildChartVersionMap', () => {
  it('builds map with single chart and version', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' }
    ];

    const result = buildChartVersionMap(input);

    assert.strictEqual(result.size, 1);
    assert.ok(result.has('fleet'));
    assert.deepStrictEqual(result.get('fleet'), ['109.0.0']);
  });

  it('builds map with multiple versions for same chart', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'fleet', version: '109.0.2' }
    ];

    const result = buildChartVersionMap(input);

    assert.strictEqual(result.size, 1);
    assert.deepStrictEqual(result.get('fleet'), ['109.0.0', '109.0.1', '109.0.2']);
  });

  it('builds map with multiple charts', () => {
    const input: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'longhorn', version: '103.5.0' },
      { chart: 'neuvector', version: '103.0.0' }
    ];

    const result = buildChartVersionMap(input);

    assert.strictEqual(result.size, 3);
    assert.deepStrictEqual(result.get('fleet'), ['109.0.0']);
    assert.deepStrictEqual(result.get('longhorn'), ['103.5.0']);
    assert.deepStrictEqual(result.get('neuvector'), ['103.0.0']);
  });

  it('handles empty array', () => {
    const result = buildChartVersionMap([]);
    assert.strictEqual(result.size, 0);
  });
});

describe('buildBaseVersionMap', () => {
  it('groups actual versions by base version', () => {
    const actualVersions: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3+up0.15.3-rc.1' },
      { chart: 'fleet', version: '109.0.3+up0.15.3-rc.2' }
    ];
    const baseVersions: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3' }
    ];

    const result = buildBaseVersionMap(actualVersions, baseVersions);

    assert.strictEqual(result.size, 1);
    const innerMap = result.get('fleet');
    assert.ok(innerMap);
    assert.deepStrictEqual(innerMap.get('109.0.3'), [
      '109.0.3+up0.15.3-rc.1',
      '109.0.3+up0.15.3-rc.2'
    ]);
  });

  it('handles multiple charts', () => {
    const actualVersions: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3-rc.1' },
      { chart: 'longhorn', version: '103.5.0-rc.1' }
    ];
    const baseVersions: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3' },
      { chart: 'longhorn', version: '103.5.0' }
    ];

    const result = buildBaseVersionMap(actualVersions, baseVersions);

    assert.strictEqual(result.size, 2);
    assert.deepStrictEqual(result.get('fleet')!.get('109.0.3'), ['109.0.3-rc.1']);
    assert.deepStrictEqual(result.get('longhorn')!.get('103.5.0'), ['103.5.0-rc.1']);
  });

  it('skips base versions for charts not in actual versions', () => {
    const actualVersions: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3-rc.1' }
    ];
    const baseVersions: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3' },
      { chart: 'missing', version: '1.0.0' }
    ];

    const result = buildBaseVersionMap(actualVersions, baseVersions);

    assert.strictEqual(result.size, 1);
    assert.ok(!result.has('missing'));
  });

  it('handles empty arrays', () => {
    const result = buildBaseVersionMap([], []);
    assert.strictEqual(result.size, 0);
  });
});
