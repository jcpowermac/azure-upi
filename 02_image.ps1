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

$imageConfig = New-AzImageConfig -Location $location 

$managedDisk = Set-AzImageOsDisk -Image $imageConfig -OsType 'Linux' -OsState 'Generalized' -BlobUri $blobUri

#$imageName = "rhcos"

#New-AzImage -Image $imageConfig -ImageName $imageName -ResourceGroupName $resourceGroupName 


$galleryImage = New-AzGalleryImage `
    -ResourceGroupName $resourceGroupName `
    -GalleryName $galleryName `
    -GalleryImageDefinitionName $galleryImageDefinitionName `
    -Name $imageVersion `
    -OsState generalized `
    -OsType Linux `
    -DataDiskReferences @(New-AzGalleryDataDiskReference -Lun 0 -ManagedDiskId $managedDisk.Id)

# Create a new shared image gallery
$gallery = New-AzGallery `
    -ResourceGroupName $resourceGroupName `
    -GalleryName $galleryName `
    -Location $location `
    -Description "Shared Image Gallery"

# Publish the image to the shared image gallery
Publish-AzGalleryImageVersion `
    -ResourceGroupName $resourceGroupName `
    -GalleryName $galleryName `
    -GalleryImageDefinitionName $imageDefinitionName `
    -Version $imageVersion `
    -ImageId $galleryImage.Id


$gallery
$galleryImage

