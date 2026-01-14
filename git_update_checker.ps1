# ============================================
# Git Repository Update Checker (PowerShell)
# Checks all repos in the parent folder
# ============================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScanDir = Split-Path -Parent $ScriptDir  # Scan parent folder (where all repos live)
$LogFile = Join-Path $ScriptDir "git_update_log.txt"

# Initialize counters
$TotalRepos = 0
$UpdatesFound = 0
$ReposWithUpdates = @()
$Results = @()

# Log header
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LogHeader = @"

============================================
Git Update Check - $Timestamp
============================================
"@

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Git Repository Update Checker" -ForegroundColor Cyan
Write-Host "  Scanning: $ScanDir" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Get all directories with .git folder
$GitRepos = Get-ChildItem -Path $ScanDir -Directory -ErrorAction SilentlyContinue | Where-Object {
    Test-Path (Join-Path $_.FullName ".git")
}

foreach ($Repo in $GitRepos) {
    $TotalRepos++
    $RepoName = $Repo.Name
    $RepoPath = $Repo.FullName

    Write-Host "Checking: $RepoName" -NoNewline

    Push-Location $RepoPath

    try {
        # Fetch all remotes
        git fetch --all 2>&1 | Out-Null

        # Get current branch
        $CurrentBranch = git branch --show-current 2>&1

        if ($CurrentBranch) {
            # Check commits behind
            $Behind = git rev-list HEAD.."@{u}" --count 2>&1

            if ($Behind -match '^\d+$' -and [int]$Behind -gt 0) {
                $UpdatesFound++
                $ReposWithUpdates += $RepoName

                # Get latest remote commit
                $LatestCommit = git log --oneline "@{u}" -1 2>&1

                Write-Host " [UPDATE AVAILABLE]" -ForegroundColor Yellow
                Write-Host "  $Behind new commit(s) on branch $CurrentBranch" -ForegroundColor Yellow
                Write-Host "  Latest: $LatestCommit" -ForegroundColor Gray

                $Results += [PSCustomObject]@{
                    Repo = $RepoName
                    Status = "UPDATE AVAILABLE"
                    Behind = $Behind
                    Branch = $CurrentBranch
                    LatestCommit = $LatestCommit
                }
            }
            else {
                Write-Host " [UP TO DATE]" -ForegroundColor Green
                $Results += [PSCustomObject]@{
                    Repo = $RepoName
                    Status = "UP TO DATE"
                    Behind = 0
                    Branch = $CurrentBranch
                    LatestCommit = ""
                }
            }
        }
        else {
            # Check if remote exists
            $Remotes = git remote -v 2>&1
            if ($Remotes) {
                Write-Host " [NO UPSTREAM]" -ForegroundColor DarkYellow
                $Results += [PSCustomObject]@{
                    Repo = $RepoName
                    Status = "NO UPSTREAM"
                    Behind = "N/A"
                    Branch = "N/A"
                    LatestCommit = ""
                }
            }
            else {
                Write-Host " [NO REMOTE]" -ForegroundColor DarkGray
                $Results += [PSCustomObject]@{
                    Repo = $RepoName
                    Status = "NO REMOTE"
                    Behind = "N/A"
                    Branch = "N/A"
                    LatestCommit = ""
                }
            }
        }
    }
    catch {
        Write-Host " [ERROR]" -ForegroundColor Red
        Write-Host "  $_" -ForegroundColor Red
        $Results += [PSCustomObject]@{
            Repo = $RepoName
            Status = "ERROR"
            Behind = "N/A"
            Branch = "N/A"
            LatestCommit = $_.Exception.Message
        }
    }

    Pop-Location
}

# Summary
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Total repos: $TotalRepos"
Write-Host "  With updates: $UpdatesFound" -ForegroundColor $(if ($UpdatesFound -gt 0) { "Yellow" } else { "Green" })

if ($UpdatesFound -gt 0) {
    Write-Host "  Repos: $($ReposWithUpdates -join ', ')" -ForegroundColor Yellow
}

Write-Host ""

# Write to log file
$LogContent = $LogHeader
foreach ($Result in $Results) {
    $LogContent += "`n$($Result.Repo): $($Result.Status)"
    if ($Result.Behind -ne "N/A" -and $Result.Behind -gt 0) {
        $LogContent += " - $($Result.Behind) commits behind on $($Result.Branch)"
    }
}
$LogContent += "`n`nSummary: $TotalRepos repos checked, $UpdatesFound with updates"
if ($UpdatesFound -gt 0) {
    $LogContent += "`nRepos needing updates: $($ReposWithUpdates -join ', ')"
}

Add-Content -Path $LogFile -Value $LogContent
Write-Host "Log saved to: $LogFile" -ForegroundColor Gray

# Toast notification if updates found
if ($UpdatesFound -gt 0) {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $Notify = New-Object System.Windows.Forms.NotifyIcon
        $Notify.Icon = [System.Drawing.SystemIcons]::Information
        $Notify.Visible = $true
        $Notify.BalloonTipTitle = "Git Updates Available"
        $Notify.BalloonTipText = "$UpdatesFound repo(s) have updates:`n$($ReposWithUpdates -join ', ')"
        $Notify.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        $Notify.ShowBalloonTip(10000)
        Start-Sleep -Seconds 5
        $Notify.Dispose()
    }
    catch {
        Write-Host "Could not show notification: $_" -ForegroundColor DarkGray
    }
}

Write-Host "============================================" -ForegroundColor Cyan
