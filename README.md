# Introduction
This repository serves as a way to simply deploy Sentinel and content for Sentinel to a customer tenants Sentinel Workspace.

# Workflows
## Deployment

## Deploy rules and rule updates




# TODO
- Add git app token based approach:
```yaml
  - name: Generate GitHub App Token
    id: app-token
    uses: actions/create-github-app-token@v1
    with:
      # TODO: create the SENTINEL_MDR_WRITE_APP_ID and SENTINEL_MDR_WRITE_PRIVATE_KEY secrets
      # and add them to the repository secrets
      app-id: ${{ vars.SENTINEL_MDR_WRITE_APP_ID }}
      private-key: ${{ secrets.SENTINEL_MDR_WRITE_PRIVATE_KEY }}
      owner: ${{ github.repository_owner }}
      repositories: |
        mdr_root
```