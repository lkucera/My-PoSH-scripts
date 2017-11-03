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

------
get-cmlogs.ps1
  - get-CMLogsFull

Examples:

gci 'C:\windows\ccm\LOGS\*' -Exclude "*-*","scc*","scn*" | get-CMLogsFull | ? {$_.datetime -gt (get-date).AddMinutes(-10)}  |ft datetime,component,message

Powershell function for readinf SCCM logs and return them as object, it deals with multiline logs and include all informations, datetime is however returned as "as writen" in log as I didnt find it usefull to retain timezone (plus there is conversion issue)
