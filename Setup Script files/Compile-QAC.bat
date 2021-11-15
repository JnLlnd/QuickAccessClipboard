rem Check that there is no debug code flag
IF [%CHECKHASHTAGS%] == [1] >NUL find "#####" ..\QuickAccessClipboard.ahk && (ECHO Debug code ##### FOUND in QuickAccessClipboard.ahk & PAUSE & EXIT) || (ECHO NO debug code flag found)
rem Check if version number is OK in source file
>NUL find "SetVersion %QACVERSIONNUMBER%" ..\QuickAccessClipboard.ahk && (ECHO Version %QACVERSIONNUMBER% #1 FOUND in QuickAccessClipboard.ahk) || (ECHO SetVersion %QACVERSIONNUMBER% = Version number NOT FOUND in QuickAccessClipboard.ahk & PAUSE & EXIT)
>NUL find """%QACVERSIONNUMBER%""" ..\QuickAccessClipboard.ahk && (ECHO Version %QACVERSIONNUMBER% #2 FOUND in QuickAccessClipboard.ahk) || (ECHO "%QACVERSIONNUMBER%" = Version number NOT FOUND in QuickAccessClipboard.ahk & PAUSE & EXIT)
rem Check branch
IF [%QACBETAPROD%] == [] >NUL find "g_strCurrentBranch := ""prod""" ..\QuickAccessClipboard.ahk && (ECHO Branch "prod" OK in QuickAccessClipboard.ahk) || (ECHO Branch "prod" NOT FOUND in QuickAccessClipboard.ahk & PAUSE & EXIT)
IF [%QACBETAPROD%] == [-beta] >NUL find "g_strCurrentBranch := ""beta""" ..\QuickAccessClipboard.ahk && (ECHO Branch "beta" OK in QuickAccessClipboard.ahk) || (ECHO Branch "beta" NOT FOUND in QuickAccessClipboard.ahk & PAUSE & EXIT)
IF [%QACBETAPROD%] == [-alpha] >NUL find "g_strCurrentBranch := ""alpha""" ..\QuickAccessClipboard.ahk && (ECHO Branch "alpha" OK in QuickAccessClipboard.ahk) || (ECHO Branch "alpha" NOT FOUND in QuickAccessClipboard.ahk & PAUSE & EXIT)
rem Check if Language files are available
rem ECHO Checking language files...
rem C:\Dropbox\AutoHotkey\QuickAccessClipboard\Language\AutoExec-Check4QACLanguageFilesReady.ahk
rem Set current directory
C:
CD \Dropbox\AutoHotkey\QuickAccessClipboard\Build%QACBETAPROD%\
rem Create or update version variables
SET QACVERSIONPREV=%QACVERSIONPREV%%QACBETAPROD%
SET QACVERSIONFILE=%QACVERSION%%QACBETAPROD%
SET QACZIPFILE=quickaccessclipboard%QACBETAPROD%
SET QACZIPFILEVERSION=quickaccessclipboard-%QACVERSIONFILE%
rem Check current version file
IF NOT EXIST "QAC-v%QACVERSIONPREV%.txt" ECHO QAC-v%QACVERSIONPREV%.txt INTROUVABLE...
IF EXIST "QAC-v%QACVERSIONFILE%.txt" ECHO MAIS QAC-v%QACVERSIONFILE%.txt EXISTE - OK!
rem Compile exe files
ECHO Ahk2Exe-QAC.ahk 32 %QACBETAPROD%
"C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Ahk2Exe-Custom\Ahk2Exe-QAC.ahk" 32 %QACBETAPROD%
ECHO Ahk2Exe-QAC.ahk 64 %QACBETAPROD%
"C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Ahk2Exe-Custom\Ahk2Exe-QAC.ahk" 64 %QACBETAPROD%
rem Paude a few seconds
ping 127.0.0.1 -n 3 > nul
ECHO Sign 32 %QACBETAPROD%
CALL "C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Sign-certificat.bat" "C:\Temp\QAC_Compile\Build%QACBETAPROD%\QuickAccessClipboard-32-bit.exe"
IF %ERRORLEVEL% NEQ 0 ECHO UNE ERREUR EST SURVENUE...
IF %ERRORLEVEL% NEQ 0 PAUSE
IF %ERRORLEVEL% NEQ 0 EXIT
ECHO Sign 64 %QACBETAPROD%
CALL "C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Sign-certificat.bat" "C:\Temp\QAC_Compile\Build%QACBETAPROD%\QuickAccessClipboard-64-bit.exe"
IF %ERRORLEVEL% NEQ 0 ECHO UNE ERREUR EST SURVENUE...
IF %ERRORLEVEL% NEQ 0 PAUSE
IF %ERRORLEVEL% NEQ 0 EXIT
rem Paude a few seconds
ping 127.0.0.1 -n 3 > nul
ECHO Copy 32 %QACBETAPROD%
COPY "C:\Temp\QAC_Compile\Build%QACBETAPROD%\QuickAccessClipboard-32-bit.exe"
ECHO Copy 64 %QACBETAPROD%
COPY "C:\Temp\QAC_Compile\Build%QACBETAPROD%\QuickAccessClipboard-64-bit.exe"
rem Compile Setup file
ECHO Inno Setup Compile-QAC.iss
"C:\Program Files (x86)\Inno Setup 6\Compil32.exe" /cc "C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Compile-QAC.iss"
IF %ERRORLEVEL% NEQ 0 ECHO UNE ERREUR EST SURVENUE...
IF %ERRORLEVEL% NEQ 0 PAUSE
IF %ERRORLEVEL% NEQ 0 EXIT
rem Paude a few seconds
ping 127.0.0.1 -n 3 > nul
ECHO Sign Setup file
CALL "C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Sign-certificat.bat" "C:\Temp\QAC_Compile\quickaccessclipboard-setup%QACBETAPROD%.exe"
IF %ERRORLEVEL% NEQ 0 ECHO UNE ERREUR EST SURVENUE...
IF %ERRORLEVEL% NEQ 0 PAUSE
IF %ERRORLEVEL% NEQ 0 EXIT
ECHO Copy quickaccessclipboard-setup%QACBETAPROD%.exe
COPY "C:\Temp\QAC_Compile\quickaccessclipboard-setup%QACBETAPROD%.exe"
ECHO Copy quickaccessclipboard-setup-%QACVERSIONFILE%.exe (for Chocolatey and archives)
COPY "quickaccessclipboard-setup%QACBETAPROD%.exe" "quickaccessclipboard-setup-%QACVERSIONFILE%.exe"
rem Update version file
IF NOT EXIST "QAC-v%QACVERSIONFILE%.txt" REN "QAC-v%QACVERSIONPREV%.txt" "QAC-v%QACVERSIONFILE%.txt"
ECHO Remove previous version and executable files from zip file
"C:\Program Files\7-Zip\7z.exe" d -bso0 "%QACZIPFILE%.zip" QAC-v*.txt QuickAccessClipboard-??-bit.exe
ECHO Add new version and executable files to zip file
"C:\Program Files\7-Zip\7z.exe" a -bso0 "%QACZIPFILE%.zip" QAC-v%QACVERSIONFILE%.txt QuickAccessClipboard-??-bit.exe
ECHO Check if ZIP file is good
IF EXIST "*.tmp*" ECHO Erreur dans le fichier ZIP...
IF EXIST "*.tmp*" GOTO:finish
ECHO Copy %QACZIPFILE%.zip %QACZIPFILE%-%QACVERSIONFILE%.zip (for archives)
COPY "%QACZIPFILE%.zip" "quickaccessclipboard-%QACVERSIONFILE%.zip"
IF [%QACBETAPROD%] == [] CALL "C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Backup-sources.bat"
IF [%QACBETAPROD%] == [] GOTO:messagesbeta
ECHO Copy %QACZIPFILE%.zip to %QACZIPFILEVERSION%.zip
COPY %QACZIPFILE%.zip %QACZIPFILEVERSION%.zip
ECHO Delete previous ZIP file quickaccessclipboard-%QACVERSIONPREV%.zip
IF EXIST quickaccessclipboard-%QACVERSIONPREV%.zip DEL quickaccessclipboard-%QACVERSIONPREV%.zip
:messagesbeta
ECHO TERMINE DE v%QACVERSIONPREV% A v%QACVERSIONFILE% AVEC SUCCES
IF [%QACBETAPROD%] == [] GOTO:messagesprod
ECHO COPIER quickaccessclipboard-setup-%QACVERSIONFILE%.exe dans FTP ftp://clipboard.quickaccesspopup.com/download
ECHO COPIER quickaccessclipboard-%QACVERSIONFILE%.zip dans FTP ftp://clipboard.quickaccesspopup.com/download
ECHO DEPLACER anciennes versions dans FTP ftp://clipboard.quickaccesspopup.com/download/archives
GOTO:finish
:messagesprod
ECHO COPIER quickaccessclipboard-setup.exe dans FTP ftp://www.quickaccessclipboard/download
ECHO COPIER quickaccessclipboard.zip dans FTP ftp://www.quickaccessclipboard/download
ECHO COPIER quickaccessclipboard-setup-%QACVERSIONFILE%.exe et %QACZIPFILE%-%QACVERSIONFILE%.zip dans FTP ftp://www.quickaccessclipboard/download/archives
:finish
PAUSE
