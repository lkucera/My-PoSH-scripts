<#
.Synopsis
   Sets port fowarding on windows
.DESCRIPTION
   Using NETSH :)
.EXAMPLE
   Example of how to use this cmdlet
#>
function set-portfowarding
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Local IP Address
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ipaddress]$LocalIPAddress,

        # Local Port
        [Parameter(Mandatory=$true,
                   Position=1)]
        [int]$LocalPort,

        # Remote IP Address
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ipaddress]$RemoteIPAddress,

        # Remote Port
        [Parameter(Mandatory=$true,
                   Position=3)]
        [int]$RemotePort
    )

    Begin
    {
    }
    Process
    {
        netsh interface portproxy add v4tov4 listenaddress=$LocalIPAddress listenport=$LocalPort connectaddress=$RemoteIPAddress connectport=$RemotePort 
        netsh interface portproxy show all 

    }
    End
    {
    }
}