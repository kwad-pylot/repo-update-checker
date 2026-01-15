# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Windows tool that monitors Git repositories for available updates. Scans the **parent folder** of the script location, checks each repo against its remote, and shows Windows toast notifications when updates are found.

## Running the Scripts

```powershell
# Interactive mode (prompts to pull updates if found)
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1"

# Silent mode (no pull prompt, just check and notify)
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1" -Silent

# Check only (silent, returns exit code: 0=no updates, 1=updates found)
powershell -ExecutionPolicy Bypass -File "git_update_checker.ps1" -CheckOnly
```

Or use the batch files:
- `check_and_pull.bat` - Interactive mode with pause at end
- `run_git_checker.bat` - Two-phase: silent check, then popup if updates found

## Task Scheduler Setup

```powershell
# Import the scheduled task
schtasks /create /xml "GitUpdateChecker_Task.xml" /tn "Git Update Checker"
```

The XML file contains hardcoded paths to `C:\Users\py\Desktop\GitHub Projects\repo-update-checker\` - update these if the repo location changes.

## Architecture

Single PowerShell script (`git_update_checker.ps1`) that:
1. Scans `$ScanDir` (parent of script location) for directories containing `.git`
2. For each repo: `git fetch --all`, then `git rev-list HEAD.."@{u}" --count` to check commits behind
3. Collects results into `$Results` array with status (UPDATE AVAILABLE, UP TO DATE, NO UPSTREAM, NO REMOTE, ERROR)
4. Shows Windows balloon notification via `System.Windows.Forms.NotifyIcon` if updates found
5. In interactive mode: offers menu to pull all repos, specific repos by number, or skip
6. Logs to `git_update_log.txt` in script directory

## Key Parameters

- `-Silent` switch: Skips interactive pull prompt, still shows output and notification
- `-CheckOnly` switch: Runs silently, exits with code 1 if updates found, 0 if none (used by `run_git_checker.bat` for two-phase flow)
