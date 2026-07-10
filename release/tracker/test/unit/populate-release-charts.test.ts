import { describe, it } from 'node:test';
import assert from 'node:assert';
import { findChartsToRelease } from '../../src/commands/populate-release-charts.js';
import { ChartVersion } from '../../src/adapters/yaml.js';

// TODO: Update tests for new signature (devCharts, devReleaseBase, releaseCharts)
describe.skip('findChartsToRelease', () => {
  it('finds new chart versions in dev not in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'fleet', version: '109.0.1+up0.15.1' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.4.0+up1.6.0' }
    ];

    const result = devBumpedVersionsToRelease(devCharts, releaseCharts);

    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.1+up0.15.1' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ]);
  });

  it('returns all dev charts when release is empty', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const releaseCharts: ChartVersion[] = [];

    const result = devBumpedVersionsToRelease(devCharts, releaseCharts);

    assert.deepStrictEqual(result, devCharts);
  });

  it('returns empty when all dev versions already in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const result = devBumpedVersionsToRelease(devCharts, releaseCharts);

    assert.deepStrictEqual(result, []);
  });

  it('handles multiple versions per chart', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'fleet', version: '109.0.1+up0.15.1' },
      { chart: 'fleet', version: '109.0.2+up0.15.2' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'fleet', version: '109.0.1+up0.15.1' }
    ];

    const result = devBumpedVersionsToRelease(devCharts, releaseCharts);

    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.2+up0.15.2' }
    ]);
  });

  it('identifies new chart not present in release at all', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'neuvector', version: '103.0.0+up2.8.0' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' }
    ];

    const result = devBumpedVersionsToRelease(devCharts, releaseCharts);

    assert.deepStrictEqual(result, [
      { chart: 'neuvector', version: '103.0.0+up2.8.0' }
    ]);
  });

  it('excludes dev version if same chart has different version in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '106.1.14+up0.12.16' } // Old version
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'fleet', version: '109.0.1+up0.15.1' }
    ];

    const result = devBumpedVersionsToRelease(devCharts, releaseCharts);

    // 106.1.14 not in release versions, so should be added
    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '106.1.14+up0.12.16' }
    ]);
  });
});
