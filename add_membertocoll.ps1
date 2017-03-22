function GetCMSiteConnection
{
  param ($siteCode)
  $CMModulePath = Join-Path -Path (Split-Path -Path "${Env:SMS_ADMIN_UI_PATH}" -ErrorAction Stop) -ChildPath "ConfigurationManager.psd1"
  Import-Module $CMModulePath -ErrorAction Stop
  $CMProvider = Get-PSDrive -PSProvider CMSite -Name $siteCode -ErrorAction Stop
  CD "$($CMProvider.SiteCode):\"
  $global:CMProvider = $CMProvider
  return $CMProvider
}


function Add-CMWMIMembersToCollection
{
  param($collectionName, $newMembers)

  $collectionName

  $CMProvider = GetCMSiteConnection -sitecode "CAP" #change the CAS site name here
      
  $collectionId = Get-CMDeviceCollection -Name $collectionName | select -ExpandProperty CollectionID | select -first 1
  $SccmServer = $CMProvider.Root 
  $SccmNamespace = "root\sms\site_$($CMProvider.Name)"
  $coll = [wmi]"\\$($SccmServer)\root\sms\site_$($CMProvider.Name):SMS_Collection.CollectionId='$collectionId'"
  $ruleClass = [WMICLASS]"\\$($SccmServer)\root\sms\site_$($CMProvider.Name):SMS_CollectionRuleDirect"   
  [array]$rules = $null
 
  
  $count = 0
  foreach ($newMember in $newMembers.GetEnumerator())  
  {
      $resource = gwmi -ComputerName $SccmServer -Namespace $SccmNamespace -Class "SMS_R_System" -Filter "Name = '$($newMember)'" | select name,resourceid
 
      if ($resource -ne $null)
      {
            $newRule = $ruleClass.CreateInstance()     
            $newRule.RuleName = $($resource.name)
            $newRule.ResourceClassName = "SMS_R_System"       
            $newRule.ResourceID = $($resource.resourceid)
            $rules += $newRule
  
        Write-Host " $newMember added to collection" -ForegroundColor Green
        $count++
      }
      else
      {
        Write-Host " $newMember was not found in SCCM, skipping" -ForegroundColor Red
      }
  }
  
  If($rules.Count -gt 0)
  {
      #Add all the rules in the array    
      #See: http://msdn.microsoft.com/en-us/library/hh949023.aspx         
      $coll.AddMembershipRules($rules) | Out-Null

      #Refresh the collection
      $coll.requestrefresh()      | Out-Null
  }
  
  Write-Host $count" new members added to collection "$collectionName
  }