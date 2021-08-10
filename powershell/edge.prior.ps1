#------------------------------
# Configure homepage

Add-WindowsFeature Web-Server
Add-Content -Path "C:\\inetpub\\wwwroot\\Default.htm" -Value "<p style = `"font-family:Arial,Helvetica,sans-serif;font-size:24px`">$($env:computername)</p>"

"" | Out-String
"Simple IIS site configured." | Out-String

#------------------------------

# Edge - Disable First Run Experience and set AppData's default homepage to http://localhost
# Based on https://github.com/gunnarhaslinger/Microsoft-Edge-based-on-Chromium-Scripts

# Check the User Data directory is there

$LocalAppData   = 'C:\Users\Default\AppData\Local'
if (!(Test-Path $LocalAppData)) { "ERROR: LocalAppData: ""$LocalAppData"" missing!" | Out-String; exit 1; }

$EdgeUserData   = "$LocalAppData\Microsoft\Edge\User Data"
if (!(Test-Path $EdgeUserData)) {
   "Creating default Edge profile directory: ""$EdgeUserData""" | Out-String
   New-Item -ItemType Directory -Path $EdgeUserData | Out-Null
}

$EdgeDefaults = "$EdgeUserData\Default"
if (!(Test-Path $EdgeDefaults)) {
   "Creating default subdirectory: ""$EdgeDefaults""" | Out-String
   New-Item -ItemType Directory -Path $EdgeDefaults | Out-Null
}

# Update Local State with has_seen_signin_fre = true

$LocalStateJSON = "$EdgeUserData\Local State"

if (!(Test-Path -Path $LocalStateJSON)) {
  $LocalState = @{}
  """$LocalStateJSON"" does not exist, starting empty." | Out-String
} else {
  $LocalState = Get-content $LocalStateJSON -Encoding Default | ConvertFrom-Json
}

if ($LocalState.Count -gt 0) {
	"# --- Existing Edge Settings --- " | Out-String
	$LocalState | Out-String
	"-------------------------------- " | Out-String
}

if ($LocalState.fre.has_user_seen_fre -eq "true") {
   "Edge First Run Experience (FRE) already done, no modification needed" | Out-String
} else {
   "Edge First Run Experience (FRE) Setting is missing => Configuring: Set has_user_seen_fre=true" | Out-String

  # Whole node "fre" is Missing? => Add
  if ($LocalState.fre -eq $null) { $LocalState | Add-Member -Name fre -MemberType NoteProperty -Value @{has_user_seen_fre=$true} }

  # Node "fre" is present, but SubEntry "has_user_seen_fre" is missing?
  if ($LocalState.fre.has_user_seen_fre -eq $null) { $LocalState.fre | Add-Member -Name has_user_seen_fre -MemberType NoteProperty -Value $true; }
  else { $LocalState.fre.has_user_seen_fre=$true } # SubEntry "has_user_seen_fre" is present but not true => set $true

  "Writing Settings-File: $LocalStateJSON" | Out-String
  $LocalState | ConvertTo-Json -Depth 99 -Compress | Out-String
  $LocalState | ConvertTo-Json -Depth 99 -Compress | Out-File -FilePath $LocalStateJSON -Encoding default
}

## $LocalState.fre.has_user_seen_fre = $true
## $LocalState | ConvertTo-Json -Depth 99 -Compress | Out-File -FilePath $LocalStateJSON -Encoding default
## "Set fre.has_user_seen_fre=true in $LocalStateJSON" | Out-String

# Repeat for Secure Preferences, adding the section
# ~ $ jq .session < SecurePreferences
# {
#   "restore_on_startup": 4,
#   "startup_urls": [
#     "http://localhost/"
#   ]
# }

$SecurePrefJSON = "$EdgeUserData\Default\Secure Preferences"

if (!(Test-Path -Path $SecurePrefJSON)) {
  $SecurePref = @{}
  """$SecurePrefJSON"" does not exist, starting empty." | Out-String
} else {
  $SecurePref = Get-content $SecurePrefJSON -Encoding Default | ConvertFrom-Json
}

## $SecurePref     = Get-content $SecurePrefJSON -Encoding Default | ConvertFrom-Json

if ($SecurePref.session -eq $null) { $SecurePref | Add-Member -Name session -MemberType NoteProperty -Value @{restore_on_startup=4} }
if ($SecurePref.session.restore_on_startup -eq $null) {$SecurePref.session | Add-Member -Name restore_on_startup -MemberType NoteProperty -Value 4}
$SecurePref.session.restore_on_startup = 4

if ($SecurePref.session.startup_urls -eq $null) {$SecurePref.session | Add-Member -Name startup_urls -MemberType NoteProperty -Value @("http://localhost/")}
$SecurePref.session.startup_urls = @("http://localhost/")

$SecurePref | ConvertTo-Json -Depth 99 -Compress | Out-String
$SecurePref | ConvertTo-Json -Depth 99 -Compress | Out-File -FilePath $SecurePrefJSON -Encoding default

"Set http://localhost as .session.startup_urls[0] in $SecurePrefJSON" | Out-String
