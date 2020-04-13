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
Write-Host $logicAppURL

# Get EventHub Values
$outputValues = $logicAppOutput[1].Outputs.Values

foreach ($item in $outputKeys)
{
      $keysList.Add($item)
}

$index = 0;
foreach ($item in $outputValues)
{
      
      $logicAppURLKey = $keysList[$index]
      $logicAppURL = $item.Value

      $logicAppURLObject = ConvertTo-SecureString `
      -String $logicAppURL -AsPlainText -Force

      Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $logicAppURLKey `
      -SecretValue $logicAppURLObject

      ++$index
}

# Clean up KeysList
$keysList.Clear();

#  Function deploy
$logicAppURLCommand = " -logicAppURL '" + $logicAppURL + "'"
$functionDeployPath = $templatesFolderPath + $functionDeployCommand + $logicAppURLCommand

Invoke-Expression -Command $functionDeployPath