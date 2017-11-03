function read-CMLogsFull
{
    param(
            [string]$filePath = "C:\windows\ccm\Logs\AlternateHandler.log"
    )

    $file = gc $filePath
    $obj = @()

    $linecount = (Get-Content $filePath | Measure-Object –Line).Lines
    $si=1
    $diverder = [math]::Truncate($linecount/100)

    $Constructedline = $null

$file | % {

    if( $si/$diverder -eq [math]::Truncate($si/$diverder) ){Write-Progress -Activity "Processing  $si / $linecount" -Status "Retrieving Collection data" -PercentComplete (($si / $linecount) * 100)}
    
    #split to content(message) and data

    if ($Constructedline -eq $null) {$Constructedline = $_}
    else {$Constructedline = $Constructedline + " " + $_}

    $CDline = $Constructedline -split("]LOG]!><")
    
    if($cdline[1] -ne $null)
    {
        $Constructedline = $null
        #clean the message and data from log remains
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

read-CMLogsFull