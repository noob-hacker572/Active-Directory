# This script monitors processes running in real time on the system, even when executed by a low-privileged user.

$existing = @{}

# Ask for mode
Write-Host "Select monitoring mode:"
Write-Host "1) Monitor all new processes"
Write-Host "2) Monitor specific process name"
$choice = Read-Host "Enter 1 or 2"

if ($choice -eq '2') {
    $filterName = Read-Host "Enter the process name to monitor (e.g. backup.exe)"
}

Write-Host "`nMonitoring started. Press Ctrl+C to stop.`n"

while ($true) {
    # Get current processes (optionally filtered)
    $processes = Get-CimInstance Win32_Process

    # Current PIDs in this iteration
    $currentPIDs = $processes.ProcessId

    # Remove exited processes from $existing
    foreach ($procId in $existing.Keys) {
        if (-not $currentPIDs.Contains($procId)) {
            $existing.Remove($procId)
        }
    }

    # Detect new processes (PIDs not in $existing)
    foreach ($proc in $processes) {
        if (-not $existing.ContainsKey($proc.ProcessId)) {

            # If filtering by name, check here
            if ($choice -eq '1' -or ($choice -eq '2' -and $proc.Name.ToLower() -eq $filterName.ToLower())) {
                $timestamp = (Get-Date).ToString("o")
                $path = if ($proc.ExecutablePath) { $proc.ExecutablePath } else { "<Path Unavailable>" }
                $parentPID = $proc.ParentProcessId

                Write-Output "$timestamp - New Process Detected: $($proc.Name) (PID: $($proc.ProcessId)) ParentPID: $parentPID Path: $path"
                # Mark as seen
                $existing[$proc.ProcessId] = $true
            }
        }
    }

    Start-Sleep -Seconds 1
}
