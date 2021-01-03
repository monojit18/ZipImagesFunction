param([Parameter(Mandatory=$false)] [string] $resourceGroup = "serverless-workshop-rg",
      [Parameter(Mandatory=$true)] [string] $location = "eastus",
      [Parameter(Mandatory=$true)]  [string] $keyVaultName = "srvlswkshkv",      
      [Parameter(Mandatory=$true)]  [string] $vnetName = "srvless-workshop-vnet",
      [Parameter(Mandatory=$true)]  [string] $vnetPrefix = "190.0.0.0/20",        
      [Parameter(Mandatory=$true)]  [string] $subnetName = "srvless-workshop-subnet",
      [Parameter(Mandatory=$true)]  [string] $subNetPrefix = "190.0.0.0/24",
      [Parameter(Mandatory=$true)]  [string] $kvTemplateFileName = "keyvault-deploy",
      [Parameter(Mandatory=$true)]  [string] $networkTemplateFileName = "network-deploy",
      [Parameter(Mandatory=$true)]  [string] $laTemplateFileName = "logicapp-deploy",
      [Parameter(Mandatory=$true)]  [string] $functionTemplateFileName = "zipimagesapp-deploy",
      [Parameter(Mandatory=$true)]  [string] $appName = "ZipImagesApp",
      [Parameter(Mandatory=$false)] [string] $logicAppName = "<logicApp_Name>",
      [Parameter(Mandatory=$false)] [string] $o365ConnectionName = "<Office365_Connection_Name>",
      [Parameter(Mandatory=$true)]  [string] $storageAccountName = "<storageAccount_Name>",
      [Parameter(Mandatory=$true)]  [string] $objectId = "<object_Id>",
      [Parameter(Mandatory=$true)]  [string] $subscriptionId = "<subscription_id>",
      [Parameter(Mandatory=$false)] [string] $baseFolderPath = "<folder_path>")

$templatesFolderPath = $baseFolderPath + "/Templates"

$keyvaultDeployCommand = "/KeyVault/$kvTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $kvTemplateFileName -keyVaultName $keyVaultName -objectId $objectId"

$networkNames = "-vnetName $vnetName -vnetPrefix $vnetPrefix -subnetName $subnetName -subNetPrefix $subNetPrefix"
$networkDeployCommand = "/Network/$networkTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $networkTemplateFileName $networkNames"

$logicAppDeployCommand = "/LogicApp/$laTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -logicAppName $logicAppName -o365ConnectionName $o365ConnectionName -storageAccountName $storageAccountName"

$functionDeps = "-appName $appName -storageAccountName $storageAccountName"
$functionDeployCommand = "/ZipImagesApp/$functionTemplateFileName.ps1 -rg $resourceGroup -fpath $templatesFolderPath -deployFileName $functionTemplateFileName $functionDeps"

# PS Select Subscription 
Select-AzSubscription -SubscriptionId $subscriptionId

# CLI Select Subscriotion 
$subscriptionCommand = "az account set -s $subscriptionId"
Invoke-Expression -Command $subscriptionCommand

$rgRef = Get-AzResourceGroup -Name $resourceGroup -Location $location
if (!$rgRef)
{

   $rgRef = New-AzResourceGroup -Name $resourceGroup -Location $location
   if (!$rgRef)
   {
        Write-Host "Error creating Resource Group"
        return;
   }

}

$vnetDisconnectCommand = "az webapp vnet-integration remove --name $appName --resource-group $resourceGroup"
Invoke-Expression -Command $vnetDisconnectCommand

$slotNamesList = @("Dev", "QA")
foreach ($slotName in $slotNamesList)
{      
      $vnetDisconnectCommand = "az webapp vnet-integration remove --name $appName --resource-group $resourceGroup -s $slotName"
      Invoke-Expression -Command $vnetDisconnectCommand

}

$LASTEXITCODE
if (!$?)
{

      Write-Host "Error Disconnecting exsitng VNET integration for $appName"

}

# Network deploy
$networkDeployPath = $templatesFolderPath + $networkDeployCommand
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroup
if (!$vnet)
{

      Invoke-Expression -Command $networkDeployPath
      
}
else
{

      $subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
      if (!$subnet)
      {

            $subnet = Add-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet -AddressPrefix $subNetPrefix
            if (!$subnet) 
            {

                  Write-Host "Error adding Subnet for $appName"

            }
            else
            {
                  Set-AzVirtualNetwork -VirtualNetwork $vnet

            }

      }
}

#  KeyVault deploy
$keyvaultDeployPath = $templatesFolderPath + $keyvaultDeployCommand
Invoke-Expression -Command $keyvaultDeployPath

#  Logic App deploy
$logicAppDeployPath = $templatesFolderPath + $logicAppDeployCommand
$logicAppOutput = Invoke-Expression -Command $logicAppDeployPath

# Get LogicApp URL
$outputValues = $logicAppOutput[1].Outputs.Values
$logicAppURL = ""
foreach ($item in $outputValues)
{
      $logicAppURL = $item.Value
}

#  Function deploy
$logicAppURLCommand = " -logicAppURL '" + $logicAppURL + "'"
$functionDeployPath = $templatesFolderPath + $functionDeployCommand + $logicAppURLCommand
Invoke-Expression -Command $functionDeployPath