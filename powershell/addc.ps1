Install-WindowsFeature -Name AD-Domain-Services
Install-ADDSForest -DomainName micro-hack.local -SafeModeAdministratorPassword (ConvertTo-SecureString -String "microhack-12345%" -AsPlainText -Force) -Force -SkipPreChecks

Write-Host "Server added to the domain as a domain controller."