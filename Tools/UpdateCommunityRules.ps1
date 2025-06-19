# Take input parameters of path to all customer locations (root of customer)
# Make synopsis
<#
.SYNOPSIS
    This script updates community rules for all customers based on the rules from Azure Sentinel repository on Github.
.DESCRIPTION
    This script takes a path to all customer locations (root of customer) and updates the community rules for each customer after a git pull has been initiated. 

    # CustomerRootPath should be a multi input parameter that allows the user to specify multiple paths.
.PARAMETER CustomerRootPath
    The root path where all customer directories are located. Each customer directory should contain a 'CommunityRules' folder.
    
#>
