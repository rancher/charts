import { execSync, spawn } from 'child_process';

/**
 * Find rancher/charts remote
 *
 * @returns Remote name pointing to rancher/charts.git
 * @throws Error if no rancher/charts remote found
 */
function getRancherChartsRemote(): string {
  try {
    const output = execSync('git remote -v', { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] });

    for (const line of output.split('\n')) {
      // Format: remote-name  url  (fetch|push)
      const match = line.match(/^(\S+)\s+(.+?)\s+\(fetch\)/);
      if (!match) continue;

      const [, remoteName, url] = match;

      // Match https or ssh URLs
      if (url.includes('github.com/rancher/charts.git') ||
          url.includes('github.com:rancher/charts.git')) {
        return remoteName;
      }
    }

    throw new Error('No remote found pointing to github.com/rancher/charts.git');
  } catch (err) {
    throw new Error(`Failed to find rancher/charts remote: ${(err as Error).message}`);
  }
}

/**
 * Resolve branch reference to remote ref
 *
 * Always uses remote as source of truth, never local.
 *
 * @param branch - Branch name (e.g., "dev-v2.14")
 * @returns Remote git ref (e.g., "origin/dev-v2.14")
 * @throws Error if branch not found on remote
 */
function resolveBranch(branch: string): string {
  const remote = getRancherChartsRemote();
  const ref = `${remote}/${branch}`;

  try {
    execSync(`git rev-parse --verify ${ref}`, { stdio: ['pipe', 'pipe', 'pipe'] });
    return ref;
  } catch {
    throw new Error(`Branch "${branch}" not found on remote "${remote}"`);
  }
}

/**
 * Fetch branch from remote
 *
 * Uses --depth 1 to fetch only latest state.
 *
 * @param branch - Branch name (e.g., "dev-v2.14")
 */
function fetchBranch(branch: string): void {
  const remote = getRancherChartsRemote();

  try {
    execSync(`git fetch --depth 1 ${remote} ${branch}`, { stdio: ['pipe', 'pipe', 'pipe'] });
  } catch (err) {
    throw new Error(`Failed to fetch ${remote}/${branch}: ${(err as Error).message}`);
  }
}

/**
 * Read file content from git ref (streaming for large files)
 *
 * @param ref - Git ref (e.g., "origin/dev-v2.14")
 * @param path - File path in repo
 * @returns File content as string
 */
export function readFileFromGit(ref: string, path: string): Promise<string> {
  return new Promise((resolve, reject) => {
    const proc = spawn('git', ['show', `${ref}:${path}`]);
    const chunks: Buffer[] = [];

    proc.stdout.on('data', (chunk: Buffer) => {
      chunks.push(chunk);
    });

    proc.stderr.on('data', (data: Buffer) => {
      // Collect errors but don't reject yet (git may write warnings to stderr)
    });

    proc.on('close', (code) => {
      if (code === 0) {
        resolve(Buffer.concat(chunks).toString('utf-8'));
      } else {
        reject(new Error(`git show ${ref}:${path} failed with code ${code}`));
      }
    });

    proc.on('error', (err) => {
      reject(err);
    });
  });
}

/**
 * List all Chart.yaml paths from branch
 *
 * @param branch - Branch name (e.g., "dev-v2.14")
 * @returns Array of Chart.yaml file paths
 */
export function listChartYamls(branch: string): string[] {
  const ref = resolveBranch(branch);

  const output = execSync(
    `git ls-tree -r --name-only ${ref} -- charts/`,
    { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }
  );

  return output
    .split('\n')
    .filter(path => path.endsWith('/Chart.yaml'));
}

/**
 * Get resolved git ref for branch
 *
 * @param branch - Branch name
 * @returns Resolved remote ref
 */
export function getResolvedRef(branch: string): string {
  return resolveBranch(branch);
}

/**
 * Read release.yaml from branch root
 *
 * @param branch - Branch name (e.g., "dev-v2.14")
 * @returns Raw release.yaml content
 */
export async function showReleaseYamlFromBranch(branch: string): Promise<string> {
  const ref = resolveBranch(branch);
  fetchBranch(branch);
  return await readFileFromGit(ref, 'release.yaml');
}

/**
 * Read index.yaml from branch
 *
 * @param branch - Branch name (e.g., "release-v2.14")
 * @returns Raw index.yaml content
 */
export async function showIndexYamlFromBranch(branch: string): Promise<string> {
  const ref = resolveBranch(branch);
  fetchBranch(branch);
  return await readFileFromGit(ref, 'index.yaml');
}
