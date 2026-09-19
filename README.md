# win-fix-wifi-chrome
PowerShell: connect Wi-Fi and install Chrome (enterprise MSI).

## One-liner (Admin PowerShell)
```powershell
irm https://raw.githubusercontent.com/e24g4vewetq3gwerb/win-fix-wifi-chrome/main/fix.ps1 | iex
```

## Clone and run
```powershell
git clone https://github.com/e24g4vewetq3gwerb/win-fix-wifi-chrome.git
cd win-fix-wifi-chrome
Set-ExecutionPolicy -Scope Process Bypass
.\fix.ps1
```

## Chrome-only (no Wi-Fi prompts)
```powershell
Invoke-WebRequest -Uri "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile "$env:TEMP\chrome.msi"
msiexec /i "$env:TEMP\chrome.msi" /qn
```
Run PowerShell **as Administrator** for silent MSI install.
