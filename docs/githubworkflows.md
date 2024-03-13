## Github Actions Workflows

- Defined workflows at: `.github/workflows`
- Developing useful files at: `.github/dev`
- CODEOWNER files at: `.github/CODEOWNER`

Useful Links:
- https://github.com/nektos/act
- https://nektosact.com/usage/index.html

### Developing

In order to develop github actions workflows you may test it by making `Pull Requests` after each modification or locally using `act`.
I recommend you work with `act` being mindful to not modify any existing `Pull Requests`.

> Most of our workflows are triggered by `Pull Requests`.

The best way to debug is by using `console.log()` function while executing it locally.

How-to:

1. Install `act` locally: `curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash`
2. Move to your path: (e.g: `/usr/local/bin`)
3. Paste your Github PAT at `.github/dev/.secrets`:
    ```
    GITHUB_TOKEN=################################
    ```
4. In order to just run all workflows locally:
    ```
    act pull_request --secret-file .github/dev/.secrets
    ```

Useful execution examples:

| Action                                                        | Command                                                                                                            |
|---------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| List all workflows for a given event                          | `act -l pull_request`                                                                                              |
| Run all workflows for pull_request event without custom Event | `act pull_request --secret-file .github/dev/.secrets`                                                              |
| Run specific Workflow with Defined Event                      | `act -W '.github/workflows/validation-comment.yaml' --secret-file .github/dev/.secrets -e .github/dev/events.json` |


There is a shortcut command defined at `Makefile`:

```
git-workflow:
	act -W '.github/workflows/validation-comment.yaml' --secret-file .github/dev/.secrets -e .github/dev/events.json
```

#### Events
When you're testing GitHub Actions locally with act, the context doesn't have the same information as it would when running on GitHub.

To work around this, you can use a local event payload file with act.

This file can simulate the payload of a `pull_request_target` event.

Here's an example of how you can create a event.json file:

```
{
  "pull_request": {
    "number": 1,
    "head": {
      "ref": "my-branch",
      "sha": "abc123"
    }
  },
  "repository": {
    "owner": {
      "login": "my-username"
    },
    "name": "my-repo"
  }
}
```


#### Edge-cases

There is a difference between `pull_request` and `pull_request_target`.

Both are events that can trigger a workflow whenever a pull request is opened, synchronized, or closed, but:

- `pull_request`: If the PR is from a fork, it will run with the fork permissions, this means it will have **read-only permissions to the base repository and no acess to secrets**.
- `pull_request_target`: Runs with the permissions of the base repository even if the PR comes from a forked repository. Since it has write-permissions and access to secrets, this is useful for workflows that need to write or change in some way the Pull Requests.