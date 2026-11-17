# How this repository works

This repository holds the catalog of the Rancher charts in two branches, and every
workflow that moves charts between them runs from one of them.

## The branches

| Branch | What it is | What it has |
|---|---|---|
| `staging` | The default branch. Charts arrive here first, and everything is automated from here. | The catalog being built (`entries/`, `legacy/`, `assets/`, `index.yaml`), and every workflow, script and doc. |
| `production` | What customers see. | Only the catalog (`index.yaml`, `entries/`, `legacy/`, `assets/logos/`), the README and the owners file. |

`production` has no workflows on purpose: it is the end product, and nothing there is
for anyone but the people who read the catalog. The workflows that write to it run
from `staging`, check `production` out by name, and open a pull request against it.
If something ever has to live on `production`, it is a trade-off to decide, not a
default.

Two things follow from it:

- A workflow can only be started by hand when its file is on the default branch, which
  is `staging`, so one place starts everything.
- A check on a pull request reads its workflow from the branch the pull request is
  for, so none would run on a pull request to `production`. The audit of `production` is
  a workflow of `staging` that starts on `pull_request_target`, which runs the workflow of
  the default branch for a pull request to another one, and the ruleset of `production`
  requires its check. It only reads the pull request as data, and nothing in it is run.

## The workflows

They are in `.github/workflows/`, and the logic that is more than a few lines is in a
script of `.github/scripts/` that can be run by hand. Each one has its purpose and its
inputs written at the top of its file.

| Workflow | What it does | How it starts |
|---|---|---|
| `chart-staged` | Ships a chart that another repository pushed to the staging registry: writes its entry, rebuilds the index and opens a pull request to `staging`. | Dispatched by the repository that pushed the chart. |
| `audit` | Checks every pull request to `staging` against the staging registry. | A pull request to `staging`. |
| `audit-production` | Checks every pull request to `production` against the production registry, the legacy versions included, and is the check its ruleset requires. | A pull request to `production`. |
| `legacy-import` | Brings the versions of the old system (`release-v2.15`, Rancher 2.10 to 2.15) into `staging` as legacy versions: pushes each chart to the staging registry and opens a pull request with one commit for each family. | By hand. |
| `legacy-release` | Releases to `production` the legacy versions that `staging` has: copies each chart from the staging registry to the production one, and opens a pull request to `production`. It takes a `family` input, and a release of everything is more than one run can copy, so it is run a family at a time. | By hand. |
| `chart-released` | Will release the charts of the new system to `production`. It does nothing yet. | By hand. |
| `pages` | Will publish the index of `production` over HTTP with GitHub Pages. It is switched off. | By hand. |
| `auto-bump-manual-trigger`, `retry-failed-jobs` | Were here before these ones, and are not described here. | See the files. |

Start the ones that run by hand with `gh workflow run <file> --repo rancher/charts --ref staging`.

## The legacy versions

The versions of the old system are in `legacy/<chart>/<version>.yaml`: the entry of the
old index as it was, with its URL changed to point to the manifest of the chart in the
registry. `legacy-import` writes them to `staging`, and `legacy-release` to `production`.

- Both can run again at any time: what is done is not done twice, and a tag the registry
  has with the same content is adopted. A tag that has other content is never
  overwritten, and is reported.
- A version that fails does not stop the others. What went through is in the pull
  request, and the run fails at the end.
- **Merge their pull requests with a merge commit or a rebase, never a squash.** A squash
  would put every family in one commit.
- `legacy-release` installs the latest release of `cargueiro`, and its `cargueiro_version`
  input names another one.

## Credentials

The workflows read the registry and App credentials from Vault, as `chart-staged` does,
and `cargueiro` only sends each pair to its own registry. Reading the staging catalog and
pushing to it use the staging registry credentials. Writing the production registry uses
its own, which only `legacy-release` loads. A dry run of `legacy-release` loads none.

## Still to decide

- How the index of `production` is published with GitHub Pages: a workflow that
  deploys it, or Pages deploying straight from the branch.
