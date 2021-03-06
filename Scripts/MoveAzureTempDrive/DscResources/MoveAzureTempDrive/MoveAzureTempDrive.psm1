function Get-TargetResource 
{    
    [OutputType([System.Collections.Hashtable])] 
  param 
   (   
	[Parameter(Mandatory)] 
        [string]$TempDriveLetter

   ) 
   
        $returnValue = @{ 
           TempDriveLetter = $TempDriveLetter           
   }     
    $returnValue 
} 

function Set-TargetResource 
{   
   param 
    ( 
      [Parameter(Mandatory)] 
        [string]$TempDriveLetter   
    ) 
    #Change D drive to new drive letter
    #$drive = Get-WmiObject -Class win32_volume -Filter “DriveLetter = 'D:'”    
    #Set-WmiInstance -input $drive -Arguments @{DriveLetter = "$TempDriveLetter"}
    
    Get-Partition -DriveLetter "D"| Set-Partition -NewDriveLetter $TempDriveLetter
    $TempDriveLetter = $TempDriveLetter + ":"
    $drive = Get-WmiObject -Class win32_volume -Filter “DriveLetter = '$TempDriveLetter'”
    Out-File -FilePath c:\packages\driveinfo.txt -InputObject $drive    
    #re-enable page file on new Drive
    $drive = Get-WmiObject -Class win32_volume -Filter “DriveLetter = '$TempDriveLetter'”
    Set-WMIInstance -Class Win32_PageFileSetting -Arguments @{ Name = "$TempDriveLetter\pagefile.sys"; MaximumSize = 0; }

    Restart-Computer -Force                
    
} 

function Test-TargetResource 
{ 
    [OutputType([System.Boolean])]    
    param 
     ( 
      	[Parameter(Mandatory)] 
        [string]$TempDriveLetter
    ) 
    
    $pf=gwmi win32_pagefilesetting

    if ($pf -eq $null)
    {
        return $false
    }

    else
    {
        return $true
    }
} 


Export-ModuleMember -Function *-TargetResource 