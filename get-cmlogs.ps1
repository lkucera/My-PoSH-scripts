function get-CMLogsFull
{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]
        [string]$filePath = "C:\windows\ccm\Logs\AlternateHandler.log"
    )

    #load file and initiate variables

    $file = gc $filePath
    
    $obj = @()
    $linecount = (Get-Content $filePath | Measure-Object –Line).Lines
    $si=1
    $diverder = [math]::Truncate($linecount/100)

    $Constructedline = $null

$file | % {
    
    #display progress of file loading, in order to speed up we dispalay every refresh 1% only
    if( $si/$diverder -eq [math]::Truncate($si/$diverder) ){Write-Progress -Activity "Processing  $si / $linecount" -Status "Loading logfile $filePath" -PercentComplete (($si / $linecount) * 100)}
    
    #check if we are working on constructed line on line from file and proceed acordingly
    if ($Constructedline -eq $null) {$Constructedline = $_}
    else {$Constructedline = $Constructedline + " " + $_}

    #split to content(message) and data
    $CDline = $Constructedline -split("]LOG]!><")
    
    #check that split was succesfull (if no, it means we work on multiline log entry and we need to contsruct log entry first)
    if($cdline[1] -ne $null)
    {
        $Constructedline = $null
        
        #tideup the message and data from log remains
        $Message = $CDline[0].replace("<![LOG[","")
        $data = ($CDline[1].replace("<","")).replace(">","")
          
        #split data
        $nData = $data.split("="" ")

        $loglinefinal = @{
            'Message' = $Message
           # 'Time' = $nData[2]
           # 'Date' = $nData[6]
            'DateTime' = [datetime]($nData[6] +" "+ $nData[2].split("-")[0])
            'Component' = $nData[10]
            'Context' = $nData[14]
            'Type' = $nData[18]
            'Thread' = $nData[22]
            'File' = $nData[26]
        }

            $obj = New-Object PSObject -Property $loglinefinal

            $si++  
        Return $obj
    }
    $si++   
}
}

get-CMLogsFull