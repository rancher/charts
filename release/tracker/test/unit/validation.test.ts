import { test } from 'node:test';
import assert from 'node:assert';
import { validateCommonInputs, validateOwner } from '../../src/utils/validation.js';

test('validateCommonInputs - throws when html empty', () => {
  assert.throws(
    () => validateCommonInputs('', 'fleet', '1.0.0'),
    /HTML input is required/
  );
});

test('validateCommonInputs - throws when html whitespace', () => {
  assert.throws(
    () => validateCommonInputs('   ', 'fleet', '1.0.0'),
    /HTML input is required/
  );
});

test('validateCommonInputs - throws when chart empty', () => {
  assert.throws(
    () => validateCommonInputs('<table></table>', '', '1.0.0'),
    /{chart} is required/
  );
});

test('validateCommonInputs - throws when version empty', () => {
  assert.throws(
    () => validateCommonInputs('<table></table>', 'fleet', ''),
    /{version} is required/
  );
});

test('validateCommonInputs - passes when all valid', () => {
  assert.doesNotThrow(() => {
    validateCommonInputs('<table></table>', 'fleet', '1.0.0');
  });
});

test('validateOwner - throws when owner empty', () => {
  assert.throws(
    () => validateOwner(''),
    /owner is required/
  );
});

test('validateOwner - throws when owner whitespace', () => {
  assert.throws(
    () => validateOwner('   '),
    /owner is required/
  );
});

test('validateOwner - passes when valid', () => {
  assert.doesNotThrow(() => {
    validateOwner('@user');
  });
});
