import { readFileSync } from 'fs';
import * as yaml from 'js-yaml';

export interface DispatchTarget {
  repo: string;
  workflow: string;
}

export function loadChartFamilies(filepath: string): Record<string, string[]> {
  return yaml.load(readFileSync(filepath, 'utf-8')) as Record<string, string[]>;
}

export function loadDispatchTargets(filepath: string): Record<string, DispatchTarget> {
  return yaml.load(readFileSync(filepath, 'utf-8')) as Record<string, DispatchTarget>;
}
