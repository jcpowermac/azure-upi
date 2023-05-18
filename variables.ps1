#!/usr/bin/pwsh

$resourceGroupName = "jcallen-temp-rg"

$location = "centralus"

$vnetSubnet = "10.0.0.0/16"
$vnetName = "jcallen-temp-vnet"

$masterAddressPrefix = "10.0.0.0/24"
$masterVirtualNetworkSubnetName = "jcallen-temp-master-subnet"


$workerAddressPrefix = "10.0.1.0/24"
$workerVirtualNetworkSubnetName = "jcallen-temp-worker-subnet"


$storageAccountName = "jcallentempsan"

$storageContainerName = "jcallencontain"



$galleryImageDefinitionName = "rhcos"
$imageVersion = "1.0.0"

$galleryName = "jcallen-gallery"

# turn off annoying messages
Update-AzConfig -DisplayBreakingChangeWarning $false