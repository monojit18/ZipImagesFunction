param([Parameter(Mandatory=$true)] [string] $rg,      
      [Parameter(Mandatory=$true)] [string] $fpath,
      [Parameter(Mandatory=$true)] [string] $deployFileName,
      [Parameter(Mandatory=$true)] [string] $logicAppName,
      [Parameter(Mandatory=$true)] [string] $storageConnectionName,
      [Parameter(Mandatory=$true)] [string] $o365ConnectionName,
      [Parameter(Mandatory=$true)] [string] $storageAccountName)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/LogicApp/$deployFileName.json" `
-logicAppName $logicAppName `
-o365ConnectionName $o365ConnectionName `
-storageConnectionName $storageConnectionName `
-storageAccountName $storageAccountName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/LogicApp/$deployFileName.json" `
-logicAppName $logicAppName `
-o365ConnectionName $o365ConnectionName `
-storageConnectionName $storageConnectionName `
-storageAccountName $storageAccountName
