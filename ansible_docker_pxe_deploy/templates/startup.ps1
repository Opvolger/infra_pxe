[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

$hostname = "{{ boot_ipxe.samba.hostname }}"
$share = "{{ boot_ipxe.samba.share }}"
$username = "{{ boot_ipxe.samba.username }}"
$password = "{{ boot_ipxe.samba.password }}"

Start-Sleep -s 15

CMD /C VER

net use s: \\${hostname}\${share} $password /user:WORKGROUP\$username

Write-Output (Get-Date)

Start-Sleep -s 15

Start-Process -FilePath "S:\iso\{{ item.name_os }}/{{ item.version }}/{{ item.arch }}\setup.exe" -Wait
