# Services to set to "below normal" priority
$services_belownormal = @(
	"SearchUI.exe"
	"SearchIndexer.exe"
        )

# Services to set to "low" priority
$services_low = @(
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
	"MsMpEng.exe"
        )

# Services to disable
$services_disable = @(
        "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
        "DiagTrack"                                # Diagnostics Tracking Service
        "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
        "XblAuthManager"                           # Xbox Live Auth Manager
        "XblGameSave"                              # Xbox Live Game Save Service
        "XboxNetApiSvc"                            # Xbox Live Networking Service
        "XboxGipSvc"
        "ndu"                                      # Windows Network Data Usage Monitor
        )

function Show-Menu {
    Clear-Host
    Write-Host "================ LAN Optimize ================"
    Write-Host ""
    Write-Host "Press '1' For Basic setup ; "
    Write-Host ""
    Write-Host "  - Set balanced power Profile (best for turbo)"
    Write-Host "  - DNS (Auto DHCP assigned, for LAN cahce)" 
    Write-Host ""
    Write-Host "Press '2' For the works! ; "
    Write-Host ""
    Write-Host "  - All Above (in option 1)"
    Write-Host "  - Disable Game Bar and Recording services"
    Write-Host "  - Deprioritize services (temp, does not hold over reboot)"
    Write-Host "  - Disable xBox services (perminant)"
    Write-Host ""
    Write-Host "=============================================="
    Write-Host ""
    Write-Host "Press '3' to set power profile to Balanced (for home)"
    Write-Host ""
    Write-Host ""
}

function Run-Quick {
	# if exists changes power mode to "high performance" -- forces higher clock speed on computer 
	powercfg.exe /setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
	Write-Host ""
	Write-Host "Your Power Profile is now set to : " -NoNewLine
	powercfg.exe /getactivescheme

	Write-Host "Set DNS back to AUTO on DHCP (for LAN cache)..." 
    	Get-NetAdapter | Set-DnsClientServerAddress -ResetServerAddresses
    	Write-Host ""
}

function Run-Works {

    Write-Host ""
    Write-Host "Remove W10 xbox app..." 
    Get-AppxPackage Microsoft.XboxApp | Remove-AppxPackage
    
    Write-Output "Disable easy access keyboard stuff..."
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
    Set-ItemProperty "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"
    
    # Reduce Prioitity of services to speed up my PC  
    Write-Output "De-prioritising Services - Below Normal ..."
    foreach ($service in $services_belownormal) {

        Write-Host "  Adjusting $service" 
	    Get-WmiObject Win32_process -filter "name = '$service'" | foreach-object { $_.SetPriority(16384) } | Out-Null
	    }

    Write-Output "De-prioritising Services - Low  ..."
    foreach ($service in $services_low) {

	    Write-Host "  Adjusting $service" 
	    Get-WmiObject Win32_process -filter "name = '$service'" | foreach-object { $_.SetPriority(64) } | Out-Null
	    }

    Write-Output "Disabling Services..." 
    foreach ($service in $services_disable) {
    
    	Write-Output "  Disabling $service"
    	Get-Service -Name $service | Set-Service -StartupType Disabled
	}

    Write-Output ""
}

function Run-Balanced {
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
    $selection = Read-Host "(Q to quit) "
    switch ($selection)
    {
    '1' {Run-Quick} 
    '2' {    
        Run-Quick
        Run-Works
        } 
    '3' {Run-Balanced}
    }
    pause
 }
 until ($selection -eq 'q')
