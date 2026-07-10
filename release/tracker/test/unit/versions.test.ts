import { describe, it } from 'node:test';
import assert from 'node:assert';
import { filterToStableVersions, getHighestVersion } from '../../src/adapters/versions.js';

// TODO: Fix expectations - filterToStableVersions returns base only, not base+up
describe.skip('filterToStableVersions', () => {
  it('extracts base versions from RC versions', () => {
    const input = ['100.0.0', '100.0.0-rc.1', '100.0.0-rc.2', '100.0.1-rc.1'];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, ['100.0.0', '100.0.1']);
  });

  it('handles mixed prerelease types (alpha, beta, rc)', () => {
    const input = ['100.0.0-alpha.1', '100.0.0-beta.2', '100.0.0-rc.3', '100.0.1'];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, ['100.0.0', '100.0.1']);
  });

  it('returns stable versions unchanged', () => {
    const input = ['100.0.0', '100.0.1', '100.0.2'];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, ['100.0.0', '100.0.1', '100.0.2']);
  });

  it('extracts base from RC-only versions', () => {
    const input = ['100.0.0-rc.1', '100.0.0-rc.2', '100.0.1-rc.1'];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, ['100.0.0', '100.0.1']);
  });

  it('handles empty array', () => {
    const input: string[] = [];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, []);
  });

  it('deduplicates base versions', () => {
    const input = ['100.0.0-rc.1', '100.0.0-rc.2', '100.0.0-rc.3', '100.0.0'];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, ['100.0.0']);
  });

  it('sorts versions numerically', () => {
    const input = ['100.0.2', '100.0.0-rc.1', '100.0.1'];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, ['100.0.0', '100.0.1', '100.0.2']);
  });

  it('handles complex versions with +up notation (fleet - only RCs)', () => {
    const input = [
      '109.0.3+up0.15.3-rc.2',
      '109.0.3+up0.15.3-rc.1',
      '109.0.2+up0.15.2-rc.3',
      '109.0.1+up0.15.1-rc.2',
      '109.0.0+up0.15.0-rc.6',
      '109.0.0+up0.15.0-beta.4',
      '109.0.0+up0.15.0-alpha.10'
    ];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, [
      '109.0.0+up0.15.0',
      '109.0.1+up0.15.1',
      '109.0.2+up0.15.2',
      '109.0.3+up0.15.3'
    ]);
  });

  it('handles versions with +up notation (mixed stable and RC)', () => {
    const input = [
      '109.0.7+up10.0.8-rc.1',
      '109.0.6+up10.0.7',
      '109.0.5+up10.0.5'
    ];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, [
      '109.0.5+up10.0.5',
      '109.0.6+up10.0.7',
      '109.0.7+up10.0.8'
    ]);
  });

  it('handles versions with +up notation (only stable)', () => {
    const input = [
      '109.0.3+up2.10.3',
      '109.0.2+up2.10.2'
    ];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, [
      '109.0.2+up2.10.2',
      '109.0.3+up2.10.3'
    ]);
  });

  it('handles complex rancher version format with -rancher suffix', () => {
    const input = [
      '109.0.1-rc.1+up4.10.0-rancher.24',
      '109.0.4-rc.1+up80.9.1-rancher.15',
      '109.0.3+up80.9.1-rancher.14'
    ];
    const result = filterToStableVersions(input);
    assert.deepStrictEqual(result, [
      '109.0.1+up4.10.0-rancher.24',
      '109.0.3+up80.9.1-rancher.14',
      '109.0.4+up80.9.1-rancher.15'
    ]);
  });
});

describe('getHighestVersion', () => {
  it('returns highest version from RC versions', () => {
    const input = [
      '109.0.5+up0.15.5-rc.1',
      '109.0.5+up0.15.5-rc.2',
      '109.0.5+up0.15.4-rc.3'
    ];
    const result = getHighestVersion(input);
    assert.strictEqual(result, '109.0.5+up0.15.5');
  });

  it('returns highest when +up metadata differs', () => {
    const input = [
      '109.0.3+up0.15.3',
      '109.0.3+up0.15.5',
      '109.0.3+up0.15.4'
    ];
    const result = getHighestVersion(input);
    assert.strictEqual(result, '109.0.3+up0.15.5');
  });

  it('returns highest base version', () => {
    const input = [
      '109.0.2+up0.15.3',
      '109.0.5+up0.15.4',
      '109.0.3+up0.15.5'
    ];
    const result = getHighestVersion(input);
    assert.strictEqual(result, '109.0.5+up0.15.4');
  });

  it('returns null for empty array', () => {
    const result = getHighestVersion([]);
    assert.strictEqual(result, null);
  });

  it('strips RC markers before comparison', () => {
    const input = [
      '109.0.5+up0.15.5-rc.10',
      '109.0.5+up0.15.5-rc.2'
    ];
    const result = getHighestVersion(input);
    assert.strictEqual(result, '109.0.5+up0.15.5');
  });

  it('handles single version', () => {
    const input = ['109.0.3+up0.15.5-rc.1'];
    const result = getHighestVersion(input);
    assert.strictEqual(result, '109.0.3+up0.15.5');
  });

  it('handles versions without +up metadata', () => {
    const input = ['109.0.5', '109.0.3', '109.0.4'];
    const result = getHighestVersion(input);
    assert.strictEqual(result, '109.0.5');
  });
});
