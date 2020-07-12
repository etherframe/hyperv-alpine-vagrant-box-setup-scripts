param (
    [string]$VmName = "vagrant",
    [string]$OutputDirectory = $PSScriptRoot
)

If (Get-VM -Name $VmName -ErrorAction SilentlyContinue) {
    $ExportOutputDirectory = Join-Path $OutputDirectory ("export-$VmName-" + (Get-Date -Format yyyyMMddHHmmss))
    Try {
        Export-VM -Name $VmName -Path $ExportOutputDirectory
        $ExportedFilesRootPath = Join-Path $ExportOutputDirectory $VmName

        $BoxPath = Join-Path $OutputDirectory "$VmName.box"
        $ZipInputPaths =
            (Join-Path $PSScriptRoot "metadata.json"),
            (Join-Path $ExportedFilesRootPath "Virtual Hard Disks"),
            (Join-Path $ExportedFilesRootPath "Virtual Machines")
        7z a -t7z $BoxPath @ZipInputPaths
        If ($LASTEXITCODE -eq 0) {
            Write-Output "Packaging is complete. Box is located at: $BoxPath"
        }
    } Finally {
        Remove-Item -Path $ExportOutputDirectory -Recurse -Force -ErrorAction Ignore
    }
} Else {
    Write-Error "A VM with the name '$VmName' doesn't exist."
}