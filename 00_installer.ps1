#!/usr/bin/pwsh

. .\variables.ps1

$ErrorActionPreference = "Stop"
Remove-Item Env:\KUBECONFIG -ErrorAction SilentlyContinue

$releaseStreamUri = "https://amd64.$($project).releases.ci.openshift.org/api/v1/releasestream/$($releaseStream)/latest"


$progressPreference = 'silentlyContinue'
$webrequest = Invoke-WebRequest -Uri $releaseStreamUri
$progressPreference = 'Continue'
$releases = ConvertFrom-Json $webrequest.Content -AsHashtable
$registry = ($releases['pullSpec'] -split '/')[0]

$releases | Format-List

# Set Release Image Override for Installer
$Env:OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE = $releases['pullSpec']

# Read and convert the cloud.redhat.com pull secret
$tempPullSecret = Get-Content -Path $pullSecretFile -Raw
$pullSecretHash = ConvertFrom-Json $tempPullSecret -AsHashtable


# Download `oc`
if (-Not (Test-Path -Path "./bin/oc")) {
    $ocClientUri = "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$($ocClientVersion)/openshift-client-linux.tar.gz"
    #$progressPreference = 'silentlyContinue'
    Invoke-WebRequest -Uri $ocClientUri -OutFile "oc.tar.gz"
    tar -xvf "oc.tar.gz" -C ./bin
    #$progressPreference = 'Continue'
}



# if the installer is missing or the ci registry token file is greater than 12 hours old
if ( (-Not (Test-Path -Path "./bin/openshift-install")) -or (-Not (Test-Path ./secrets/ci.json -NewerThan (Get-Date).AddHours(-12)))) {
    if ( $releases['pullSpec'] -notlike "quay*") {
        $token = Read-Host -Prompt "Token from $($ciTokenUri)" -MaskInput

        # TODO: Change to start-process
        ./bin/oc login --token=$token --server=$ciApiUri
        ./bin/oc registry login --to $ciRegistryAuthFile
        $ciauth = Get-Content -Path $ciRegistryAuthFile -Raw
        $ciHash = ConvertFrom-Json $ciauth -AsHashtable


        if ($pullSecretHash["auths"].ContainsKey($registry)) {
            $pullSecretHash["auths"].Remove($registry)
            $pullSecretHash["auths"].Add($registry, $ciHash["auths"][$registry])
        }
        else {
            $pullSecretHash["auths"].Add($registry, $ciHash["auths"][$registry])
        }
        $pullSecret = ConvertTo-Json $pullSecretHash
        Out-File -FilePath $pullSecretFile -InputObject $pullSecret -Force -Confirm:$false
    }
    else {
        # make a copy of pull-secret.json
        Copy-Item -Path $pullSecretFile -Destination $ciRegistryAuthFile
    }

    ./bin/oc adm release extract --tools $releases['pullSpec'] --registry-config $pullSecretFile

    Get-Item -Path *.tar.gz | ForEach-Object -Process {
        tar -xvf $_ -C ./bin
    }
    Remove-Item -Path *.tar.gz
    Remove-Item -Path *.txt
}
