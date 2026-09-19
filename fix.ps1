# Run in Administrator PowerShell:
# irm https://raw.githubusercontent.com/e24g4vewetq3gwerb/win-fix-wifi-chrome/main/fix.ps1 | iex

$ErrorActionPreference = 'Continue'
Write-Host 'Enable Wi-Fi...'
Start-Service WlanSvc -ErrorAction SilentlyContinue
Start-Service Dhcp -ErrorAction SilentlyContinue
netsh interface set interface name='Wi-Fi' admin=enabled
netsh wlan set autoconfig enabled=yes interface='Wi-Fi'
try { Get-NetAdapter -Name 'Wi-Fi' | Enable-NetAdapter -Confirm:$false } catch {}

Write-Host 'Nearby networks:'
netsh wlan show networks

$ssid = Read-Host 'Wi-Fi name (SSID)'
$pw   = Read-Host 'Wi-Fi password'

$xml = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
  <name>$ssid</name>
  <SSIDConfig><SSID><name>$ssid</name></SSID></SSIDConfig>
  <connectionType>ESS</connectionType>
  <connectionMode>auto</connectionMode>
  <MSM><security>
    <authEncryption><authentication>WPA2PSK</authentication><encryption>AES</encryption><useOneX>false</useOneX></authEncryption>
    <sharedKey><keyType>passPhrase</keyType><protected>false</protected><keyMaterial>$pw</keyMaterial></sharedKey>
  </security></MSM>
</WLANProfile>
"@
$path = "$env:TEMP\wifi.xml"
$xml | Set-Content $path -Encoding UTF8
netsh wlan add profile filename="$path" user=all
netsh wlan connect name="$ssid"
Start-Sleep 8
netsh wlan show interfaces

Write-Host 'Testing network...'
ping 8.8.8.8 -n 4

if (-not (Test-Connection 8.8.8.8 -Count 2 -Quiet)) {
  Write-Host 'Still offline. Check SSID/password or airplane mode.'
  return
}

Set-DnsClientServerAddress -InterfaceAlias 'Wi-Fi' -ServerAddresses 8.8.8.8,1.1.1.1 -ErrorAction SilentlyContinue
$ProgressPreference = 'SilentlyContinue'
Write-Host 'Downloading Chrome...'
Invoke-WebRequest -Uri "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile "$env:TEMP\chrome.msi"
Write-Host 'Installing Chrome...'
msiexec /i "$env:TEMP\chrome.msi" /qn
Write-Host 'Done. Open Chrome from the Start menu.'
