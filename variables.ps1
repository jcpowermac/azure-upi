#!/usr/bin/pwsh


# Modify these variables below for your environment

$ciTokenUri = "https://oauth-openshift.apps.ci.l2s4.p1.openshiftapps.com/oauth/token/request"
$ciApiUri = "https://api.ci.l2s4.p1.openshiftapps.com:6443"

# Find release stream here
# https://amd64.origin.releases.ci.openshift.org/
# https://amd64.ocp.releases.ci.openshift.org/
# The latest will be used.
$releaseStream = "4-stable" # 4-dev-preview or 4-stable
$project = "ocp" # this should be origin or ocp

# https://mirror.openshift.com/pub/openshift-v4/clients/ocp/
$ocClientVersion = "stable-4.13"


$ciRegistryAuthFile = "secrets/ci.json"
$pullSecretFile = "secrets/pull-secret.json"


$resourceGroupName = "jcallentemprg"

$location = "centralus"

$vnetSubnet = "10.0.0.0/16"
$vnetName = "jcallentempvnet"

$masterAddressPrefix = "10.0.0.0/24"
$masterVirtualNetworkSubnetName = "jcallentempmastersubnet"


$workerAddressPrefix = "10.0.1.0/24"
$workerVirtualNetworkSubnetName = "jcallentempworkersubnet"


$storageAccountName = "jcallentempsan"

$storageContainerName = "jcallencontain"



$galleryImageDefinitionName = "rhcos"
$imageVersion = "1.0.0"

$galleryName = "jcallengallery"

# turn off annoying messages
Update-AzConfig -DisplayBreakingChangeWarning $false | Out-Null
