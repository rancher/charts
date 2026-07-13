/**
 * Parse CLI flags
 */
export function parseFlags(argv: string[]): {
  issueNum?: string;
  issueBody: string;
  commentBody: string;
  commentUser: string;
  commentId?: string;
} {
  const flags: Record<string, string> = {};

  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith('--')) {
      const key = argv[i].slice(2);
      const value = argv[i + 1];
      if (value && !value.startsWith('--')) {
        flags[key] = value;
        i++; // Skip next arg
      }
    }
  }

  const parsed = {
    issueNum: flags['issue-num'],
    issueBody: flags['issue-body'],
    commentBody: flags['comment-body'],
    commentUser: flags['comment-user'],
    commentId: flags['comment-id']
  };

  if (!checkFlags(parsed)) {
    throw new Error('Missing required flags: --issue-body, --comment-body, --comment-user');
  }

  return parsed as {
    issueNum?: string;
    issueBody: string;
    commentBody: string;
    commentUser: string;
    commentId?: string;
  };
}

/**
 * Check if flags are valid for GHA mode
 */
export function checkFlags(flags: ReturnType<typeof parseFlags>): boolean {
  return !!(flags.issueBody && flags.commentBody && flags.commentUser);
}
