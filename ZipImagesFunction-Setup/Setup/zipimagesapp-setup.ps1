param([Parameter(Mandatory=$false)] [string] $resourceGroup = "<resource_group>",
      [Parameter(Mandatory=$false)] [string] $subscriptionId = "<subscription_id>",
      [Parameter(Mandatory=$false)] [string] $baseFolderPath = "<folder_path>",
      [Parameter(Mandatory=$false)] [string] $keyVaultname = "<keyvault_name>",
      [Parameter(Mandatory=$false)] [string] $objectId = "<object_Id>",
      [Parameter(Mandatory=$false)] [string] $appName = "<app_Name>",
      [Parameter(Mandatory=$false)] [string] $logicAppName = "<logicApp_Name>",
      [Parameter(Mandatory=$false)] [string] $storageAccountName = "<storageAccount_Name>")

$templatesFolderPath = $baseFolderPath + "/Templates"
$keyvaultDeployCommand = "/keyvault-deploy.ps1 -rg $resourceGroup -fpath $templatesFolderPath -keyVaultName $keyVaultName -objectId $objectId"
$logicAppDeployCommand = "/processzip-logicapp-deploy.ps1 -rg $resourceGroup -fpath $templatesFolderPath -logicAppName $logicAppName -storageAccountName $storageAccountName"
$functionDeployCommand = "/zipimagesapp-deploy.ps1 -rg $resourceGroup -fpath $templatesFolderPath -appName $appName -storageAccountName $storageAccountName"

# # PS Logout
# Disconnect-AzAccount

# # PS Login
# Connect-AzAccount

# PS Select Subscriotion 
Select-AzSubscription -SubscriptionId $subscriptionId

#  KeyVault deploy
$keyvaultDeployPath = $templatesFolderPath + $keyvaultDeployCommand
Invoke-Expression -Command $keyvaultDeployPath

#  Logic App deploy
$logicAppDeployPath = $templatesFolderPath + $logicAppDeployCommand
$logicAppOutput = Invoke-Expression -Command $logicAppDeployPath
$logicAppURL = $logicAppOutput[1].Outputs.Values[0].Value
Write-Host $logicAppURL

#  Function deploy
$logicAppURLCommand = " -logicAppURL '" + $logicAppURL + "'"
$functionDeployPath = $templatesFolderPath + $functionDeployCommand + $logicAppURLCommand

Invoke-Expression -Command $functionDeployPath