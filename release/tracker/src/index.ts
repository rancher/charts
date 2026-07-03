#!/usr/bin/env node
import { addChart } from './commands/add-chart.js';
import { updateQA } from './commands/update-qa.js';
import { updateUnRC } from './commands/update-unrc.js';
import { markReleased } from './commands/mark-released.js';
import { removeChart } from './commands/remove-chart.js';

const args = process.argv.slice(2);
const command = args[0];

// CLI entry point for release tracking table operations
//
// Dual mode operation:
// 1. Local testing: reads from test/output.md or test/fixtures/issue-body.md, writes to test/output.md
// 2. GHA production: reads from stdin, writes to stdout (when piped)
//
// Commands parse HTML table with data attributes, perform CRUD operations on chart rows

// TODO: Detect stdin vs file mode
// TODO: Read input (stdin or file)

const input = ""; // TODO: Load from stdin or file
let result = '';

switch (command) {
  case 'add-chart': {
    // Add new chart row to tracking table
    // Sets data-chart, data-version, data-owner attributes
    // Inserts before <!-- END: CHART_DATA --> marker
    console.log({ command })

    const chart = args[1];
    const version = args[2];
    const owner = args[3];

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
    console.log({ command })

    const chart = args[1];
    const version = args[2];

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
    const chart = args[1];
    const version = args[2];

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
    console.log({ command })
    // result = markReleased(input, chart, version);
    break;
  }
  case 'remove-chart': {
    // Remove chart row from tracking table
    // Finds row by chart+version, removes entire <tr> element
    console.log({ command })
    // result = removeChart(input, chart, version);
    break;
  }
  default:
    // TODO: Error handling for unknown commands
}

// TODO: Write output (stdout or file)
