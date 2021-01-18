# -------------------------------------------------+
# PowerShell-Colorizer by GameGodS3
# https://github.com/GameGodS3/Powershell-Colorizer
# -------------------------------------------------+

#PowerShell requires parameters/flags and global variables to be called as first command

param ($index, $colorvalue)
$global:globindex = $index
$global:globcolor = $colorvalue

$cwd = Get-Location #To save the current location and return back to the folder after completion of script

cls
Write-Host "------------------------------------------------" -ForegroundColor "Yellow"
Write-Host "--           PowerShell-Colorizer             --" -ForegroundColor "Yellow"
Write-Host "------------------------------------------------" -ForegroundColor "Yellow"
Write-Host "------------------------------------------------" -ForegroundColor "Yellow"
Write-Host "                By GameGodS3                    " -ForegroundColor "Yellow"
Write-Host "------------------------------------------------" -ForegroundColor "Yellow"
" "
"Your Current Colour Palette:"
$colors = [enum]::GetValues([System.ConsoleColor])
Foreach ($bgcolor in $colors){
    $colorarray = [array]::IndexOf($colors, $bgcolor)
    Write-Host " " -NoNewLine
    Write-Host "__"  -ForegroundColor $bgcolor -BackgroundColor $bgcolor -NoNewLine
}
" "
for ($i = 0; $i -lt 16; $i++) {
    if ($i -lt 10){Write-Host " 0$i" -NoNewLine} 
    else{Write-Host " $i" -NoNewLine} 
}
" "
" "
#Accessing Registry Editor Console folder
Push-Location

try {
    Set-Location HKCU:\Console
    New-Item ".\%SystemRoot%_system32_WindowsPowerShell_v1.0_powershell.exe" -ErrorAction Stop
}
catch {
    Set-Location ".\%SystemRoot%_system32_WindowsPowerShell_v1.0_powershell.exe"
}


function ResetDefault {
    $confirm = Read-Host -Prompt "Are you sure you wish to reset to default config?(y/n)"
    if ( $confirm -eq "n" -or $confirm -eq "N"){
        Write-Host "Cacelling operation." -ForegroundColor "Yellow"
        return
    }

    for ($i = 00; $i -lt 16; $i++) {
        if ($i -eq 05 -or $i -eq 06) {
            Set-ItemProperty . ColorTable05 -value 0x00562401
            Set-ItemProperty . ColorTable06 -value 0x00f0edee
            continue
        }
        try{
            if ($i -lt 10) {
                Remove-ItemProperty . ColorTable0$i -ErrorAction Stop
            }
            else {
                Remove-ItemProperty . ColorTable$i -ErrorAction Stop
            }
            "Custom Color Table entry $i removed"
        }
        catch{
            continue
        }
    }
    "------------------------------------------------"
    Write-Host "           Color Table Set to Default           " -ForegroundColor "Green"
    "------------------------------------------------"
}

function CustomColor([REF]$globindex, [REF]$globcolor) {
    if ($globindex.Value -ne $null){
        $indexvalue = $globindex.Value
    }
    else{
        $indexvalue = 100
    }
    while ($indexvalue -gt 15) {
        [int]$indexvalue = Read-Host -Prompt "Enter index value of color (0-15) to be changed in the color table"
        if ($indexvalue -gt 15) {
            Write-Host "Index out of range. Enter Valid Index." -ForegroundColor "Red"
        }        
    }

    if ($globindex.Value -ne $null){
        $hexvalue = $globcolor.Value
    }
    else{
       $hexvalue = Read-Host -Prompt "Enter Hex Value of color to be input(without #)"
    }
    
    $hexarray = $hexvalue.ToCharArray()
    while ($hexarray.length -ne 6) {
        Write-Host "Hex value length incorrect. Try Again" -ForegroundColor "Red"
        $hexvalue = Read-Host -Prompt "Enter Hex Value of color to be input(without #)"
        $hexarray = $hexvalue.ToCharArray()
    }
    #Swapping hex values as color hex is stored in reg as 0x00BBGGRR
    $temp1 = $hexarray[0]
    $temp2 = $hexarray[1]
    $hexarray[0] = $hexarray[4]
    $hexarray[1] = $hexarray[5]
    $hexarray[4] = $temp1
    $hexarray[5] = $temp2
    $hexstring = -join $hexarray
    $hexstring = "0x00$hexstring"    
    if ($indexvalue -lt 10){[string]$indexvalue = "0$indexvalue"}
    else{$indexvalue = [string]"$indexvalue"}

    Write-Host "You have chosen #$hexvalue as Color for Table Index $indexvalue." -ForegroundColor "Green"
    $confirm = Read-Host -Prompt "Confirm?(n for no. Any other key for yes)"
    if ( $confirm -eq "n" -or $confirm -eq "N"){
        Write-Host "Cacelling operation." -ForegroundColor "Yellow"
        return
    }

    try {
        New-ItemProperty . ColorTable$indexvalue -type DWORD -value $hexstring -ErrorAction Stop
    }
    catch {
        Set-ItemProperty . ColorTable$indexvalue -type DWORD -value $hexstring
    }
    " "
    "---------------------------------------"
    Write-Host "ColorTable$indexvalue set to $hexvalue successfully" -ForegroundColor "Green"
    "---------------------------------------"
}


#Function calls if parameters/flags are given inline
if ($index -ne $null -and $colorvalue -ne $null){
try{
   CustomColor ([REF]$global:globindex) ([REF]$global:globcolor)
}  
finally{ 
   Set-Location $cwd
   Exit
}
}
elseif($index -eq $null -and $colorvalue -ne $null){
    Write-Host "Index Parameter missing. Executing Script normally" -ForegroundColor "Red"
    " "
}
elseif($index -ne $null -and $colorvalue -eq $null){
    Write-Host "ColorValue Parameter missing. Executing Script normally" -ForegroundColor "Red"
    " "
}

#Prompt if script is called without flags
try {
    "(1) Set Custom Color"
    "(2) Reset to Default Color Settings"
    "(q) Exit"
    " "
    $switch = Read-Host -Prompt "Choose from above options"

    if ($switch -eq 1) {
        CustomColor ([REF]$global:globindex) ([REF]$global:globcolor)
    }
    elseif ($switch -eq 2) {
        ResetDefault
    }
    elseif ($switch -eq "q" -or $switch -eq "Q") {
        Exit
    }
    else {
        "Invalid input."
    }
}
finally {
    Set-Location $cwd
    Write-Host "Exiting Script. Restart Powershell to take effect." -ForegroundColor "Yellow"
    Pause
}

