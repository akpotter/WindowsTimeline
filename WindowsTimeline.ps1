# Device Name and Model of the originating machine can be seen 
# in the HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskFlow\DeviceCache\

# Show an Open File Dialog 
Function Get-FileName($initialDirectory)
{  
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |Out-Null
		$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
		$OpenFileDialog.Title = 'Select ActivitiesCache.db database to access'
		$OpenFileDialog.initialDirectory = $initialDirectory
		$OpenFileDialog.Filter = "ActivitiesCache.db (*.db)|ActivitiesCache.db"
		$OpenFileDialog.ShowDialog() | Out-Null
		$OpenFileDialog.ShowReadOnly = $true
		$OpenFileDialog.filename
		$OpenFileDialog.ShowHelp = $false
} #end function Get-FileName 

$dBPath =  $env:LOCALAPPDATA+"\ConnectedDevicesPlatform\"
$File = Get-FileName -initialDirectory $dBPath
$F =$File.replace($env:LOCALAPPDATA,'')
# Run SQLite query of the Selected dB
# The Query (between " " below)
# can also be copy/pasted and run on 'DB Browser for SQLite' 

Try{(Get-Item $File).FullName}
Catch{Write-Host "(WindowsTimeline.ps1):" -f Yellow -nonewline; Write-Host " User Cancelled" -f White; exit}
$elapsedTime = [system.diagnostics.stopwatch]::StartNew()    

$db = $File
$sql = 
"
		select
		ActivityOperation.PlatformDeviceId as 'ID'
		from Activity_PackageId
		join ActivityOperation on Activity_PackageId.ActivityId = ActivityOperation.Id 
		where Activity_PackageId.ActivityId = ActivityOperation.Id
		union
		select
		Activity.platformdeviceid as 'ID'
		from Activity_PackageId
		join Activity on Activity_PackageId.ActivityId = Activity.Id 
		where Activity_PackageId.ActivityId = Activity.Id
		group by platformdeviceid
"
1..1000 | %{write-progress -id 1 -activity "Running SQLite query" -status "$([string]::Format("Time Elapsed: {0:d2}:{1:d2}:{2:d2}", $elapsedTime.Elapsed.hours, $elapsedTime.Elapsed.minutes, $elapsedTime.Elapsed.seconds))" -percentcomplete ($_/100);}

$dbresult = @(sqlite3.exe -readonly $db $sql) 
$dbcount=$dbresult.count
$elapsedTime.stop()
write-progress -id 1 -activity "Running SQLite query" -status "Query Finished" 

#Query HKCU, check results against the Database 
	$DeviceID =  (Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskFlow\DeviceCache\" -name)|Select-Object 
	$RegCount =$DeviceID.count
	$r=0
$Output = foreach ($entry in $DeviceID){$r++
	$dpath = join-path -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskFlow\DeviceCache\" -childpath $entry
	Write-Progress -id 2 -Activity "Checking dB package IDs against HKCU DeviceCache" -Status "HKCU Entry $r of $($DeviceID.Count))" -PercentComplete (([double]$r / $DeviceID.Count)*100) -ParentID 1
                                    $Type = (get-itemproperty -path $dpath).DeviceType
                                    $Name = (get-itemproperty -path $dpath).DeviceName
                                    $Make = (get-itemproperty -path $dpath).DeviceMake
                                    $Model = (get-itemproperty -path $dpath).DeviceModel
                                    
                                    if ($dbresult -eq $entry){$platformID = "Exists"}else{$platformID = "Missing"}

									[PSCustomObject]@{
                                    
                                    'HKCU DeviceCache ID' = $entry
                                    Type = $Type
                                    DeviceType = 
                                                if($Type -eq 15){"Windows 10 Laptop"}
                                                elseif($Type -eq 1){"Xbox One"}
                                                elseif($Type -eq 6){"Apple iPhone"}
                                                elseif($Type -eq 7){"Apple iPad"}
                                                elseif($Type -eq 8){"Android device"}
                                                elseif($Type -eq 9){"Windows 10 Desktop"}
                                                elseif($Type -eq 9){"Desktop PC"}
                                                elseif($Type -eq 11){"Windows 10 Phone"}
                                                elseif($Type -eq 12){"Linux device"}
                                                elseif($Type -eq 13){"Windows IoT"}
                                                elseif($Type -eq 14){"Surface Hub"}
                                                else{$rin.Type} # Reference: https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-CDP/[MS-CDP].pdf
                                    'Device Name' = $Name
                                    Make = $Make
                                    Model = $Model
                                    'DeviceID in dB' = $platformID
													}
                                }
# Display results           
$output|Out-GridView -PassThru -Title "There are ($RegCount) device IDs in the Registry key (HKCU) and $dbcount in : ($F)"
[gc]::Collect() 

