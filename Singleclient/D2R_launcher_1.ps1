#== D2R singleclient transparent launcher by Chobot - https://github.com/Chobotz/D2R-multiclient-tools ==================
$bnet_email = 'changeme@gmail.com'
$bnet_password = 'mypassword123'
#default_region values can be eu/us/kr - default is applied when you do not provide any input and just press enter during region selection
$region = 'eu'
#======================================== Send me lot of FGs ==========================================================================================================


#============= Check for mandatory components and folder placement =====================================================================

$pc_username = [System.Environment]::UserName

if(![System.IO.File]::Exists("$PSScriptRoot\D2R.exe"))
{
    Write-Host "Warning: Script needs to be placed in D2R installation folder. Use lnk shortcut to start it. Follow the installation instructions."
    Write-Host "Exiting now."
    Read-host "Press ENTER to continue..."
    Exit
}

if(![System.IO.File]::Exists("$PSScriptRoot\handle64.exe"))
{
    Write-Host "Warning: handle64.exe is missing in the current folder - Follow the installation instructions. You can get it from the Microsoft Official site: https://docs.microsoft.com/en-us/sysinternals/downloads/handle"
    Write-Host "Exiting now."
    read-host "Press ENTER to continue..."
    Exit
}

#============= Enumerate D2R process handles and close the D2R instance handle to allow to start other clients - admin required ==========

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

& "$PSScriptRoot\handle64.exe" -accepteula -a -p D2R.exe > $PSScriptRoot\d2r_handles.txt

$proc_id_populated = ""
$handle_id_populated = ""

foreach($line in Get-Content $PSScriptRoot\d2r_handles.txt) {
    
    
    $proc_id = $line | Select-String -Pattern '^D2R.exe pid\: (?<g1>.+) ' | %{$_.Matches.Groups[1].value}
    if ($proc_id)
    {
        $proc_id_populated = $proc_id
    }
    $handle_id = $line | Select-String -Pattern '^(?<g2>.+): Event.*DiabloII Check For Other Instances' | %{$_.Matches.Groups[1].value}
    if ($handle_id)
    {
        $handle_id_populated = $handle_id
    }
    
    if($handle_id){
        
        Write-Host "Closing" $proc_id_populated $handle_id_populated
        & "$PSScriptRoot\handle64.exe" -p $proc_id_populated -c $handle_id_populated -y
        
    }
    
}

 & "$PSScriptRoot\D2R.exe" -username $bnet_email -password $bnet_password -address $region'.actual.battle.net'
    
 Write-Host 'Starting:'$region'.actual.battle.net'
