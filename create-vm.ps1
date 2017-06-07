param (
    [Parameter(Mandatory=$True)][string]$IsoPath,
    [string]$VmName = "vagrant",
    [string]$VhdDirectory = Join-Path ([System.Environment]::GetFolderPath("CommonDocuments")) "Hyper-V\Virtual Hard Disks"
)

If (Get-VM -Name $VmName -ErrorAction SilentlyContinue) {
    Write-Error "The VM was not created because a VM with the name '$VmName' already exists."
} Else {
    $VhdPath = Join-Path $VhdDirectory "$VmName.vhdx"
    Remove-Item -Path $VhdPath -Force -ErrorAction Ignore
    New-VM -Name $VmName -Generation 1 -MemoryStartupBytes 512MB -BootDevice CD -NewVHDPath $VhdPath -NewVHDSizeBytes 20GB -SwitchName "Hyper-V Switch"
    Set-VMMemory -VMName $VmName -DynamicMemoryEnabled $False
    Set-VMDvdDrive -VMName $VmName -Path $IsoPath
}