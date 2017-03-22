$updates = gc C:\temp\Update.txt
$SUGName = "TestSUG"
$allupdates = get-cmsoftwareupdate -fast

Foreach ($Update in $Updates) {
 
    $patches = $allupdates | where {$_.ArticleID -eq $update}
 
    Foreach ($patch in $patches) {
        Add-CMSoftwareUpdateToGroup -SoftwareUpdateGroupName $SUGName -SoftwareUpdateID $patch.CI_ID -verbose
    }

}
