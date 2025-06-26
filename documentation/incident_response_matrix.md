# <Company> Incident Response Matrix

**Customer:** Customer  
**Last update:** <span style="color:red"></span>  

## Response

| Category | Action  | Permissions needed | Playbook |  <Customer> | <COMPANY> |
|----------|---------|--------------------|----------|--------|------------|
| **Entra ID** | Revoke user sessions     | <span style="color:red">Helpdesk Administrator</span>          | <span style="color:green">✅ Deployed</span> | Informed in teams           | Allowed    |
|            | Reset user password                | <span style="color:red">Helpdesk Administrator</span>          | <span style="color:green">✅ Deployed</span> | Informed in teams           | Allowed    |
|            | Block EntraID user                 |  | <span style="color:red">❌</span>           | -        | -          |
| **Email**     | Soft delete emails                  | <span style="color:green">Unified RBAC<br>Email & collaboration advanced actions (manage)</span>         |           |          | Allowed    |
|            | Hard delete emails                 | <span style="color:green">Unified RBAC<br>Email & collaboration advanced actions (manage)</span>         |           |          | Allowed    |
|            | Read email content                 | <span style="color:green">Unified RBAC<br>Email & collaboration content (read)</span>                    |           | Informed in teams           | Allowed    |
| **Endpoints** | Run quick Antivirus scan            | <span style="color:red">Security Administrator</span>          | <span style="color:green">✅ Deployed</span> | Informed in teams           | Allowed    |
|            | Isolate/release infected device    | <span style="color:red">Security Operator</span>               | <span style="color:green">✅ Deployed</span> | Informed in teams           | Allowed    |
|            | Live response | <span style="color:green">Unified RBAC<br>Basic / Advanced live response (manage)</span>                 |           | Informed in teams           | Allowed    |

---

## Additional Actions

| Action | Permissions needed  |  <Customer>      | <COMPANY> |
|--------|---------------------|-------------|-----------|
| Contact with end users                | | Responsible |            |
| Updating tenant allow / blocklist     | <span style="color:red">Security Administrator</span> | Responsible | Responsible|
| Restore isolated users / devices      | | Responsible |            |
