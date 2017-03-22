$ModuleVersion = 1.0
$ModuleAuthor  = "kucerlu1"
$ModuleLastUpdated = "12/9/2016"
$WSUSServer = "localhost"
$WSUSPort = 8530
$PoshWSUSPath = "C:\TEMP\poshwsus\PoshWSUS.psm1"
$baseSWGroup = "Software"


<#
    .SYNOPSIS
    Function Approves given application to given group with given dates
    !!This module is depending on old PoshWSUS!!

    .DESCRIPTION
    

    .PARAMETER Application
    MANDATORY Name of application to be approved

    .PARAMETER Group
    Name of group where application will be approved for installation.
    If not supplied new Group will be created under default location.
    
    .PARAMETER DeadLine
    Deadline for deployment in DD.MM.YYYY HH:MM

    .PARAMETER TestOnly
    SWITCH for testing only, helpfull with $DebugPreference = "Continue"
    
    .EXAMPLE
    Approve application for available, create NEW group with same name as application

    Approve-WSUSApplicationDeployment -Application "7-zipv2"

    .EXAMPLE 
    Approve application for available, use existing group

    Approve-WSUSApplicationDeployment -Application "7-zipv2" -Group "7-zipv2"

    .EXAMPLE 
    Approve application with deadline, use existing group

    Approve-WSUSApplicationDeployment -Application "7-zipv2" -Group "7-zipv2" -Deadline "05.10.2016 21:00"

    .NOTES
    you may also use alias AproveApp
    

#>
function Approve-WSUSApplicationDeployment
{
     param(
        [parameter(Mandatory=$true,Position=0,HelpMessage="Name Of application")] 
        [string] $Application, 
        
        [parameter(Mandatory=$False,Position=1,HelpMessage="Group Name where application will be approved to")]
        [String] $Group,
        
        [parameter(Mandatory=$False, Position=2,helpmessage="dd.mm.yyyy hh:mm")]
        [ValidatePattern("^(0[1-9]|1\d|2\d|3[01])\.(0[1-9]|1\d|2\d|3[01])\.(19|20)\d{2}\s+(0[0-9]|1[0-9]|2[0-3])\:(0[0-9]|[1-5][0-9])")]
        [string] $DeadLine,

        [parameter(Mandatory=$False,Position=3)]
        [Switch] $TestOnly
        
        )

    write-debug "following parametrs were passed to script:"
    write-debug "Application: $Application"
    write-debug "Group: $Group"
    write-debug "Deadline: $DeadLine"
    write-debug "TestOnly: $TestOnly"

    write-debug "Importing PoshWSUS module from $PoshWSUSPath"
    import-module $PoshWSUSPath

#connect to server
    write-debug "contacting $WSUSServer on port $WSUSPort"
    $null = Connect-PSWSUSServer $WSUSServer $WSUSPort

#create the application object
    write-debug "geting the application"
    $ObjApplication = Get-PSWSUSUpdate -Update $Application

    if ($ObjApplication -eq $Null){
        write-host "Supplied application name wasnt found. ($Application)" -ForegroundColor Red -BackgroundColor Black
        break
        }

    if ($ObjApplication.count -gt 1)        {
        write-Host "MOre thatn one Application match $Application" -BackgroundColor Red
        $ObjApplication | ft Title,CreationDate
        write-Host " "
        write-Host "please run it again with exact name of application you want to approve instead" -BackgroundColor Yellow -ForegroundColor Black
  
        Break 
        }


#create on connect to group
    if ($Group -eq ''){
        Write-host "No name of group were supplied creating new group ""$Application"" under ""$baseSWGroup"""
        $Group = $Application
        if($TestOnly){
            Write-host "Running in testonly, group ""$group"" would have be created under ""$baseSWGroup""" -ForegroundColor Yellow -BackgroundColor Black
            }
        Else{
            Get-PSWSUSGroup -Name $baseSWGroup | New-PSWSUSGroup -name $group
            $ObjGroup = Get-PSWSUSGroup -Name $Group
            }
        }
    Else{
        Write-Debug "geting object for the group $Group"
        $ObjGroup = Get-PSWSUSGroup -Name $Group
        if($ObjGroup -eq $null){
            Write-Host "Supplied group name ($Group) is not valid."  -ForegroundColor Red -BackgroundColor Black
            break
            }
        }

#approve it
     if ($DeadLine -eq ''){
        write-host "No deadline were suplied for deployment, approving as Available only" -BackgroundColor Yellow -ForegroundColor Black
        if($TestOnly){
            Write-host "Running in testonly, application ""$Application"" would have be approved to group ""$Group"""
            }
        Else{
            Approve-PSWSUSUpdate -Update $ObjApplication -Action Install -Group $ObjGroup
            }
        }
    Else{
        if($TestOnly){
            Write-host "Running in testonly, application ""$Application"" would have be approved to group ""$Group"" with deadline ""$deadline""" -ForegroundColor Yellow -BackgroundColor Black
            }
        Else{
            write-host "Approving deployment with deadline $DeadLine" -BackgroundColor Yellow -ForegroundColor Black
            Approve-PSWSUSUpdate -Update $ObjApplication -Action Install -Group $ObjGroup -Deadline $DeadLine
            }
        }

    Write-host "$Application is approved for following groups:"
    Get-PSWSUSUpdateApproval -Update $objapplication | % {

        #write-host "$OUTgrpname - $OUTAction - $OUTdeadline (created:$OUTcreated by $OUTadminName)"

        $object = New-Object -TypeName PSObject
        $object | Add-Member -MemberType NoteProperty -Name "GroupName" -Value (Get-PSWSUSGroup -Id $_.ComputerTargetGroupId).name
        $object | Add-Member -MemberType NoteProperty -Name "Action" -Value $_.Action
        $object | Add-Member -MemberType NoteProperty -Name "CreationDate" -Value $_.CreationDate
        $object | Add-Member -MemberType NoteProperty -Name "DeadLine" -Value $_.Deadline
        $object | Add-Member -MemberType NoteProperty -Name "CreatedBy" -Value $_.AdministratorName
        
    $object


        }


}