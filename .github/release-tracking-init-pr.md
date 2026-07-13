## Initialize Release Tracking YAMLs

This PR creates new release tracking YAML files and populates them with chart versions from the corresponding dev branches.

### What happened

1. Created YAML files from `templates/release-versions.yaml`
2. Ran `populate-release-charts` CLI for each version
3. Populated chart versions by reading dev branch `release.yaml` and release branch `index.yaml`

### What to review

- Verify YAML files match expected release versions
- Check chart versions populated correctly from dev branches
- Confirm no unexpected charts or versions included
