# Log-File-Analysis

This repository contains a log file analysis report for `access.log`, generated on May 10, 2025. It analyzes web server requests, failures, and patterns, with suggestions to improve performance and security.

## Contents
- **Report**: PDF with detailed analysis (`docs/Log_Analysis_Report.pdf`)
- **Script**: Bash script to analyze logs (`src/analyze_log.sh`)
- **Data**: Placeholder for log files (`data/`)

## Key Findings
- **Total Requests**: 9,344 (all GET)
- **Failures**: 1,533 (16.4%), mostly 403 and 404 errors
- **Top IP**: `82.154.31.44` (338 requests)
- **Peak Time**: Hour 12 (983 requests)
- **Suggestions**:
  - Fix 403/404 errors
  - Monitor high-traffic IPs
  - Add caching for peak hours

## How to Use
1. **Run Analysis**:
   - Place `access.log` in `data/`.
   - Run script: `bash src/analyze_log.sh data/access.log`
2. **View Report**:
   - Open `docs/Log_Analysis_Report.pdf`.

## Requirements
- Bash (Linux/macOS or WSL on Windows)
