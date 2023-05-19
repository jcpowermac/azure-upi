#!/usr/bin/pwsh

. ./variables.ps1

# todo: jcallen: fix me ....
#$ ./openshift-install coreos print-stream-json | jq '.architectures["x86_64"]."rhel-coreos-extensions"."azure-disk".url'

$osUri = "https://rhcos.blob.core.windows.net/imagebucket/rhcos-413.92.202305021736-0-azure.x86_64.vhd"

$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -SkuName "Standard_LRS" -Location $location

New-AzStorageContainer -Name $storageContainerName -Context $storageAccount.Context -Permission Blob

$copy = Start-AzStorageBlobCopy -AbsoluteUri $osUri -DestContainer $storageContainerName -DestBlob "rhcos.vhd" -DestContext $storageAccount.Context

$copy | Get-AzStorageBlobCopyState -WaitForComplete


$blob = Get-AzStorageBlob -Blob "rhcos.vhd" -Container $storageContainerName -Context $storageAccount.Context

$blobUri = $blob.BlobClient.Uri

$imageConfig = New-AzImageConfig -Location $location -HyperVGeneration V2

$managedDisk = Set-AzImageOsDisk -Image $imageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $blobUri

$imageName = "rhcos"

# copy seems racy...
Start-Sleep -Seconds 30

$image = New-AzImage -Image $imageConfig -ImageName $imageName -ResourceGroupName $resourceGroupName


$managedDisk
$image


$osDisk = @{Source = @{Id = $image.Id}}

$gallery = New-AzGallery `
    -GalleryName 'myGallery' `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Description 'Azure Compute Gallery for my organization'


# Why is hyperVGeneration set to V1?

$imageDefinition = New-AzGalleryImageDefinition `
    -GalleryName $gallery.Name `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -Name 'rhcos' `
    -OsState 'Generalized'`
    -OsType 'Linux'`
    -Publisher 'RedHat' `
    -Offer 'rhcos' `
    -Sku 'basic' `
    -HyperVGeneration V2

#$imageVersion = New-AzGalleryImageVersion `
#    -GalleryImageDefinitionName $imageDefinition.Name`
#    -GalleryImageVersionName '1.0.0' `
#    -GalleryName $gallery.Name `
#    -ResourceGroupName $resourceGroupName `
#    -Location $location `
#    -OSDiskImage $osDisk

$imageVersion = New-AzGalleryImageVersion `
    -GalleryImageDefinitionName $imageDefinition.Name`
    -GalleryImageVersionName '1.0.0' `
    -GalleryName $gallery.Name `
    -ResourceGroupName $resourceGroupName `
    -Location $location `
    -SourceImageId $image.Id

