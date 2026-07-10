/**
 * Check if comment contains valid command pattern
 */
function checkComment(parsed: { command: string, args: string[] } | null): void {
    if (!parsed) {
        throw new Error('No valid command found in comment');
    }
}

/**
 * Parse comment body to extract command and arguments
 *
 * Supported patterns (case-insensitive, colon required):
 * - ToRelease: <chart> <version> → add-chart
 * - QA: <chart> <version> → update-qa
 * - UnRC: <chart> <version> → update-unrc
 *
 * @param commentBody - GitHub comment body text
 * @param commentUser - GitHub username (for owner in add-chart)
 * @returns {command, args}
 * @throws Error if no valid command pattern found
 */
export function parseComment(commentBody: string, commentUser: string): { command: string, args: string[] } {
    const toRelease = commentBody.match(/^torelease:\s+(\S+)\s+(\S+)/im);
    if (toRelease) {
        const result = {
            command: 'add-chart',
            args: [toRelease[1], toRelease[2], `@${commentUser}`]
        };
        checkComment(result);
        return result;
    }

    const qa = commentBody.match(/^qa:\s+(\S+)\s+(\S+)/im);
    if (qa) {
        const result = {
            command: 'update-qa',
            args: [qa[1], qa[2]]
        };
        checkComment(result);
        return result;
    }

    const unrc = commentBody.match(/^unrc:\s+(\S+)\s+(\S+)/im);
    if (unrc) {
        const result = {
            command: 'update-unrc',
            args: [unrc[1], unrc[2]]
        };
        checkComment(result);
        return result;
    }

    checkComment(null);
    // Never reached, just for TypeScript
    throw new Error('Unreachable');
}
