param([Parameter(Mandatory=$false)] [string] $rg,      
      [Parameter(Mandatory=$false)] [string] $fpath,
      [Parameter(Mandatory=$true)]  [string] $deployFileName,
      [Parameter(Mandatory=$false)] [string] $logicAppName,
      [Parameter(Mandatory=$false)] [string] $o365ConnectionName,
      [Parameter(Mandatory=$false)] [string] $storageAccountName)

Test-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/LogicApp/$deployFileName.json" `
-logicAppName $logicAppName `
-o365ConnectionName $o365ConnectionName `
-storageAccountName $storageAccountName

New-AzResourceGroupDeployment -ResourceGroupName $rg `
-TemplateFile "$fpath/LogicApp/$deployFileName.json" `
-logicAppName $logicAppName `
-o365ConnectionName $o365ConnectionName `
-storageAccountName $storageAccountName
