@ECHO OFF
ECHO Create ZIP file for QAC_source_%QAPVERSIONPREV%.zip
SET AHK_SOURCE_DIR=C:\Dropbox\AutoHotkey
SET DEST_DIR=C:\Dropbox\AutoHotkey\QuickAccessClipboard\Build-v8\Sources_backups
ECHO Add AHK source files
CD %AHK_SOURCE_DIR%
"C:\Program Files\7-Zip\7z.exe" a -bso0 "%DEST_DIR%\QAC_source_%QACVERSION%.zip" QuickAccessClipboard\*.ahk
ping 127.0.0.1 -n 1 > nul
ECHO Copying sources to ZIP file terminated
