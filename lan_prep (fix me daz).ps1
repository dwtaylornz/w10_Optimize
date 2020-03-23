function Show-Menu {
    param (
        [string]$Title = 'My Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for this option."
    Write-Host "2: Press '2' for this option."
    Write-Host "3: Press '3' for this option."
    Write-Host "Q: Press 'Q' to quit."
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    'You chose option #1'
    } '2' {
    'You chose option #2'
    } '3' {
      'You chose option #3'
    }
    }
    pause
 }
 until ($selection -eq 'q')

# if exists changes power mode to "high performance" -- forces higher clock speed on computer 
# echo Changing power settings to "High performance" or "Ultimate Performance" if exist... 
powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg.exe /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
#echo .
#echo Power Profile set to ; 
powercfg.exe /getactivescheme
#echo . 

#echo Press ANY key to further optimize windows 10... 
#pause

Write-Output "Disable Game DVR and Game Bar"
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" "AllowgameDVR" 0

# Ensure auto DNS is set so LAN cache works! 
Get-NetAdapter | Set-DnsClientServerAddress -ResetServerAddresses

Write-Output "Disable easy access keyboard stuff"
Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"

$services = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
    "HomeGroupListener"                        # HomeGroup Listener
    "HomeGroupProvider"                        # HomeGroup Provider
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteAccess"                             # Routing and Remote Access
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WbioSrvc"                                 # Windows Biometric Service (required for Fingerprint reader / facial detection)
    #"WlanSvc"                                 # WLAN AutoConfig
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "wscsvc"                                   # Windows Security Center Service
    "WSearch"                                  # Windows Search
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service
    "ndu"                                      # Windows Network Data Usage Monitor
)

foreach ($service in $services) {
    Write-Output "Trying to disable $service"
    Get-Service -Name $service | Set-Service -StartupType Disabled
}

# Reduce Prioitity of services to speed up my PC 

$appsBN = @(
    # Windows 10 services
	"SearchUI.exe"
	"SearchIndexer.exe"
    )

$appsL = @(
    # Windows 10 services
	"nessusd.exe"
	"SavService.exe"
	"swi_fc.exe"
	"CcmExec.exe"	
	"DSATray.exe"
	"esrv_svc.exe"
	"WMiPrvSE.exe"
	"fontdrvhost.exe"
	"RuntimeBroker.exe"
	"DSATray.exe"
    )

Write-Output "De-Prioitising Services - Below Normal ..."
foreach ($app in $appsBN) {

	#Write-Output "De-Prioitising $app"
	Get-WmiObject Win32_process -filter "name = '$app'" | foreach-object { $_.SetPriority(16384) }

	}

Write-Output "De-Prioitising Services - Low  ..."
foreach ($app in $appsL) {

	#Write-Output "De-Prioitising $app"
	Get-WmiObject Win32_process -filter "name = '$app'" | foreach-object { $_.SetPriority(64) }

	}


#256	Realtime
#128	High
#32768	Above normal
#32		Normal
#16384	Below normal
#64		Low

pause

