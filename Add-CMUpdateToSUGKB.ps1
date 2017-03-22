$updates = gc C:\temp\Update.txt

$allupdates = get-cmsoftwareupdate -fast

Foreach ($Update in $Updates) {
 
 $patches = $allupdates | where {$_.ArticleID -eq $update}
 
    Foreach ($patch in $patches) {Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName "Server_MS_Office_updates" -SoftwareUpdateID $patch.CI_ID -verbose}
  
 }
