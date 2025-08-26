# Introduction
This repository serves as a way to simply Sentinel content for a customer tenant's Sentinel Workspace.

## Rule deployment logic: 
1. Reads all rules from mdr_root repository and creates a list of them
2. Uses deployment_config.yml to exclude rules explicitly based on the `ExcludeRules` key
3. Looks through the current rule (in the loop logic) and checks for connector deployment status - If a rule is missing one of the connectors listed in the rules requirements it is excluded from the current list.
4. Furthermore the current rule being considered is compared on ID with the existing YAML files within `/customer/artifacts/rules/*.y*ml`. If there is a rule with matching ID - the customer specific one takes precedence. 
5. A workflow to automatically delete rules from the customer's tenant is _being implemented_ and should run automatically

Operational notes:
- To `Add` a rule to all customers, do so in the mdr_root `artifacts/rules` folder in the wanted location. 
- To `exclude` a rule from mdr_root to specific customer, add it to `deployment_config.yml`
- To `override` a rule we add the rule we want to override (simply copy and paste) into the customers artifacts folder - **Keep the original ID**. The ID match is used in the logic to override.
- To `delete` a rule (IN PROGRESS) simply delete the rule:
  - For customer specific - delete in customer repository
  - For all customer - in mdr_root repository
  - The procedure (end result) is that the rule is removed from the customer tenant and the rule is added to the `DeletedRules` in the `deployment_config.yml` file. This is used to keep track of deleted rules and may be used for future reconsiderations. But the real deletion happens with a github action that runs on a schedule and deletes the rules from the customer tenant.
- TODO: Add connector check logis!!!


---

# Azure Lighthouse-based deployment (MDR tenant delegated access)

This template now deploys Sentinel rules to a customer using Azure Lighthouse. The workflow authenticates with a service principal in the MDR tenant and performs deployments under delegated access to the customer subscription.

Key actions
- Login with MDR SP, set the customer subscription via Lighthouse, load customer settings from `deployment-config.yaml` and `lighthouse/lighthouse-template.parameters.json`, then deploy rules.

Prerequisites (one-time per customer)
- Deploy Azure Lighthouse registration to the customer subscription using the template in `lighthouse/lighthouse-template.json`.
  - Ensure `variables.managedByTenantId` matches your MDR tenant ID.
  - In `lighthouse/lighthouse-template.parameters.json`, set:
    - AutomationServicePrincipalID: Object ID of the MDR SP used by the workflow.
    - AutomationServicePrincipalName: Friendly name for the SP.
    - AnalystsGroupID, EngineersGroupID, ManagersGroupID, ReaderGroupID (and PIMApproversGroupID if used): MDR tenant group object IDs.
    - SentinelResourceGroup and SecurityAutomationResourceGroup: target resource groups in the customer subscription.
- The MDR SP must have at least Microsoft Sentinel Contributor (and Reader where applicable) via the Lighthouse definition.

GitHub Actions configuration (per repo)
- Secrets:
  - MDR_AZURE_CREDENTIALS: JSON for azure/login, example:
    ```json
    {"clientId":"<appId>","clientSecret":"<password>","tenantId":"<mdrTenantId>"}
    ```
  - CUSTOMER_SUBSCRIPTION_ID: Customer subscription ID (delegated).
  - PAT_TOKEN: Token with read access to `mdr_root`.
- Optional repository variables (if you do not want to rely solely on config files):
  - AZURE_RG: Customer Sentinel RG.
  - AZURE_WORKSPACE: Customer Sentinel workspace name.

Customer repository configuration
- `deployment-config.yaml` (already in the repo):
  - Settings.WorkSpace-Resource-Group: Sentinel RG name.
  - Settings.Workspace-Name: Sentinel workspace name.
  - Settings.Automation-Resource-Group: Optional, used for automation content later.
- `lighthouse/lighthouse-template.parameters.json`:
  - SentinelResourceGroup and SecurityAutomationResourceGroup: used as fallbacks to determine RGs.
  - AutomationServicePrincipalID and group IDs: ensure they are filled prior to initial Lighthouse deployment.

How the workflow uses these values
- Login with MDR SP -> set customer subscription via Lighthouse.
- Load settings step reads:
  - Primary: `deployment-config.yaml` Settings (Workspace-Name, WorkSpace-Resource-Group).
  - Fallback: `lighthouse-template.parameters.json` (SentinelResourceGroup, SecurityAutomationResourceGroup).
  - Final fallback: discover first workspace in the RG.
- Exports AZURE_RG and AZURE_WORKSPACE to the job environment.
- Rule deployment uses these env vars and honors ExcludeRules/DeletedRules in `deployment-config.yaml`.

New customer bootstrap steps
1. Create repo from this template.
2. Fill `deployment-config.yaml` Settings (Workspace-Name, WorkSpace-Resource-Group).
3. Fill `lighthouse/lighthouse-template.parameters.json` with RG names, MDR SP object ID, and MDR group IDs.
4. Deploy Lighthouse template to the customer subscription (one-time).
5. Add GitHub secrets: MDR_AZURE_CREDENTIALS, CUSTOMER_SUBSCRIPTION_ID, PAT_TOKEN.
6. Optionally add variables: AZURE_RG, AZURE_WORKSPACE (if not in config files).
7. Run the "Deploy Rules" workflow (manually via Workflow Dispatch or on push to master while testing).

Troubleshooting
- Missing delegated access: Ensure Lighthouse assignment exists and MDR SP/object IDs are correct.
- Workspace not found: Verify Settings in `deployment-config.yaml` or set AZURE_RG/AZURE_WORKSPACE variables.
- 403 errors from az rest: Check that MDR SP is granted Microsoft Sentinel Contributor via Lighthouse.



# Tagging/relase issues
## Move to the lastest version of the action
```bash
git pull
git tag -a v1.0.0 -m "message"
git tag -fa v1 -m "Move v1 to latest release"
git push origin v1.0.0
git push origin v1 --force
```