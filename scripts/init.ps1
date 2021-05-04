[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $Command
)

if (Get-Service 'Docker' -ErrorAction SilentlyContinue) {
    if ((Get-Service Docker).Status -ne 'Running') { Start-Service Docker }
    while ((Get-Service Docker).Status -ne 'Running') { Start-Sleep -s 5 }

    Start-Process -NoNewWindow -FilePath "docker.exe" -ArgumentList "$($Command)"
    exit 0
}
else {
    Write-Host "Docker Service was not found! Could not init RKE."
    exit 1
}