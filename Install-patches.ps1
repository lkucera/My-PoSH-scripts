#General script for installing all patches available in SCCM client


     write-host "ALL Following patches will be installed:"  -ForegroundColor DarkCyan
    #[void](get-wmiobject -query “SELECT * FROM CCM_SoftwareUpdate” -namespace “ROOT\ccm\ClientSDK” | ft Name,ArticleID)

    #Install
    [void]([wmiclass]’ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager’).InstallUpdates([System.Management.ManagementObject[]] (get-wmiobject -query “SELECT * FROM CCM_SoftwareUpdate” -namespace “ROOT\ccm\ClientSDK”))

    #check EvaluationState
    #8 ... PendingReboot
    #7 ... Installing
    #6 ... waiting
    #13 .. Error
    #5 ... Downloading
    #12 .. Complete

    #1..100 | % {sleep 5;get-wmiobject -query “SELECT * FROM CCM_SoftwareUpdate” -namespace “ROOT\ccm\ClientSDK” | ft ArticleID,EvaluationState,Name}

    Do{
        Start-Sleep -s 5
        $x = $x+5

        $Statuses  = @()
        $PatchStats  = @()

        gwmi -query "SELECT * FROM CCM_SoftwareUpdate" -namespace "ROOT\ccm\ClientSDK" | % {
            $patch = $_
            switch ($patch.EvaluationState)
            {
                    #$patch.Name;"Available"
                0 {
                    $SingleStatus = $false
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Available"
                        } 
                   }
                    #$patch.Name;"Downloading"
                5 {
                    $SingleStatus = $false
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Downloading"
                        }
                    }
                    #$patch.Name;"Waiting"
                6 {
                    $SingleStatus = $false
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Waiting"
                        }
                    }
                    #$patch.Name;"Installing"
                7 {
                    $SingleStatus = $false
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Installing"
                        }
                    }
                    #$patch.Name;"Pendign Reboot"
                8 {
                    $SingleStatus = $true
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Pending reboot"
                        }
                    }
                    #$patch.Name;"Complete"
                12 {
                    $SingleStatus = $true
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Complete"
                        }
                    }
                    #$patch.Name;"Error"
                13 {
                    $SingleStatus = $true
                    $PatchStats += [PSCustomObject]@{
                        "Name" = $patch.Name
                        "Status" = "Error"
                        }
                    }
            }
            
            $Statuses = $Statuses + $SingleStatus
        }
        #$PatchStats | ft Name, Status
        $Status = $Statuses -contains $false
        }
    While($status)

    write-host "Following patches were isntalled"  -ForegroundColor DarkCyan
    get-wmiobject -query “SELECT * FROM CCM_SoftwareUpdate” -namespace “ROOT\ccm\ClientSDK” | ft PsComputerName,Name,EvaluationState
