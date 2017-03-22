# Helpfull posh SCRIPTS

-----
add_membertocooll.ps1
  - GetCMSiteConnection
  - Add-CMWMIMembersToCollection

...thisone is based on some example microsoft script which I was not able to trace back...
adds client devices to collection using WMI, much faster than PoSH way

------
Add-CMUpdateToSUGKB.ps1

Loads file with KB numbers, serach all updates in SCCM for those files and add them to difened SUG
Needs some polishing for universal usage

------
wsusApplication.psm1
  - Approve-WSUSApplicationDeployment

Powershell module with funcition for handing Application imported to WSUS using SCUP
