import { describe, it } from 'node:test';
import assert from 'node:assert';
import { findChartsToRelease } from '../../src/commands/populate-release-charts.js';
import { ChartVersion } from '../../src/adapters/yaml.js';

describe('findChartsToRelease', () => {
  it('finds stable versions in dev not in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'fleet', version: '109.0.1+up0.15.1' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const devReleaseBase: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'longhorn', version: '103.5.0' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.4.0+up1.6.0' }
    ];

    const result = findChartsToRelease(devCharts, devReleaseBase, releaseCharts);

    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.1+up0.15.1' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ]);
  });

  it('picks highest RC when only RCs exist for base version', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3+up0.15.3-rc.1' },
      { chart: 'fleet', version: '109.0.3+up0.15.3-rc.5' },
      { chart: 'fleet', version: '109.0.3+up0.15.3-rc.2' }
    ];

    const devReleaseBase: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.3' }
    ];

    const releaseCharts: ChartVersion[] = [];

    const result = findChartsToRelease(devCharts, devReleaseBase, releaseCharts);

    // Should pick highest RC (rc.5 -> strips to 109.0.3+up0.15.3)
    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.3+up0.15.3' }
    ]);
  });

  it('skips base version if any version for that base already released', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.2+up0.15.5-rc.1' },
      { chart: 'fleet', version: '109.0.2+up0.15.5-rc.2' }
    ];

    const devReleaseBase: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.2' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.2+up0.15.4' } // Different +up, but same base
    ];

    const result = findChartsToRelease(devCharts, devReleaseBase, releaseCharts);

    // Base 109.0.2 already released, skip RCs
    assert.deepStrictEqual(result, []);
  });

  it('returns all dev stable charts when release is empty', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const devReleaseBase: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'longhorn', version: '103.5.0' }
    ];

    const releaseCharts: ChartVersion[] = [];

    const result = findChartsToRelease(devCharts, devReleaseBase, releaseCharts);

    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ]);
  });

  it('returns empty when all dev versions already in release', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const devReleaseBase: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0' },
      { chart: 'longhorn', version: '103.5.0' }
    ];

    const releaseCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.0+up0.15.0' },
      { chart: 'longhorn', version: '103.5.0+up1.7.0' }
    ];

    const result = findChartsToRelease(devCharts, devReleaseBase, releaseCharts);

    assert.deepStrictEqual(result, []);
  });

  it('handles mixed stable and RC versions', () => {
    const devCharts: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.1+up0.15.1' }, // Stable
      { chart: 'fleet', version: '109.0.2+up0.15.2-rc.1' }, // RC only for base 109.0.2
      { chart: 'fleet', version: '109.0.2+up0.15.2-rc.3' }
    ];

    const devReleaseBase: ChartVersion[] = [
      { chart: 'fleet', version: '109.0.1' },
      { chart: 'fleet', version: '109.0.2' }
    ];

    const releaseCharts: ChartVersion[] = [];

    const result = findChartsToRelease(devCharts, devReleaseBase, releaseCharts);

    // Stable 109.0.1 + highest RC for 109.0.2
    assert.deepStrictEqual(result, [
      { chart: 'fleet', version: '109.0.1+up0.15.1' },
      { chart: 'fleet', version: '109.0.2+up0.15.2' }
    ]);
  });
});
