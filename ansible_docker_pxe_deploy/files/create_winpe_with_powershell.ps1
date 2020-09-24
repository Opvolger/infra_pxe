# make a empty directory
$tmp_create_winpe = 'C:\temp\winpe'
if (Test-Path -Path $tmp_create_winpe) {
    Remove-Item -Path $tmp_create_winpe -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $tmp_create_winpe

copype amd64 "$tmp_create_winpe\amd64"
copype x86 "$tmp_create_winpe\x86"

Function AddCabsToBootWim([string]$winpe_path)
{
    if (Test-Path -Path ${winpe_path}\mount) {
        Remove-Item -Path ${winpe_path}\mount -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path ${winpe_path}\mount
    Dism /Mount-Image /ImageFile:"${winpe_path}\media\sources\boot.wim" /Index:1 /MountDir:"${winpe_path}\mount"

    # Start: Copy background image
    $acl = Get-Acl "${winpe_path}\mount\Windows\System32\winpe.jpg"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.NTAccount] "Administrators","FullControl","Allow")
    $acl.SetAccessRule($AccessRule)	
    $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
    Set-Acl "${winpe_path}\mount\Windows\System32\winpe.jpg" $acl
    Copy-Item "C:\temp\winpe.jpg" -Destination "${winpe_path}\mount\Windows\System32" -Force
    $acl = Get-Acl "${winpe_path}\mount\Windows\System32\winpe.jpg"
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule([System.Security.Principal.NTAccount] "Administrators","FullControl","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl.SetOwner([System.Security.Principal.NTAccount] "Administrators")
    Set-Acl "${winpe_path}\mount\Windows\System32\winpe.jpg" $acl
    # End: Copy background image

    $winpeocs = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs'

    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\WinPE-WMI.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\en-us\WinPE-WMI_en-us.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\WinPE-NetFX.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\en-us\WinPE-NetFX_en-us.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\WinPE-Scripting.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\en-us\WinPE-Scripting_en-us.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\WinPE-PowerShell.cab"
    Dism /Add-Package /Image:"${winpe_path}\mount" /PackagePath:"${winpeocs}\en-us\WinPE-PowerShell_en-us.cab"

    Dism /Unmount-Image /MountDir:"${winpe_path}/mount" /Commit
}

AddCabsToBootWim "$tmp_create_winpe\amd64"
AddCabsToBootWim "$tmp_create_winpe\x86"
