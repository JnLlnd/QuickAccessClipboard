;===============================================
/*

Quick Access Clipboard
Written using AutoHotkey v1.1.33.09+ (http://autohotkey.com)
By Jean Lalonde (JnLlnd on AHKScript.org forum)

Copyright 2021-2021 Jean Lalonde
--------------------------------

HISTORY
=======

version: 0.0.2 (2021-11-??)
- 

Version: 0.0.1 (2021-11-14)
- repository creation

*/ 
;========================================================================================================================
!_010_COMPILER_DIRECTIVES:
;========================================================================================================================

; Doc: http://fincs.ahk4.net/Ahk2ExeDirectives.htm
; Note: prefix comma with `

;@Ahk2Exe-SetVersion 0.0.2
;@Ahk2Exe-SetName Quick Access Clipboard
;@Ahk2Exe-SetDescription Quick Access Clipboard (Windows Clipboard editor)
;@Ahk2Exe-SetOrigFilename QuickAccessClipboard.exe
;@Ahk2Exe-SetCopyright (c) Jean Lalonde since 2021
;@Ahk2Exe-SetCompanyName Jean Lalonde


;========================================================================================================================
!_011_INITIALIZATION:
;========================================================================================================================

#NoEnv
#SingleInstance force
#KeyHistory 0
#MaxHotkeysPerInterval 200
ListLines, Off
DetectHiddenWindows, On ; On required for button centering function GuiCenterButtons
SendMode, Input
StringCaseSense, Off
ComObjError(False) ; we will do our own error handling

; #Include %A_ScriptDir%\XML_Class.ahk ; by Maestrith (Chad) https://autohotkey.com/boards/viewtopic.php?f=62&t=33114
#Include %A_ScriptDir%\..\QuickAccessPopup\QAPtools.ahk ; by Jean Lalonde
; #Include %A_ScriptDir%\..\QuickAccessPopup\Class_LV_Rows.ahk ; https://github.com/Pulover/Class_LV_Rows from Rodolfo U. Batista / Pulover (as of 2020-11-22)

; avoid error message when shortcut destination is missing
; see http://ahkscript.org/boards/viewtopic.php?f=5&t=4477&p=25239#p25236
DllCall("SetErrorMode", "uint", SEM_FAILCRITICALERRORS := 1)

; make sure the default system mouse pointer are used after a QAP reload
SetCursor(false)

;---------------------------------
; App Name

global g_strAppNameFile := "QuickAccessClipboard"
global g_strAppNameText := "Quick Access Clipboard"

;---------------------------------
; Init class for command line parameters
; "/Settings:file_path" (must end with ".ini"), "/AdminSilent" and "/Working:path"
global o_CommandLineParameters := new CommandLineParameters()

global g_blnPortableMode
Gosub, SetQACWorkingDirectory
; To test Setup mode in dev environement:
; 1- rename !_do_not_remove_or_rename.txt to _do_not_remove_or_rename.txt
; 2- Below ;@Ahk2Exe-IgnoreBegin, comment out line "SetWorkingDir, %A_ScriptDir%"
; 3- In class Settings, uner __New(), comment out lines changing "this.strIniFile := ..."

; Force A_WorkingDir to A_ScriptDir if uncompiled (development environment)
;@Ahk2Exe-IgnoreBegin
; Start of code for development environment only - won't be compiled
; see http://fincs.ahk4.net/Ahk2ExeDirectives.htm
SetWorkingDir, %A_ScriptDir%
ListLines, On
; to test user data directory: SetWorkingDir, %A_AppData%\Quick Access Clipboard
; / End of code for developement environment only - won't be compiled
;@Ahk2Exe-IgnoreEnd

OnExit, CleanUpBeforeExit ; must be positioned before InitFileInstall to ensure deletion of temporary files

;---------------------------------
; Version global variables

global g_strCurrentVersion := "0.0.2" ; "major.minor.bugs" or "major.minor.beta.release", currently support up to 5 levels (1.2.3.4.5)
global g_strCurrentBranch := "alpha" ; "prod", "beta" or "alpha", always lowercase for filename
global g_strAppVersion := "v" . g_strCurrentVersion . (g_strCurrentBranch <> "prod" ? " " . g_strCurrentBranch : "")
global g_strJLiconsVersion := "1.6.3"

;---------------------------------
; Init class for JLicons
if (g_blnPortableMode)
	global o_JLicons := new JLIcons(A_ScriptDir . "\JLicons.dll") ; in portable mode, same folder as QAP exe file or script directory in developement environment
else ; setup mode
	global o_JLicons := new JLIcons(A_AppDataCommon . "\JeanLalonde\JLicons.dll") ; in setup mode, shared data folder
; set tray icon to loading icon
; Menu, Tray, Icon, % o_JLicons.strFileLocation, 60, 1 ; 60 is iconQAPloading, last 1 to freeze icon during pause or suspend

;---------------------------------
; Init Settings instance
global o_Settings := new Settings

;---------------------------------
; Check if we received an alternative settings file in parameter /Settings:

if StrLen(o_CommandLineParameters.AA["Settings"])
{
	o_Settings.strIniFile := PathCombine(A_WorkingDir, EnvVars(o_CommandLineParameters.AA["Settings"]))
	SplitPath, % o_Settings.strIniFile, strIniFileNameExtOnly
	o_Settings.strIniFileNameExtOnly := strIniFileNameExtOnly
	strIniFileNameExtOnly := ""
}

;---------------------------------
; Create temporary folder

o_Settings.ReadIniOption("Launch", "strQAPTempFolderParent", "QAPTempFolder", " ", "General"
	, "f_strQAPTempFolderParentPath|f_lblQAPTempFolderParentPath|f_btnQAPTempFolderParentPath") ; g_strQAPTempFolderParent

if !StrLen(o_Settings.Launch.strQAPTempFolderParent.IniValue)
	if StrLen(EnvVars("%TEMP%")) ; make sure the environment variable exists
		o_Settings.Launch.strQAPTempFolderParent.IniValue := "%TEMP%" ; for new installation v8.6.9.2+
	else
		o_Settings.Launch.strQAPTempFolderParent.IniValue := A_WorkingDir ; for installations installed before v8.6.9.2

global g_strTempDirParent := PathCombine(A_WorkingDir, EnvVars(o_Settings.Launch.strQAPTempFolderParent.IniValue))

; add a random number between 0 and 2147483647 to generate a unique temp folder in case multiple QAP instances are running
global g_strTempDir := g_strTempDirParent . "\_QAC_temp_" . RandomBetween()
FileCreateDir, %g_strTempDir%

; remove temporary folders older than 7 days
SetTimer, RemoveOldTemporaryFolders, -10000, -100 ; run once in 60 seconds, low priority -100

;---------------------------------
; Init temporary folder

Gosub, InitFileInstall

;---------------------------------
; Init language variables (must be after g_strCurrentBranch init)

global g_strEscapeReplacement := "!r4nd0mt3xt!"
global o_L := new Language

;---------------------------------
; Init global variables

global g_strDiagFile := A_WorkingDir . "\" . g_strAppNameFile . "-DIAG.txt"

global g_intGuiDefaultWidth := 636
global g_intGuiDefaultHeight := 496 ; was 601
global g_saGuiControls := Object() ; to build Editor gui
global g_strGui1Hwnd ; editor window ID
global g_strCliboardBackup

;---------------------------------
; Init language

global o_L := new Language

;---------------------------------
; Initial validation

if InStr("WIN_VISTA|WIN_2003|WIN_XP|WIN_2000", A_OSVersion)
{
	MsgBox, 0, %g_strAppNameText%, % L(o_L["OopsOSVerrsionError"], g_strAppNameText)
	OnExit ; disable exit subroutine
	ExitApp
}

; if the app runs from a zip file, the script directory is created under the system Temp folder
if InStr(A_ScriptDir, A_Temp) ; must be positioned after g_strAppNameFile is created
{
	Oops(0, o_L["OopsZipFileError"], g_strAppNameFile)
	OnExit ; disable exit subroutine
	ExitApp
}

;---------------------------------
; Init routines

Gosub, InitGuiControls

;---------------------------------
; Check JLicons.dll version (now that language file is available)
if (g_blnPortableMode)
	o_JLicons.CheckVersion() ; quits if icon file is outdated

;---------------------------------
; Init class for Triggers (must be before LoadIniFile)
global o_MouseButtons := new Triggers.MouseButtons
global o_PopupHotkeys := new Triggers.PopupHotkeys ; load QAC menu triggers from ini file
global o_PopupHotkeyOpenHotkeyMouse := o_PopupHotkeys.SA[1]
global o_PopupHotkeyOpenHotkeyKeyboard := o_PopupHotkeys.SA[2]

;---------------------------------
; Init class for UTC time conversion
global o_Utc2LocalTime := new Utc2LocalTime

;---------------------------------
; Load Settings file

Gosub, LoadIniFile ; load options, load/enable popup hotkeys, load favorites to menu object

;---------------------------------
; Must be after LoadIniFile

; Init diag mode
if (o_Settings.Launch.blnDiagMode.IniValue)
{
	Gosub, InitDiagMode
	; Diag("Launch", "strLaunchSettingsFolderDiag", strLaunchSettingsFolderDiag)
	strLaunchSettingsFolderDiag := ""
}

; Build menu used in Settings Gui
Gosub, BuildGuiMenuBar ; must be before BuildMainMenuInit
Gosub, BuildTrayMenu

; Build Editor Gui
Gosub, BuildGui
if (o_Settings.Launch.blnCheck4Update.IniValue) ; must be after BuildGui
	Gosub, Check4Update

Gosub, SetTrayMenuIcon

if (o_Settings.Launch.blnDisplayTrayTip.IniValue)
{
	TrayTip, % L(o_L["TrayTipInstalledTitle"], g_strAppNameText)
		, % L(o_L["TrayTipInstalledDetail"]
			, (HasShortcutText(o_PopupHotkeyOpenHotkeyMouse.AA.strPopupHotkeyText)
				? o_PopupHotkeyOpenHotkeyMouse.AA.strPopupHotkeyText : "")
				. (HasShortcutText(o_PopupHotkeyOpenHotkeyMouse.AA.strPopupHotkeyText)
					and HasShortcutText(o_PopupHotkeyOpenHotkeyKeyboard.AA.strPopupHotkeyText)
					? " " . o_L["DialogOr"] . " " : "")
				. (HasShortcutText(o_PopupHotkeyOpenHotkeyKeyboard.AA.strPopupHotkeyText)
					? o_PopupHotkeyOpenHotkeyKeyboard.AA.strPopupHotkeyText : "")) ; "NavigateOrLaunchHotkeyKeyboard"
		, , 17 ; 1 info icon + 16 no sound
	Sleep, 20 ; tip from Lexikos for Windows 10 "Just sleep for any amount of time after each call to TrayTip" (http://ahkscript.org/boards/viewtopic.php?p=50389&sid=29b33964c05f6a937794f88b6ac924c0#p50389)
}

; Enabling Clipboard change in editor
OnClipboardChange("ClipboardContentChanged", 1)
SB_SetText("A) Clipboard: connected", 2)

; startups count and trace
IniWrite, % (intStartups + 1), % o_Settings.strIniFile, Global, Startups
IniWrite, %g_strCurrentVersion%, % o_Settings.strIniFile, Global, % "LastVersionUsed" . (g_strCurrentBranch = "alpha" ? "Alpha" : (g_strCurrentBranch = "beta" ? "Beta" : "Prod"))
IniWrite, % (g_blnPortableMode ? "Portable" : "Easy Setup"), % o_Settings.strIniFile, Global, Installation

;---------------------------------
; Setting window hotkey conditional assignment

Hotkey, If, WinActive(QACSettingsString()) ; main Gui title

	Hotkey, ^c, EditorCtrlC, On UseErrorLevel
	Hotkey, ^v, EditorCtrlV, On UseErrorLevel

	; other Hotkeys are created by menu assignement in BuildGuiMenuBar

Hotkey, If

return

;========================================================================================================================
; Handles for the "Hotkey, If" condition
;========================================================================================================================

;------------------------------------------------------------
;------------------------------------------------------------
#If, CanPopup(A_ThisHotkey)
; empty - act as a handle for the "Hotkey, If, Expression" condition in PopupHotkey.__New() (and elsewhere)
; ("Expression must be an expression which has been used with the #If directive elsewhere in the script.")
#If
;------------------------------------------------------------
;------------------------------------------------------------


;------------------------------------------------------------
;------------------------------------------------------------
#If, WinActive(QACSettingsString()) ; main Gui title
; empty - act as a handle for the "Hotkey, If, Expression" condition in PopupHotkey.__New() (and elsewhere)
; ("Expression must be an expression which has been used with the #If directive elsewhere in the script.")
#If
;------------------------------------------------------------
;------------------------------------------------------------



;========================================================================================================================
!_012_GUI_HOTKEYS:
;========================================================================================================================

; Settings Gui Hotkeys
; see Hotkey, If, WinActive(QAPSettingsString())

;-----------------------------------------------------------
EditorCtrlS: ; ^S::
EditorEsc: ; Escape::
EditorCtrlC: ; Copy
EditorCtrlV: ; Paste
;-----------------------------------------------------------

if (A_ThisLabel = "EditorCtrlS")
{
	Gosub, GuiSaveEditor
}

else if (A_ThisLabel = "EditorEsc")
{
	Gosub, GuiClose
}

else if (A_ThisLabel = "EditorCtrlC" or A_ThisLabel = "EditorCtrlV")
{
	; Disable Clipboard change in editor
	OnClipboardChange("ClipboardContentChanged", 0)
	Send, % (A_ThisLabel = "EditorCtrlC" ? "^c" : "^v")
}

return
;-----------------------------------------------------------

; End of Gui Hotkeys


;========================================================================================================================
; END OF GUI HOTKEYS
;========================================================================================================================


;========================================================================================================================
!_015_INITIALIZATION_SUBROUTINES:
;========================================================================================================================


;-----------------------------------------------------------
SetQACWorkingDirectory:
;-----------------------------------------------------------

; WORKING PARAMETER

; If the "/Working:" parameter is used from the command line (i.e. "c:\path\quickaccessclipboard.exe /working:c:\path"),
; set it as A_WorkingDir and return after setting the portable or setup mode below.

; FYI, the "/Working:" parameter can be set by the user at the command line, in a Windows file shortcut or in the
; current user registry Run key. It has precedence on the Working Folder value in settings file.

if StrLen(o_CommandLineParameters.AA["Working"])
	SetWorkingDir, % o_CommandLineParameters.AA["Working"]

; DETECT INSTALL MODE

; Check in what mode QAC is running:
; - if the file "_do_not_remove_or_rename.txt" is in A_ScriptDir, we are in Setup mode
; - else we are in Portable mode.

g_blnPortableMode := !FileExist(A_ScriptDir . "\_do_not_remove_or_rename.txt")
strLaunchSettingsFolderDiag .= "g_blnPortableMode: " . g_blnPortableMode . "`n"

; IF PORTABLE MODE

; If we are in Portable mode and the parameter "/Working:" is absent, keep the current A_WorkingDir and return. The
; A_WorkingDir is equal to A_ScriptDir except if the user set the "Start In" folder in a Windows file shortcut.
; For example, if the "Run at startup" is enabled with QAC in portable mode, a shortcut is created in the user's
; startup folder with "Start In" set to the current A_WorkingDir.

if (g_blnPortableMode or StrLen(o_CommandLineParameters.AA["Working"]))
	return ; keep current A_WorkingDir or /Working: folder

; FIRST LAUNCH IN SETUP MODE

; The first time QAC is launched after an install (and also for re-install or upgrade), QAC completes its setup.
; To detect if this is the first launch, check if the A_WorkingDir is "C:\ProgramData\Quick Access Clipboard".
; Note: when launched from the Start menu shortcut, A_WorkingDir can also be "C:\ProgramData\Quick Access Clipboard".

if (A_WorkingDir = A_AppDataCommon . "\" . g_strAppNameText) ; this is first launch after installation or update
{
	; This is the first run after installing or re-installing (or QAC was launched from the Start menu shortcut).
	
	if !RegistryExist("HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder")
	{
		; This is the first install (the "WorkingFolder" registry does not exist), set the default autostart key
		; (check if the "WorkingFolder" key exists to avoid setting Run again at next install if user turned it off).
		SetRegistry("quickaccessclipboard.exe", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText)
		; ###_V(A_ThisLabel . " - setup mode, first run after FIRST install, set Run registry key"
			; , "*Run registry key", GetRegistry("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText))
		
		; If the "WorkingFolder" registry value does not exists, create it under the user's "My Documents" folder
		; (e.g. "C:\Users\UserName\Documents\Quick Access Clipboard\"). Create this folder before if required.
		strWorkingFolder := A_MyDocuments . "\" . g_strAppNameText
		if !FileExist(strWorkingFolder) ; must be created before setting the registry key
			FileCreateDir, %strWorkingFolder%
		
		; Create the registry value to register QAC working folder ("HKEY_CURRENT_USER\Software\Jean Lalonde\Quick Access Clipboard\WorkingFolder").
		; The key "HKEY_CURRENT_USER\Software\Jean Lalonde\" is key is removed when uninstalling QAC.
		SetRegistry(strWorkingFolder, "HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder")
		; ###_V(A_ThisLabel . " - setup mode, first run after FIRST install, created (probably) working folder under A_MyDocuments and set working folder registry key"
			; , "*WorkingFolder registry key", GetRegistry("HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder"))
		strLaunchSettingsFolderDiag .= "strWorkingFolder (first install key does not exist): " . strWorkingFolder . "`n"
	}
	else
	{
		; This is first run after re-install or QAC was launched from the Start menu shortcut. The working folder registry value exists.
		strWorkingFolder := GetRegistry("HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder")
		strLaunchSettingsFolderDiag .= "strWorkingFolder (first launch after re-install key exists): " . strWorkingFolder . "`n"
		; ###_V(A_ThisLabel . " - setup mode, first run after RE-install or launched from Start menu, get working folder registry key"
			; , "*WorkingFolder registry key", GetRegistry("HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder"))
	}
}
else ; NOT first launch
{
	; Set working folder by reading the working folder in the registry key:
	; "HKEY_CURRENT_USER\Software\Jean Lalonde\Quick Access Clipboard\WorkingFolder".
	strWorkingFolder := GetRegistry("HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder")
	strLaunchSettingsFolderDiag .= "strWorkingFolder (not first launch): " . strWorkingFolder . "`n"
	; ###_V(A_ThisLabel . " - setup mode, not first run after install, get working folder registry key"
		; , "*WorkingFolder registry key", GetRegistry("HKEY_CURRENT_USER\Software\Jean Lalonde\" . g_strAppNameText, "WorkingFolder"))
}

; At each launch, copy templates files if they do not exist and set the working folder as A_WorkingDir.
if StrLen(strWorkingFolder) 
{
	; Recreate the folder in case the WorkingFolder registry key exists but the folder was deleted
	if !FileExist(strWorkingFolder) 
	{
		FileCreateDir, %strWorkingFolder%
		; ###_V(A_ThisLabel . " - each run, SHOULD NOT happen, created working folder", strWorkingFolder)
	}
	
	; If they do not exist in the working folder, copy the files "quickaccessclipboard-setup.ini" (indicating in what language to run QAC)
	; created by the setup script in the "Common Application Data" folder (e.g. "C:\ProgramData\Quick Access Clipboard") and, if they exist, 
	; the template files for new installations on the same machine/server created by a sysadmin for "quickaccessclipboard.ini" and "QAPconnect.ini".
	if !FileExist(strWorkingFolder . "\quickaccessclipboard-setup.ini")
		FileCopy, %A_AppDataCommon%\Quick Access Clipboard\quickaccessclipboard-setup.ini, %strWorkingFolder%
	if !FileExist(strWorkingFolder . "\quickaccessclipboard.ini")
		FileCopy, %A_AppDataCommon%\quickaccessclipboard.ini, %strWorkingFolder%

	; If working folder exists, sets the A_WorkingDir to this folder.
	; If this folder does not exist, displays an error message and exits the application.
	SetWorkingDir, %strWorkingFolder%
	; ###_V(A_ThisLabel . " - each run, working folder exists, set it as working folder", "*A_WorkingDir", A_WorkingDir)
}
else ; This could happen if the working folder registry value exist but is empty. Ask user to re-install QAC and quit.
{
	Oops(0, "The Quick Access Clipboard settings folder could not be found.`n`nPlease, re-install Quick Access Clipboard.") ; language file is not available yet
	OnExit ; disable exit subroutine
	ExitApp
}

strWorkingFolder := ""
strLaunchSettingsFolderDiag .= "A_WorkingDir: " . A_WorkingDir . "`n"

return
;-----------------------------------------------------------


;-----------------------------------------------------------
InitFileInstall:
;-----------------------------------------------------------

FileInstall, FileInstall\QACrules.exe, %g_strTempDir%\QACrules.exe, 1
FileInstall, FileInstall\QACrules.txt, %g_strTempDir%\QACrules.txt, 1 ; #### temporary until file is generated by QAC
	
return
;-----------------------------------------------------------


;-----------------------------------------------------------
LoadIniFile:
; load options, load rules to menu object
;-----------------------------------------------------------

g_blnIniFileCreation := !FileExist(o_Settings.strIniFile)
if (g_blnIniFileCreation) ; if it exists, it is not first launch
{
	strLanguageCode := o_Settings.Launch.strLanguageCode.IniValue
	
	FileAppend,
		(LTrim Join`r`n
			[Global]
			LanguageCode=%strLanguageCode%
			FixedFont=1
			FontSize=10
			DisplayTrayTip=1
			RulesTimeoutSecs=60
			AlwaysOnTop=0
			UseTab=0
			[Rules]

) ; leave the last extra line above
			, % o_Settings.strIniFile, % (A_IsUnicode ? "UTF-16" : "")
}
else
	Settings.BackupIniFile(o_Settings.strIniFile) ; backup main ini file

; ---------------------
; Load Options

; Group General
o_Settings.ReadIniOption("Launch", "blnRunAtStartup", "", , "General", "f_lblOptionsRunAtStartup|f_blnOptionsRunAtStartup") ; blnRunAtStartup is not used but strGuiControls is
o_Settings.ReadIniOption("Launch", "blnDisplayTrayTip", "DisplayTrayTip", 1, "General", "f_blnDisplayTrayTip") ; g_blnDisplayTrayTip
o_Settings.ReadIniOption("Launch", "blnCheck4Update", "Check4Update", (g_blnPortableMode ? 0 : 1), "General", "f_blnCheck4Update|f_lnkCheck4Update") ; g_blnCheck4Update ; enable by default only in setup install mode
o_Settings.ReadIniOption("Launch", "intRulesTimeoutSecs", "RulesTimeoutSecs", 60, "General", "")

; Group SettingsWindow
o_Settings.ReadIniOption("SettingsWindow", "blnDisplaySettingsStartup", "DisplaySettingsStartup", 0, "SettingsWindow", "f_blnDisplaySettingsStartup|f_lblOptionsSettingsWindow")
o_Settings.ReadIniOption("SettingsWindow", "blnRememberSettingsPosition", "RememberSettingsPosition", 1, "SettingsWindow", "f_blnRememberSettingsPosition") ; g_blnRememberSettingsPosition
o_Settings.ReadIniOption("SettingsWindow", "blnOpenSettingsOnActiveMonitor", "OpenSettingsOnActiveMonitor", 1, "SettingsWindow", "f_blnOpenSettingsOnActiveMonitor") ; g_blnOpenSettingsOnActiveMonitor
o_Settings.ReadIniOption("SettingsWindow", "blnDarkModeCustomize", "DarkModeCustomize", 0, "SettingsWindow", "f_blnDarkModeCustomize")
o_Settings.ReadIniOption("SettingsWindow", "blnFixedFont", "FixedFont", 0, "SettingsWindow", "")
o_Settings.ReadIniOption("SettingsWindow", "intFontSize", "FontSize", 10, "SettingsWindow", "")
o_Settings.ReadIniOption("SettingsWindow", "blnAlwaysOnTop", "AlwaysOnTop", 0, "SettingsWindow", "")
o_Settings.ReadIniOption("SettingsWindow", "blnUseTab", "UseTab", 0, "SettingsWindow", "")

; Group MenuAdvanced
o_Settings.ReadIniOption("MenuAdvanced", "intShowMenuBar", "ShowMenuBar", 3, "MenuAdvanced", "") ; default false, if true reload QAP as admin ; g_blnRunAsAdmin

; Group AdvancedOther
o_Settings.ReadIniOption("LaunchAdvanced", "blnRunAsAdmin", "RunAsAdmin", 0, "AdvancedOther", "f_blnRunAsAdmin|f_picRunAsAdmin") ; default false, if true reload QAP as admin ; g_blnRunAsAdmin

; not in Options Gui
o_Settings.ReadIniOption("Launch", "blnDiagMode", "DiagMode", 0) ; g_blnDiagMode
o_Settings.ReadIniOption("SettingsFile", "strBackupFolder", "BackupFolder", A_WorkingDir, "General"
	, "f_lblBackupFolder|f_strBackupFolder|f_btnBackupFolder|f_lblWorkingFolder|f_strWorkingFolder|f_btnWorkingFolder|f_lblWorkingFolderDisabled")

; ---------------------
; Load rules

Gosub, LoadRulesFromIni

strLanguageCode := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
SetTrayMenuIcon:
;------------------------------------------------------------

Menu, Tray, NoStandard
o_Settings.ReadIniOption("LaunchAdvanced", "strAlternativeTrayIcon", "AlternativeTrayIcon", " ", "AdvancedLaunch", "f_strAlternativeTrayIcon|f_lblAlternativeTrayIcon|f_btnAlternativeTrayIcon") ; empty if not found

Menu, Tray, UseErrorLevel ; will be turned off at the end of SetTrayMenuIcon
arrAlternativeTrayIcon := StrSplit(o_Settings.LaunchAdvanced.strAlternativeTrayIcon.IniValue, ",") ; 1 file, 2 index
strTempAlternativeTrayIconLocation := arrAlternativeTrayIcon[1]
if StrLen(arrAlternativeTrayIcon[1]) and FileExistInPath(strTempAlternativeTrayIconLocation) ; return strTempLocation with expanded relative path and envvars, and absolute location if in PATH
	Menu, Tray, Icon, %strTempAlternativeTrayIconLocation%, % arrAlternativeTrayIcon[2], 1 ; last 1 to freeze icon during pause or suspend
else
	gosub, SetTrayMenuIconForCurrentBranch

if (g_blnTrayIconError)
	Oops(0, o_L["OopsJLiconsError"], g_strJLiconsVersion, (StrLen(strTempAlternativeTrayIconLocation) ? arrAlternativeTrayIcon[1] : o_JLicons.strFileLocation))

arrAlternativeTrayIcon := ""
strTempAlternativeTrayIconLocation := ""
g_blnTrayIconError := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
SetTrayMenuIconForCurrentBranch:
;------------------------------------------------------------

if (A_IsAdmin and o_Settings.LaunchAdvanced.blnRunAsAdmin.IniValue)
	; 68 is iconQACadminBeta and 67 is iconQACadmin, last 1 to freeze icon during pause or suspend
	Menu, Tray, Icon, % o_JLicons.strFileLocation, % (g_strCurrentBranch <> "prod" ? 68 : 67), 1
else
	; 70 is iconQACbeta, 71 is iconQACdev and 66 is iconQAC, last 1 to freeze icon during pause or suspend
	; Menu, Tray, Icon, % o_JLicons.strFileLocation, % (g_strCurrentBranch <> "prod" ? (g_strCurrentBranch = "beta" ? 70 : 71) : 66), 1
	Menu, Tray, Icon, % o_JLicons.strFileLocation, % (g_strCurrentBranch <> "prod" ? (g_strCurrentBranch = "beta" ? 70 : 71) : 66), 1

g_blnTrayIconError := ErrorLevel or g_blnTrayIconError
Menu, Tray, UseErrorLevel, Off

;@Ahk2Exe-IgnoreBegin
; Start of code for developement phase only - won't be compiled
; Menu, Tray, Icon, % o_JLicons.strFileLocation, % (A_IsAdmin ? 69 : 71), 1 ; 69 is iconQACadminDev and 71 is iconQACdev, last 1 to freeze icon during pause or suspend
Menu, Tray, Icon, % o_JLicons.strFileLocation, 71, 1 ; 69 is iconQACadminDev and 71 is iconQACdev, last 1 to freeze icon during pause or suspend
Menu, Tray, Standard
; / End of code for developement phase only - won't be compiled
;@Ahk2Exe-IgnoreEnd

return
;------------------------------------------------------------


;------------------------------------------------------------
BuildTrayMenu:
;------------------------------------------------------------

Menu, Tray, Add, % o_L["MenuEditor"], GuiShowFromTray
if (o_Settings.MenuAdvanced.intShowMenuBar.IniValue > 1) ; 1 Customize menu bar, 2 System menu, 3 both
{
	Menu, Tray, Add
	Menu, Tray, Add, % o_L["MenuFile"], :menuBarFile
}
Menu, Tray, Add
Menu, Tray, Add, % o_L["MenuSuspendHotkeys"], ToggleSuspendHotkeys
Menu, Tray, Add, % o_L["MenuRunAtStartup"], ToggleRunAtStartup ; function ToggleRunAtStartup replaces RunAtStartup
Menu, Tray, Add, % L(o_L["MenuExitApp"], g_strAppNameText), GuiCloseAndExitApp
;@Ahk2Exe-IgnoreBegin
; Start of code for developement phase only - won't be compiled
Menu, Tray, Add
; / End of code for developement phase only - won't be compiled
;@Ahk2Exe-IgnoreEnd

Menu, Tray, NoDefault ; do not open the Customize window on tray icon double-click
Menu, Tray, Tip, % g_strAppNameText . " " . g_strAppVersion . " (" . (A_PtrSize * 8) . "-bit)" ; A_PtrSize * 8 = 32 or 64
Menu, Tray, Default, % o_L["MenuEditor"]
	
return
;------------------------------------------------------------


;------------------------------------------------------------
InitDiagMode:
;------------------------------------------------------------

MsgBox, 52, %g_strAppNameText%, % L(o_L["DiagModeCaution"], g_strAppNameText, g_strDiagFile)
IfMsgBox, No
{
	o_Settings.Launch.blnDiagMode.WriteIni(0)
	return
}

if !FileExist(g_strDiagFile)
{
	FileAppend, DateTime`tType`tData`n, %g_strDiagFile%
	Diag("DIAGNOSTIC FILE", o_L["DiagModeIntro"], "")
	Diag("A_ScriptFullPath", A_ScriptFullPath, "")
	Diag("AppVersion", g_strAppVersion, "")
	Diag("A_WorkingDir", A_WorkingDir, "")
	Diag("A_AhkVersion", A_AhkVersion, "")
	Diag("A_OSVersion", A_OSVersion, "")
	Diag("A_Is64bitOS", A_Is64bitOS, "")
	Diag("A_IsUnicode", A_IsUnicode, "")
	Diag("A_Language", A_Language, "")
	Diag("A_IsAdmin", A_IsAdmin, "")
}

FileRead, strIniFileContent, % o_Settings.strIniFile
strIniFileContent := StrReplace(strIniFileContent, """", """""")
Diag("IniFile", "`n""" . strIniFileContent . """`n", "")
FileAppend, `n, %g_strDiagFile% ; required when the last line of the existing file ends with "

strIniFileContent := ""

return
;------------------------------------------------------------



;========================================================================================================================
!_032_GUI:
;========================================================================================================================

;------------------------------------------------------------
BuildGuiMenuBar:
; see https://docs.microsoft.com/fr-fr/windows/desktop/uxguide/cmd-menus
;------------------------------------------------------------

Menu, menuBarFile, Add, % o_L["GuiSaveClipboard"] . "`tCtrl+S", EditorCtrlS
Menu, menuBarFile, Add, % o_L["GuiCancelEditor"], GuiCancelEditor
Menu, menuBarFile, Add, % o_L["GuiClose"] . "`tEsc", GuiClose
Menu, menuBarFile, Add
Menu, menuBarFile, Add, % L(o_L["MenuExitApp"], g_strAppNameText), GuiCloseAndExitApp
Menu, menuBarMain, Add, % o_L["MenuFile"], :menuBarFile

return
;------------------------------------------------------------


;------------------------------------------------------------
LoadRulesFromIni:
;------------------------------------------------------------

if !FileExist(o_Settings.strIniFile)
{
	Oops(0, o_L["OopsWriteProtectedError"], g_strAppNameText)
	OnExit ; disable exit subroutine
	ExitApp
}
else
{
	; load
}

return
;------------------------------------------------------------


;------------------------------------------------------------
InitGuiControls:
; Order of controls important to avoid drawgins gliches when resizing
;------------------------------------------------------------

; InsertGuiControlPos(strControlName, intX, intY, blnCenter := false, blnDraw := false)

InsertGuiControlPos("f_strClipboardEditor",				 20,   130)

InsertGuiControlPos("f_btnGuiSaveEditor",			0,  -65, , true)
InsertGuiControlPos("f_btnGuiCancelEditor",			0,  -65, , true)
InsertGuiControlPos("f_btnGuiClose",				0,  -65, , true)

return
;------------------------------------------------------------


;------------------------------------------------------------
InsertGuiControlPos(strControlName, intX, intY, blnCenter := false, blnDraw := false)
;------------------------------------------------------------
{
	aaGuiControl := Object()
	aaGuiControl.Name := strControlName
	aaGuiControl.X := intX
	aaGuiControl.Y := intY
	aaGuiControl.Center := blnCenter
	aaGuiControl.Draw := blnDraw
	
	g_saGuiControls.Push(aaGuiControl)
}
;------------------------------------------------------------


;------------------------------------------------------------
BuildGui:
;------------------------------------------------------------

Gui, 1:New, +Hwndg_strGui1Hwnd +Resize -MinimizeBox +MinSize%g_intGuiDefaultWidth%x%g_intGuiDefaultHeight%, % QACSettingsString()

if (o_Settings.MenuAdvanced.intShowMenuBar.IniValue <> 2) ; 1 Customize menu bar, 2 System menu, 3 both
	Gui, Menu, menuBarMain

Gui, 1:Font, s8 w600
Gui, 1:Add, Text, x20 y10, % o_L["GuiRules"]
Gui, 1:Font, s8 w400
Gui, 1:Add, Checkbox, x20 vf_blnLowerCase gRuleCheckboxChanged, % o_L["GuiLowerCase"]
Gui, 1:Add, Checkbox, x+1 yp vf_blnUpperCase gRuleCheckboxChanged, % o_L["GuiUpperCase"]
Gui, 1:Add, Checkbox, x+1 yp vf_blnFirstUpperCase gRuleCheckboxChanged, % o_L["GuiFirstUpperCase"]
Gui, 1:Add, Checkbox, x+1 yp vf_blnTitleCase gRuleCheckboxChanged, % o_L["GuiTitleCase"]
Gui, 1:Add, Checkbox, x+1 yp vf_blnUnderscore2Space gRuleCheckboxChanged, % o_L["GuiUnderscore2Space"]
Gui, 1:Font, s8 w600, Verdana
Gui, 1:Add, Button, x10 y+10 vf_btnGuiApplyRules gGuiApplyRules h25 Disabled, % o_L["GuiApplyRules"]
GuiCenterButtons(g_strGui1Hwnd, , , , "f_btnGuiApplyRules")

Gui, 1:Font, s8 w600
Gui, 1:Add, Text, x20 y+5, % o_L["MenuEditor"]
Gui, 1:Font, s8 w400
Gui, 1:Add, Checkbox, % "x20 y+5 vf_blnFixedFont gClipboardEditorFontChanged " . (o_Settings.SettingsWindow.blnFixedFont.IniValue = 1 ? "checked" : ""), % o_L["DialogFixedFont"]
Gui, 1:Add, Text, x+10 yp vf_lblFontSize, % o_L["DialogFontSize"]
Gui, 1:Add, Edit, x+5 yp w40 vf_intFontSize gClipboardEditorFontChanged
Gui, 1:Add, UpDown, Range6-18 vf_intFontUpDown, % o_Settings.SettingsWindow.intFontSize.IniValue
Gui, 1:Add, Checkbox, % "x+20 yp vf_blnAlwaysOnTop gClipboardEditorAlwaysOnTopChanged " . (o_Settings.SettingsWindow.blnAlwaysOnTop.IniValue = 1 ? "checked" : ""), % o_L["DialogAlwaysOnTop"]
Gui, 1:Add, Checkbox, % "x+10 yp vf_blnUseTab gClipboardEditorUseTabChanged " . (o_Settings.SettingsWindow.blnUseTab.IniValue = 1 ? "checked" : ""), % o_L["DialogUseTab"]

Gui, 1:Font, s10 w400, Arial
Gui, 1:Add, Edit, x10 y50 w600 vf_strClipboardEditor gClipboardEditorChanged Multi WantReturn

Gui, 1:Font, s8 w600, Verdana
Gui, 1:Add, Button, vf_btnGuiSaveEditor Disabled gGuiSaveEditor x200 y400 w140 h35, % o_L["GuiSaveClipboard"]
Gui, 1:Add, Button, vf_btnGuiCancelEditor Disabled gGuiCancelEditor x350 yp w140 h35, % o_L["GuiCancelEditor"]
Gui, 1:Add, Button, vf_btnGuiClose gGuiClose Default x500 yp w100 h35, % o_L["GuiClose"]
Gui, 1:Font

g_blnAlwaysOnTop := !o_Settings.SettingsWindow.blnAlwaysOnTop.IniValue
gosub, ClipboardEditorAlwaysOnTopChanged
g_blnUseTab := !o_Settings.SettingsWindow.blnUseTab.IniValue
gosub, ClipboardEditorUseTabChanged

Gui, 1:Add, StatusBar
SB_SetParts(200, 200)

GetSavedSettingsWindowPosition(saSettingsPosition) ; format: x|y|w|h with optional |M if maximized

Gui, 1:Show, % "Hide "
	. (saSettingsPosition[1] = -1 or saSettingsPosition[1] = "" or saSettingsPosition[2] = ""
	? "center w" . g_intGuiDefaultWidth . " h" . g_intGuiDefaultHeight
	: "x" . saSettingsPosition[1] . " y" . saSettingsPosition[2])
sleep, 100
if (saSettingsPosition[1] <> -1)
{
	WinMove, ahk_id %g_strGui1Hwnd%, , , , % saSettingsPosition[3], % saSettingsPosition[4]
	if (saSettingsPosition[5] = "M")
	{
		WinMaximize, ahk_id %g_strGui1Hwnd%
		WinHide, ahk_id %g_strGui1Hwnd%
	}
}

; testing the dark mode display on Customize window (see https://www.autohotkey.com/boards/viewtopic.php?p=426678&sid=0f08bed4b46e1ed1f59601053df8c959#p426678)
RegRead, blnLightMode, HKCU, SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme ; check SystemUsesLightTheme for Windows system preference
if (o_Settings.SettingsWindow.blnDarkModeCustomize.IniValue and !blnLightMode)
	; si dark mode forcer theme "Windows"
{
	intWindowColor := 0x404040
	intControlColor := 0xFFFFFF
		
	WinGet, strControlList, ControlList, ahk_id %g_strGui1Hwnd%
	Gui, Color, %intWindowColor%, %intControlColor%
	for strKey, strControl in StrSplit(strControlList,"`n","`r`n")
	{
		ControlGet, strControlHwnd, HWND, , %strControl%, ahk_id %strHwnd%
		
		if InStr(strControl, "ListView") ; for ListView control
		{
			GuiControl, +Background%intWindowColor%,%strControl%
			Gui,Font, c%intControlColor%
			GuiControl, Font, %strControl%
		}
		if InStr(strControl, "Static")
		{
			Gui,Font, c%intControlColor%
			GuiControl, Font, %strControl%
		}
	}
}

saSettingsPosition := ""
strTextColor := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

OnClipboardChange("ClipboardContentChanged", 0)
SB_SetText("B) " . o_L["GuiLength"] . ": " . StrLen(f_strClipboardEditor), 1)
SB_SetText("B) " . "Clipboard: NOT connected", 2)
gosub, EnableSaveAndCancel

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorAlwaysOnTopChanged:
;------------------------------------------------------------

g_blnAlwaysOnTop := !g_blnAlwaysOnTop

WinSet, AlwaysOnTop, % (g_blnAlwaysOnTop ? "On" : "Off"), ahk_id %g_strGui1Hwnd% ; do not use default Toogle for safety
GuiControl, %g_blnAlwaysOnTop%, f_blnAlwaysOnTop
; Menu, menuBarTools, ToggleCheck, % aaMenuToolsL["ControlToolTipAlwaysOnTopOff"]

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorUseTabChanged:
;------------------------------------------------------------

g_blnUseTab := !g_blnUseTab

; GuiControl, % (g_blnUseTab ? "+" : "-") . "WantTab", f_blnUseTab
GuiControl, % (g_blnUseTab ? "+" : "-") . "WantTab", f_strClipboardEditor
GuiControl, %g_blnUseTab%, f_blnUseTab
; Menu, menuBarTools, ToggleCheck, % aaMenuToolsL["ControlToolTipAlwaysOnTopOff"]

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardContentChanged()
;------------------------------------------------------------
{
	strDetectHiddenWindowsBefore := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	If WinExist("ahk_id " . g_strGui1Hwnd)
	{
		g_strCliboardBackup := ClipboardAll
		GuiControl, , f_strClipboardEditor, %Clipboard%
		Gosub, DisableSaveAndCancel
		SB_SetText("C) " . o_L["GuiLength"] . ": " . StrLen(Clipboard), 1)
	}
	DetectHiddenWindows, %strDetectHiddenWindowsBefore%

}
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorFontChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

o_Settings.SettingsWindow.blnFixedFont.IniValue := f_blnFixedFont
o_Settings.SettingsWindow.intFontSize.IniValue := f_intFontSize

if (o_Settings.SettingsWindow.blnFixedFont.IniValue)
	Gui, 1:Font, % "s" . o_Settings.SettingsWindow.intFontSize.IniValue, Courier New
else
	Gui, 1:Font, % "s" . o_Settings.SettingsWindow.intFontSize.IniValue
GuiControl, Font, f_strClipboardEditor
Gui, 1:Font

return
;------------------------------------------------------------


;------------------------------------------------------------
RuleCheckboxChanged:
;------------------------------------------------------------

GuiControl, Enable, f_btnGuiApplyRules

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiSaveEditor:
GuiCancelEditor:
;------------------------------------------------------------
Gui, Submit, NoHide

gosub, DisableSaveAndCancel

if (A_ThisLabel = "GuiSaveEditor")
	Clipboard := f_strClipboardEditor
else
	GuiControl, , f_strClipboardEditor, %Clipboard%

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiApplyRules:
;------------------------------------------------------------
Gui, Submit, NoHide

GuiControl, Disable, f_btnGuiApplyRules
Gosub, RulesUpdate

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiSize:
;------------------------------------------------------------

if (A_EventInfo = 1)  ; The window has been minimized.  No action needed.
    return

intEditorH := A_GuiHeight - 205
g_intEditorW := A_GuiWidth - 40

; space before, between and after save/reload/close buttons
; = (A_GuiWidth - left margin - right margin - (3 buttons width)) // 4 (left, between x 2, right)
intButtonSpacing := (A_GuiWidth - 120 - 120 - (140 + 100 + 100)) // 4

for intIndex, aaGuiControl in g_saGuiControls
{
	intX := aaGuiControl.X
	intY := aaGuiControl.Y

	if (intX < 0)
		intX:= A_GuiWidth + intX
	if (intY < 0)
		intY := A_GuiHeight + intY

	if (aaGuiControl.Center)
	{
		GuiControlGet, arrPos, Pos, % aaGuiControl.Name
		intX := intX - (arrPosW // 2) ; Floor divide
	}

	if (aaGuiControl.Name = "f_btnGuiSaveEditor")
		intX := 80 + intButtonSpacing
	else if (aaGuiControl.Name = "f_btnGuiCancelEditor")
		intX := 80 + (2 * intButtonSpacing) + 140 ; 140 for 1st button
	else if (aaGuiControl.Name = "f_btnGuiClose")
		intX := 80 + (3 * intButtonSpacing) + 140 + 140 ; 140 for 1st button, 100 for 2nd button
		
	GuiControl, % "1:Move" . (aaGuiControl.Draw ? "Draw" : ""), % aaGuiControl.Name, % "x" . intX	.  " y" . intY
		
}

GuiControl, 1:Move, f_strClipboardEditor, w%g_intEditorW% h%intEditorH%

intListH := ""
intButtonSpacing := ""
intIndex := ""
aaGuiControl := ""
intX := ""
intY := ""
arrPos := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiCheck4Update:
;------------------------------------------------------------
; !! adapt

strChangeLog := Url2Var("https://www.quickaccesspopup.com/changelog/changelog" . (g_strUpdateProdOrBeta <> "prod" ? "-" . g_strUpdateProdOrBeta : "") . ".txt")

if StrLen(strChangeLog)
{
	intPos := InStr(strChangeLog, "Version" . (g_strUpdateProdOrBeta = "beta" ? " BETA" : (g_strUpdateProdOrBeta = "alpha" ? " ALPHA" : "")) . ": " . g_strUpdateLatestVersion . " ")
	strChangeLog := SubStr(strChangeLog, intPos)
	intPos := InStr(strChangeLog, "`n`n")
	strChangeLog := SubStr(strChangeLog, 1, intPos - 1)
}

strGuiTitle := L(o_L["UpdateTitle"], g_strAppNameText)
Gui, Update:New, +Hwndg_strGui3Hwnd, %strGuiTitle%
; Do not use g_strMenuBackgroundColor here because it is not set yet

Gui, Update:Font, s10 w700, Verdana
Gui, Update:Add, Text, x10 y10 w640, % L(o_L["UpdateTitle"], g_strAppNameText)
Gui, Update:Font
Gui, Update:Add, Text, x10 w640, % l(o_L["UpdatePrompt"], g_strAppNameText, g_strCurrentVersion
	, g_strUpdateLatestVersion . (g_strUpdateProdOrBeta <> "prod" ? " " . g_strUpdateProdOrBeta : ""))
Gui, Update:Add, Edit, x8 y+10 w640 h300 ReadOnly, %strChangeLog%
Gui, Update:Font

Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogChangeLog gButtonCheck4UpdateDialogChangeLog, % o_L["UpdateButtonChangeLog"]
Gui, Update:Add, Button, yp x+20 vf_btnCheck4UpdateDialogVisit gButtonCheck4UpdateDialogVisit, % o_L["UpdateButtonVisit"]

GuiCenterButtons(g_strGui3Hwnd, 10, 5, 20, "f_btnCheck4UpdateDialogChangeLog", "f_btnCheck4UpdateDialogVisit")

if (g_strUpdateProdOrBeta = "prod")
{
	if (g_blnPortableMode)
		Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogDownload gButtonCheck4UpdateDialogDownloadPortable, % o_L["UpdateButtonDownloadPortable"]
	else
		Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogDownload gButtonCheck4UpdateDialogDownloadSetup, % o_L["UpdateButtonDownloadSetup"]

	GuiCenterButtons(g_strGui3Hwnd, 10, 5, 20, "f_btnCheck4UpdateDialogDownload")
}

Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogSkipVersion gButtonCheck4UpdateDialogSkipVersion, % o_L["UpdateButtonSkipVersion"]
Gui, Update:Add, Button, yp x+20 vf_btnCheck4UpdateDialogRemind gButtonCheck4UpdateDialogRemind, % o_L["UpdateButtonRemind"]
Gui, Update:Add, Text

GuiCenterButtons(g_strGui3Hwnd, 10, 5, 20, "f_btnCheck4UpdateDialogSkipVersion", "f_btnCheck4UpdateDialogRemind")

GuiControl, Update:Focus, f_btnCheck4UpdateDialogRemind
CalculateTopGuiPosition(g_strGui3Hwnd, g_strGui1Hwnd, intX, intY)
Gui, Update:Show, AutoSize x%intX% y%intY%

strGuiTitle := ""

return

;------------------------------------------------------------


;------------------------------------------------------------
ButtonCheck4UpdateDialogChangeLog:
ButtonCheck4UpdateDialogVisit:
ButtonCheck4UpdateDialogDownloadSetup:
ButtonCheck4UpdateDialogDownloadPortable:
ButtonCheck4UpdateDialogSkipVersion:
ButtonCheck4UpdateDialogRemind:
UpdateGuiClose:
UpdateGuiEscape:
;------------------------------------------------------------

strUrlChangeLog := AddUtm2Url("https://www.quickaccesspopup.com/change-log" . (g_strUpdateProdOrBeta <> "prod" ? "-" . g_strUpdateProdOrBeta . "-version" : "") . "/", A_ThisLabel, "Check4Update")
strUrlDownloadSetup := AddUtm2Url("https://www.quickaccesspopup.com/latest/check4update-download-setup-redirect.html", A_ThisLabel, "Check4Update") ; prod only
strUrlDownloadPortable:= AddUtm2Url("https://www.quickaccesspopup.com/latest/check4update-download-portable-redirect.html", A_ThisLabel, "Check4Update") ; prod only
strUrlAppLandingPageBeta := AddUtm2Url("https://forum.quickaccesspopup.com/forumdisplay.php?fid=11", A_ThisLabel, "Check4Update")

if InStr(A_ThisLabel, "ButtonCheck4UpdateDialogChangeLog")
	Run, %strUrlChangeLog%
else if (A_ThisLabel = "ButtonCheck4UpdateDialogVisit")
	Run, % (g_strUpdateProdOrBeta = "prod" ? g_strUrlAppLandingPage : strUrlAppLandingPageBeta) ; beta page also for alpha
else if (A_ThisLabel = "ButtonCheck4UpdateDialogDownloadSetup")
	Run, %strUrlDownloadSetup%
else if (A_ThisLabel = "ButtonCheck4UpdateDialogDownloadPortable")
	Run, %strUrlDownloadPortable%
else if (A_ThisLabel = "ButtonCheck4UpdateDialogSkipVersion")
{
	IniWrite, % (g_strUpdateProdOrBeta = "alpha" ? strLatestVersionAlpha : (g_strUpdateProdOrBeta = "beta" ? strLatestVersionBeta : strLatestVersionProd)), % o_Settings.strIniFile, Global
		, % "LatestVersionSkipped" . (g_strUpdateProdOrBeta = "alpha" ? "Alpha" : (g_strUpdateProdOrBeta = "beta" ? "Beta" : "")) ; do not add "Prod" to ini variable for backward compatibility
	if (g_strUpdateProdOrBeta <> "prod")
	{
		MsgBox, 4, % l(o_L["UpdateTitle"], g_strAppNameText . " " . g_strUpdateProdOrBeta)
			, % (g_strUpdateProdOrBeta = "alpha" ? StrReplace (o_L["UpdatePromptBetaContinue"], "beta" "alpha") ; it seems safe to replace for all languages
			: o_L["UpdatePromptBetaContinue"])
		IfMsgBox, No
			IniWrite, 0.0, % o_Settings.strIniFile, Global, LastVersionUsedBeta
	}
}
else ; ButtonCheck4UpdateDialogRemind, UpdateGuiClose or UpdateGuiEscape
	IniWrite, 0.0, % o_Settings.strIniFile, Global
		, % "LatestVersionSkipped" . (g_strUpdateProdOrBeta = "alpha" ? "Alpha" : (g_strUpdateProdOrBeta = "beta" ? "Beta" : "")) ; do not add "Prod" to ini variable for backward compatibility

Gui, Destroy

Check4UpdateDialogCleanup:
strChangelog := ""
strUrlChangeLog := ""
strUrlDownloadSetup := ""
strUrlDownloadPortable:= ""
strUrlAppLandingPageBeta := ""

return
;------------------------------------------------------------


;========================================================================================================================
; END OF INITIALIZATION
;========================================================================================================================


;========================================================================================================================
!_017_EXIT:
;========================================================================================================================

;-----------------------------------------------------------
CleanUpBeforeExit:
;-----------------------------------------------------------

; kill QACrules.exe
if QACrulesExists()
{
	Process, Close, QACrules.exe
	ToolTip, Quick Access Clipboard rules removed...
	Sleep, 1000
}

if (o_Settings.Launch.blnDiagMode.IniValue)
	Run, %g_strDiagFile%

DllCall("LockWindowUpdate", Uint, g_strGui1Hwnd) ; lock QAP window while restoring window
if FileExist(o_Settings.strIniFile) ; in case user deleted the ini file to create a fresh one, this avoids creating an ini file with just this value
{
	SaveWindowPosition("SettingsPosition", "ahk_id " . g_strGui1Hwnd)
	IniWrite, % GetScreenConfiguration(), % o_Settings.strIniFile, Global, LastScreenConfiguration
	IniDelete, % o_Settings.strIniFile, Global, ExternalErrorMessageExclusions ; delete value created to avoid (in this session only) repetitive error messages for unfound external menus
}
DllCall("LockWindowUpdate", Uint, 0)  ; 0 to unlock the window

FileRemoveDir, %g_strTempDir%, 1 ; Remove all files and subdirectories

ExitApp
;-----------------------------------------------------------


;========================================================================================================================
; END OF EXIT
;========================================================================================================================



;========================================================================================================================
!_040_RULES:
;========================================================================================================================

;-----------------------------------------------------------
RulesUpdate:
;-----------------------------------------------------------
Gui, Submit, NoHide

While QACrulesExists()
	Process, Close, QACrules.exe

strRulesPathNoExt := g_strTempDir . "\QACrules"
FileDelete, %strRulesPathNoExt%.ahk

intTimeoutSecs := o_Settings.Launch.intRulesTimeoutSecs.IniValue
intTimeoutMs := intTimeoutSecs * 1000

FileAppend,
	(LTrim Join`r`n
	#NoEnv
	#Persistent
	#SingleInstance force
	#NoTrayIcon

	global g_intLastTick := A_TickCount ; initial timeout delay after rules are enabled
	
	OnClipboardChange("LowerCase", %f_blnLowerCase%)
	OnClipboardChange("UpperCase", %f_blnUpperCase%)
	OnClipboardChange("FirstUpperCase", %f_blnFirstUpperCase%)
	OnClipboardChange("TitleCase", %f_blnTitleCase%)
	OnClipboardChange("Underscore2Space", %f_blnUnderscore2Space%)

	SetTimer, CheckTimeOut, 2000
	
	return
	
	;-----------------------------------------------------------
	CheckTimeOut:
	;-----------------------------------------------------------

	if (A_TickCount - g_intLastTick > %intTimeoutMs%)
	{
		ToolTip, Quick Access Clipboard rules disabled (%intTimeoutSecs% seconds timeout)
		Sleep, 2000
		ExitApp
	}

	return
	;-----------------------------------------------------------


) ; leave the 2 last extra lines above
	, %strRulesPathNoExt%.ahk, % (A_IsUnicode ? "UTF-16" : "")

; #### temporary until generated by QAC
FileRead, strRules, %strRulesPathNoExt%.txt
FileAppend, %strRules%, %strRulesPathNoExt%.ahk, % (A_IsUnicode ? "UTF-16" : "")

Run, %strRulesPathNoExt%.exe

ToolTip, Quick Access Clipboard rules updated...
Sleep, 1000
ToolTip

strRulesPathNoExt := ""
strRules := ""

return
;-----------------------------------------------------------


;-----------------------------------------------------------
QACrulesExists()
;-----------------------------------------------------------
{
	Process, Exist, QACrules.exe
	return ErrorLevel
}
;-----------------------------------------------------------


;========================================================================================================================
; END OF RULES
;========================================================================================================================



;========================================================================================================================
!_050_GUI_CLOSE-CANCEL-BK_OBJECTS:
;========================================================================================================================

;------------------------------------------------------------
GuiEscape:
;------------------------------------------------------------

GoSub, GuiCloseFromEscape

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiClose:
GuiCloseFromEscape:
GuiCloseAndExitApp:
;------------------------------------------------------------

if EditorUnsaved()
{
	Gui, 1:+OwnDialogs
	MsgBox, 36, % L(o_L["DialogCancelTitle"], g_strAppNameText, g_strAppVersion), % o_L["DialogCancelPrompt"]
	IfMsgBox, No
		return
}

if (A_ThisLabel = "GuiCloseAndExitApp")
	ExitApp
; else continue

Gosub, DisableSaveAndCancel

Gui, 1:Cancel

return
;------------------------------------------------------------


;------------------------------------------------------------
EnableSaveAndCancel:
DisableSaveAndCancel:
;------------------------------------------------------------

; enable/disable editor's gui buttons
GuiControl, % (A_ThisLabel = "EnableSaveAndCancel" ? "1:Enable" : "1:Disable"), f_btnGuiSaveEditor
GuiControl, % (A_ThisLabel = "EnableSaveAndCancel" ? "1:Enable" : "1:Disable"), f_btnGuiCancelEditor

Menu, menuBarFile, % (A_ThisLabel = "EnableSaveAndCancel" ? "Enable" : "Disable"), % o_L["GuiSaveClipboard"] . "`tCtrl+S"
Menu, menuBarFile, % (A_ThisLabel = "EnableSaveAndCancel" ? "Enable" : "Disable"), % L(o_L["GuiCancelEditor"])

OnClipboardChange("ClipboardContentChanged", (A_ThisLabel = "DisableSaveAndCancel"))
SB_SetText("D) Clipboard: " . ((A_ThisLabel = "DisableSaveAndCancel") ? "" : "NOT") . " connected", 2)

return
;------------------------------------------------------------


;========================================================================================================================
!_060_POPUP:
return
;========================================================================================================================

;------------------------------------------------------------
OpenHotkeyMouse:
OpenHotkeyKeyboard:
;------------------------------------------------------------

Gosub, GuiShow

return
;------------------------------------------------------------


;------------------------------------------------------------
CanPopup(strMouseOrKeyboard) ; SEE HotkeyIfWin.ahk to use Hotkey, If, Expression
;------------------------------------------------------------
{
	global

/* !! Adapt from QAP? Will process window exclusions?
	if (strMouseOrKeyboard = o_PopupHotkeyNavigateOrLaunchHotkeyMouse.P_strAhkHotkey) ; if hotkey is mouse
		Loop, Parse, % o_Settings.MenuPopup.strExclusionMouseList.strExclusionMouseListApp, |
			if StrLen(A_Loopfield)
				and (InStr(g_strTargetClass, A_LoopField)
				or InStr(g_strTargetWinTitle, A_LoopField)
				or InStr(g_strTargetProcessName, A_LoopField))
				return (o_Settings.MenuPopup.blnExclusionMouseListWhitelist.IniValue ? true : false)

	if WindowIsTray(g_strTargetClass)
		return o_Settings.MenuPopup.blnOpenMenuOnTaskbar.IniValue

	if WindowIsTreeview(g_strTargetWinId)
		return false
	
	if WindowIsDialog(g_strTargetClass, g_strTargetWinId) and DialogBoxParentExcluded(g_strTargetWinId)
		return false
	
	; else we can launch

	return (o_Settings.MenuPopup.blnExclusionMouseListWhitelist.IniValue ? false : true)
*/
	return true
}
;------------------------------------------------------------


;------------------------------------------------------------
GuiShow:
GuiShowFromTray:
;------------------------------------------------------------

strCheckBoxes := "f_blnLowerCase|f_blnUpperCase|f_blnFirstUpperCase|f_blnTitleCase|f_blnUnderscore2Space"
aaCheckBoxesValues := Object()
loop, Parse, strCheckBoxes, |
{
	GuiControlGet, blnValue, , %A_LoopField%
	aaCheckBoxesValues[A_LoopField] := blnValue
}
blnValue := ""

g_strCliboardBackup := ClipboardAll
GuiControl, , f_strClipboardEditor, %Clipboard%
; GuiControl, Focus, f_strClipboardEditor
SB_SetText("E) " . o_L["GuiLength"] . ": " . StrLen(Clipboard), 1)

Gosub, DisableSaveAndCancel
Gui, Show

; wait until window is closed to alert user if rules were changed but not applied

strDetectHiddenWindowsBefore := A_DetectHiddenWindows
DetectHiddenWindows, Off
WinWaitClose, ahk_id %g_strGui1Hwnd%

; from here, window has been closed
Gui, Submit, NoHide
GuiControlGet, blnUpdateRulesButtonChecked, Enabled, f_btnGuiApplyRules

if (blnUpdateRulesButtonChecked) ; rules were changed but not applied
{
	; reset checkboxes to their original value
	loop, Parse, strCheckBoxes, |
		GuiControl, , %A_LoopField%, % aaCheckBoxesValues[A_LoopField]
	strCheckBoxes := ""
	oCheckBoxesValues := ""
	
	ToolTip, % o_L["GuiRulesNotUpdated"]
	Sleep, 2500
	ToolTip
}

DetectHiddenWindows, %strDetectHiddenWindowsBefore%
strDetectHiddenWindowsBefore := ""

return
;------------------------------------------------------------



;========================================================================================================================
!_076_TRAY_MENU_ACTIONS:
;========================================================================================================================

;------------------------------------------------------------
ShowSettingsIniFile:
;------------------------------------------------------------

; !! add to File menu bar
Run, % o_Settings.strIniFile

return
;------------------------------------------------------------


;========================================================================================================================
; END OF TRAY MENU ACTIONS
;========================================================================================================================


;========================================================================================================================
!_090_VARIOUS_COMMANDS:
return
;========================================================================================================================

;------------------------------------------------------------
RemoveOldTemporaryFolders:
; remove temporary folders older than 5 days
;------------------------------------------------------------

Loop, Files, %g_strTempDirParent%\_QAP_temp_*,  D
{
	strDate := A_Now
	EnvSub, strDate, %A_LoopFileTimeModified%, D
	if (strDate > 5)
	{
		FileRemoveDir, %A_LoopFileFullPath%, 1 ; Remove all files and subdirectories
		Sleep, 10000 ; wait 10 second
	}
}

return
;------------------------------------------------------------


;------------------------------------------------------------
Check4Update:
Check4UpdateNow:
;------------------------------------------------------------

; !! implement on website
strUrlCheck4Update := "https://clipboard.quickaccesspopup.com/latest/latest-version-4.php"

g_strUrlAppLandingPage := "https://clipboard.quickaccesspopup.com" ; must be here if user select Check for update from tray menu
strBetaLandingPage := "https://clipboard.quickaccesspopup.com/latest/check4update-beta-redirect.html"

strLatestSkippedProd := o_Settings.ReadIniValue("LatestVersionSkipped", 0.0)
strLatestSkippedBeta := o_Settings.ReadIniValue("LatestVersionSkippedBeta", 0.0)
strLatestUsedBeta := o_Settings.ReadIniValue("LastVersionUsedBeta", 0.0)
strLatestSkippedAlpha := o_Settings.ReadIniValue("LatestVersionSkippedAlpha", 0.0)
strLatestUsedAlpha := o_Settings.ReadIniValue("LastVersionUsedAlpha", 0.0)

blnSetup := (FileExist(A_ScriptDir . "\_do_not_remove_or_rename.txt") = "" ? 0 : 1)

; FileGetTime, strShell32Date, %A_WinDir%\System32\shell32.dll
; FileGetTime, strImageresDate, %A_WinDir%\System32\imageres.dll

strQuery := strUrlCheck4Update
	. "?v=" . g_strCurrentVersion
	. "&os=" . GetOSVersion()
	. "&is64=" . A_Is64bitOS
	. "&setup=" . (blnSetup)
				; + 0 ; was (2 * (g_blnSponsor ? 1 : 0))
				; + (4 * (o_FileManagers.P_intActiveFileManager = 2 ? 1 : 0)) ; DirectoryOpus
				; + (8 * (o_FileManagers.P_intActiveFileManager = 3 ? 1 : 0)) ; TotalCommander
				; + (16 * (o_FileManagers.P_intActiveFileManager = 4 ? 1 : 0)) ; QAPconnect
	. "&lsys=" . A_Language
	. "&lfp=" . o_Settings.Launch.strLanguageCode.IniValue
	. "&nbi=" . g_intRulesItemsCount ; !!
strLatestVersions := Url2Var(strQuery)
if !StrLen(strLatestVersions)
	if (A_ThisLabel = "Check4UpdateNow")
	{
		Oops(0, o_L["UpdateError"])
		gosub, Check4UpdateCleanup
		return ; an error occured during ComObjCreate
	}

strLatestVersions := SubStr(strLatestVersions, InStr(strLatestVersions, "[[") + 2) 
strLatestVersions := SubStr(strLatestVersions, 1, InStr(strLatestVersions, "]]") - 1) 
strLatestVersions := Trim(strLatestVersions, "`n`l") ; remove en-of-line if present
Loop, Parse, strLatestVersions, , 0123456789.| ; strLatestVersions should only contain digits, dots and one pipe (|) between prod and beta versions
	; if we get here, the content returned by the URL above is wrong
	if (A_ThisMenuItem <> aaHelpL["MenuUpdate"])
	{
		gosub, Check4UpdateCleanup
		return ; return silently
	}
	else
	{
		Oops(0, o_L["UpdateError"]) ; return with an error message
		gosub, Check4UpdateCleanup
		return
	}

objLatestVersions := StrSplit(strLatestVersions, "|")
strLatestVersionProd := objLatestVersions[1]
strLatestVersionBeta := objLatestVersions[2]
strLatestVersionAlpha := objLatestVersions[3]

; DEGUG VALUES
; g_strCurrentVersion := "10.4.9.3"
; strLatestVersionAlpha := "9.3.1"
; strLatestUsedAlpha := "1.1"
; strLatestSkippedAlpha := "9.3.2"
; strLatestVersionBeta := "10.4.9.3"
; strLatestUsedBeta := "1.1"
; strLatestSkippedBeta := "9.3.1"
; strLatestVersionProd := "9.2"
; strLatestSkippedProd := "9.4"
; DEGUG VALUES
; ###_V(A_ThisLabel, "*g_strCurrentVersion", g_strCurrentVersion, "*", ""
	; , "*strLatestVersionAlpha", strLatestVersionAlpha, "*strLatestUsedAlpha", strLatestUsedAlpha, "*strLatestSkippedAlpha", strLatestSkippedAlpha
	; , "*Propose ALPHA?", ((strLatestUsedAlpha <> "0.0" and ProposeUpdate(strLatestVersionAlpha, g_strCurrentVersion, strLatestSkippedAlpha)) ? "OUI" : ""), "*", ""
	; , "*strLatestVersionBeta", strLatestVersionBeta, "*strLatestUsedBeta", strLatestUsedBeta, "*strLatestSkippedBeta", strLatestSkippedBeta
	; , "*Propose BETA?", ((strLatestUsedBeta <> "0.0" and ProposeUpdate(strLatestVersionBeta, g_strCurrentVersion, strLatestSkippedBeta)) ? "OUI" : ""), "*", ""
	; , "*strLatestVersionProd", strLatestVersionProd, "*strLatestSkippedProd", strLatestSkippedProd
	; , "*Propose PROD?", (ProposeUpdate(strLatestVersionProd, g_strCurrentVersion, strLatestSkippedProd) ? "OUI" : "")
	; , "*", "")
; KEEP DEBUGGING CODE

if (strLatestUsedAlpha <> "0.0" and ProposeUpdate(strLatestVersionAlpha, g_strCurrentVersion, strLatestSkippedAlpha))
{
	g_strUpdateProdOrBeta := "alpha"
	g_strUpdateLatestVersion := strLatestVersionAlpha
	Gosub, GuiCheck4Update
}
else if (strLatestUsedBeta <> "0.0" and ProposeUpdate(strLatestVersionBeta, g_strCurrentVersion, strLatestSkippedBeta))
{
	g_strUpdateProdOrBeta := "beta"
	g_strUpdateLatestVersion := strLatestVersionBeta
	Gosub, GuiCheck4Update
}
else if ProposeUpdate(strLatestVersionProd, g_strCurrentVersion, strLatestSkippedProd)
{
	g_strUpdateProdOrBeta := "prod"
	g_strUpdateLatestVersion := strLatestVersionProd
	Gosub, GuiCheck4Update
}
else if (A_ThisLabel = "Check4UpdateNow")
{
	MsgBox, 4, % l(o_L["UpdateTitle"], g_strAppNameText), % l(o_L["UpdateYouHaveLatest"], g_strAppVersion, g_strAppNameText)
	IfMsgBox, Yes
		Run, %g_strUrlAppLandingPage%
}
; else do nothing

Check4UpdateCleanup:
strLatestSkippedAlpha := ""
strLatestSkippedBeta := ""
strLatestSkippedProd := ""
strLatestUsedAlpha := ""
strLatestUsedBeta := ""
strQuery := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
ProposeUpdate(strVersionNew, strVersionRunning, strVersionSkipped)
	; si (version_nouveau_beta > version_installe_beta) / il y a une nouvelle version
		; et (version_nouveau_beta <= version_sautee_beta / et elle n'a pas été sautée
;------------------------------------------------------------
{
	; ###_V(A_ThisFunc, strVersionNew, strVersionRunning, strVersionSkipped
		; , FirstVsSecondIs(strVersionNew, strVersionRunning), FirstVsSecondIs(strVersionNew, strVersionSkipped)
		; , (FirstVsSecondIs(strVersionNew, strVersionRunning) = 1 and FirstVsSecondIs(strVersionNew, strVersionSkipped) > 0))
	; FirstVsSecondIs() returns -1 if first smaller, 0 if equal, 1 if first greater
	; return (strVersionNew > strVersionRunning) and (strVersionNew >= strVersionSkipped)
	return (ComparableVersionNumber(strVersionNew) > ComparableVersionNumber(strVersionRunning)
		and ComparableVersionNumber(strVersionNew) >= ComparableVersionNumber(strVersionSkipped))
}
;------------------------------------------------------------


;------------------------------------------------------------
ToggleRunAtStartup(blnForce := -1)
; blnForce: -1 toggle, 0 disable, 1 enable
;------------------------------------------------------------
{
	if (blnForce = o_L["MenuRunAtStartup"]) ; toggle from Tray menu
		; function assigneds to Tray menu puts the menu name in first parameter (https://hotkeyit.github.io/v2/docs/commands/Menu.htm#Add_or_Change_Items_in_a_Menu)
		; when called from Tray menu, art blnForce to toggle
		blnForce := -1
	
	if (g_blnPortableMode)
		blnValueBefore := StrLen(FileExist(A_Startup . "\" . g_strAppNameFile . ".lnk")) ; convert file attribute to numeric (boolean) value
	else
		blnValueBefore := RegistryExist("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText)

	blnValueAfter := (blnForce = -1 ? !blnValueBefore : blnForce)

	Menu, Tray, % (blnValueAfter ? "Check" : "Uncheck"), % o_L["MenuRunAtStartup"]
	
	if (g_blnPortableMode)
	{
		; Startup code adapted from Avi Aryan Ryan in Clipjump
		if FileExist(A_Startup . "\" . g_strAppNameFile . ".lnk")
			FileDelete, %A_Startup%\%g_strAppNameFile%.lnk
		if (blnValueAfter)
			Gosub, CreateStartupShortcut
	}
	else ; setup mode

		if (blnValueAfter)
			SetRegistry("QuickAccessClipboard.exe", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText)
		else
			RemoveRegistry("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText)
}
;------------------------------------------------------------


;------------------------------------------------------------
CreateStartupShortcut:
;------------------------------------------------------------

FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%g_strAppNameFile%.lnk, %A_WorkingDir%
	, % o_CommandLineParameters.strParams ; since version 8.7.1 now includes the changed /Settings: parameter if user switched settings file

return
;------------------------------------------------------------


;------------------------------------------------------------
ToggleSuspendHotkeys:
;------------------------------------------------------------

Suspend, % (A_IsSuspended ? "Off" : "On")

Menu, menuBarTools, % (A_IsSuspended ? "Check" : "Uncheck"), % aaMenuToolsL["MenuSuspendHotkeys"]
Menu, Tray, % (A_IsSuspended ? "Check" : "Uncheck"), % o_L["MenuSuspendHotkeys"]

return
;------------------------------------------------------------



;========================================================================================================================
; END OF VARIOUS COMMANDS
;========================================================================================================================


;========================================================================================================================
!_095_VARIOUS_FUNCTIONS:
return
;========================================================================================================================

;------------------------------------------------
Oops(varOwner, strMessage, objVariables*)
; varOwner can be a number or a string
;------------------------------------------------
{
	if (!varOwner)
		varOwner := 1
	Gui, %varOwner%:+OwnDialogs
	MsgBox, 48, % L(o_L["OopsTitle"], g_strAppNameText, g_strAppVersion), % L(strMessage, objVariables*)
}
;------------------------------------------------


;------------------------------------------------
L(strMessage, objVariables*)
;------------------------------------------------
{
	Loop
	{
		if InStr(strMessage, "~" . A_Index . "~")
			strMessage := StrReplace(strMessage, "~" . A_Index . "~", objVariables[A_Index])
 		else
			break
	}
	
	return strMessage
}
;------------------------------------------------


;------------------------------------------------------------
SetCursor(blnOnOff, strCursorName := "")
; from Gio in https://autohotkey.com/boards/viewtopic.php?f=5&t=13284
; cursors list: https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setsystemcursor
; wait 32514 / hand 32649 / appstarting 32650 / whatsthis 32651
;------------------------------------------------------------
{
	static s_blnCursorWaitAlreadyOn
	static s_oWaitCursor
	
	if (blnOnOff)
		if (s_blnCursorWaitAlreadyOn)
			return
		else
		{
			if StrLen(strCursorName)
				if (strCursorName = "wait") ; OCR_WAIT
					strCursorCode := 32514
				else if (strCursorName = "hand") ; OCR_HAND
					strCursorCode := 32649
				else if (strCursorName = "appstarting") ; OCR_APPSTARTING
					strCursorCode := 32650
				else if (strCursorName = "whatsthis") ; OCR_HELP
					strCursorCode := 32651
				else
					return
			
			; The line of code below loads a cursor from the system set
			s_oWaitCursor :=  DllCall("LoadImage", "Uint", 0, "Uint", strCursorCode, "Uint", 2, "Uint", 0, "Uint", 0, "Uint", 0x8000)

			; And then we set all the default system cursors to be our choosen cursor. CopyImage is necessary as SetSystemCursor destroys the cursor we pass to it after using it.
			strCursors := "32650,32512,32515,32649,32651,32513,32648,32646,32643,32645,32642,32644,32516,32514"
			Loop, Parse, strCursors, `,
				DllCall("SetSystemCursor", "Uint", DllCall("CopyImage", "Uint", s_oWaitCursor, "Uint", 2, "Int", 0, "Int", 0, "Uint", 0), "Uint", A_LoopField)
			
			s_blnCursorWaitAlreadyOn := true
		}
	else
	{
		; And finally, when the action is over, we call the code below to revert the default set of cursors back to its original state.
		; SystemParametersInfo() (with option 0x0057) changes the set of system cursors to the system defaults. 
		; We are loading a system cursor, so there is no need to destroy it. Also the copies we are creating with CopyImage() are destroyed by SetSystemCursor() itself.
		DllCall("SystemParametersInfo", "Uint", 0x0057, "Uint", 0, "Uint", 0, "Uint", 0)
		Sleep, 50
		
		s_oWaitCursor := ""
		s_blnCursorWaitAlreadyOn := false
	}
}
;------------------------------------------------------------


;------------------------------------------------------------
FileExistInPath(ByRef strFile)
;------------------------------------------------------------
{
	strFile := EnvVars(strFile) ; expand environment variables like %APPDATA% or %USERPROFILE%, and user variables like {DropBox}
	
	if (!StrLen(strFile) or InStr(strFile, "://") or SubStr(strFile, 1, 1) = "{") ; this is not a file - caution some URLs in WhereIs cause an infinite loop
		return false
	
	if !InStr(strFile, "\") ; if no path in filename
		strFile := WhereIs(strFile) ; search if file exists in path env variable or registry app paths
	else
		strFile := PathCombine(A_WorkingDir, strFile) ; make relative path absolute
	
	if (SubStr(strFile, 1, 2) = "\\") ; this is an UNC path (option network drives always online enabled)
	; avoid FileExist on the root of a UNC path "\\something" or "\\something\"
	; check if it is the UNC root - if yes, return true without confirming if path exist because FileExist limitation with UNC root path
	{
		intPos := InStr(strFile, "\", false, 3) ; if there is no "\" after the initial "\\" (after the domain or IP address), this is the UNC root
		if !(intPos) ; there is no "\" after the domain or IP address, this is an UNC root (example: "\\something")
			or (SubStr(strFile, intPos) = "\") ; the 3rd \ the last char, this is also an UNC root (example: "\\something\")
			return true
	}
	
	return FileExist(strFile) ; returns the file's attributes if file exists or empty (false) is not
}
;------------------------------------------------------------


;------------------------------------------------------------
WhereIs(strThisFile)
; based on work from Skan in https://autohotkey.com/board/topic/20807-fileexist-in-path-environment/
;------------------------------------------------------------
{
	if !StrLen(GetFileExtension(strThisFile)) ; if file has no extension
	{
		; re-enter WhereIs with each extension until one returns an existing file
		Loop, Parse, g_strExeExtensions, `; ; for example ".COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC;.AHK"
		{
			strFoundFile := WhereIs(strThisFile . A_LoopField) ; recurse into WhereIs with a complete filename
		} until StrLen(strFoundFile)
		
		return %strFoundFile% ; exit if we find an existing file, or return empty if not
	}
	; from here, we have a filename with an extension
	
	; prepare locations list
	SplitPath, A_AhkPath, , strAhkDir
	EnvGet, strDosPath, Path
	strPaths := A_WorkingDir . ";" . A_ScriptDir . ";" . strAhkDir . ";" . strAhkDir . "\Lib;" . A_MyDocuments . "\AutoHotkey\Lib" . ";" . strDosPath
	
	; search in each location
	Loop, Parse, strPaths, `;
		If StrLen(A_LoopField)
			If FileExist(A_LoopField . "\" . strThisFile)
				Return, RegExReplace(A_LoopField . "\" . strThisFile, "\\\\", "\") ; RegExReplace to prevent results like C:\\Directory
	
	; if not found, check in registry paths for this filename
	RegRead, strAppPath, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%strThisFile%
	If FileExist(strAppPath)
		Return, strAppPath
	
	; else return empty
}
;------------------------------------------------------------


;------------------------------------------------------------
PathCombine(strAbsolutePath, strRelativePath)
; see http://www.autohotkey.com/board/topic/17922-func-relativepath-absolutepath/page-3#entry117355
; and http://stackoverflow.com/questions/29783202/combine-absolute-path-with-a-relative-path-with-ahk/
;------------------------------------------------------------
{
    VarSetCapacity(strCombined, (A_IsUnicode ? 2 : 1) * 260, 1) ; MAX_PATH
    DllCall("Shlwapi.dll\PathCombine", "UInt", &strCombined, "UInt", &strAbsolutePath, "UInt", &strRelativePath)
    Return, strCombined
}
;------------------------------------------------------------


;------------------------------------------------------------
EnvVars(str)
; from Lexikos http://www.autohotkey.com/board/topic/40115-func-envvars-replace-environment-variables-in-text/#entry310601
; adapted from Lexikos http://www.autohotkey.com/board/topic/40115-func-envvars-replace-environment-variables-in-text/#entry310601
;------------------------------------------------------------
{
    if sz:=DllCall("ExpandEnvironmentStrings", "uint", &str, "uint", 0, "uint", 0)
    {
        VarSetCapacity(dst, A_IsUnicode ? sz*2:sz)
        if DllCall("ExpandEnvironmentStrings", "uint", &str, "str", dst, "uint", sz)
            return dst
    }
	
    return str
}
;------------------------------------------------------------


;------------------------------------------------------------
RandomBetween(intMin := 0, intMax := 2147483647)
;------------------------------------------------------------
{
	Random, intValue, %intMin%, %intMax%
	
	return intValue
}
;------------------------------------------------------------


;------------------------------------------------------------
CalculateTopGuiPosition(g_strTopHwnd, g_strRefHwnd, ByRef intTopGuiX, ByRef intTopGuiY)
;------------------------------------------------------------
{
	WinGetPos, intRefGuiX, intRefGuiY, intRefGuiW, intRefGuiH, ahk_id %g_strRefHwnd%
	intRefGuiCenterX := intRefGuiX + (intRefGuiW // 2)
	intRefGuiCenterY := intRefGuiY + (intRefGuiH // 2)

	WinGetPos, , , intTopGuiW, intTopGuiH, ahk_id %g_strTopHwnd%
	intTopGuiX := intRefGuiCenterX - (intTopGuiW // 2) + 5 ; + 5 correction from trial/error
	intTopGuiY := intRefGuiCenterY - (intTopGuiH // 2)
	
	WinGetPos, intWindowX, intWindowY, intWindowWidth, intWindowHeight, ahk_id %g_strRefHwnd%
	WinGetTitle, v, ahk_id %g_strRefHwnd%
	SysGet, arrCurrentMonitor, Monitor, % GetActiveMonitorForPosition(intWindowX, intWindowY, intNbMonitors)

	; ###_V(A_ThisFunc, v, g_strRefHwnd, intWindowX, intWindowY, GetActiveMonitorForPosition(intWindowX, intWindowY, intNbMonitors))
	intTopGuiX := (intTopGuiX < arrCurrentMonitorLeft ? arrCurrentMonitorLeft : intTopGuiX)
	intTopGuiY := (intTopGuiY < arrCurrentMonitorTop ? arrCurrentMonitorTop : intTopGuiY)
}
;------------------------------------------------------------


;------------------------------------------------------------
GetSavedSettingsWindowPosition(ByRef saSettingsPosition)
; use LastScreenConfiguration and window position from ini file
; if screen configuration changed, return -1 instead of the saved position
;------------------------------------------------------------
{
	g_strLastScreenConfiguration := o_Settings.ReadIniValue("LastScreenConfiguration", " ") ; to reset position if screen config changed since last session
	
	strCurrentScreenConfiguration := GetScreenConfiguration()
	if !StrLen(g_strLastScreenConfiguration) or (strCurrentScreenConfiguration <> g_strLastScreenConfiguration)
	{
		IniWrite, %strCurrentScreenConfiguration%, % o_Settings.strIniFile, Global, LastScreenConfiguration ; always save in case QAP is not closed properly
		arrSettingsPosition1 := -1 ; returned value by first ByRef parameter
	}
	else
		if (o_Settings.SettingsWindow.blnRememberSettingsPosition.IniValue)
		{
			strSettingsPosition := o_Settings.ReadIniValue("SettingsPosition", -1) ; by default -1 to center at minimal size
			saSettingsPosition := StrSplit(strSettingsPosition, "|")
		}
		else ; delete Settings position
		{
			IniDelete, % o_Settings.strIniFile, Global, SettingsPosition
			arrSettingsPosition1 := -1 ; returned value by first ByRef parameter
		}
	
	g_strLastConfiguration := strCurrentScreenConfiguration
}
;------------------------------------------------------------


;------------------------------------------------------------
GetScreenConfiguration()
; return the current monitor configuration in the following format:
; n,p:left,top,right,bottom|left,top,right,bottom|...
; nb of monitors, primary display, and coordinates of each monitor
;------------------------------------------------------------
{
	SysGet, intNbMonitors, MonitorCount
	SysGet, intIdPrimaryDisplay, MonitorPrimary

	strMonitorConfiguration := intNbMonitors . "," . intIdPrimaryDisplay . ":"
	Loop %intNbMonitors%
	{
		SysGet, arrMonitor, Monitor, %A_Index%
		Loop, Parse, % "Left|Top|Right|Bottom", |
			strMonitorConfiguration .= arrMonitor%A_LoopField% . (A_Index < 4 ? "," : "")
		strMonitorConfiguration .= (A_Index < intNbMonitors ? "|" : "")
	}
	
	return strMonitorConfiguration
}
;------------------------------------------------------------


;------------------------------------------------------------
SaveWindowPosition(strThisWindow, strWindowHandle)
; format: x|y|w|h
;------------------------------------------------------------
{
	if (strThisWindow <> "SettingsPosition" or o_Settings.SettingsWindow.blnRememberSettingsPosition.IniValue)
	; always for Add, Edit, Copy or Move Favorites dialog boxes, only if remember for Settings
	{
		WinGet, intMinMax, MinMax, %strWindowHandle%
		if (intMinMax = 1) ; if window is maximized, restore normal state to get position
			WinRestore, %strWindowHandle%
		
		WinGetPos, intX, intY, intW, intH, %strWindowHandle%
		strPosition := intX . "|" . intY . "|" . intW . "|" . intH . (intMinMax = 1 ? "|M" : "")
		IniWrite, %strPosition%, % o_Settings.strIniFile, Global, %strThisWindow%
	}
	else ; delete Settings position
		IniDelete, % o_Settings.strIniFile, Global, %strThisWindow%
}
;------------------------------------------------------------


;------------------------------------------------------------
GetWindowPositionOnActiveMonitor(strWindowId, intActivePositionX, intActivePositionY, ByRef intWindowX, ByRef intWindowY)
; returns true if more than one monitor and success retrieving new X-Y position on active monitor else returns false
; returns ByRef new or unmodified X and Y
;------------------------------------------------------------
{
	WinGetPos, intWindowX, intWindowY, intWindowWidth, intWindowHeight, %strWindowId%
	
	intActiveMonitorForWindow := GetActiveMonitorForPosition(intWindowX, intWindowY, intNbMonitors)
	intActiveMonitorForPosition := GetActiveMonitorForPosition(intActivePositionX, intActivePositionY, intNbMonitors)
	; ###_V(A_ThisFunc, "*intActiveMonitorForWindow", intActiveMonitorForWindow, "*intActiveMonitorForPosition", intActiveMonitorForPosition)
	
	if (intNbMonitors > 1) and intActiveMonitorForWindow and (intActiveMonitorForWindow <> intActiveMonitorForPosition)
	{
		; calculate Explorer window position relative to center of screen
		SysGet, arrThisMonitor, Monitor, %intActiveMonitorForPosition% ; Left, Top, Right, Bottom
		intWindowX := arrThisMonitorLeft + (((arrThisMonitorRight - arrThisMonitorLeft) - intWindowWidth) / 2)
		intWindowY := arrThisMonitorTop + (((arrThisMonitorBottom - arrThisMonitorTop) - intWindowHeight) / 2)
		
		; ###_V(A_ThisFunc . " True", strWindowId, intActivePositionX, intActivePositionY, intNbMonitors, intActiveMonitorForWindow, intActiveMonitorForPosition, "", intActivePositionX, intActivePositionY, "ByRef", intWindowX, intWindowY)
		return true
	}

	; ###_V(A_ThisFunc . " False", strWindowId, intActivePositionX, intActivePositionY, intNbMonitors, intActiveMonitorForWindow, intActiveMonitorForPosition, "", intActivePositionX, intActivePositionY, "ByRef", intWindowX, intWindowY)
	return false
}
;------------------------------------------------------------


;------------------------------------------------------------
GetActiveMonitorForPosition(intX, intY, ByRef intNbMonitors)
;------------------------------------------------------------
{
	SysGet, intNbMonitors, MonitorCount
	Loop, % intNbMonitors
	{
		SysGet, arrThisMonitor, Monitor, %A_Index% ; Left, Top, Right, Bottom
		; ###_V(A_ThisFunc . " monitor " . A_Index, arrThisMonitorLeft, intX, arrThisMonitorRight, "", arrThisMonitorTop, intY, arrThisMonitorBottom, ""
			; , (intX >= arrThisMonitorLeft and intX < arrThisMonitorRight
				; and intY >= arrThisMonitorTop and intY < arrThisMonitorBottom))

		if  (intX >= arrThisMonitorLeft and intX < arrThisMonitorRight
			and intY >= arrThisMonitorTop and intY < arrThisMonitorBottom)
			
			return A_Index
	}
}
;------------------------------------------------------------


;------------------------------------------------------------
GetPositionFromMouseOrKeyboard(strMenuTriggerLabel, strThisHotkey, ByRef intPositionX, ByRef intPositionY)
; get current mouse position (if favorite was open with mouse) or active window position (if favorite was open with keyboard)
;------------------------------------------------------------
{
	if !StrLen(strMenuTriggerLabel) ; when strMenuTriggerLabel is empty, if strThisHotkey contains "Button" or "Wheel", check mouse position
		strPositionReference := (InStr(strThisHotkey, "Button") or InStr(strThisHotkey, "Wheel") ? "Mouse" : "Window")
	else if InStr(strMenuTriggerLabel, "Keyboard")
		strPositionReference := "Window" ; check active window position
	else
		strPositionReference := "Mouse" ; all other menu triggers, check mouse position
	
	if (strPositionReference = "Mouse")
	{
		CoordMode, Mouse, Screen
		MouseGetPos, intPositionX, intPositionY
	}
	else
		WinGetPos, intPositionX, intPositionY, , , A ; window top-left position
	
	; ###_V(A_ThisFunc, strMenuTriggerLabel, strThisHotkey, "ByRef", intPositionX, intPositionY)
}
;------------------------------------------------------------


;------------------------------------------------------------
BuildMonitorsList(intDefault)
;------------------------------------------------------------
{
	if !(intDefault)
		intDefault := 1
	SysGet, intNbMonitors, MonitorCount
	Loop, %intNbMonitors%
		str .= o_L["DialogWindowMonitor"] . " " . A_Index . "|" . (A_Index = intDefault ? "|" : "")
	
	return str
}
;------------------------------------------------------------


;------------------------------------------------------------
GetFileExtension(strFile)
;------------------------------------------------------------
{
	SplitPath, strFile, , , strExtension
	return strExtension
}
;------------------------------------------------------------


;------------------------------------------------------------
ComparableVersionNumber(strVersionNumber)
; Make version number strings comparable by < and > operators.
; Returns a padded string of 5 sub-numbers of 3 digits each, NOT separated.
; Example: "1.22.333" returns "001022333000000"
;------------------------------------------------------------
{
	; RegExReplace(..., "[^.]") removes all but dots
	; StrLen() counts number of dots in version number
	; the loop add ".0" until we have 4 dots and five sub-numbers (eg "0.0.0.0.0")
	loop, % 4 - StrLen(RegExReplace(strVersionNumber, "[^.]"))
		strVersionNumber .= ".0"

	; make sure every version sub-number has an equal number of 3 digits, removing dots
	loop, parse, strVersionNumber, .
	{
		strSubNumber := A_LoopField
		while StrLen(strSubNumber) < 3
			strSubNumber := "0" . strSubNumber
		strResult .= strSubNumber
	}
	
	return strResult
}
;------------------------------------------------------------


;---------------------------------------------------------
RegistryExist(strKeyName, strValueName)
;---------------------------------------------------------
{
	RegRead, strValue, %strKeyName%, %strValueName%
	
	return StrLen(strValue)
}
;---------------------------------------------------------


;---------------------------------------------------------
GetRegistry(strKeyName, strValueName)
;---------------------------------------------------------
{
	RegRead, strValue, %strKeyName%, %strValueName%
	
	return strValue
}
;---------------------------------------------------------


;---------------------------------------------------------
SetRegistry(strValue, strKeyName, strValueName)
;---------------------------------------------------------
{
	RegWrite, REG_SZ, %strKeyName%, %strValueName%, %strValue%
	if (ErrorLevel)
		Oops(0, "An error occurred while writing the registry key.`n`nValue: " . strValueName . "`nKey name: " . strKeyName)
}
;---------------------------------------------------------


;---------------------------------------------------------
RemoveRegistry(strKeyName, strValueName)
;---------------------------------------------------------
{
	if !RegistryExist(strKeyName, strValueName)
		return
	
	RegDelete, %strKeyName%, %strValueName%
	if (ErrorLevel)
		Oops(0, "An error occurreed while removing the registre key.`n`nValue: " . strValueName . "`nKey name: " . strKeyName)	
}
;---------------------------------------------------------


;------------------------------------------------------------
HasShortcut(strCandidateShortcut)
; checking the shortcut internal code
;------------------------------------------------------------
{
	return StrLen(strCandidateShortcut) and (strCandidateShortcut <> "None")
}
;------------------------------------------------------------


;------------------------------------------------------------
HasShortcutText(strCandidateShortcutText)
; checking the shortcut localized text
;------------------------------------------------------------
{
	return StrLen(strCandidateShortcutText) and (strCandidateShortcutText <> o_L["DialogNone"])
}
;------------------------------------------------------------


;------------------------------------------------------------
StrUpper(str)
;------------------------------------------------------------
{
	StringUpper, strUpper, str
	return strUpper
}
;------------------------------------------------------------


;------------------------------------------------------------
GetOSVersion()
;------------------------------------------------------------
{
	if (GetOSVersionInfo().MajorVersion = 10)
		return "WIN_10"
	else
		return A_OSVersion
}
;------------------------------------------------------------


;------------------------------------------------------------
GetOSVersionInfo()
; by shajul (http://www.autohotkey.com/board/topic/54639-getosversion/?p=414249)
; reference: http://msdn.microsoft.com/en-ca/library/windows/desktop/ms724833(v=vs.85).aspx
;------------------------------------------------------------
{
	static s_oVer

	If !s_oVer
	{
		VarSetCapacity(OSVer, 284, 0)
		NumPut(284, OSVer, 0, "UInt")
		If !DllCall("GetVersionExW", "Ptr", &OSVer)
		   return 0 ; GetSysErrorText(A_LastError)
		s_oVer := Object()
		s_oVer.MajorVersion      := NumGet(OSVer, 4, "UInt")
		s_oVer.MinorVersion      := NumGet(OSVer, 8, "UInt")
		s_oVer.BuildNumber       := NumGet(OSVer, 12, "UInt")
		s_oVer.PlatformId        := NumGet(OSVer, 16, "UInt")
		s_oVer.ServicePackString := StrGet(&OSVer+20, 128, "UTF-16")
		s_oVer.ServicePackMajor  := NumGet(OSVer, 276, "UShort")
		s_oVer.ServicePackMinor  := NumGet(OSVer, 278, "UShort")
		s_oVer.SuiteMask         := NumGet(OSVer, 280, "UShort")
		s_oVer.ProductType       := NumGet(OSVer, 282, "UChar") ; 1 = VER_NT_WORKSTATION, 2 = VER_NT_DOMAIN_CONTROLLER, 3 = VER_NT_SERVER
		s_oVer.EasyVersion       := s_oVer.MajorVersion . "." . s_oVer.MinorVersion . "." . s_oVer.BuildNumber
	}
	return s_oVer
}
;------------------------------------------------------------


;------------------------------------------------------------
GuiCenterButtons(strWindowHandle, intInsideHorizontalMargin := 10, intInsideVerticalMargin := 0, intDistanceBetweenButtons := 20, arrControls*)
; This is a variadic function. See: http://ahkscript.org/docs/Functions.htm#Variadic
;------------------------------------------------------------
{
	; A_DetectHiddenWindows must be on (app's default); Gui, Show acts on current default gui (1: or 2: , etc)
	Gui, Show, Hide ; hides the window and activates the one beneath it, allows a hidden window to be moved, resized, or given a new title without showing it
	WinGetPos, , , intWidth, , ahk_id %strWindowHandle%

	; find largest control height and width
	intMaxControlWidth := 0
	intMaxControlHeight := 0
	intNbControls := 0
	for intIndex, strControl in arrControls
		if StrLen(strControl) ; avoid emtpy control names
		{
			intNbControls++ ; use instead of arrControls.MaxIndex() in case we get empty control names
			GuiControlGet, arrControlPos, Pos, %strControl%
			if (arrControlPosW > intMaxControlWidth)
				intMaxControlWidth := arrControlPosW
			if (arrControlPosH > intMaxControlHeight)
				intMaxControlHeight := arrControlPosH
		}
	
	intMaxControlWidth := intMaxControlWidth + intInsideHorizontalMargin
	intButtonsWidth := (intNbControls * intMaxControlWidth) + ((intNbControls  - 1) * intDistanceBetweenButtons)
	intLeftMargin := (intWidth - intButtonsWidth) // 2

	for intIndex, strControl in arrControls
		if StrLen(strControl) ; avoid emtpy control names
			GuiControl, Move, %strControl%
				, % "x" . intLeftMargin + ((intIndex - 1) * intMaxControlWidth) + ((intIndex - 1) * intDistanceBetweenButtons)
				. " w" . intMaxControlWidth
				. " h" . intMaxControlHeight + intInsideVerticalMargin
}
;------------------------------------------------------------


;------------------------------------------------------------
AddUtm2Url(strUrl, strMedium, strCampaign)
; example: https://www.quickaccesspopup.com/?utm_source=QAP&utm_medium=Medium&utm_campaign=Campaign
;------------------------------------------------------------
{
	strUrl .= (InStr(strUrl, "?") ? "&" : "?") ; add parameter separator or question mark if first parameter 
	strUrl .= "utm_source=QAP&utm_medium=" . strMedium . "&utm_campaign=" . strCampaign
	return strUrl
}
;------------------------------------------------------------


;------------------------------------------------------------
EditorUnsaved()
;------------------------------------------------------------
{
	global

	GuiControlGet, blnCancelEnabled, 1:Enabled, f_btnGuiCancelEditor 

	return blnCancelEnabled
}
;------------------------------------------------------------


;------------------------------------------------------------
QACSettingsString()
;------------------------------------------------------------
{
	return L(o_L["GuiTitle"], g_strAppNameText, g_strAppVersion)
}
;------------------------------------------------------------



;========================================================================================================================
; END OF VARIOUS_FUNCTIONS
;========================================================================================================================


;========================================================================================================================
!_700_CLASSES:
return
;========================================================================================================================

;-------------------------------------------------------------
class CommandLineParameters
;-------------------------------------------------------------
/*
class CommandLineParameters
	Methods
	- CommandLineParameters.__New(): collect the command line parameters in an internal object and concat strParams
	  - each param must begin with "/" and be separated by a space
	  - supported parameters: "/Settings:[file_path]" (must end with ".ini"), "/AdminSilent" and "/Working:[working_dir_path]"
	- CommandLineParameters.ConcatParams(I): returns a concatenated string of each parameter ready to be used when reloading
	- CommandLineParameters.SetParam(strKey, strValue): set the param strkey to the value strValue
	Instance variables
	- AA: simple array for each item (parameter) from the A_Args object (for internal usage)
	- strParams: list of command line parameters collected when launching this instance, separated by space, with quotes if required
*/
;-------------------------------------------------------------
{
	; Instance variables
	AA := Object() ; associative array
	strParams := ""
	
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
		for intArg, strOneArg in A_Args ; A_Args requires v1.1.27+
		{
			if !StrLen(strOneArg)
				continue
			
			intColon := InStr(strOneArg, ":")
			if (intColon)
			{
				strParamKey := SubStr(strOneArg, 2, intColon - 2) ; excluding the starting slash and ending colon
				strParamValue := SubStr(strOneArg, intColon + 1)
				if (strParamKey = "Settings" and GetFileExtension(strParamValue) <> "ini")
					continue
				this.AA[strParamKey] := strParamValue
			}
			else
			{
				strParamKey := SubStr(strOneArg, 2)
				if (strParamKey = "Settings")
					continue
				this.AA[strParamKey] := "" ; keep it empty, check param with this.AA.HasKey(strOneArg)
			}
		}
		
		this.strParams := this.ConcatParams()
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	ConcatParams()
	;---------------------------------------------------------
	{
		strConcat := ""
		
		for strParamKey, strParamValue in this.AA
		{
			strQuotes := (InStr(strParamKey . strParamValue, " ") ? """" : "") ; enclose param with double-quotes only if it includes space
			strConcat .= strQuotes . "/" . strParamKey
			strConcat .= (StrLen(strParamValue) ? ":" . strParamValue : "") ; if value, separate with :
			strConcat .= strQuotes . " " ; ending quote and separate with next params with space
		}
		
		return SubStr(strConcat, 1, -1) ; remove last space
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	SetParam(strKey, strValue)
	;---------------------------------------------------------
	{
		this.AA[strKey] := strValue
		this.strParams := this.ConcatParams()
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------


;-------------------------------------------------------------
class JLicons
;-------------------------------------------------------------
/*
class JLicons
	Methods
	- JLicons.__New(strJLiconsFile): add array oIcons "name"->"file,index" to class JLicons for each JLicon.dll and to simple array saNames index of names
	- JLicons.GetName(intKey): return name of JLicons element of index intKey (was g_objJLiconsNames[intKey] before class)
	- JLicons.AddIcon(strKey, strFileIndex): add icon resource strFileIndex for JLicons element strKey (used to add DOpus and Total Commander icons)
	- JLicons.ProcessReplacements(strReplacements): removes previous JLicons replacements in oReplacements and do the current replacements in strReplacements
	Instance variables
	- strFileLocation: path and file name of the JLicons library file
	- AA: items of JLicons
	- saNames: simple array index of icon names (iconXYZ)
	- aaReplacementPrevious: associative array "strKey->strValue" (iconXYZ->file,index) backup for original "file,index" value for replaced icons
*/
;-------------------------------------------------------------
{
	; Instance variables
	strFileLocation := ""
	AA := Object() ; associative array
	saNames := Object() ; was g_objJLiconsNames before class
	aaReplacementPrevious := Object() ; associative array, original values of replaced icons
	
	;---------------------------------------------------------
	__New(strJLiconsFile)
	;---------------------------------------------------------
	{
		this.strFileLocation := strJLiconsFile ; was g_strJLiconsFile
		
		strNames := "iconQAP|iconAbout|iconAddThisFolder|iconApplication|iconCDROM"
			. "|iconChangeFolder|iconClipboard|iconClose|iconControlPanel|iconCurrentFolders"
			. "|iconDesktop|iconDocuments|iconDonate|iconDownloads|iconDrives"
			. "|iconEditFavorite|iconExit|iconFavorites|iconFolder|iconFonts"
			. "|iconFTP|iconGroup|iconHelp|iconHistory|iconHotkeys"
			. "|iconAddFavorite|iconMyComputer|iconMyMusic|iconMyVideo|iconNetwork"
			. "|iconNetworkNeighborhood|iconNoContent|iconOptions|iconPictures|iconRAMDisk"
			. "|iconRecentFolders|iconRecycleBin|iconReload|iconRemovable|iconSettings"
			. "|iconSpecialFolders|iconSubmenu|iconSwitch|iconTemplates|iconTemporary"
			. "|iconTextDocument|iconUnknown|iconWinver|iconFolderLive|iconIcons"
			. "|iconPaste|iconPasteSpecial|iconNoIcon|iconUAClogo|iconQAPadmin"
			. "|iconQAPadminBeta|iconQAPadminDev|iconQAPbeta|iconQAPdev|iconQAPloading"
			. "|iconFolderLiveOpened|iconSortAlphaAsc|iconSortAlphaDesc|iconSortNumAsc|iconSortNumDesc"
			. "|iconQAC|iconQACadmin|iconQACadminBeta|iconQACadminDev|iconQACbeta"
			. "|iconQACdev"

		; EXAMPLE
		; JLicons.AA["iconAbout"] -> "file,2"
		; JLicons.saNames[2] -> "iconAbout"
		this.saNames := StrSplit(strNames, "|")
		Loop, Parse, strNames, |
			this.AddIcon(A_LoopField, strJLiconsFile . "," . A_Index)
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	CheckVersion()
	;---------------------------------------------------------
	{
		FileGetVersion, strVersion, % this.strFileLocation
		; if FirstVsSecondIs(strVersion, g_strJLiconsVersion) < 0 ; JLicons.dll file loaded is outdated (0 or > 0 are OK)
		if ComparableVersionNumber(strVersion) < ComparableVersionNumber(g_strJLiconsVersion) ; JLicons.dll file loaded is outdated
		{
			Oops(0, o_L["OopsJLiconsOutdated"], this.strFileLocation, g_strJLiconsVersion, g_strAppNameText)
			ExitApp
		}
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	AddIcon(strKey, strFileIndex) ; to add DOpus and Total Commander icons
	;---------------------------------------------------------
	{
		this.AA[strKey] := strFileIndex
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	GetName(intKey) ; was g_objJLiconsNames[intKey] before class
	;---------------------------------------------------------
	{
		return this.saNames[intKey]
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ProcessReplacements(strReplacements)
	;---------------------------------------------------------
	{
		; restore previously replaced icons
		for strKey, strFileIndex in this.aaReplacementPrevious
			this.AA[strKey] := strFileIndex
		
		this.aaReplacementPrevious := Object() ; reset replacements
		
		loop, parse, strReplacements, |
			if StrLen(A_LoopField)
			{
				saIconReplacement := StrSplit(A_LoopField, "=")
				if This.AA.HasKey(saIconReplacement[2]) ; support replacement with another JLicons item
					saIconReplacement[2] := This.AA[saIconReplacement[2]]
				if this.AA.HasKey(saIconReplacement[1]) and InStr(saIconReplacement[2], ",")
				; this icon exists and replacement is "file,index" (includes a coma)
				{
					this.aaReplacementPrevious[saIconReplacement[1]] := this.AA[saIconReplacement[1]]
					this.AA[saIconReplacement[1]] := saIconReplacement[2]
				}
			}
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------


;-------------------------------------------------------------
class Settings
/*
TODO
*/
;-------------------------------------------------------------
{
	aaGroupItems := Object()
	saOptionsGroups := Object()
	saOptionsGroupsLabelNames := Object()
	
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
		this.strIniFile := A_WorkingDir . "\" . g_strAppNameFile . ".ini" ; value changed when reading external ini files

; /* #### UNCOMMENT TO TEST WITH NORMAL SETTINGS FILE NAME
		; Set developement ini file
;@Ahk2Exe-IgnoreBegin
		; Start of code for developement environment only - won't be compiled
		if (A_ComputerName = "JEAN-PC") ; for my home PC
			this.strIniFile := A_WorkingDir . "\" . g_strAppNameFile . "-HOME.ini"
		else if InStr(A_ComputerName, "ELITEBOOK-JEAN") ; for my work hotkeys
			this.strIniFile := A_WorkingDir . "\" . g_strAppNameFile . "-WORK.ini"
		; / End of code for developement environment only - won't be compiled
;@Ahk2Exe-IgnoreEnd
; */ ; #### UNCOMMENT TO TEST WITH NORMAL SETTINGS FILE NAME

		; set file name used for Edit settings label
		SplitPath, % this.strIniFile, strIniFileNameExtOnly
		this.strIniFileNameExtOnly := strIniFileNameExtOnly
		this.strIniFileDefault := this.strIniFile
		
		this.saOptionsGroups := ["General", "SettingsWindow", "AdvancedOther"]
			
		; at first launch quickaccesspopup.ini does not exist, read language value in quickaccesspopup-setup.ini (if exist) created by Setup
		this.ReadIniOption("Launch", "strLanguageCode", "LanguageCode", "EN", "General", "", "Global"
			, (FileExist(this.strIniFile) ? this.strIniFile : A_WorkingDir . "\" . g_strAppNameFile . "-setup.ini"))
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	InitOptionsGroupsLabelNames()
	; called after o_L is initialized
	;---------------------------------------------------------
	{
		this.saOptionsGroupsLabelNames := ["OptionsGeneral", "OptionsSettingsWindow", "OptionsAdvancedOther"]
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ReadIniOption(strOptionGroup, strSettingName, strIniValueName, strDefault := "", strGuiGroup := "", strGuiControls := "", strSection := "Global", strIniFile := "")
	;---------------------------------------------------------
	{
		if !IsObject(this[strOptionGroup])
			this[strOptionGroup] := Object()
		if !IsObject(this.aaGroupItems[strGuiGroup])
			this.aaGroupItems[strGuiGroup] := Object()
		
		if StrLen(strIniValueName) ; for exception f_blnOptionsRunAtStartup having no ini value, but a control in Options gui
			strOutValue := this.ReadIniValue(strIniValueName, strDefault, strSection, strIniFile)
		
		oIniValue := new this.IniValue(strIniValueName, strOutValue, strGuiGroup, strGuiControls, strSection, strIniFile)
		
		this[strOptionGroup][strSettingName] := oIniValue
		this.aaGroupItems[strGuiGroup].Push(oIniValue)
		
		return oIniValue.IniValue
		; ###_O("this", this)
		; ###_O("this[strOptionGroup][strSettingName]", this[strOptionGroup][strSettingName])
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ReadIniValue(strIniValueName, strDefault := "", strSection := "Global", strIniFile := "")
	;---------------------------------------------------------
	{
		IniRead, strOutValue, % (StrLen(strIniFile) ? strIniFile : this.strIniFile), %strSection%, %strIniValueName%, %strDefault%
		; ###_V(A_ThisFunc, strIniValueName, "|" . strDefault . "|", strSection, strIniFile, this.strIniFile, strOutValue)
		return strOutValue
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	BackupIniFile(strIniFile, blnReplaceSpecialFolderLocationBackup := false)
	; call as base class function Settings.BackupIniFile() only, not as an instance method
	; (because various ini files are not instances of this class - could be done later)
	; do not update global variable g_blnReplaceSpecialFolderLocationBackup here because its value must be reset only after last call to this function
	;---------------------------------------------------------
	{
		SplitPath, strIniFile, strIniFileFilename, strIniFileFolder
		
		strThisBackupFolder := o_Settings.ReadIniValue("BackupFolder", " ", "Global", strIniFile) ; can be main ini file, alternative ini or external ini file backup folder
		if !StrLen(strThisBackupFolder) ; if no backup folder in ini file, backup in ini file's folder
			strThisBackupFolder := strIniFileFolder
		
		strThisBackupFolder := PathCombine(A_WorkingDir, EnvVars(strThisBackupFolder))
		
		if (blnReplaceSpecialFolderLocationBackup) ; different name and do not delete old files
			strIniBackupFile := strThisBackupFolder . "\" . StrReplace(strIniFileFilename, ".ini", "-backup-special_folders-??????????????.ini")
		else
		{
			; delete old backup files (keep only 5/10 most recent files)
			strIniBackupFile := strThisBackupFolder . "\" . StrReplace(strIniFileFilename, ".ini", "-backup-????????.ini")
			Loop, %strIniBackupFile%
				strFilesList .= A_LoopFileFullPath . "`n"
			Sort, strFilesList, R ; reverse alphabetical order - most recent first 
			intNumberOfBackups := (g_strCurrentBranch <> "prod" ? 10 : 5)
			Loop, Parse, strFilesList, `n
				if (A_Index > intNumberOfBackups)
					if StrLen(A_LoopField)
						FileDelete, %A_LoopField%
		}
		; create a daily backup of the ini file
		strIniBackupFile := StrReplace(strIniBackupFile, "????????" . (blnReplaceSpecialFolderLocationBackup ? "??????" : "")
			, SubStr(A_Now, 1, (blnReplaceSpecialFolderLocationBackup ? 14 : 8)))
		
		; always keep the most recent backup for a given day
		FileCopy, %strIniFile%, %strIniBackupFile%, 1
		
		; if this is a shared menu, delete the lock flag from the backup (it does nothing in a regular settings file)
		IniDelete, %strIniBackupFile%, Global, MenuReservedBy
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	class IniValue
	;---------------------------------------------------------
	{
		;-----------------------------------------------------
		__New(strIniValueName, strIniValue, strGuiGroup, strGuiControls, strSection, strIniFile)
		;-----------------------------------------------------
		{
			this.IniValue := strIniValue
			this.strGuiGroup := strGuiGroup
			this.strGuiControls := strGuiControls
			this.strIniFile := strIniFile
			this.strIniValueName := strIniValueName
			this.strSection := strSection
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		WriteIni(varNewValue := "", blnDoNotSave := false)
		; update the IniValue if a value is provided and write it to ini file (Global section of the main ini file only)
		;-----------------------------------------------------
		{
			if !(blnDoNotSave)
				this.IniValue := varNewValue
			IniWrite, % this.IniValue, % (StrLen(this.strIniFile) ? this.strIniFile : o_Settings.strIniFile)
				, % (StrLen(this.strSection) ? this.strSection : "Global"), % this.strIniValueName
		}
		;-----------------------------------------------------
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------

;-------------------------------------------------------------
class Triggers
/*
TODO
*/

/*
class Triggers

class Triggers.PopupHotkeys
	Methods
	- Triggers.PopupHotkeys.__New(): add an array of 2 QAC window triggers objects of class PopupHotkey to I object array and enable these hotkeys
	- Triggers.PopupHotkeys.EnablePopupHotkeys(): enable popup window hotkeys
	- BackupPopupHotkeys(): backup hotkeys (used when opening Options)
	- RestorePopupHotkeys(): restore backuped hotkeys (used when cancelling Options changes)
	Instance variables
	- SA: array of 2 PopupHotkey object items
	- aaPopupHotkeysByNames: associative array "name->object" as index of objects by PopupHotkey names
	
	class Triggers.PopupHotkeys.PopupHotkey
		Methods
		- Triggers.PopupHotkeys.PopupHotkey.__New(): create one PopupHotkey QAC window trigger object
		- Triggers.PopupHotkeys.PopupHotkey.EnableHotkey(): disable previous popup window hotkey and enable the new hotkey
		Properties
		- Triggers.PopupHotkeys.PopupHotkey.P_strAhkHotkey: set a new _PopupHotkey value and update dependent text values strPopupHotkeyText and strPopupHotkeyTextShort
		Instance variables
		- strPopupHotkey: mouse (like "^MButton" for Ctrl + MButton) or keyboard (like "^#V" for Ctrl + Win + V) hotkey trigger for a the QAC window
		- strPopupHotkeyInternalName: one of the mouse or keyboard triggers internal names
		- strPopupHotkeyText: text of default hotkey trigger
		- strPopupHotkeyTextShort: short text of hotkey trigger
		- strPopupHotkeyDefault: default hotkey trigger
		- strPopupHotkeyPrevious: backup of hotkey trigger
		- strPopupHotkeyLocalizedName: displayed name of QAC window trigger
		- strPopupHotkeyLocalizedDescription: description of QAC window trigger

class Triggers.HotkeyParts
	Methods
	- HotkeyParts.__New(strHotkey): create an object and split parts in properties modifier, keyboard or mouse button
	- HotkeyParts.SplitParts(strHotkey): split strHotkey into parts strModifiers, strKey and strMouseButton
	- HotkeyParts.Hotkey2Text(blnShort := false): returns localized text for HotkeyParts, in long or short format
	Instance variables
	- strModifiers: modifier part of the hotkey (like "!" for Alt+Q or Alt+MButton)
	- strKey: keyboard part of hotkey (like "Q" for Alt+Q), empty if hotkey is a mouse button
	- strMouseButton: mouse button part of hotkey (like "MButton" for Alt+MButton), empty if hotkey is a keyboard key

class Triggers.MouseButtons
	Methods
	- Triggers.MouseButtons.__New(): add an array of objects of class Button to I object array
	- Triggers.MouseButtons.GetMouseButtonInternal4LocalizedName(strLocalizedName): returns corresponding internal name for localized name (not the short name)
	- Triggers.MouseButtons.GetMouseButtonLocalized4InternalName(strInternalName, blnShort): returns corresponding localized name for internal name
	- Triggers.MouseButtons.IsMouseButton(strInternalName): returns true if strInternalName is member of the buttons array
	- Triggers.MouseButtons.GetDropDownList(strDefault): returns the mouse buttons dropdown list with button strDefault as default button
	Instance variables
	- SA: array of MouseButton object items
	- oMouseButtonInternalNames: associative array "name->object" index of mouse buttons name
	- oMouseButtonLocalizedNames: associative array "localized name->object" index of mouse buttons localized name
	- strMouseButtonsDropDownList: mouse buttons dropdown
	
	class Triggers.MouseButtons.MouseButton
		Methods
		- MouseButtons.MouseButton.__New(): create an object for one mouse button
		Instance variables
		- strInternalName: internal name of button (like "MButton")
		- strLocalizedName: localized name of button (like "Middle Mouse Button")
		- strLocalizedNameShort: short localized name of button (like "Middle Mouse")
*/
;-------------------------------------------------------------
{
	;---------------------------------------------------------
	class PopupHotkeys
	;---------------------------------------------------------
	{
		; Instance variables
		aaPopupHotkeysByNames := Object() ; associative array
		
		;-----------------------------------------------------
		__New()
		;-----------------------------------------------------
		{
			SA := Object() ; simple array
			saPopupHotkeyInternalNames := Object() ; simple array
			
			saPopupHotkeyInternalNames := ["OpenHotkeyMouse", "OpenHotkeyKeyboard"]
			saPopupHotkeyDefaults := StrSplit("^MButton|^#V", "|")
			saOptionsPopupHotkeyLocalizedNames := StrSplit(o_L["OptionsPopupHotkeyTitles"], "|")
			saOptionsPopupHotkeyLocalizedDescriptions := StrSplit(o_L["OptionsPopupHotkeyTitlesSub"], "|")
			
			for intThisIndex, strThisPopupHotkeyInternalName in saPopupHotkeyInternalNames
			{
				; Init Settings class items for Triggers (must be before o_PopupHotkeys)
				strThisPopupHotkey := o_Settings.ReadIniOption("MenuPopup", "str" . strThisPopupHotkeyInternalName, strThisPopupHotkeyInternalName, saPopupHotkeyDefaults[A_Index], "PopupHotkeys"
					, "f_lblChangeShortcut" . A_Index . "|f_lblHotkeyText" . A_Index . "|f_btnChangeShortcut" . A_Index . "|f_lnkChangeShortcut" . A_Index)
				oPopupHotkey := new this.PopupHotkey(strThisPopupHotkeyInternalName, strThisPopupHotkey, saPopupHotkeyDefaults[A_Index]
					, saOptionsPopupHotkeyLocalizedNames[A_Index], saOptionsPopupHotkeyLocalizedDescriptions[A_Index])
				this.SA[A_Index] := oPopupHotkey
				this.aaPopupHotkeysByNames[strThisPopupHotkeyInternalName] := oPopupHotkey
			}
			this.EnablePopupHotkeys()
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		EnablePopupHotkeys()
		;-----------------------------------------------------
		{
			; Two hotkey variants for A_ThisHotkey: if CanNavigate or if CanLaunch, else A_ThisHotkey does nothing
			; "If more than one variant of a hotkey is eligible to fire, only the one created earliest will fire."
			; Hotkey, If, CanNavigate(A_ThisHotkey)
			Hotkey, If, CanPopup(A_ThisHotkey)
				; (1 OpenHotkeyMouse and 2 OpenHotkeyKeyboard) 
				this.SA[1].EnableHotkey("Open", "Mouse")
				this.SA[2].EnableHotkey("Open", "Keyboard")
			Hotkey, If
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		BackupPopupHotkeys()
		;-----------------------------------------------------
		{
			for intKey, oOnePopupHotkey in this.SA
				oOnePopupHotkey.AA.strPopupHotkeyPrevious := oOnePopupHotkey.P_strAhkHotkey
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		RestorePopupHotkeys()
		;-----------------------------------------------------
		{
			for intKey, oOnePopupHotkey in this.SA
				oOnePopupHotkey.P_strAhkHotkey := oOnePopupHotkey.AA.strPopupHotkeyPrevious
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		class PopupHotkey
		;-----------------------------------------------------
		{
			; Instance variables
			AA := Object()
			
			;-------------------------------------------------
			__New(strThisInternalName, strThisPopupHotkey, strThisPopupHotkeyDefault, strThisLocalizedName, strThisLocalizedDescription)
			;-------------------------------------------------
			{
				this.AA.strPopupHotkeyInternalName := strThisInternalName
				this.P_strAhkHotkey := strThisPopupHotkey
				
				this.AA.strPopupHotkeyDefault := strThisPopupHotkeyDefault
				this.AA.strPopupHotkeyPrevious := ""
				this.AA.strPopupHotkeyLocalizedName := strThisLocalizedName
				this.AA.strPopupHotkeyLocalizedDescription := strThisLocalizedDescription
			}
			;-------------------------------------------------
			
			;-------------------------------------------------
			P_strAhkHotkey[]
			;-------------------------------------------------
			{
				Get
				{
					return this._strAhkHotkey ; Lexikos: "One common convention is to use a single underscore for internal members, as in _propertyname. But it's just a convention."
				}
				
				Set
				{
					oHotkeyParts := new Triggers.HotkeyParts(value)
					this.AA.strPopupHotkeyText := oHotkeyParts.Hotkey2Text()
					this.AA.strPopupHotkeyTextShort := oHotkeyParts.Hotkey2Text(true)
					
					return this._strAhkHotkey := value
				}
			}
			;-------------------------------------------------
			
			;-------------------------------------------------
			EnableHotkey(strActionType, strTriggerType)
			;-------------------------------------------------
			{
				strLabel := strActionType . "Hotkey" . strTriggerType
				if HasShortcut(this.AA.strPopupHotkeyPrevious)
					Hotkey, % this.AA.strPopupHotkeyPrevious, , Off UseErrorLevel ; do nothing if error (probably because default mouse trigger not supported by system)
				if HasShortcut(this.P_strAhkHotkey)
					Hotkey, % this.P_strAhkHotkey, %strLabel%, On UseErrorLevel
				if (ErrorLevel)
					Oops(0, o_L["DialogInvalidHotkey"], this.AA.strPopupHotkeyText, this.AA.strPopupHotkeyLocalizedName)
			}
			;-------------------------------------------------
		}
		;-----------------------------------------------------
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	class HotkeyParts
	;---------------------------------------------------------
	{
		; Instance variables
		strModifiers := ""
		strKey := ""
		strMouseButton := ""
		
		;-----------------------------------------------------
		__New(strHotkey)
		;-----------------------------------------------------
		{
			this.SplitParts(strHotkey)
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		SplitParts(strHotkey)
		;-----------------------------------------------------
		{
			if (strHotkey = "None") ; do not compare with o_L["DialogNone"] because it is translated
			{
				this.strModifiers := ""
				this.strKey := ""
				this.strMouseButton := "None" ; do not use o_L["DialogNone"] because it is translated
			}
			else 
			{
				intPosFirstNotModifier := 0
				loop, Parse, strHotkey
					if InStr("^!+#<>", A_LoopField)
						intPosFirstNotModifier++
					else
						break ; got first character not a modifier
				str := SubStr(strHotkey, 1, intPosFirstNotModifier)
				this.strModifiers := str
				str := SubStr(strHotkey, intPosFirstNotModifier + 1)
				this.strKey := str
				
				if o_MouseButtons.IsMouseButton(this.strKey) ; we have a mouse button
				{
					this.strMouseButton := this.strKey
					this.strKey := ""
				}
				else ; we have a key
					this.strMouseButton := ""
			}
		}
		;-----------------------------------------------------
		
		;-----------------------------------------------------
		Hotkey2Text(blnShort := false)
		;-----------------------------------------------------
		{
			if StrLen(this.strKey) ; localize system key names
			{
				strSystemKeyNames := "sc15D|AppsKey|Space|Enter|Escape"
				saLocalizedKeyNames := StrSplit(o_L["DialogMenuKey"] . "|" . o_L["DialogMenuKey"] . "|" . o_L["DialogSpace"]
					. "|" . o_L["DialogEnter"] . "|" . o_L["DialogEscape"], "|")
				Loop, Parse, strSystemKeyNames, |
					if (this.strKey = A_LoopField)
						this.strKey := saLocalizedKeyNames[A_Index]
			}
			
			if (this.strMouseButton = "None") ; do not compare with o_L["DialogNone"] because it is translated
				or !StrLen(this.strModifiers . this.strMouseButton . this.strKey) ; if all parameters are empty
				str := o_L["DialogNone"] ; use o_L["DialogNone"] because this is displayed
			else
			{
				str := ""
				loop, parse, % this.strModifiers
				{
					if (A_LoopField = "!")
						str := str . (InStr(this.strModifiers, "<!") ? "<" : InStr(this.strModifiers, ">!") ? ">" : "") . (blnShort ? o_L["DialogAltShort"] : o_L["DialogAlt"]) . "+"
					if (A_LoopField = "^")
						str := str . (InStr(this.strModifiers, "<^") ? "<" : InStr(this.strModifiers, ">^") ? ">" : "") . (blnShort ? o_L["DialogCtrlShort"] : o_L["DialogCtrl"]) . "+"
					if (A_LoopField = "+")
						str := str . (InStr(this.strModifiers, "<+") ? "<" : InStr(this.strModifiers, ">+") ? ">" : "") . (blnShort ? o_L["DialogShiftShort"] : o_L["DialogShift"]) . "+"
					if (A_LoopField = "#")
						str := str . (InStr(this.strModifiers, "<#") ? "<" : InStr(this.strModifiers, ">#") ? ">" : "") . (blnShort ? o_L["DialogWinShort"] : o_L["DialogWin"]) . "+"
				}
				if StrLen(this.strMouseButton)
					str := str . o_MouseButtons.GetMouseButtonLocalized4InternalName(this.strMouseButton, blnShort)
					
				if StrLen(this.strKey)
					str := str . StrUpper(this.strKey)
			}
			
			return str
		}
		;-----------------------------------------------------
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	class MouseButtons
	;---------------------------------------------------------
	{
		; Instance variables
		SA := Object()
		aaMouseButtonInternalNames := Object() ; associative array "name->index"
		aaMouseButtonLocalizedNames := Object() ; associative array of "localized name->index"
		strMouseButtonsDropDownList := ""
		
		;-----------------------------------------------------
		__New()
		;-----------------------------------------------------
		{
			saMouseButtonsInternalNames := StrSplit("None|LButton|MButton|RButton|XButton1|XButton2|WheelUp|WheelDown|WheelLeft|WheelRight", "|")
			this.strMouseButtonsDropDownList := o_L["DialogNone"] . "|" . o_L["DialogMouseButtonsText"] ; default item not identified
			saMouseButtonsLocalizedNames := StrSplit(this.strMouseButtonsDropDownList, "|")
			saMouseButtonsLocalizedNamesShort := StrSplit(o_L["DialogNone"] . "|" . o_L["DialogMouseButtonsTextShort"], "|")

			loop, % saMouseButtonsInternalNames.Length()
			{
				this.aaMouseButtonInternalNames[saMouseButtonsInternalNames[A_Index]] := A_Index
				this.aaMouseButtonLocalizedNames[saMouseButtonsLocalizedNames[A_Index]] := A_Index
				oMouseButton := new this.MouseButton(saMouseButtonsInternalNames[A_Index], saMouseButtonsLocalizedNames[A_Index], saMouseButtonsLocalizedNamesShort[A_Index])
				this.SA[A_Index] := oMouseButton
			}
		}
		;-----------------------------------------------------

		;-----------------------------------------------------
		GetMouseButtonInternal4LocalizedName(strLocalizedName)
		; strLocalizedName must be the normal name, not the short name
		;-----------------------------------------------------
		{
			return this.SA[this.aaMouseButtonLocalizedNames[strLocalizedName]].strInternalName
		}
		;-----------------------------------------------------

		;-----------------------------------------------------
		GetMouseButtonLocalized4InternalName(strInternalName, blnShort)
		; keep blnShort required to avoid error - do not use short version in mouse buttons dropdown list
		;-----------------------------------------------------
		{
			return (blnShort ? this.SA[this.aaMouseButtonInternalNames[strInternalName]].strLocalizedNameShort
				: this.SA[this.aaMouseButtonInternalNames[strInternalName]].strLocalizedName)
		}
		;-----------------------------------------------------

		;-----------------------------------------------------
		IsMouseButton(strInternalName)
		;-----------------------------------------------------
		{
			return this.aaMouseButtonInternalNames.HasKey(strInternalName)
		}
		;-----------------------------------------------------

		;-----------------------------------------------------
		GetDropDownList(strDefault) ; strDefault can be internal or localized (if "None")
		;-----------------------------------------------------
		{
			if (strDefault = o_L["DialogNone"]) ; here strDefault contains the localized text
				return StrReplace(this.strMouseButtonsDropDownList, o_L["DialogNone"] . "|", o_L["DialogNone"] . "||") ; use o_L["DialogNone"] because this is localized
			else if StrLen(strDefault) ; here strDefault contains the mouse internal name (not localized text)
				return StrReplace(this.strMouseButtonsDropDownList, this.GetMouseButtonLocalized4InternalName(strDefault, false) . "|", this.GetMouseButtonLocalized4InternalName(strDefault, false) . "||")
			else
				return this.strMouseButtonsDropDownList
		}
		;-----------------------------------------------------

		;-----------------------------------------------------
		class MouseButton
		;-----------------------------------------------------
		{
			; Instance variables
			strInternalName := ""
			strLocalizedName := ""
			strLocalizedNameShort := ""
			
			;-------------------------------------------------
			__New(strThisInternalName, strThisLocalizedName, strThisLocalizedNameShort)
			;-------------------------------------------------
			{
				this.strInternalName := strThisInternalName
				this.strLocalizedName := strThisLocalizedName
				this.strLocalizedNameShort := strThisLocalizedNameShort
			}
			;-------------------------------------------------
		}
		;-----------------------------------------------------
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------

;-------------------------------------------------------------
class Utc2LocalTime
;-------------------------------------------------------------
{
	static intMinutesUtcOffset ; calculated at launch to store Local time vs UTC difference in minutes
	
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
		intMinutes := A_Now

		EnvSub, intMinutes, A_NowUTC, Minutes
		this.intMinutesUtcOffset := intMinutes
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	ConvertToLocal(strUtcTime)
	; Each method has a hidden parameter named this, which typically contains a reference to an object derived from the class.
	; Inside a method, the pseudo-keyword base can be used to access the super-class versions of methods or properties which are overridden in a derived class.
	;---------------------------------------------------------
	{
		EnvAdd, strUtcTime, % this.intMinutesUtcOffset, Minutes
		return strUtcTime
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------

;-------------------------------------------------------------
class Language
;-------------------------------------------------------------
{
	;---------------------------------------------------------
	__New()
	;---------------------------------------------------------
	{
		#Include %A_ScriptDir%\QuickAccessClipboard_LANG.ahk
		
		this.LanguageCode := o_Settings.Launch.strLanguageCode.IniValue
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	LanguageCode[]
	;---------------------------------------------------------
	{
		Set
		{
			; check if we have a testing language file
			strDebugLanguageFile := A_WorkingDir . "\" . g_strAppNameFile . "_LANG_ZZ.txt"
			if FileExist(strDebugLanguageFile)
			{
				strLanguageFile := strDebugLanguageFile
				this._LanguageCode := "EN"
			}
			else
			{
				strLanguageFile := (value = "EN" ? "" : g_strTempDir . "\" . g_strAppNameFile . "_LANG_" . value . ".txt")
				
				; if localized language file does not exists, keep "EN" language code and existing EN values
				this._LanguageCode := (FileExist(strLanguageFile) ? value : "EN")
			}
			
			if StrLen(strLanguageFile) and FileExist(strLanguageFile) ; we have an existing localized language file
			{
				strReplacementForSemicolon := g_strEscapeReplacement ; for non-comment semi-colons ";" escaped as ";;"
				
				FileRead, strLanguageStrings, %strLanguageFile%
				
				Loop, Parse, strLanguageStrings, `n, `r
				{
					if (SubStr(A_LoopField, 1, 1) <> ";") ; skip comment lines
					{
						saLanguageBit := StrSplit(A_LoopField, "`t")
						; ###_O("saLanguageBit-1", saLanguageBit)
						if SubStr(saLanguageBit[1], 1, 1) <> "l"
							continue
						else
							saLanguageBit[1] := SubStr(saLanguageBit[1], 2) ; remove leading "l" from language files variable names
						this[saLanguageBit[1]] := saLanguageBit[2]
						this[saLanguageBit[1]] := StrReplace(this[saLanguageBit[1]], "``n", "`n")
						
						if InStr(this[saLanguageBit[1]], ";;") ; preserve escaped ; in string
							this[saLanguageBit[1]] := StrReplace(this[saLanguageBit[1]], ";;", strReplacementForSemicolon)
						; ###_V("1", saLanguageBit[1], saLanguageBit[2], this[saLanguageBit[1]])
						if InStr(this[saLanguageBit[1]], ";")
							this[saLanguageBit[1]] := Trim(SubStr(this[saLanguageBit[1]], 1, InStr(this[saLanguageBit[1]], ";") - 1)) ; trim comment from ; and trim spaces and tabs
						; ###_V("2", saLanguageBit[1], saLanguageBit[2], this[saLanguageBit[1]])
						if InStr(this[saLanguageBit[1]], strReplacementForSemicolon) ; restore escaped ; in string
							this[saLanguageBit[1]] := StrReplace(this[saLanguageBit[1]], strReplacementForSemicolon, ";")
						; ###_V("3", saLanguageBit[1], saLanguageBit[2], this[saLanguageBit[1]])
						; ###_O("this", this)
					}
				}
			}
		; save strCode to ini
		; if changed need to restart?
		}
		
		Get
		{
			return this._LanguageCode
		}
	}
	;---------------------------------------------------------
	
}
;-------------------------------------------------------------

