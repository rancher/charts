#!/usr/bin/env node
import { populateReleaseCharts } from './commands/populate-release-charts.js';
import { findReleaseYaml } from './adapters/yaml.js';

// CLI entry point
if (import.meta.url === `file://${process.argv[1]}`) {
  const argv = process.argv.slice(2);
  const command = argv[0];

  (async () => {
  try {
    switch (command) {
    case 'populate-release-charts': {
      // Usage: populate-release-charts <minor-version>
      const minorVersion = argv[1]; // "2.14"

      if (!minorVersion) {
        console.error('Usage: populate-release-charts <minor-version>');
        console.error('Example: populate-release-charts 2.14');
        process.exit(1);
      }

      const { yamlPath, releaseVersion } = findReleaseYaml(minorVersion);
      const devBranch = `dev-v${minorVersion}`;
      const releaseBranch = `release-v${minorVersion}`;

      console.log(`Found: ${yamlPath}`);
      console.log(`Version: ${releaseVersion}`);
      console.log(`Dev: ${devBranch}`);
      console.log(`Release: ${releaseBranch}`);

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

    case 'detect-qa-done': {
      // Usage: detect-qa-done <base-ref> <file1,file2,...>
      const baseRef = argv[1];
      const filesArg = argv[2];

      if (!baseRef || !filesArg) {
        console.error('Usage: detect-qa-done <base-ref> <file1,file2,...>');
        process.exit(1);
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
      console.error('  - detect-qa-done');
      console.error('  - sync-table');
      process.exit(1);
    }
  } catch (err) {
    console.error(`Error: ${(err as Error).message}`);
    process.exit(1);
  }
  })();
}
