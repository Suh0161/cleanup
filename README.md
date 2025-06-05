# Cleanup Scripts

This repository contains a Windows batch script for performing a comprehensive system cleanup. The script can help free up disk space by removing temporary files, clearing caches, and emptying the recycle bin.

## Usage

Run `full_cleanup.bat` from an elevated command prompt:

```bat
full_cleanup.bat
```

The script will terminate common processes that might lock files, clean temporary directories, clear npm and yarn caches if present, remove common metadata files, and report the amount of disk space freed.

## Notes

- Administrator privileges are recommended to ensure all cleanup operations succeed.
- Review the script before running to confirm it matches your environment.

