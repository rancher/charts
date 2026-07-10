#!/usr/bin/env node
import { populateReleaseCharts } from './commands/populate-release-charts.js';

// CLI entry point
if (import.meta.url === `file://${process.argv[1]}`) {
  const argv = process.argv.slice(2);
  const command = argv[0];

  (async () => {
  try {
    switch (command) {
    case 'populate-release-charts': {
      // Usage: populate-release-charts <version> <yaml-path> <dev-branch> <release-branch>
      const releaseVersion = argv[1];
      const yamlPath = argv[2];
      const devBranch = argv[3];
      const releaseBranch = argv[4];

      if (!releaseVersion || !yamlPath || !devBranch || !releaseBranch) {
        console.error('Usage: populate-release-charts <version> <yaml-path> <dev-branch> <release-branch>');
        process.exit(1);
      }

      console.log(`Populating release ${releaseVersion}`);
      console.log(`  YAML: ${yamlPath}`);
      console.log(`  Dev: ${devBranch}`);
      console.log(`  Release: ${releaseBranch}`);

      const result = await populateReleaseCharts({
        releaseVersion,
        yamlPath,
        devBranch,
        releaseBranch
      });

      console.log(`\nAdded ${result.added} chart(s):`);
      for (const chart of result.charts) {
        console.log(`  - ${chart}`);
      }

      process.exit(0);
      break;
    }

    case 'sync-table': {
      // Usage: sync-table <version> <yaml-path>
      const releaseVersion = argv[1];
      const yamlPath = argv[2];

      if (!releaseVersion || !yamlPath) {
        console.error('Usage: sync-table <version> <yaml-path>');
        process.exit(1);
      }

      console.log('TODO: sync-table implementation');
      console.log(`  Version: ${releaseVersion}`);
      console.log(`  YAML: ${yamlPath}`);

      process.exit(0);
      break;
    }

    default:
      console.error(`Unknown command: ${command}`);
      console.error('Available commands:');
      console.error('  - populate-release-charts');
      console.error('  - sync-table');
      process.exit(1);
    }
  } catch (err) {
    console.error(`Error: ${(err as Error).message}`);
    process.exit(1);
  }
  })();
}
