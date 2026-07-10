import { readFileSync } from 'fs';

const CODEOWNERS_PATH = '../../templates/CODEOWNERS_DEV';

/**
 * Lookup GitHub team for a chart from CODEOWNERS_DEV
 *
 * Parses CODEOWNERS_DEV file, finds `packages/{chart}` entry,
 * returns first @team mentioned. Falls back to empty string if not found.
 *
 * @param chart - Chart name (e.g. "fleet", "longhorn")
 * @returns Team handle (e.g. "@rancher/fleet") or empty string
 */
export function lookupTeam(chart: string): string {
    try {
        const content = readFileSync(CODEOWNERS_PATH, 'utf-8');
        const lines = content.split('\n');

        // Find line matching "packages/{chart}"
        const pattern = `packages/${chart}`;
        for (const line of lines) {
            // Skip comments and empty lines
            if (line.trim().startsWith('#') || line.trim() === '') {
                continue;
            }

            // Check if line starts with our pattern
            if (line.startsWith(pattern)) {
                // Extract teams (everything after the path)
                const parts = line.split(/\s+/);
                // First part is path, rest are teams
                const teams = parts.slice(1).filter(t => t.startsWith('@'));

                if (teams.length > 0) {
                    return teams[0]; // Return first team
                }
            }
        }

        // Chart not found
        return '';
    } catch (err) {
        // File not found or unreadable - return empty
        console.error(`Warning: Could not read CODEOWNERS_DEV: ${(err as Error).message}`);
        return '';
    }
}
