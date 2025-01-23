#### Pull Requests Rules

- `Never remove an already released chart!`
    - This does not apply to RC's because they are not released.
- Each Pull Request should only modify one chart with its dependencies.

- Pull request title:
    ```
    [dev-v2.X] <chart> <version> <action>
    ```
    - `<action>`: 1 of (bump; remove; UnRC)

---

##### Checkpoints for Chart Bumps

`release.yaml`:
- [ ] Each chart version in release.yaml DOES NOT modify an already released chart. If so, stop and modify the versions so that it releases a net-new chart.
- [ ] Each chart version in release.yaml IS exactly 1 more patch or minor version than the last released chart version. If not, stop and modify the versions so that it releases a net-new chart.

`Chart.yaml and index.yaml`:
- [ ] The `index.yaml` file has an entry for your new chart version.
- [ ] The `index.yaml` entries for each chart matches the `Chart.yaml` for each chart.
- [ ] Each chart has ALL required annotations
  - kube-version annotation
  - rancher-version annotation
  - permits-os annotation (indicates Windows and/or Linux)

---

Fill the following only if required by your manager.

##### Issue: <!-- link the issue or issues this PR resolves here -->
<!-- If your PR depends on changes from another pr link them here and describe why they are needed in your solution section. -->

##### Solution
<!-- Describe what you changed to fix the issue. Relate your changes back to the original issue / feature and explain how this addresses the issue. -->

##### QA Testing Considerations
<!-- Highlight areas or (additional) cases that QA should test w.r.t a fresh install as well as the upgrade scenarios -->