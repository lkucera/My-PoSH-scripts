
#script for enabling and checking for meltdown/specter vulnerability
#Source of documentation:
#https://support.microsoft.com/en-us/help/4072698/windows-server-guidance-to-protect-against-the-speculative-execution

    write-host "Adding registry key to enable patch instalaltion:" -ForegroundColor DarkCyan
    [void](reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" /v cadca5fe-87d3-4b96-b7fb-a231484277cc /t REG_DWORD /d 0 /f)

    write-host "Stopping Windows Update" -ForegroundColor DarkCyan
    [void](Net stop wuauserv)
    
    write-host "Starting Windows Update" -ForegroundColor DarkCyan
    [void](Net start wuauserv)

    #Enable the security feature (after installation)
    write-host "Enabling protection 1/3:"  -ForegroundColor DarkCyan
    [void](reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 0 /f)

    write-host "Enabling protection 2/3:"  -ForegroundColor DarkCyan
    [void](reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f)
    
    write-host "Enabling protection 3/3:"  -ForegroundColor DarkCyan
    [void](reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization" /v MinVmVersionForCpuBasedMitigations /t REG_SZ /d "1.0" /f)
    
    write-host "Executing scans 1/2:"  -ForegroundColor DarkCyan

    #Scan
    [void]([wmiclass]"\root\ccm:SMS_Client").TriggerSchedule('{00000000-0000-0000-0000-000000000113}')

    write-host "Executing scans 2/2:"  -ForegroundColor DarkCyan
    
    #re-Scan
    [void]([wmiclass]"\root\ccm:SMS_Client").TriggerSchedule('{00000000-0000-0000-0000-000000000108}')

    write-host "Scanning for patches:"  -ForegroundColor DarkCyan
    Do{Start-Sleep -s 5;$x = $x+5}While(Get-WmiObject -Class CCM_ScanJobInstance -Namespace root\ccm\scanagent);$x=0

    write-host "Executing scans 1/2:"  -ForegroundColor DarkCyan
    #Scan
    [void]([wmiclass]"\root\ccm:SMS_Client").TriggerSchedule('{00000000-0000-0000-0000-000000000113}')

    write-host "Executing scans 2/2:"  -ForegroundColor DarkCyan
        #re-Scan
    [void]([wmiclass]"\root\ccm:SMS_Client").TriggerSchedule('{00000000-0000-0000-0000-000000000108}')

    write-host "Scanning for patches:"  -ForegroundColor DarkCyan
    Do{Start-Sleep -s 5;$x = $x+5}While(Get-WmiObject -Class CCM_ScanJobInstance -Namespace root\ccm\scanagent);$x=0

    write-host "List of available patches:"  -ForegroundColor DarkCyan

    $Patchlist  = @()
    $patches = get-wmiobject -query “SELECT * FROM CCM_SoftwareUpdate” -namespace “ROOT\ccm\ClientSDK”
    $patches | % {
        $patch = $_
        $Patchlist += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "ArticleID" = $patch.ArticleID
                        }

        }
    $patchlist