param([Parameter(Mandatory=$false)] [string] $rg,
      [Parameter(Mandatory=$false)] [string] $fpath,
      [Parameter(Mandatory=$false)] [string] $appName,
      [Parameter(Mandatory=$false)] [string] $storageAccountName,
      [Parameter(Mandatory=$false)] [string] $logicAppURL)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/zipimagesapp-deploy.json" `
-appName $appName -logicAppURL $logicAppURL `
-storageAccountName $storageAccountName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/zipimagesapp-deploy.json" `
-appName $appName -logicAppURL $logicAppURL `
-storageAccountName $storageAccountName
