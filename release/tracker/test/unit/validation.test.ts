import { test } from 'node:test';
import assert from 'node:assert';
import { validateInputs } from '../../src/commands/validation.js';

test('validateInputs - throws when html empty', () => {
  assert.throws(
    () => validateInputs({ html: '' }),
    /HTML input is required/
  );
});

test('validateInputs - throws when html whitespace', () => {
  assert.throws(
    () => validateInputs({ html: '   ' }),
    /HTML input is required/
  );
});

test('validateInputs - throws when chart empty', () => {
  assert.throws(
    () => validateInputs({ chart: '' }),
    /{chart} is required/
  );
});

test('validateInputs - throws when version empty', () => {
  assert.throws(
    () => validateInputs({ version: '' }),
    /{version} is required/
  );
});

test('validateInputs - throws when owner empty', () => {
  assert.throws(
    () => validateInputs({ owner: '' }),
    /owner is required/
  );
});

test('validateInputs - passes when all valid', () => {
  assert.doesNotThrow(() => {
    validateInputs({
      html: '<table></table>',
      chart: 'fleet',
      version: '1.0.0',
      owner: '@user'
    });
  });
});

test('validateInputs - skips undefined fields', () => {
  // Should not throw when fields are undefined (not provided)
  assert.doesNotThrow(() => {
    validateInputs({ html: '<table></table>' });
  });
});
