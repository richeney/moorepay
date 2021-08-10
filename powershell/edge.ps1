#---------------------------------------------------------------------------------------
# Configure homepage

Add-WindowsFeature Web-Server
Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value "<p style = `"font-family:Arial,Helvetica,sans-serif;font-size:24px`">$($env:computername)</p>"

"Simple IIS site configured." | Out-String

#---------------------------------------------------------------------------------------
# Copy the customised policy definitions to the C:\Windows\PolicyDefinitions folder
# To modify the files, copy to the following locations:
#   C:\Windows\PolicyDefinitions\msedge.admx
#   C:\Windows\PolicyDefinitions\EN-US\msedge.adml
# Then modify using Start -> Run, gpedit.msc

Get-Location | Out-String
Copy-Item -Path msedge.admx -Destination C:\Windows\PolicyDefinitions -PassThru
Copy-Item -Path msedge.adml -Destination C:\Windows\PolicyDefinitions\EN-US -PassThru

"Edge policy files copied to PolicyDefinitions folder." | Out-String

#---------------------------------------------------------------------------------------
# Modify the registry

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
New-ItemProperty -Path $RegistryPath -Name 'HideFirstRunExperience' -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name 'RestoreOnStartup' -Value 4 -PropertyType DWORD -Force

$StartupUrls = "$RegistryPath\RestoreOnStartupURLs"
If (-NOT (Test-Path $StartupUrls)) { New-Item -Path $StartupUrls -Force | Out-Null }
New-ItemProperty -Path $StartupUrls -Name '1' -Value 'http://localhost' -PropertyType DWORD -Force

"Modified the registry for Edge policy files ($RegistryPath)." | Out-String
