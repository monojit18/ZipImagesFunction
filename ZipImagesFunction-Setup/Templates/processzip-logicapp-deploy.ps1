param([Parameter(Mandatory=$false)] [string] $rg,      
      [Parameter(Mandatory=$false)] [string] $fpath,
      [Parameter(Mandatory=$false)] [string] $logicAppName,
      [Parameter(Mandatory=$false)] [string] $storageAccountName)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/processzip-logicapp-deploy.json" `
-logicAppName $logicAppName `
-storageAccountName $storageAccountName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/processzip-logicapp-deploy.json" `
-logicAppName $logicAppName `
-storageAccountName $storageAccountName
