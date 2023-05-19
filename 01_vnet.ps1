#!/usr/bin/pwsh


. ./variables.ps1

# Get-AzLocation | Select-Object -Property Location

$rg = New-AzResourceGroup -Name $resourceGroupName -Location $location

$apiRule = New-AzNetworkSecurityRuleConfig -Name "ocp-api-tcp-6443" -Description "Allow OCP API TCP/6443" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 101 `
    -SourcePortRange * -SourceAddressPrefix * -DestinationAddressPrefix * -DestinationPortRange 6443

$apiSecurityGroup = New-AzNetworkSecurityGroup -ResourceGroupName $rg.ResourceGroupName -Location $location -Name "OCP-API" -SecurityRules $apiRule


$masterSubnet = New-AzVirtualNetworkSubnetConfig -Name $masterVirtualNetworkSubnetName -AddressPrefix $masterAddressPrefix -NetworkSecurityGroup $apiSecurityGroup
$workerSubnet = New-AzVirtualNetworkSubnetConfig -Name $workerVirtualNetworkSubnetName -AddressPrefix $workerAddressPrefix -NetworkSecurityGroup $apiSecurityGroup


New-AzVirtualNetwork -Name $vnetName -AddressPrefix $vnetSubnet -ResourceGroupName $rg.ResourceGroupName -Location $location -Subnet $masterSubnet,$workerSubnet

