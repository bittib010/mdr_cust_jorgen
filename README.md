# Introduction
This repository serves as a way to simply deploy Sentinel and content for Sentinel to a customer tenants Sentinel Workspace.

# Consulent work
## High overview
- Run deployment Powershell script to deploy with customer:
Enter the step to start with:
  - Add and register resource providers
  - Create Monitor and Automation Resource Groups
  - Deploy Lighthouse Template
  - Create Entra ID Groups and Assign Azure RBAC Roles
  - Invite External Users and Add Them to Groups
  - Configure Defender XDR and Custom Role Assignments
  - Provision Teams (Team and Channels)
  - Deploy Sentinel
  - Set Resource Locks and Final Cleanup
  - Create Entra Groups for the customer
- Start delivering content on CI/CD:
  - Runs on a per needed basis.

## Deploy rules and rule updates workflow
- Create a new repository based on cust_template
- Add the needed parameters into deployment_config.yml
- Run the CI/CD for the deploy content (rules, playbooks, workbooks etc)

### Rule deployment logic: 
1. Reads all rules from mdr_root and creates a list of them
2. Uses deployment_config.yml to exclude rules explicitly based on the `ExcludeRules` key
3. Looks through the current rule being considered and checks for connector deployment status - If a rule is missing one of the connectors listed in the rules requirements it is excluded from the current list.
    <span style="color:red">TODO: Some connectors write to the same table - and a rule might therefore run even if the connector is not listed. Consider adding connector groupins to cover this. Another approach is also to create rule overrides for these scenarios. Less overhead now, but no overhead once created </span>
4. Furthermore the current rule being considered is compared on ID with the existing YAML files within /customer/artifacts/*.y*ml. If there is a rule with matching ID - the customer specific one takes precedence. 
5. A workflow to automatically delete rules from the customer's tenant is being implemented and should run automatically

Operational notes:
- To `Add` a rule to all customers, do so in the mdr_root `artifacts` folder in the wanted location. 
- To `exclude` a rule from mdr_root to specific customer, add it to `deployment_config.yml`
- To `override` a rule we add the rule we want to override (simply copy and paste) into the customers artifacts folder - **Keep the original ID**. The ID match is used in the logic to override.
- To `delete` a rule (IN PROGRESS) simply delete the rule:
  - For customer specific - delete in customer repository
  - For all customer - in mdr_root repository


## Rule additions
Automatic workflow for adding rules from Azure Github repository should preferrably be done via a simple GUI that let's us keep an overview of all active, deployed, deleted, overriden, excluded etc rules for all customers. 

Wanted functionality:
- Do a git pull for all customers
- Scan folders on opening the application for all rules
- All analysts have their own workspace setup (folder structure wise). So a few options to detect customers:
    - Scan iteratively from a given location for `deployment_config.yml` file to decide if the current scanned location is a customer
    - Add that customer root folder as an input to the application
- When all customer locations has been found - scan them for rules (artifacts folder), excluded rules in the deployment config file, Deleted files may be commented in the `DeletedRules` in the deployment config file. This list is optionally kept there and may serve as input to why rule is not present at customer. Helps for future reconsiderations. 
- Pagination

*Getting rules from Azure Repository Locally*
The application is a simple "moving files" type of application. It should scan for y*ml files in a given path recursively. If there are any findings, add it to the list and get these fields out from the YAML file:
- Name
- ID
- MITRE (Both techniques and tactics)
- Connectors and tables
- Type (and calculate if the type is not there if it is a hunting rule)
- Version
- Severity

*Comparing Azure available rules with current rules*
We should now check to see which rules we have in mdr_root and the customer specific locations.
Each customer should have a column of their own used to set a flag for deployed, excluded, overridden etc.
There might be rules in these repositories that are not present in the azure repo. So we should also have a root placement of the files. For overrides where there are multiple files with same ID, we know that location for that specific customer as good as we need to to find it quickly - the root location is good enough. 



# TODO
- Add git app token based approach as this is way more safe than current test solution is:
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