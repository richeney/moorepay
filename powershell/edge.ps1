#---------------------------------------------------------------------------------------
# Configure homepage

Add-WindowsFeature Web-Server
Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value "<p style = `"font-family:Arial,Helvetica,sans-serif;font-size:24px`">$($env:computername)</p>"

"Simple IIS site configured." | Out-String

#---------------------------------------------------------------------------------------
# Copy the Edge policy administrative templates to the C:\Windows\PolicyDefinitions folder
# Can then see the registry policy settings below in gpedit.msc

Copy-Item -Path msedge.admx -Destination C:\Windows\PolicyDefinitions -PassThru
Copy-Item -Path msedge.adml -Destination C:\Windows\PolicyDefinitions\EN-US -PassThru

"Edge policy administrative templates files copied to PolicyDefinitions folder." | Out-String

#---------------------------------------------------------------------------------------
# Modify the registry

# These improve the first use experience a little

# Stop Server Manager opening by default
New-ItemProperty -Path 'HKCU:\Software\Microsoft\ServerManager' -Name 'DoNotOpenServerManagerAtLogon' -PropertyType DWORD -Value 1 -Force


# Fake MDM Management

$RegistryPath = 'HKLM:SOFTWARE\Microsoft\Enrollments\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
If (-NOT (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
New-ItemProperty -Path $RegistryPath -Name 'EnrollmentState' -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name 'EnrollmentType' -Value 0 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name 'IsFederated' -Value 0 -PropertyType DWORD -Force

$RegistryPath = 'HKLM:SOFTWARE\Microsoft\Provisioning\OMADM\Accounts\FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'
If (-NOT (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
New-ItemProperty -Path $RegistryPath -Name 'Flags' -Value '0x00d6fb7f' -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name 'AcctUId' -Value '0x000000000000000000000000000000000000000000000000000000000000000000000000' -PropertyType String -Force
New-ItemProperty -Path $RegistryPath -Name 'RoamingCount' -Value 0 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name 'SslClientCertReference' -Value 'MY;User;0000000000000000000000000000000000000000' -PropertyType String -Force
New-ItemProperty -Path $RegistryPath -Name 'ProtoVer' -Value '1.2' -PropertyType String -Force

"Faked MDM Management entries in the registry." | Out-String


# Remove Edge first run experience and disable sync, preventing the choice prompt
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
If (-NOT (Test-Path $RegistryPath)) { New-Item -Path $RegistryPath -Force | Out-Null }
New-ItemProperty -Path $RegistryPath -Name 'HideFirstRunExperience' -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $RegistryPath -Name 'SyncDisabled' -Value 1 -PropertyType DWORD -Force

# The following only work on joined or managed machines, but I'll keep them here for reference

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge'
New-ItemProperty -Path $RegistryPath -Name 'RestoreOnStartup' -Value 4 -PropertyType DWORD -Force

$StartupUrls = "$RegistryPath\RestoreOnStartupURLs"
If (-NOT (Test-Path $StartupUrls)) { New-Item -Path $StartupUrls -Force | Out-Null }
New-ItemProperty -Path $StartupUrls -Name '1' -Value "http://localhost" -PropertyType String -Force

"Modified the registry for Edge policy files ($RegistryPath)." | Out-String
