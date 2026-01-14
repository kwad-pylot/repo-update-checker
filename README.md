# Repo Update Checker

A Windows tool that automatically checks all Git repositories in a folder for available updates and sends a toast notification when updates are found.

## Features

- Scans all Git repos in the same folder as the script
- Fetches from remote and checks for new commits
- Shows Windows toast notification when updates are available
- Logs results to `git_update_log.txt`
- Runs on a schedule via Windows Task Scheduler

## Files

| File | Description |
|------|-------------|
| `git_update_checker.ps1` | Main PowerShell script |
| `run_git_checker.bat` | Wrapper batch file for Task Scheduler |
| `GitUpdateChecker_Task.xml` | Task Scheduler import file (backup) |

## Setup

1. Place the scripts in your Git projects folder (e.g., `C:\Users\you\GitHub Projects\`)
2. Import the scheduled task:
   ```powershell
   schtasks /create /xml "GitUpdateChecker_Task.xml" /tn "Git Update Checker"
   ```
3. Or create manually in Task Scheduler pointing to `run_git_checker.bat`

## Schedule

Default schedule runs 6 times daily:
- 12:00 AM (midnight)
- 8:00 AM
- 12:00 PM
- 3:00 PM
- 6:00 PM
- 9:00 PM

## Manual Run

Double-click `run_git_checker.bat` or run:
```powershell
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1"
```

## Output

When updates are found, you'll see:
- A Windows toast notification
- Console output showing which repos have updates
- Log entry in `git_update_log.txt`
