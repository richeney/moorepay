Add-WindowsFeature Web-Server
Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value "<p style = `"font-family:Arial,Helvetica,sans-serif;font-size:24px`">$($env:computername)</p>"

Write-Host "Simple IIS site configured."