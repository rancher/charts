#!/usr/bin/env node
import { writeFileSync } from 'fs';
import { addChart } from './commands/add-chart.js';
import { updateQA } from './commands/update-qa.js';
import { updateUnRC } from './commands/update-unrc.js';
import { markReleased } from './commands/mark-released.js';
import { removeChart } from './commands/remove-chart.js';
import { parseComment } from './adapters/github.js';
import { parseFlags } from './adapters/flags.js';

const OUTPUT_FILE = 'test/output.md';

/**
 * Executes release tracking command on HTML input
 *
 * Pure transformation function - no I/O, just HTML in → HTML out.
 * Routes command to appropriate handler function.
 *
 * @param command - Command name (add-chart, update-qa, update-unrc, mark-released, remove-chart)
 * @param input - Issue body HTML containing release tracking table
 * @param args - Command arguments (chart, version, owner depending on command)
 * @returns Updated HTML with command applied
 * @throws Error if command unknown or operation fails
 */
export function runCommand(command: string, input: string, args: string[]): string {
  let result = '';

  console.log({ command })
  console.log({ input })
  console.log({ args })

  switch (command) {
  case 'add-chart': {
    // Add new chart row to tracking table
    // Sets data-chart, data-version, data-owner attributes
    // Inserts before <!-- END: CHART_DATA --> marker
    const chart = args[0];
    const version = args[1];
    const owner = args[2];

    result = addChart({
      html: input,
      chart,
      version,
      owner
    });
    break;
  }
  case 'update-qa': {
    // Mark QA sign-off complete for chart
    // Finds row by chart+version, sets data-qa="true", updates cell text
    const chart = args[0];
    const version = args[1];

    result = updateQA({
      html: input,
      chart,
      version
    });
    break;
  }
  case 'update-unrc': {
    // Mark Un-RC complete for chart
    // Finds row by chart+version, sets data-unrc="true", updates cell text
    const chart = args[0];
    const version = args[1];

    result = updateUnRC({
      html: input,
      chart,
      version
    });
    break;
  }
  case 'mark-released': {
    // Mark chart as released
    // Finds row by chart+version, sets data-released="true", updates cell text
    const chart = args[0];
    const version = args[1];

    result = markReleased({
      html: input,
      chart,
      version
    });
    break;
  }
  case 'remove-chart': {
    // Remove chart row from tracking table
    // Finds row by chart+version, removes entire <tr> element
    const chart = args[0];
    const version = args[1];

    result = removeChart({
      html: input,
      chart,
      version
    });
    break;
  }
  default:
    throw new Error(`Unknown command: ${command}`);
  }

  return result;
}

// CLI entry point - only runs when executed directly, not when imported
if (import.meta.url === `file://${process.argv[1]}`) {
  const argv = process.argv.slice(2);

  try {
    const flags = parseFlags(argv);
    const parsed = parseComment(flags.commentBody, flags.commentUser);

    console.log(`Command: ${parsed.command}`);
    console.log(`Args: ${parsed.args.join(', ')}`);

    const result = runCommand(parsed.command, flags.issueBody, parsed.args);
    writeFileSync(OUTPUT_FILE, result);
    console.log(`Updated ${OUTPUT_FILE}`);
    process.exit(0);
  } catch (err) {
    console.error(`Error: ${(err as Error).message}`);
    process.exit(1);
  }
}
