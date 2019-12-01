Param(
    [string]$configuration
)

if(-Not ($PSBoundParameters.ContainsKey('configuration'))) {
    $configuration = "./config.json"
}
else {
    $configFileName = "./" + $configuration
    if (Test-Path  $configFileName -PathType leaf) {
        $configuration = $configFileName
    }
    else {
        Write-Error "Invalid configuration file specified" -ErrorAction Stop
    }
}

$config = Get-Content $configuration | ConvertFrom-Json

foreach ($watch in $config."watch") {
    if (Test-Path $watch."sourceDll" -PathType leaf) {
        foreach ($targetPath in $watch."targets") {
            Write-Output $targetPath
            if (-Not (Test-Path -Path $targetPath )) {
                $message = "Invalid Target Path: {0}" -f $targetPath
                Write-Error  $message -ErrorAction Stop
            }
        }
    }
    else {
        $message = "Invalid Source File Path: {0}" -f $watch."sourceDll"
        Write-Error  $message -ErrorAction Stop
    }
}


# config OK
$watchers = New-Object Collections.Generic.List[System.IO.FileSystemWatcher]

$test = @{
}

$count = 1
foreach ($watch in $config."watch") {
    $FileSystemWatcher = New-Object System.IO.FileSystemWatcher
    $folder = Split-Path -Path $watch."sourceDll" 
    $filter = Split-Path $watch."sourceDll" -leaf 
    $FileSystemWatcher.Path = $folder
    $FileSystemWatcher.Filter = $filter
    $FileSystemWatcher.IncludeSubdirectories = $false

    $Action = {
        $details = $event.SourceEventArgs
        #$Name = $details.Name
        $FullPath = $details.FullPath
        $ChangeType = $details.ChangeType
        $Timestamp = $event.TimeGenerated
        $text = "{0} was {1} at {2}" -f $FullPath, $ChangeType, $Timestamp
        Write-Host ""
        Write-Host $text -ForegroundColor Green
        
        #$text2 = ("Copying {0} to {1}" -f $Name, $event.MessageData.includePdb)
        #Write-Host $text2 -ForegroundColor Green
        
        foreach ($targetPath in $event.MessageData."targets") {
            try {
                Copy-Item $FullPath -Destination $targetPath -Force -Verbose
                if($event.MessageData.includePdb) {
                    $pdbFileName = $FullPath.SubString(0, $FullPath.LastIndexOf('.')) + ".pdb"
                    #Write-Host $pdbFileName -ForegroundColor Green
                    Copy-Item $pdbFileName -Destination $targetPath -Force -Verbose
                }    
            }
            catch {
                Write-Error "Registering ChangeEvent failed" -ErrorAction Stop
            }
        }

        # you can also execute code based on change type here
        # if ($ChangeType == "Changed" Or $ChangeType == "Created") {
                
        # }
        # else {
        #     Write-Host $ChangeType
        # }
    }
  
    $sourceIdentifier = "FSChange{0}" -f $count
   try {
        $event = Register-ObjectEvent -InputObject $FileSystemWatcher -EventName Changed -Action $Action -SourceIdentifier $sourceIdentifier -MessageData $watch
        $test.add($sourceIdentifier, $event)
        $count++
        $FileSystemWatcher.EnableRaisingEvents = $true
        $watchers.Add($FileSystemWatcher)
    }
    catch {
        Unregister-Event -SourceIdentifier $sourceIdentifier
        Write-Error "Registering ChangeEvent failed" -ErrorAction Stop
    }   
}

try {
    Write-Host "Press Control-C to exit"
    do {
        Wait-Event -Timeout 1
        Write-Host "." -NoNewline
        
    } while ($true)
}
finally {
    # this gets executed when user presses CTRL+C
    # remove the event handlers
    Write-Host ""
    Write-Host ("{0} EventHandlers will be unregistered" -f $test.Keys.Count)
        
    foreach ($key in $test.Keys) {
        try {
            Unregister-Event -SourceIdentifier $key
        }
        catch {
        }
    }
   
    # remove background jobs
    $test.Values | Remove-Job
    # remove filesystemwatcher

    Write-Host ("{0} Watchers will be disposed" -f $watchers.Count)
    foreach ($watcher in $watchers) {
        try {
            $watcher.EnableRaisingEvents = $false
            $watcher.Dispose()
        }
        catch {
        }
      
    }
   
    "Event Handler disabled."
}