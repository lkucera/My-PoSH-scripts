function get-complexpassword(){

 Param
    (
        #Minimum Password Lenght
        [Parameter(Mandatory=$False,
                   Position=0)]
        [int]$MinPassLenght = 9,

        #Maximum Password Lenght
        [Parameter(Mandatory=$False,
                   Position=1)]
        [int]$MaxPassLenght = 14,

        #Do Not Use Special Charaters
        [Parameter(Mandatory=$False,
                   Position=2)]
        [Switch]$DoNotUseSpecChar,

        #Complexity treshold
        [Parameter(Mandatory=$False,
                   Position=3)]
        [int]$ComplexityTreshold = 3

    )


if (!$DoNotUseSpecChar){$spcASCI = [char[]]([char]33)  + [char[]]([char]35..[char]46)  + [char[]]([char]58..[char]64) + [char[]]([char]91..[char]95) + [char[]]([char]123..[char]126)}

$numASCI = [char[]]([char]48..[char]57)
$lrgASCI = [char[]]([char]65..[char]90)
$smlASCI = [char[]]([char]97..[char]122)

$reslspcASCI = $False
$reslnumASCI = $False 
$resllrgASCI = $False
$reslsmlASCI = $False
$complexity = 0

$ascii = $spcASCI + $numASCI + $lrgASCI + $smlASCI

    do {
        $i = $i +1

        $passwd = (1..$(get-random -Minimum $MinPassLenght -Maximum $MaxPassLenght) | % {$ascii | get-random})
        
        $spcASCI | % {$($passwd -contains $_)} | % {$reslspcASCI = $reslspcASCI -or $_}
        $numASCI | % {$($passwd -contains $_)} | % {$reslnumASCI = $reslnumASCI -or $_}
        $lrgASCI | % {$($passwd -contains $_)} | % {$resllrgASCI = $resllrgASCI -or $_}
        $smlASCI | % {$($passwd -contains $_)} | % {$reslsmlASCI = $reslsmlASCI -or $_}

        $complexity = $reslspcASCI + $reslnumASCI + $resllrgASCI + $reslsmlASCI
    
    } while ($complexity -lt $ComplexityTreshold)

    Write-Verbose "Found on $i try"
    Write-Verbose "Complexity treshold is $ComplexityTreshold, Complexity score is: $complexity"

    $rtrn = $passwd -join ""

    return $rtrn
}