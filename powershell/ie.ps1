Add-WindowsFeature Web-Server
Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value "<p style = `"font-family:Arial,Helvetica,sans-serif;font-size:24px`">$($env:computername)</p>"
Write-Host "Simple IIS site configured."

$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
Stop-Process -Name Explorer -Force
Write-Host "IE Enhanced Security Configuration (IEC) disabled."

set-ItemProperty -Path ‘HKCU:\Software\Microsoft\Internet Explorer\main’ -Name “Start Page” -Value 'http://localhost'
Write-Host "IE homepage set to http://localhost."
