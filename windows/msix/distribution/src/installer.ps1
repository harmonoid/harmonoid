param(
    [string]$packageName = "harmonoid",
    [switch]$InstallCert,
    [switch]$EnableSideLoad
)

if($InstallCert -or $EnableSideLoad){
    if($InstallCert){
        certutil.exe -addstore TrustedPeople "$PSScriptRoot\$packageName.crt"
    }

    if($EnableSideLoad){
        set-itemproperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowAllTrustedApps -Value 1 -Verbose
    }
    exit 0
}
else{
    $PackageSignature = Get-AuthenticodeSignature "$PSScriptRoot\$packageName.msix"
    $PackageCertificate = $PackageSignature.SignerCertificate

    if (!$PackageCertificate)
    {
    	throw "Usigned package"
    	exit -1
    }

    $enableSideLoad = (test-path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock) -and ((get-item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock).Property.Count -ne 0)

    if($enableSideLoad){
        $enableSideLoad = (get-itemproperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowAllTrustedApps).AllowAllTrustedApps -ne 1
    }

    $trustCert = $PackageSignature.Status -ne "Valid"

    if ($enableSideLoad -or $trustCert)
    {
        $RelaunchArgs = '-ExecutionPolicy Bypass -file "' + "$PSScriptRoot\installer.ps1" + '"' + " $packageName"
    
        if($trustCert){
            $RelaunchArgs += " -InstallCert"
        }

        if($enableSideLoad){
            $RelaunchArgs += " -EnableSideLoad"
        }

        $AdminProcess = Start-Process "powershell.exe" -Verb RunAs -WorkingDirectory $PSScriptRoot -ArgumentList $RelaunchArgs -Wait
    }

    Invoke-Item "$PSScriptRoot\$packageName.msix"
}