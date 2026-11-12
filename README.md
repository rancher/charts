# chart-owners

The composite actions that a chart repository calls to release a chart: they
stamp, check, package and push it to the staging registry, and start the
`chart-staged` workflow of this repository, which ships and indexes it in a pull
request against `staging`.

The branch holds only the actions and the templates, so its head moves only when
they change. On `staging` every released chart is a commit, so following or
pinning a commit of `staging` would change with every release even when the
actions did not.

| Path | What it is |
|------|------------|
| [`.github/actions/ship-staged`](.github/actions/ship-staged/action.yaml) | Releases one chart. |
| [`.github/actions/ship-family-staged`](.github/actions/ship-family-staged/action.yaml) | Releases the charts of a family together, in one pull request. |
| [`.github/templates`](.github/templates) | Scripts to copy into the chart repository and adapt, to prepare the chart folder from a release tag. |

## Use

```yaml
- uses: rancher/charts/.github/actions/ship-staged@chart-owners
```

A repository that pins its actions to a commit SHA uses the SHA of a commit of
this branch instead of `chart-owners`, and updates it when the actions change.

What to ask EIO for, how to prepare the chart folder, and what happens next are
in the [guide for chart owners](https://github.com/rancher/cargueiro/blob/main/docs/CHART_OWNER.md).

## Changes

Every change is a pull request into this branch, reviewed by the release team:
the actions run in the release jobs of the chart repositories, with their
credentials. The `chart-staged` workflow is not here, it is on `staging`, the
default branch, because a dispatch only starts a workflow that is there.
