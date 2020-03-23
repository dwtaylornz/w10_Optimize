function Show-Menu {
    Clear-Host
    Write-Host "================ LAN Optimize ================"
    Write-Host ""
    Write-Host "Press '1' to set power profile to High (or Ultimate if exist)"
    Write-Host "Press '2' for the works! - Max power, deprioritize services etc"
    Write-Host ""
    Write-Host "================================"
    Write-Host ""
    Write-Host "Press '3' to set power profile to Balanced (for home)"
    Write-Host "Q to quit."
    Write-Host ""
}

function Run-One {
	# if exists changes power mode to "high performance" -- forces higher clock speed on computer 
	
	powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
	powercfg.exe /setactive bbc1d9f4-fcd1-46b8-b78e-18ca71c442c2 | Out-Null
	Write-Host ""
	Write-Host "Your Power Profile is now set to : " -NoNewLine
	powercfg.exe /getactivescheme
	Write-Host ""
}

function Run-Two {

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

}

function Run-Three {
	# change power profile back to balanced 	
	
	powercfg.exe /setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
	Write-Host ""
	Write-Host "Your Power Profile is now set to : " -NoNewLine
	powercfg.exe /getactivescheme
	Write-Host ""
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
    #'You chose option #1'
    Run-One
    } '2' {
    #'You chose option #2'
    Run-Two
    } '3' {
     #'You chose option #3'
     Run-Three
    }
    }
    pause
 }
 until ($selection -eq 'q')

