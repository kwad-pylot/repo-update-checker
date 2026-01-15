# Repo Update Checker

A Windows tool that automatically checks all Git repositories in a folder for available updates and shows an interactive prompt to pull when updates are found.

## Features

- Scans all Git repos in the parent folder of the script
- Fetches from remote and checks for new commits
- **Auto-popup window** when updates are found (scheduled task)
- Interactive pull menu: pull all, select specific repos, or skip
- Shows Windows toast notification when updates are available
- Logs results to `git_update_log.txt`
- Runs on a schedule via Windows Task Scheduler

## Files

| File | Description |
|------|-------------|
| `git_update_checker.ps1` | Main PowerShell script |
| `run_git_checker.bat` | Wrapper for Task Scheduler (auto-popup on updates) |
| `check_and_pull.bat` | Manual interactive mode (always shows window) |
| `GitUpdateChecker_Task.xml` | Task Scheduler import file (backup) |

## Setup

1. Place the scripts in your Git projects folder (e.g., `C:\Users\you\GitHub Projects\repo-update-checker\`)
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

**Interactive mode** (always shows window with pull options):
```
Double-click check_and_pull.bat
```

**Direct PowerShell** (with options):
```powershell
# Full interactive mode
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1"

# Silent mode (no pull prompt, just check and notify)
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1" -Silent

# Check only (silent, returns exit code: 0=no updates, 1=updates found)
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1" -CheckOnly
```

## Output

**When scheduled task runs:**
- If no updates: stays silent (no window)
- If updates found: popup window with interactive pull menu

**Pull menu options:**
- `[A]` Pull ALL repos with updates
- `[1-N]` Pull specific repo by number
- `[S]` Skip / Exit

**Additional output:**
- Windows toast notification
- Log entry in `git_update_log.txt`
