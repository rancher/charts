## Rancher-Charts Release Tracking

<<-- VERSION_INPUTS -->>

---

#### Task Checklist
- [ ] Maintain supply-chain security through `automation-core branch && CI`
- [ ] Out-of-Band Releases && Forward-ports
- [ ] Determine which versions will be released
- [ ] Create respective Confluence tables
- [ ] Public announcement on company Slack
- [ ] Coordination charts release between teams.
- [ ] Execute batch releases
- [ ] Forward Port released charts
- [ ] Release Prime Charts
- [ ] Forward Port released Prime Charts (don't sync again)
- [ ] Update branch references on Rancher before release.
- [ ] Update product confluence table with necessary chart versions.
- [ ] Clean release.yaml at Prime and Rancher Charts post-release
- [ ] Update branch references on Rancher after release.
---

#### Task Info

`Coordination charts release between teams`:
- Negotiate with @Jono-SUSE-Rancher the due date for the Charts release.
- Communicate with company at #team-rancher-release-coordination channel the proper dates.

`Execute batch releases for all versions`:
- Merge the batch releases.
- Forward-port released charts from previous branches.
- Release forward-ported charts from previous branches.
- Monitor git mirror
- Communicate results to the company.

`Update branch references for all versions on Rancher before release`:
- Merge update from `dev-v2.*` to `release-v2.*` branch references.

`Update branch references for all versions on Rancher after release`:
- Merge update from `release-v2.*` back to `dev-v2.*` branch references



