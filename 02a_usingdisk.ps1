
#!/usr/bin/pwsh
. ./variables.ps1

$osUri = "https://rhcos.blob.core.windows.net/imagebucket/rhcos-413.92.202305021736-0-azure.x86_64.vhd"


$diskName = "jcallen-temp-disk"
#$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -SkuName "Standard_LRS" -Location $location 

#New-AzStorageContainer -Name $storageContainerName -Context $storageAccount.Context -Permission Blob


$diskConfig = New-AzDiskConfig `
    -Location $location `
    -DiskSizeGB 128 `
    -OsType Linux `
    -AccountType "Standard_LRS" # Specify the appropriate account type

# Create a new managed disk from the VHD blob URI
$disk = New-AzDisk `
    -DiskName $diskName `
    -Disk $diskConfig `
    -ResourceGroupName $resourceGroupName `
    -SourceUri $osUri

# Verify the creation of the managed disk
$disk
