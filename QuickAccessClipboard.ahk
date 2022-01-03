;===============================================
/*

Quick Access Clipboard
Written using AutoHotkey v1.1.33.09+ (http://autohotkey.com)
By Jean Lalonde (JnLlnd on AHKScript.org forum)

Copyright 2021-2021 Jean Lalonde
--------------------------------

OBJECT MODEL
============

RULE TYPES
----------
Types: ChangeCase, ConvertFormat, Replace, AutoHotkey, SubStr, Prefix, Suffix
Values: .strTypeCode, .strTypeLabel, .strTypeHelp, .intID
Collections: g_aaRuleTypes (by strTypeCode), g_saRuleTypesOrder (by intID)

RULE
----
All types: .strName, .strTypeCode, .strTypeLabel, .strTypeHelp, .strCategory, .strNotes, .saVarValues (variable values, starting à 1), .intID
ConvertFormat: .intConvertFormat (1: 1-Text)
ChangeCase: .intCaseType (1), .strFind (always ".*"), .strReplace ("$L0|$U0|$T0")
Replace: .strFind (1), .strReplace (2), blnReplaceWholeWord (3), blnReplaceCaseSensitive (4)
AutoHotkey: .strCode (1)
SubStr: .intSubStrFromType (1: 1-FromStart, 2-FromPosition, 3-FromBeginText, 4-FromEndText), .intSubStrFromPosition (2), .strSubStrFromText (3), .intSubStrFromPlusMinus (4)
	, .intSubStrToType (5: 1-ToEnd, 2-ToLength, 3-ToBeforeEnd, 4-ToBeginText, 5-ToEndText), .intSubStrToLength (6, positive or negative), .strSubStrToText (7), .intSubStrToPlusMinus (8), .blnSubStrRepeat (9)
Prefix: .strPrefix (1), .blnSubStrRepeat(2)
Suffix: .strSuffix (1), .blnSubStrRepeat(2)
Collections: g_aaRulesByName (by strName), g_saRulesOrder (by intID)


HISTORY
=======

Version ALPHA: 0.0.6 (2021-12-29)
 
Editor
- add confirmation prompt before deleting a rule
- add column Notes to available rules listview
- add tooltip messages when hovering buttons
- make tab stop shorter in editor and in edit AutoHotkey rule
- edit rule when shift + double click a rule in Available rules
- do not close Editor when pressing Shift while clicking the Cancel button
 
Menu bar
- add "Rule" and "Help" menus to menu bar
- add "About QAC" under "Help menu"
- new menu item under "File" menu to open QAC ini file and QAC working directory
- only in alpha or beta releases, new menu item under "File" menu to open QACrules.ahk 
 
Rules
- add Substring subtypes FromBeginText, FromEndText, ToBeginText and ToEndText with a +/- offset
- option to execute a rule on each line of the Clipboard or editor's content for Substring and Prefix/Suffix rules
- replace LF with eol replacement chars when saving AutoHotkey code value to ini file, replace LF when editing AutoHotkey code and when building rule code
 
Various
- after saving a rule, reload rules, rebuild rules menu, update Available rules listview and relaunch QACrules
- enable check for update

Version ALPHA: 0.0.5.1 (2021-12-19)
- add rules demo in new ini file
- in rules menu, display disabled item "No rule" if no rule
- fix bug delete form values when closing the edit rule gui
- change URLs for check4update

Version ALPHA: 0.0.5 (2021-12-19)
 
Editor
- add a submenu to context menu with all rules that can be applied on demand to current Clipboard
- if text selected in editor, execute rule on demand only on selected text
- restore cursor caret or selected text after rule execution
- ad Shift-F10 hotkey to intercept context menu in editor control
 
QACrules
- in QACrules.ahk, listen to message from QAC main app to receive command exec with rule ID to execute rules on demand
- always launch QACrules even when no rule are applied
- include all rules in QACrules.ahk
- in QACrules, disable Clipboard change when executing rule on demand and enable it after execution
- removed SetTimer in QACrules preventing call to exec rule on demand (cause not found)
- when uncomplied, create QACrules.ahk in the working dir
 
Various
- reject equal sign = in rule names
- fix bug setting editor's font

Version ALPHA: 0.0.4 (2021-12-17)
- reafactor edit dialog box for substring type using radio buttons
- validate required values in edit dialog box
- add checkbox to inivisible characters only when Clipboard is unchanged in the editor
- disable the editor when the See invisible characters option is enabled
- disable the See invisible characters checkbox when content of editor is changed
- increase sleep time after rule execution

Version ALPHA: 0.0.3.1 (2021-12-14)
- fix bug in rules file name

Version ALPHA: 0.0.3 (2021-12-14)
 
Status bar
- display Clipboard connection status only if disconnected
- show if content length is from Clipboard or Editor
- show content lenght if text, else show if binary or empty
 
Object model
- develop RuleTypes class
- develop Rule class with properties name (index key), category, notes, ID (index key) and values; methods GetCode(), CopyRule()
 
Gui
- enable rules using 2 listviews instead of checkboxes, with arrows to select/deselect/deselect all rules
- align Appy rules button to Selected rules listview
- make available rules larger with columns for type and category
- when showing gui or applying rules, backup selected rules to restore them if rules changes are not applied
- sort available rules by name unless user change sorting using the header
- double click to select a rule
- buttons to add, edit, copy or remove rules
- dialog box to select type of added rule
- dialog box to add/edit/copy rule
- allow editor font up to size 36
- remove Cancel button and merge it with Close button
 
Settings file
- save options to ini file on exit
- encode pipes in values saved to ini file
- load whole Rules section from ini file and parse lines
- save addes/edited/copied rule
- remove rule
- reload rules after saving edited or added rule
- encode values when saving to ini and decode when loading 
keep ending | separator when saving to ini file to protect values ending with space
 
Rules execution
- in QACrules.ahk only include selected rules
- get code for rule types prefix and suffix;

Version ALPHA: 0.0.2 (2021-11-26)
 
Buttons
- redefine main window buttons to
  - "Save Clipboard": save editor content to Clipboard and reconnect the Clipboard
  - "Cancel": revert editor to current Clipboard content and reconnect the Clipboard
  - "Close": close the window if the editor content was not changed, or display "Discard changes?" prompt and act as "Cancel" if answer is Yes, else just close the window
- enable and disable "Save Clipboard" and "Cancel" buttons and "File" menu items following changes in editor control
- keep "Close" button always enabled
 
Menu bar
- change "File" menu items action:
  - "Save Clipboard" to same action as the "Save Clipboard" button
  - "Cancel": same action as "Cancel" button
  - new menu item "Close": same action as "Close" button
- move and resize buttons and controls
 
Options checkboxes
- add "Always on top" checkbox to editor window with value "AlwaysOnTop" in ini file
- add "Use tab" checkbox to allow tabs in editor with value "UseTab" in ini file;
 
Status bar
- display on main window status bar:
  - editor's content length (with temporary debugging info)
  - Clipboard "connection" status (with temporary debugging info)
 
Editor's context menu
- replace editor control context menu to manage Clipboard connection
  - enable or disable context menu items based on selected text, Clipboard content or editor changed status
  - intercept Ctrl+C and Ctr+V in editor to disable Clipboard connection when using these keys in the editor
 
Various
- take a backup of rules checkboxes when showing the main window; if the window is closed without applying changed rules, restore backup values and alert user with a tooltip
- change JLicons required version number to v1.6.3

Version ALPHA: 0.0.1 (2021-11-14)
- repository creation
- main window with Clipboard editor and rules, with buttons "Save", "Save and Close" and "Close/Cancel" buttons
- menu bar with "File, Save Clipboard", "File, Cancel" and "File, Exit Quick Access Editor" menu items
- checkboxes for rules LowerCase, UpperCase, FirstUpperCase, TitleCase and Underscore2Space
- rules executed in temporary script QACrules.ahk called by QACrules.exe (AutoHotkey runtime) and removed when exiting the application

*/ 
;========================================================================================================================
!_010_COMPILER_DIRECTIVES:
;========================================================================================================================

; Doc: http://fincs.ahk4.net/Ahk2ExeDirectives.htm
; Note: prefix comma with `

;@Ahk2Exe-SetVersion 0.0.6.1
;@Ahk2Exe-SetName Quick Access Clipboard
;@Ahk2Exe-SetDescription Quick Access Clipboard (Windows Clipboard editor)
;@Ahk2Exe-SetOrigFilename QuickAccessClipboard.exe
;@Ahk2Exe-SetCopyright (c) Jean Lalonde since 2021
;@Ahk2Exe-SetCompanyName Jean Lalonde

;========================================================================================================================
; END !_010_COMPILER_DIRECTIVES
;========================================================================================================================


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
#Include %A_ScriptDir%\..\QuickAccessPopup\Class_LV_Rows.ahk ; https://github.com/Pulover/Class_LV_Rows from Rodolfo U. Batista / Pulover (as of 2020-11-22)

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

global g_strCurrentVersion := "0.0.6.1" ; "major.minor.bugs" or "major.minor.beta.release", currently support up to 5 levels (1.2.3.4.5)
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

o_Settings.ReadIniOption("Launch", "strQACTempFolderParent", "QACTempFolder", "%TEMP%", "General"
	, "f_strQACTempFolderParentPath|f_lblQACTempFolderParentPath|f_btnQACTempFolderParentPath")

if !StrLen(o_Settings.Launch.strQACTempFolderParent.IniValue)
	if StrLen(EnvVars("%TEMP%")) ; make sure the environment variable exists
		o_Settings.Launch.strQAPTempFolderParent.IniValue := "%TEMP%"
	else
		o_Settings.Launch.strQACTempFolderParent.IniValue := A_WorkingDir

global g_strTempDirParent := PathCombine(A_WorkingDir, EnvVars(o_Settings.Launch.strQACTempFolderParent.IniValue))

; add a random number between 0 and 2147483647 to generate a unique temp folder in case multiple QAP instances are running
global g_strTempDir := g_strTempDirParent . "\_QAC_temp_" . RandomBetween()
FileCreateDir, %g_strTempDir%

global g_strRulesPathNameNoExt := g_strTempDir . "\QACrules" ; QACrules .exe and .ahk files path and file name no ext

; Force g_strRulesPathNameNoExt to be in A_WorkingDir if uncompiled (development environment)
;@Ahk2Exe-IgnoreBegin
; Start of code for development environment only - won't be compiled
; see http://fincs.ahk4.net/Ahk2ExeDirectives.htm
global g_strRulesPathNameNoExt := A_WorkingDir . "\QACrules"
; to test user data directory: SetWorkingDir, %A_AppData%\Quick Access Clipboard
; / End of code for developement environment only - won't be compiled
;@Ahk2Exe-IgnoreEnd

; remove temporary folders older than 7 days
SetTimer, RemoveOldTemporaryFolders, -10000, -100 ; run once in 10 seconds, low priority -100

;---------------------------------
; Init temporary folder

Gosub, InitFileInstall

;---------------------------------
; Init language variables (must be after g_strCurrentBranch init)

global g_strEscapeReplacement := "!r4nd0mt3xt!"
global o_L := new Language
o_Settings.InitOptionsGroupsLabelNames() ; init options groups labels after language is initialized

;---------------------------------
; Init global variables

global g_strDiagFile := A_WorkingDir . "\" . g_strAppNameFile . "-DIAG.txt"

global g_aaRulesByName ; object initialized when loading rules
global g_saRulesOrder ; object initialized when loading rules
global g_intGuiDefaultWidth := 784 ; 636
global g_intGuiDefaultHeight := 546 ; 496 ; was 601
global g_saGuiControls := Object() ; to build Editor gui
global g_strGui1Hwnd ; editor window ID
global g_strEditorControlHwnd ; editor control ID
global g_strCliboardBackup ; not used...
global g_intClipboardContentType ; updated by ClipboardContentChanged()
global g_saRulesBackupSelectedOrder ; backup of selected rules
global g_saRulesBackupSelectedByName ; backup of selected rules
global g_strPipe := "Ð¡þ€" ; used to replace pipe in ini file
global g_strEol := "€ö¦" ; used to replace end-of-line in AutoHotkey rules in ini file
global g_strTab := "¬ã³" ; used to replace tab in AutoHotkey rules in ini file
global g_aaToolTipsMessages := Object() ; messages to display by ToolTip when mouse is over selected buttons in Settings
global g_strRulesBackupExist := StrLen(o_Settings.ReadIniSection("Rules-backup")) ; used in BuildGui and BuildGuiMenuBar

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
; Init rule types

Gosub, InitRuleTypes

;---------------------------------
; Init startups and last version used
intStartups := o_Settings.ReadIniValue("Startups", 0)
global g_strLastVersionUsed := o_Settings.ReadIniValue("LastVersionUsed" . (g_strCurrentBranch = "alpha" ? "Alpha" : (g_strCurrentBranch = "beta" ? "Beta" : "Prod")), 0.0)

;---------------------------------
; Load Settings file

Gosub, LoadIniFile ; load options and rules

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
Gosub, BuildEditorContextMenu
Gosub, BuildGuiMenuBar
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

if (g_blnPortableMode)
	blnStartup := StrLen(FileExist(A_Startup . "\" . g_strAppNameFile . ".lnk")) ; convert file attribute to numeric (boolean) value
else
	blnStartup := RegistryExist("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText)

if (blnStartup) ; both setup and portable
{
	Menu, Tray, Check, % o_L["MenuRunAtStartup"]
	Menu, menuBarOptions, Check, % o_L["MenuRunAtStartup"]
}

Gosub, EnableClipboardChangesInEditor

; startups count and trace
IniWrite, % (intStartups + 1), % o_Settings.strIniFile, Internal, Startups
IniWrite, %g_strCurrentVersion%, % o_Settings.strIniFile, Internal, % "LastVersionUsed" . (g_strCurrentBranch = "alpha" ? "Alpha" : (g_strCurrentBranch = "beta" ? "Beta" : "Prod"))
IniWrite, % (g_blnPortableMode ? "Portable" : "Easy Setup"), % o_Settings.strIniFile, Internal, Installation

;---------------------------------
; Load the cursor and start the "hook" to change mouse cursor in Settings - See WM_MOUSEMOVE function below

g_objHandCursor := DllCall("LoadCursor", "UInt", NULL, "Int", 32649, "UInt") ; IDC_HAND
OnMessage(0x200, "WM_MOUSEMOVE")

;---------------------------------
; Respond to SendMessage sent by QACrules
OnMessage(0x4a, "RECEIVE_QACRULES")

;---------------------------------
; Setting window hotkey conditional assignment

Hotkey, If, WinActive(QACGuiTitle()) ; main Gui title

	Hotkey, ^c, EditorCtrlC, On UseErrorLevel
	Hotkey, ^x, EditorCtrlX, On UseErrorLevel
	Hotkey, +F10, EditorShiftF10, On UseErrorLevel

	; other Hotkeys are created by menu assignement in BuildGuiMenuBar

Hotkey, If

if (o_Settings.EditorWindow.blnDisplayEditorAtStartup.IniValue)
	Gosub, GuiShow

return

;========================================================================================================================
; END !_011_INITIALIZATION:
;========================================================================================================================


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
#If, WinActive(QACGuiTitle()) ; main Gui title
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
EditorCtrlX: ; Cut
EditorShiftF10: ; context menu
;-----------------------------------------------------------

if (A_ThisLabel = "EditorCtrlS")
	
	Gosub, GuiSaveEditor

else if (A_ThisLabel = "EditorEsc")

	Gosub, GuiCloseCancel

else if (A_ThisLabel = "EditorCtrlC") or (A_ThisLabel = "EditorCtrlX")
{
	Gosub, DisableClipboardChangesInEditor
	Send, % (A_ThisLabel = "EditorCtrlC" ? "^c" : "^x")
	Gosub, EnableSaveAndCancel
}
else if (A_ThisLabel = "EditorShiftF10")
	
	Gosub, ShowUpdatedEditorContextMenu

return
;-----------------------------------------------------------

; End of Gui Hotkeys

;========================================================================================================================
; END !_012_GUI_HOTKEYS:
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
	
return
;-----------------------------------------------------------


;-----------------------------------------------------------
InitRuleTypes:
;-----------------------------------------------------------

global g_aaRuleTypes = Object()
global g_saRuleTypesOrder = Object()

saRuleTypes := StrSplit("ChangeCase|ConvertFormat|Replace|AutoHotkey|Prefix|Suffix|SubStr", "|")
for intIndex, strType in saRuleTypes
{
	strLabels .= o_L["Type" . strType] . "|" ; "TypeChangeCase", etc.

	if (strType = "AutoHotkey")
		strHelp .=  L(o_L["Type" . strType . "Help"], "https://www.autohotkey.com/docs/AutoHotkey.htm"
			, "https://www.autohotkey.com/docs/Variables.htm", "https://www.autohotkey.com/docs/commands/SubStr.htm"
			, "https://www.autohotkey.com/docs/commands/InStr.htm", "https://www.autohotkey.com/docs/commands/Loop.htm"
			, "https://www.autohotkey.com/docs/commands/LoopParse.htm")
	else
		strHelp .=  o_L["Type" . strType . "Help"]
	strHelp .= "|"
}

saRuleTypesLabels := StrSplit(SubStr(strLabels, 1, -1), "|")
saRuleTypesHelp := StrSplit(SubStr(strHelp, 1, -1), "|")

Loop, % saRuleTypes.Length()
	new RuleType(saRuleTypes[A_Index], saRuleTypesLabels[A_Index], saRuleTypesHelp[A_Index])

saRuleTypes := ""
saRuleTypesLabels := ""
strLabels := ""
strHelp := ""

return
;-----------------------------------------------------------


;-----------------------------------------------------------
LoadIniFile:
; load options, load rules to menu object
;-----------------------------------------------------------

strRulesExist := StrLen(o_Settings.ReadIniSection("Rules"))

if !(strRulesExist) ; first launch
{
	IniWrite, ChangeCase|Demo|Convert Clipboard to lower case|1|, % o_Settings.strIniFile, Rules, Lower case
	IniWrite, ChangeCase|Demo|Convert Clipboard to upper case|2|, % o_Settings.strIniFile, Rules, Upper case
	IniWrite, ConvertFormat|Demo|Convert Clipboard to Text format|1|, % o_Settings.strIniFile, Rules, Convert to text
	IniWrite, Replace|Demo|Text substitution example with whole word option|this|that|1||, % o_Settings.strIniFile, Rules, Replace this with that
	IniWrite, SubStr|Demo|String manipulation example|1|||0|3|-2||0|0|, % o_Settings.strIniFile, Rules, Trim 2 last characters
	IniWrite, Prefix|Demo|Append text example|Title: |, % o_Settings.strIniFile, Rules, Prefix with Title
	IniWrite, AutoHotkey|Demo|Simple AutoHotkey line of code|MsgBox`, Your Clipboard1 contains: `%Clipboard`%|, % o_Settings.strIniFile, Rules, MsgBox
	IniWrite, % "AutoHotkey|Demo|Multiline AHK scripting|if StrLen(Clipboard) > 500" . g_strEol
		. g_strTab . "str := ""The 500 first characters of your Clipboard are:``n``n"" . SubStr(Clipboard, 1, 500) . ""...""" . g_strEol
		. "else" . g_strEol
		. g_strTab . "str := ""Your Clipboard contains:``n``n"" . Clipboard"
		. g_strEol . "MsgBox, %str%|", % o_Settings.strIniFile, Rules, MsgBox Multiline
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
o_Settings.ReadIniOption("SettingsFile", "strBackupFolder", "BackupFolder", A_WorkingDir, "General"
	, "f_lblBackupFolder|f_strBackupFolder|f_btnBackupFolder|f_lblWorkingFolder|f_strWorkingFolder|f_btnWorkingFolder|f_lblWorkingFolderDisabled")

; Group EditorWindow
o_Settings.ReadIniOption("EditorWindow", "blnDisplayEditorAtStartup", "DisplayEditorAtStartup", 1, "EditorWindow", "f_blnDisplayEditorAtStartup|f_lblOptionsEditorWindow")
o_Settings.ReadIniOption("EditorWindow", "blnRememberEditorPosition", "RememberEditorPosition", 1, "EditorWindow", "f_blnRememberEditorPosition")
o_Settings.ReadIniOption("EditorWindow", "blnOpenEditorOnActiveMonitor", "OpenEditorOnActiveMonitor", 1, "EditorWindow", "f_blnOpenEditorOnActiveMonitor")
; need improvement !! o_Settings.ReadIniOption("EditorWindow", "blnDarkModeCustomize", "DarkModeCustomize", 0, "EditorWindow", "f_blnDarkModeCustomize")
o_Settings.ReadIniOption("EditorWindow", "blnFixedFont", "FixedFont", 1, "EditorWindow", "")
o_Settings.ReadIniOption("EditorWindow", "intFontSize", "FontSize", 12, "EditorWindow", "")
o_Settings.ReadIniOption("EditorWindow", "blnAlwaysOnTop", "AlwaysOnTop", 0, "EditorWindow", "")
o_Settings.ReadIniOption("EditorWindow", "blnUseTab", "UseTab", 0, "EditorWindow", "")

; Group MenuAdvanced
o_Settings.ReadIniOption("MenuAdvanced", "intShowMenuBar", "ShowMenuBar", 3, "MenuAdvanced", "")

; Group AdvancedOther
; not ready !! o_Settings.ReadIniOption("LaunchAdvanced", "blnRunAsAdmin", "RunAsAdmin", 0, "AdvancedOther", "f_blnRunAsAdmin|f_picRunAsAdmin") ; default false, if true reload QAC as admin

; not in a Gui group
o_Settings.ReadIniOption("Launch", "blnDiagMode", "DiagMode", 0) ; g_blnDiagMode

; ---------------------
; Load rules

Gosub, LoadRulesFromIni ; load rules

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
	Gosub, SetTrayMenuIconForCurrentBranch

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
	Menu, Tray, Add, % o_L["MenuRule"], :menuBarRule
	Menu, Tray, Add, % o_L["GuiApplyRule"], :menuRules
	Menu, Tray, Add, % o_L["MenuOptions"], :menuBarOptions
	Menu, Tray, Add, % o_L["MenuHelp"], :menuBarHelp
}
Menu, Tray, Add
Menu, Tray, Add, % o_L["MenuSuspendHotkeys"], ToggleSuspendHotkeys
Menu, Tray, Add, % o_L["MenuRunAtStartup"], ToggleRunAtStartup ; function ToggleRunAtStartup replaces RunAtStartup
Menu, Tray, Add, % L(o_L["MenuExitApp"], g_strAppNameText), GuiCloseCancelAndExitApp
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
BuildEditorContextMenu:
;------------------------------------------------------------

; OnMessage to intercept Context menu in Edit control
; from Malcev (https://www.autohotkey.com/board/topic/116431-trying-to-replace-edit-box-context-menu/#entry732693)
OnMessage(0x204, "WM_RBUTTONDOWN")
OnMessage(0x205, "WM_RBUTTONUP")

Gosub, BuildRulesMenu

Menu, menuEditorContextMenu, Add, % o_L["DialogUndo"], EditorContextMenuActions
Menu, menuEditorContextMenu, Add
Menu, menuEditorContextMenu, Add, % o_L["DialogCut"], EditorContextMenuActions
Menu, menuEditorContextMenu, Add, % o_L["DialogCopy"], EditorContextMenuActions
Menu, menuEditorContextMenu, Add, % o_L["DialogPaste"], EditorContextMenuActions
Menu, menuEditorContextMenu, Add, % o_L["DialogDelete"], EditorContextMenuActions
Menu, menuEditorContextMenu, Add
Menu, menuEditorContextMenu, Add, % o_L["MenuExecuteRule"], :menuRules
Menu, menuEditorContextMenu, Add
Menu, menuEditorContextMenu, Add, % o_L["DialogSelectAll"], EditorContextMenuActions

return
;------------------------------------------------------------


;------------------------------------------------------------
BuildRulesMenu:
;------------------------------------------------------------

; delete menu before updating it
Menu, menuRules, Add ; to avoid an error if menu is empty when deleting
Menu, menuRules, DeleteAll ; required for menu updates

if g_aaRulesByName.Count()
	for strRuleName, oRule in g_aaRulesByName
		Menu, menuRules, Add, %strRuleName%, ExecuteRule
else
{
	Menu, menuRules, Add, % o_L["MenuNoRule"], DoNothing
	Menu, menuRules, Disable, % o_L["MenuNoRule"]
}

return
;------------------------------------------------------------


;------------------------------------------------------------
ShowUpdatedEditorContextMenu:
;------------------------------------------------------------

GuiControl, Focus, f_strClipboardEditor ; give focus to control for EditorContextMenuActions

GuiControlGet, blnEnable, Enabled, f_btnGuiSaveEditor ; enable Undo item if Save button is enabled
Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), % o_L["DialogUndo"]

blnEnable := GetSelectedTextLenght() ; enable Cut, Copy, Delete if text is selected in the control
Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), % o_L["DialogCut"]
Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), % o_L["DialogCopy"]
Menu, menuEditorContextMenu, % (blnEnable ? "Enable" : "Disable"), % o_L["DialogDelete"]

Menu, menuEditorContextMenu, % (StrLen(Clipboard) ? "Enable" : "Disable"), % o_L["DialogPaste"]
Menu, menuEditorContextMenu, Show

return
;------------------------------------------------------------


;------------------------------------------------------------
EditorContextMenuActions:
;------------------------------------------------------------

if (A_ThisMenuItem = "DialogCut" or A_ThisMenuItem = "DialogCopy") ; disconnect before changing the Clipboard content
	Gosub, DisableClipboardChangesInEditor

if (A_ThisMenuItem = o_L["DialogUndo"])
	Send, ^z
else if (A_ThisMenuItem = o_L["DialogCut"])
	Send, ^x
else if (A_ThisMenuItem = o_L["DialogCopy"])
	Send, ^c
else if (A_ThisMenuItem = o_L["DialogPaste"])
	Send, ^v
else if (A_ThisMenuItem = o_L["DialogDelete"])
	Send, {Del}
else if (A_ThisMenuItem = o_L["DialogSelectAll"])
	Send, ^a

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
; END !_015_INITIALIZATION_SUBROUTINES:
;========================================================================================================================


;========================================================================================================================
!_020_GUI:
;========================================================================================================================

;------------------------------------------------------------
BuildGuiMenuBar:
; see https://docs.microsoft.com/fr-fr/windows/desktop/uxguide/cmd-menus
;------------------------------------------------------------

Menu, menuBarFile, Add, % o_L["GuiSaveEditor"] . "`tCtrl+S", EditorCtrlS
Menu, menuBarFile, Add, % o_L["GuiClose"] . "`tEsc", GuiCloseCancel
Menu, menuBarFile, Add
Menu, menuBarFile, Add, % o_L["MenuOpenWorkingDirectory"], OpenWorkingDirectory
Menu, menuBarFile, Add
if (g_strCurrentBranch <> "prod")
{
	Menu, menuBarFile, Add, Debug QACrules.ahk (beta only), OpenQacRulesFile
	Menu, menuBarFile, Add
}
Menu, menuBarFile, Add, % L(o_L["MenuExitApp"], g_strAppNameText), GuiCloseCancelAndExitApp

Menu, menuBarRule, Add, % o_L["MenuRuleAdd"], GuiAddRuleSelectType
Menu, menuBarRule, Add, % o_L["MenuRuleEdit"], GuiRuleEdit
Menu, menuBarRule, Add, % o_L["MenuRuleRemove"], GuiRuleRemove
Menu, menuBarRule, Add, % o_L["MenuRuleCopy"], GuiRuleCopy
Menu, menuBarRule, Add
Menu, menuBarRule, Add, % o_L["MenuRuleUndo"], GuiRuleUndo
Menu, menuBarRule, % (g_strRulesBackupExist ? "Enable" : "Disable"), % o_L["MenuRuleUndo"]
Menu, menuBarRule, Add
Menu, menuBarRule, Add, % o_L["MenuRuleSelect"], GuiRuleSelect
Menu, menuBarRule, Add, % o_L["MenuRuleDeselect"], GuiRuleDeselect
Menu, menuBarRule, Add, % o_L["MenuRuleDeselectAll"], GuiRuleDeselectAll
Menu, menuBarRule, Add
Menu, menuBarRule, Add, % o_L["GuiApplyRules"], GuiApplyRules

Menu, menuBarOptions, Add, % o_L["MenuSelectHotkeyMouse"], GuiSelectHotkeyMouse
Menu, menuBarOptions, Add, % o_L["MenuSelectHotkeyKeyboard"], GuiSelectHotkeyKeyboard
Menu, menuBarOptions, Add
Menu, menuBarOptions, Add, % o_L["MenuRunAtStartup"], ToggleRunAtStartup
Menu, menuBarOptions, Add
Menu, menuBarOptions, Add, % L(o_L["MenuEditIniFile"], o_Settings.strIniFileNameExtOnly), ShowSettingsIniFile

Menu, menuBarHelp, Add, % o_L["MenuUpdate"], Check4Update
Menu, menuBarHelp, Add, % L(o_L["MenuAbout"], g_strAppNameText), GuiAbout

Menu, menuBarMain, Add, % o_L["MenuFile"], :menuBarFile
Menu, menuBarMain, Add, % o_L["MenuRule"], :menuBarRule
Menu, menuBarMain, Add, % o_L["GuiApplyRule"], :menuRules
Menu, menuBarMain, Add, % o_L["MenuOptions"], :menuBarOptions
Menu, menuBarMain, Add, % o_L["MenuHelp"], :menuBarHelp

return
;------------------------------------------------------------


;------------------------------------------------------------
InitGuiControls:
; Order of controls important to avoid drawings gliches when resizing
;------------------------------------------------------------

; InsertGuiControlPos(strControlName, intX, intY, blnCenter := false, blnDraw := false)
InsertGuiControlPos("f_strClipboardEditor",			20, 130) ; must be first g_saGuiControls[1]
InsertGuiControlPos("f_btnGuiSaveEditor",			0,  -65, , true)
InsertGuiControlPos("f_btnGuiCloseCancel",			0,  -65, , true)

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

Gui, 1:New, +Hwndg_strGui1Hwnd +Resize -MinimizeBox +MinSize%g_intGuiDefaultWidth%x%g_intGuiDefaultHeight%, % QACGuiTitle()
if (o_Settings.MenuAdvanced.intShowMenuBar.IniValue <> 2) ; 1 Customize menu bar, 2 System menu, 3 both
	Gui, Menu, menuBarMain

Gui, 1:Font, s8 w600, Verdana
Gui, 1:Add, Text, x40 y10, % o_L["GuiRulesAvailable"]
Gui, 1:Add, Text, x564 y10, % o_L["GuiRulesSelected"]
Gui, 1:Font, s8 w400

Gui, 1:Add, Text, x10 y+10 Section

Gui, Font, s9, Arial
; Unicode chars: https://www.fileformat.info/info/unicode/category/So/list.htm
Gui, 1:Add, Button, ys x10 ys+30 w24 vf_btnRuleAdd gGuiAddRuleSelectType, % chr(0x2795) ; or chr(0x271B)
g_aaToolTipsMessages["Button1"] := o_L["MenuRuleAdd"]
Gui, 1:Add, Button, ys+60 x10 w24 vf_btnRuleEdit gGuiRuleEdit, % chr(0x2328)
g_aaToolTipsMessages["Button2"] := o_L["MenuRuleEdit"]
Gui, 1:Add, Button, ys+90 x10 w24 vf_btnRuleRemove gGuiRuleRemove, % chr(0x2796)
g_aaToolTipsMessages["Button3"] := o_L["MenuRuleRemove"]
Gui, 1:Add, Button, ys+120 x10 w24 vf_btnRuleCopy gGuiRuleCopy, % chr(0x1F5D7) ; or 0x2750
g_aaToolTipsMessages["Button4"] := o_L["MenuRuleCopy"]
Gui, 1:Add, Button, % "ys+173 x10 w24 vf_btnRuleUndo gGuiRuleUndo " . (g_strRulesBackupExist ? "" : "Disabled"), % chr(0x238C) ; or 0x2750
g_aaToolTipsMessages["Button5"] := o_L["MenuRuleUndo"]
Gui, Font

Gui, 1:Add, ListView
	, % "vf_lvRulesAvailable +Hwndg_strRulesAvailableHwnd Count32 Sort -Multi AltSubmit LV0x10 LV0x10000 gGuiRulesAvailableEvents x40 ys w490 r10 Section"
	, % o_L["DialogRuleName"] . "|" . o_L["DialogRuleType"] . "|" . o_L["DialogRuleCategory"] . "|" . o_L["DialogRuleNotes"] ; SysHeader321 / SysListView321

Gui, Font, s9, Arial
; Unicode chars: https://www.fileformat.info/info/unicode/category/So/list.htm
Gui, 1:Add, Button, ys+30 x535 w24 vf_btnRuleSelect gGuiRuleSelect, % chr(0x25BA)
g_aaToolTipsMessages["Button6"] := o_L["MenuRuleSelect"]
Gui, 1:Add, Button, ys+60 x535 w24 vf_btnRuleDeselect gGuiRuleDeselect, % chr(0x25C4)
g_aaToolTipsMessages["Button7"] := o_L["MenuRuleDeselect"]
Gui, 1:Add, Button, ys+90 x535 w24 vf_btnRuleDeslectAll gGuiRuleDeselectAll, % chr(0x232B)
g_aaToolTipsMessages["Button8"] := o_L["MenuRuleDeselectAll"]
Gui, Font

Gui, 1:Add, ListView
	, % "vf_lvRulesSelected +Hwndg_strRulesSelectedHwnd Count32 -Multi AltSubmit NoSortHdr LV0x10 LV0x10000 gGuiRulesSelectedEvents x564 ys w200 r10"
	, % o_L["DialogRuleName"] ; SysHeader321 / SysListView321

Gosub, GuiLoadRulesAvailable
Gosub, LaunchQACrules

; initialize LV_Rows class (https://github.com/Pulover/Class_LV_Rows)
o_LvRowsHandle := New LV_Rows(Hwndg_strRulesSelectedHwnd)
o_LvRowsHandle.SetHwnd(Hwndg_strRulesSelectedHwnd)

Gui, 1:Font, s8 w600, Verdana
Gui, 1:Add, Button, x10 y+10 vf_btnGuiApplyRules gGuiApplyRules h25 Disabled, % o_L["GuiApplyRules"]
GuiCenterButtons(g_strGui1Hwnd, , , , 565, 20, "f_btnGuiApplyRules")
Gui, 1:Font ; reset default font

Gui, 1:Font, s8 w600, Verdana
Gui, 1:Add, Text, x20 y+5, % o_L["MenuEditor"]
Gui, 1:Font

Gui, 1:Add, Text, x10
Gui, 1:Add, Checkbox, % "x+1 yp vf_blnFixedFont gClipboardEditorFontChanged " . (o_Settings.EditorWindow.blnFixedFont.IniValue = 1 ? "checked" : ""), % o_L["DialogFixedFont"]
Gui, 1:Add, Text, x+10 yp vf_lblFontSize, % o_L["DialogFontSize"]
Gui, 1:Add, Edit, x+5 yp w40 vf_intFontSize gClipboardEditorFontChanged
Gui, 1:Add, UpDown, Range6-36 vf_intFontUpDown, % o_Settings.EditorWindow.intFontSize.IniValue
Gui, 1:Add, Checkbox, % "x+20 yp vf_blnAlwaysOnTop gClipboardEditorAlwaysOnTopChanged " . (o_Settings.EditorWindow.blnAlwaysOnTop.IniValue = 1 ? "checked" : ""), % o_L["DialogAlwaysOnTop"]
Gui, 1:Add, Checkbox, % "x+10 yp vf_blnUseTab gClipboardEditorUseTabChanged " . (o_Settings.EditorWindow.blnUseTab.IniValue = 1 ? "checked" : ""), % o_L["DialogUseTab"]
Gui, 1:Add, Checkbox, x+10 yp vf_blnSeeInvisible gClipboardEditorSeeInvisibleChanged disabled, % o_L["DialogSeeInvisible"] ; enable only if f_strClipboardEditor contains Clipboard

Gosub, ClipboardEditorAlwaysOnTopChanged
Gosub, ClipboardEditorUseTabChanged

Gui, 1:Add, Text, y+20 vf_lblBeginEditor ; mark for top of editor
GuiControlGet, arrControlPos, Pos, f_lblBeginEditor
g_saGuiControls[1].Y := arrControlPosY

Gui, 1:Add, Edit, x10 y50 w600 vf_strClipboardEditor gClipboardEditorChanged Multi t20 WantReturn +hwndg_strEditorControlHwnd
Gosub, ClipboardEditorFontChanged ; must be after Add Edit

Gui, 1:Font, s8 w600, Verdana
Gui, 1:Add, Button, vf_btnGuiSaveEditor Disabled gGuiSaveEditor x200 y400 w140 h35, % o_L["GuiSaveEditor"]
Gui, 1:Add, Button, vf_btnGuiCloseCancel gGuiCloseCancel Default x500 yp w100 h35, % o_L["GuiClose"]
GuiControl, 1:Focus, f_btnGuiCloseCancel
Gui, 1:Font

Gui, 1:Add, StatusBar
SB_SetParts(200, 200)

GetSavedEditorWindowPosition(saEditorPosition) ; format: x|y|w|h with optional |M if maximized

Gui, 1:Show, % "Hide "
	. (saEditorPosition[1] = -1 or saEditorPosition[1] = "" or saEditorPosition[2] = ""
	? "center w" . g_intGuiDefaultWidth . " h" . g_intGuiDefaultHeight
	: "x" . saEditorPosition[1] . " y" . saEditorPosition[2])
sleep, 100
if (saEditorPosition[1] <> -1)
{
	WinMove, ahk_id %g_strGui1Hwnd%, , , , % saEditorPosition[3], % saEditorPosition[4]
	if (saEditorPosition[5] = "M")
	{
		WinMaximize, ahk_id %g_strGui1Hwnd%
		WinHide, ahk_id %g_strGui1Hwnd%
	}
}

/*
To improve with help. "ButtonN" controls including checkboxes do not respond to colo command,

; testing the dark mode display on Customize window (see https://www.autohotkey.com/boards/viewtopic.php?p=426678&sid=0f08bed4b46e1ed1f59601053df8c959#p426678)
RegRead, blnLightMode, HKCU, SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize, AppsUseLightTheme ; check SystemUsesLightTheme for Windows system preference
if (o_Settings.EditorWindow.blnDarkModeCustomize.IniValue and !blnLightMode)
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
		if InStr(strControl, "Button")
		{
			Gui,Font, c%intControlColor%
			GuiControl, Font, %strControl%
		}
	}
}
*/

saEditorPosition := ""
strTextColor := ""
strHwnd := ""
g_strRulesBackupExist := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiLoadRulesAvailable:
;------------------------------------------------------------

Gui, 1:ListView, f_lvRulesAvailable
LV_Delete()
for strName, aaRule in g_aaRulesByName
	aaRule.ListViewAdd("f_lvRulesAvailable")
LV_ModifyCol()

Gui, 1:ListView, f_lvRulesSelected
LV_Delete()

strName := ""
aaRule := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiRuleSelect:
GuiRuleDeselect:
GuiRuleDeselectAll:
;------------------------------------------------------------

Gosub, EnableApplyRulesAndCancel

if (A_ThisLabel = "GuiRuleDeselectAll")
{
	Gosub, GuiLoadRulesAvailable
	return
}
; else

Gui, 1:ListView, % (A_ThisLabel = "GuiRuleSelect" ? "f_lvRulesAvailable" : "f_lvRulesSelected")

if !GetLVPosition(intPosition, (A_ThisLabel = "GuiRuleSelect" ? o_L["GuiSelectRuleSelect"] : o_L["GuiSelectRuleDeselect"]))
	return

LV_GetText(strName, intPosition, 1)
LV_Delete(intPosition)

Gui, 1:ListView, % (A_ThisLabel = "GuiRuleDeselect" ? "f_lvRulesAvailable" : "f_lvRulesSelected")
g_aaRulesByName[strName].ListViewAdd((A_ThisLabel = "GuiRuleDeselect" ? "f_lvRulesAvailable" : "f_lvRulesSelected"), "Select")

intPosition := ""
intOrder := ""
strName := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiRulesAvailableEvents:
GuiRulesSelectedEvents:
;------------------------------------------------------------

if (A_GuiEvent = "DoubleClick")
{
	Gui, 1:ListView, %A_GuiControl%
	if (A_GuiControl = "f_lvRulesAvailable" and GetKeyState("Shift"))
		Gosub, GuiRuleEdit
	else
		Gosub, % (A_GuiControl = "f_lvRulesAvailable" ? "GuiRuleSelect" : "GuiRuleDeSelect")
}
else if (A_ThisLabel = "GuiRulesSelectedEvents" and A_GuiEvent == "D") ; case sensitive to exclude "d" for right click
{
	; drop item in gui using LV_Rows class
	o_LvRowsHandle.SetHwnd(h%A_GuiControl%) ; select active hwnd in Handle.
	; A_EventInfo ; original position, not used
    intNewItemPos := o_LvRowsHandle.Drag("D", true, 80, 2, "3F51B5") ; returns the new item position, 3F51B5 is the color of the up/down buttons
	; intNewItemPos not used
	Gosub, EnableApplyRulesAndCancel
}

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiApplyRules:
;------------------------------------------------------------
Gui, Submit, NoHide

Gosub, BackupSelectedRules
Gosub, LaunchQACrules
Gosub, DisableApplyRulesAndCancel

return
;------------------------------------------------------------


;------------------------------------------------------------
LaunchQACrules:
;------------------------------------------------------------

While QACrulesExists()
	Process, Close, QACrules.exe

FileDelete, %g_strRulesPathNameNoExt%.ahk

; variable used in non-expression script header below
intTimeoutMs := o_Settings.Launch.intRulesTimeoutSecs.IniValue * 1000
strGuiTitle := QACGuiTitle() 

; script header
strTop =
	(LTrim Join`r`n
	#NoEnv
	#Persistent
	#SingleInstance force
	#NoTrayIcon
	
	`; (removed - cause bug preventing calling rules on demand) global g_intLastTick := A_TickCount ; initial timeout delay after rules are enabled
	global g_stTargetAppTitle := `"%strGuiTitle%`"
	
	Gosub, OnClipboardChangeInit
	`; (removed - cause bug preventing calling rules on demand) SetTimer, CheckTimeOut, 2000
	
	; Respond to SendMessage sent by QAC requesting execution of a rule
	OnMessage(0x4a, "RECEIVE_QACMAIN")

	return
	
	; end of header
	;-----------------------------------------------------------
	
	;-----------------------------------------------------------
	CheckTimeOut:
	;-----------------------------------------------------------

	if ((A_TickCount - g_intLastTick) > %intTimeoutMs%)
	{
		ToolTip, ~1~
		; send message to main app to uncheck rules checkboxes
		intResult := Send_WM_COPYDATA("rules_disabled", g_stTargetAppTitle)
		Sleep, 2000
		ExitApp
	}

	return
	;-----------------------------------------------------------

	;-----------------------------------------------------------
	Send_WM_COPYDATA(ByRef strStringToSend, ByRef strTargetScriptTitle) ; ByRef saves a little memory in this case.
	;-----------------------------------------------------------
	; Adapted from AHK documentation (https://autohotkey.com/docs/commands/OnMessage.htm)
	; This function sends the specified string to the specified window and returns the reply.
	; The reply is 1 if the target window processed the message, or 0 if it ignored it.
	;-----------------------------------------------------------
	{
		VarSetCapacity(varCopyDataStruct, 3 * A_PtrSize, 0) ; Set up the structure's memory area.
		
		; First set the structure's cbData member to the size of the string, including its zero terminator:
		intSizeInBytes := (StrLen(strStringToSend) + 1) * (A_IsUnicode ? 2 : 1)
		NumPut(intSizeInBytes, varCopyDataStruct, A_PtrSize) ; OS requires that this be done.
		NumPut(&strStringToSend, varCopyDataStruct, 2 * A_PtrSize) ; Set lpData to point to the string itself.
		
		; strPrevDetectHiddenWindows := A_DetectHiddenWindows
		; intPrevTitleMatchMode := A_TitleMatchMode
		DetectHiddenWindows On
		SetTitleMatchMode 2
		
		SendMessage, 0x4a, 0, &varCopyDataStruct, , `%strTargetScriptTitle`% ; 0x4a is WM_COPYDATA. Must use Send not Post.
		
		; DetectHiddenWindows `%strPrevDetectHiddenWindows`% ; Restore original setting for the caller.
		; SetTitleMatchMode `%intPrevTitleMatchMode`% ; Same.
		
		return ErrorLevel ; Return SendMessage's reply back to our caller.
	}
	;-----------------------------------------------------------
	
	;------------------------------------------------------------
	RECEIVE_QACMAIN(wParam, lParam) 
	; Adapted from AHK documentation (https://autohotkey.com/docs/commands/OnMessage.htm)
	;------------------------------------------------------------
	{
		intStringAddress := NumGet(lParam + 2*A_PtrSize) ; Retrieves the CopyDataStruct's lpData member.
		strCopyOfData := StrGet(intStringAddress) ; Copy the string out of the structure.
		saData := StrSplit(strCopyOfData, "|")
		
		if (saData[1] = "exec")
		{
			strRule := "Rule" . saData[2]
			`%strRule`%(1)
			`; return 1 ; success
		}
	}
	;------------------------------------------------------------

	;-----------------------------------------------------------
	OnClipboardChangeInit:
	;-----------------------------------------------------------


) ; leave the 2 last extra lines above

; OnClipboardChange functions
strOnClipboardChange := ""
loop, Parse, % "f_lvRulesSelected|f_lvRulesAvailable", |
{
	Gui, 1:ListView, %A_LoopField%
	loop, % LV_GetCount()
	{
		LV_GetText(strName, A_Index, 1)
		strOnClipboardChange .= "OnClipboardChange(""Rule" . g_aaRulesByName[strName].intID . """, " . (A_LoopField = "f_lvRulesSelected") . ")`n"
	}
}

strBottom =
	(LTrim Join`r`n
	
	return ; end of OnClipboardChangeInit
	;-----------------------------------------------------------


) ; leave the 2 last extra lines above

strSource := StrReplace(strTop, "~1~", L(o_L["RulesDisabled"], g_strAppNameText, o_Settings.Launch.intRulesTimeoutSecs.IniValue)) . strOnClipboardChange . strBottom

; add rules code
for strName, aaRule in g_aaRulesByName
	strSource .= aaRule.GetCode()

; save AHK script file QACrules.ahk
FileAppend, %strSource%, %g_strRulesPathNameNoExt%.ahk, % (A_IsUnicode ? "UTF-16" : "")

ToolTip, % L(o_L["RulesUpdated"], g_strAppNameText)
; run the AHK runtime QACrules.exe that will call the script having the same name QACrules.ahk
Run, %g_strRulesPathNameNoExt%.exe, , , strQacRulesPID
SetTimer, RemoveToolTip, -2000 ; run once in 2 seconds

strTop := ""
strOnClipboardChange := ""
strSource := ""
strGuiTitle := ""
intTimeoutMs := ""
strName := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

Gosub, DisableClipboardChangesInEditor
SB_SetText(o_L["MenuEditor"] . ": " . (StrLen(f_strClipboardEditor) = 1 ? o_L["GuiOneCharacter"] : L(o_L["GuiCharacters"], StrLen(f_strClipboardEditor))), 1)
Gosub, EnableSaveAndCancel

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorAlwaysOnTopChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

WinSet, AlwaysOnTop, % (f_blnAlwaysOnTop ? "On" : "Off"), ahk_id %g_strGui1Hwnd% ; do not use default Toogle for safety

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorUseTabChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

GuiControl, % (f_blnUseTab ? "+" : "-") . "WantTab", f_strClipboardEditor

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorSeeInvisibleChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

GuiControl, % (f_blnSeeInvisible ? "+" : "-") . "ReadOnly", f_strClipboardEditor
GuiControl, , f_strClipboardEditor, % (f_blnSeeInvisible ? ConvertInvisible(f_strClipboardEditor) : Clipboard)

return
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardContentChanged(intClipboardContentType)
; intClipboardContentType: 0 = empty / 1 = contains text / 2 = contains binary

;------------------------------------------------------------
{
	strDetectHiddenWindowsBefore := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	If WinExist("ahk_id " . g_strGui1Hwnd) ; if editor is visible, update content
	{
		g_intClipboardContentType := intClipboardContentType
		Gosub, UpdateEditorWithClipboard
		Gosub, DisableSaveAndCancel
	}
	DetectHiddenWindows, %strDetectHiddenWindowsBefore%

}
;------------------------------------------------------------


;------------------------------------------------------------
ClipboardEditorFontChanged:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

if (f_blnFixedFont)
	Gui, 1:Font, % "s" . f_intFontSize, Courier New
else
	Gui, 1:Font, % "s" . f_intFontSize
GuiControl, Font, f_strClipboardEditor
Gui, 1:Font

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiSaveEditor:
;------------------------------------------------------------
Gui, Submit, NoHide

Gosub, DisableSaveAndCancel

if (A_ThisLabel = "GuiSaveEditor")
	Clipboard := f_strClipboardEditor
else
	Gosub, UpdateEditorWithClipboard

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiSize:
;------------------------------------------------------------

if (A_EventInfo = 1)  ; The window has been minimized.  No action needed.
    return

intEditorH := A_GuiHeight - (g_saGuiControls[1].Y + 80)
g_intEditorW := A_GuiWidth - 40

; space before, between and after save/reload/close buttons
; = (A_GuiWidth - left margin - right margin - (2 buttons width)) // 3 (left, between 2 buttons, right)
intButtonSpacing := (A_GuiWidth - 120 - 120 - (140 + 100)) // 3

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
	else if (aaGuiControl.Name = "f_btnGuiCloseCancel")
		intX := 80 + (2 * intButtonSpacing) + 140 ; 140 for 1st button

	GuiControl, % "1:Move" . (aaGuiControl.Draw ? "Draw" : ""), % aaGuiControl.Name, % "x" . intX .  " y" . intY
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
	; Name=Type|Category|Notes|param1|param2|...
	; example:
	; Lower case=ChangeCase|Example|My notes|.*|$L0
	
	g_aaRulesByName := Object() ; reset list of rules by name
	g_saRulesOrder := Object()
	
	strRules := o_Settings.ReadIniSection("Rules")
	Loop, Parse, strRules, `n
	{
		intEqualSign := InStr(A_LoopField, "=")
		strRuleName := SubStr(A_LoopField, 1, intEqualSign - 1)
		saRuleValues := StrSplit(SubStr(A_LoopField, intEqualSign + 1), "|")
		loop, % saRuleValues.Length()
			if (saRuleValues[1] = "AutoHotkey")
				saRuleValues[A_Index] := DecodeAutoHokeyCodeFromIni(saRuleValues[A_Index])
			else
				saRuleValues[A_Index] := DecodeFromIni(saRuleValues[A_Index])
		new Rule(strRuleName, saRuleValues)
	}
	
	strRules := ""
	saRule := ""
	intEqualSign := ""
	strRuleName := ""
}

return
;------------------------------------------------------------


;========================================================================================================================
; END !_020_GUI:
;========================================================================================================================


;========================================================================================================================
!_030_ADD_EDIT_REMOVE_RULE:
;========================================================================================================================

;------------------------------------------------------------
GuiAddRuleSelectType:
;------------------------------------------------------------

Gui, 2:New, +Hwndg_strGui2Hwnd, % L(o_L["DialogAddRuleSelectTitle"], g_strAppNameText)
Gui, 2:+Owner1
Gui, 2:+OwnDialogs

Gui, 2:Add, Text, x10 y+20, % o_L["DialogAddRuleSelectPrompt"] . ":"

for intOrder, aaRuleType in g_saRuleTypesOrder
	Gui, 2:Add, Radio, % (A_Index = 1 ? "y+20 section" : "y+10") . " x10 w120 vf_intRadioRuleType" . A_Index . " gGuiAddRuleSelectTypeRadioButtonChanged", % aaRuleType.strTypeLabel

Gui, 2:Add, Button, x20 y+20 vf_btnAddRuleSelectTypeContinue gGuiAddRuleSelectTypeContinue default, % o_L["DialogContinue"]
Gui, 2:Add, Button, yp vf_btnAddRuleSelectTypeCancel gGuiAddRuleCancel, % o_L["GuiCancel"]
Gui, Add, Text
Gui, 2:Add, Link, x140 ys vf_lblAddRuleTypeHelp w360 h140, % L(o_L["DialogRuleSelectType"], o_L["DialogContinue"])

GuiCenterButtons(g_strGui2Hwnd, 10, 5, 20, , , "f_btnAddRuleSelectTypeContinue", "f_btnAddRuleSelectTypeCancel")

Gosub, ShowGui2AndDisableGui1

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiAddRuleCancel:
;------------------------------------------------------------

Gosub, 2GuiClose

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiAddRuleSelectTypeRadioButtonChanged:
;------------------------------------------------------------
Gui, 2:Submit, NoHide

g_intAddRuleType := StrReplace(A_GuiControl, "f_intRadioRuleType")
GuiControl, , f_lblAddRuleTypeHelp, % g_saRuleTypesOrder[g_intAddRuleType].strTypeHelp

if (A_GuiEvent = "DoubleClick")
	Gosub, GuiAddRuleSelectTypeContinue


return
;------------------------------------------------------------


;------------------------------------------------------------
GuiAddRuleSelectTypeContinue:
;------------------------------------------------------------
Gui, 2:Submit, NoHide

if !(g_intAddRuleType)
{
	Oops(2, o_L["DialogRuleSelectType"], o_L["DialogContinue"])
	return
}

Gosub, GuiRuleAdd

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiRuleAdd:
GuiRuleEdit:
GuiRuleCopy:
;------------------------------------------------------------
Gui, 1:Submit, NoHide
strAction := StrReplace(A_ThisLabel, "GuiRule")

if (strAction = "Add")
	Gosub, 2GuiClose ; to avoid flashing Gui 1:

Gui, 1:ListView, f_lvRulesAvailable
if !GetLVPosition(intPosition, (strAction <> "Add" ? o_L["GuiSelectRuleEdit"] : "")) ; no error message if adding
	and (strAction = "Edit")
	return
else
	LV_GetText(strName, intPosition, 1)

; set aaEditedRule
if (strAction = "Add")
	aaEditedRule := new Rule("", [g_saRuleTypesOrder[g_intAddRuleType].strTypeCode, "", ""]) ; __New(strName := "", saRuleValues := "")
else if (strAction = "Edit")
	aaEditedRule := g_aaRulesByName[strName]
else ; Copy
	aaEditedRule := g_aaRulesByName[strName].CopyRule()

strGuiTitle := L(o_L["DialogAddEditRuleTitle"]
	, (strAction = "Add" ? o_L["DialogEdit"] : (strAction = "Copy" ? o_L["DialogCopy"] : o_L["DialogAdd"]))
	, g_strAppNameText, g_strAppVersion, aaEditedRule.strTypeLabel)
; Gui, 2:New, +Resize -MaximizeBox +MinSize570x555 +MaxSizex555 +Hwndg_strGui2Hwnd, %strGuiTitle%
Gui, 2:New, +Resize -MaximizeBox +Hwndg_strGui2Hwnd, %strGuiTitle%
Gui, 2:+Owner1
Gui, 2:+OwnDialogs

Gui, 2:Add, Text, w400, % o_L["DialogRuleName"]
Gui, 2:Add, Edit, w400 vf_strName, % aaEditedRule.strName
Gui, 2:Add, Text, w400, % o_L["DialogRuleCategory"]
Gui, 2:Add, Edit, w400 vf_strCategory, % aaEditedRule.strCategory
Gui, 2:Add, Text, w400, % o_L["DialogRuleNotes"]
Gui, 2:Add, Edit, w400 vf_strNotes, % aaEditedRule.strNotes

Gui, 2:Font, w600
Gui, 2:Add, Text, y+10 w400, % aaEditedRule.strTypeLabel
Gui, 2:Font
Gui, 2:Add, Link, % "y+2 w" . (aaEditedRule.strTypeCode = "AutoHotkey" ? 900 : 400), % aaEditedRule.strTypeHelp

if (aaEditedRule.strTypeCode = "ChangeCase")
	
	loop, 3
		Gui, 2:Add, Radio, % (A_Index = 1 ? "vf_varValue1 " : "") . ((aaEditedRule.intCaseType = A_Index or aaEditedRule.intCaseType = "" and A_Index = 1) ? " checked" : ""), % o_L["DialogCaseType" . A_Index]
	
else if (aaEditedRule.strTypeCode = "ConvertFormat")

	Gui, 2:Add, Radio, % "vf_varValue1" . ((aaEditedRule.intConvertFormat = 1 or aaEditedRule.intConvertFormat = "") ? " Checked" : ""), % o_L["DialogConvertFormatText"]

else if (aaEditedRule.strTypeCode = "Replace")
{
	Gui, 2:Add, Text, y+5, % o_L["DialogFind"]
	Gui, 2:Add, Edit, vf_varValue1 w400, % aaEditedRule.strFind ; aaEditedRule.saVarValues[4]
	Gui, 2:Add, Text, , % o_L["DialogReplaceWith"]
	Gui, 2:Add, Edit, vf_varValue2 w400, % aaEditedRule.strReplace ; aaEditedRule.saVarValues[5]

	Gui, 2:Add, Checkbox, % "vf_varValue3 " . (aaEditedRule.blnReplaceWholeWord ? " Checked" : ""), % o_L["DialogReplaceWholeWord"]
	Gui, 2:Add, Checkbox, % "vf_varValue4 " . (aaEditedRule.blnReplaceCaseSensitive ? " Checked" : ""), % o_L["DialogReplaceCaseSensitive"]
}
else if (aaEditedRule.strTypeCode = "AutoHotkey")
{
	Gui, 2:Font, s12, Courier New
	Gui, 2:Add, Edit, w900 r12 Multi t20 WantReturn vf_varValue1, % aaEditedRule.strCode ; aaEditedRule.saVarValues[4]
	Gui, 2:Font
}
else if (aaEditedRule.strTypeCode = "SubStr")
{
	Gui, 2:Add, Radio, % "vf_blnRadioSubStrFromStart gGuiEditRuleSubStrTypeChanged"
		. ((aaEditedRule.intSubStrFromType = 1 or aaEditedRule.intSubStrFromType = "") ? " Checked" : ""), % o_L["DialogSubStrFromStart"]
	Gui, 2:Add, Radio, % "Section vf_blnRadioSubStrFromPosition gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrFromType = 2 ? " Checked" : ""), % o_L["DialogSubStrFromPosition"]
	Gui, 2:Add, Radio, % "vf_blnRadioSubStrFromBeginText gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrFromType = 3 ? " Checked" : ""), % o_L["DialogSubStrFromBeginText"]
	Gui, 2:Add, Radio, % "vf_blnRadioSubStrFromEndText gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrFromType = 4 ? " Checked" : ""), % o_L["DialogSubStrFromEndText"]
	GuiControlGet, arrWidth1, Pos, f_blnRadioSubStrFromPosition
	GuiControlGet, arrWidth2, Pos, f_blnRadioSubStrFromBeginText
	GuiControlGet, arrWidth3, Pos, f_blnRadioSubStrFromEndText
	Gui, 2:Add, Edit, % "x" . arrWidth1w + 15 . " ys-5 w40 Number Center vf_intRadioSubStrFromPosition disabled"
		, % aaEditedRule.intSubStrFromPosition
	Gui, 2:Add, Text, yp x+5 vf_lblRadioSubStrFromPosition disabled, % o_L["DialogSubStrCharacters"]
	Gui, 2:Add, Edit, % "x" . (arrWidth2w > arrWidth3w ? arrWidth2w : arrWidth3w) + 15 . " ys+25 w150 vf_strRadioSubStrFromText disabled"
		, % aaEditedRule.strSubStrFromText
	Gui, 2:Add, Text, x+10 yp+3, +/-
	Gui, 2:Add, Edit, x+5 yp-3 w40 vf_intSubStrFromPlusMinus disabled
	Gui, 2:Add, UpDown, vf_intSubStrFromUpDown Range-9999-9999, % aaEditedRule.intSubStrFromPlusMinus
		
	Gui, 2:Add, Radio, % "x10 y+25 w140 vf_blnRadioSubStrToEnd gGuiEditRuleSubStrTypeChanged"
		. ((aaEditedRule.intSubStrToType = 1 or aaEditedRule.intSubStrToType = "") ? " Checked" : ""), % o_L["DialogSubStrToEnd"] ; aaEditedRule.saVarValues[6]
	Gui, 2:Add, Radio, % "Section vf_blnRadioSubStrLength gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrToType = 2 ? " Checked" : ""), % o_L["DialogSubStrLength"] ; aaEditedRule.saVarValues[6]
	Gui, 2:Add, Radio, % "vf_blnRadioSubStrToBeforeEnd gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrToType = 3 ? " Checked" : ""), % o_L["DialogSubStrToBeforeEnd"] ; aaEditedRule.saVarValues[6]
	Gui, 2:Add, Radio, % "vf_blnRadioSubStrToBeginText gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrToType = 4 ? " Checked" : ""), % o_L["DialogSubStrToBeginText"] ; aaEditedRule.intSubStrToType
	Gui, 2:Add, Radio, % "vf_blnRadioSubStrToEndText gGuiEditRuleSubStrTypeChanged"
		. (aaEditedRule.intSubStrToType = 5 ? " Checked" : ""), % o_L["DialogSubStrToEndText"] ; aaEditedRule.saVarValues[4]
	GuiControlGet, arrWidth1, Pos, f_blnRadioSubStrLength
	GuiControlGet, arrWidth2, Pos, f_blnRadioSubStrToBeforeEnd
	GuiControlGet, arrWidth3, Pos, f_blnRadioSubStrToBeginText
	GuiControlGet, arrWidth4, Pos, f_blnRadioSubStrToEndText
	Gui, 2:Add, Edit, % "x" . (arrWidth1w > arrWidth2w ? arrWidth1w : arrWidth2w) + 15 . " ys+5 w40 Number Center vf_intSubStrCharacters disabled"
		, % Abs(aaEditedRule.intSubStrToLength) ; stored as positive or negative
	Gui, 2:Add, Text, yp x+5 vf_lblSubStrCharacters disabled, % o_L["DialogSubStrCharacters"]
	Gui, 2:Add, Edit, % "x" . (arrWidth3w > arrWidth4w ? arrWidth3w : arrWidth4w) + 15 . " ys+45 w150 vf_strRadioSubStrToText disabled"
		, % aaEditedRule.strSubStrToText
	Gui, 2:Add, Text, x+10 yp+3, +/-
	Gui, 2:Add, Edit, x+5 yp-3 w40 vf_intSubStrToPlusMinus disabled
	Gui, 2:Add, UpDown, vf_intSubStrToUpDown Range-9999-9999, % aaEditedRule.intSubStrToPlusMinus
	
	Gosub, GuiEditRuleSubStrTypeChanged
}
else if InStr("Prefix Suffix", aaEditedRule.strTypeCode)
{
	Gui, 2:Add, Text, y+5 w400, % o_L["DialogTextToAdd"]
	Gui, 2:Add, Edit, w400 vf_varValue1, % aaEditedRule.saVarValues[1] ; aaEditedRule.strPrefix or aaEditedRule.strSuffix
}

if (aaEditedRule.strTypeCode = "SubStr")
{
	Gui, 2:Add, CheckBox, x10 y+25 w400 vf_blnSubStrRepeat, % o_L["DialogRepeatOnEachLine"]
	GuiControl, , f_blnSubStrRepeat, % (aaEditedRule.blnSubStrRepeat = true)
}
else if InStr("Prefix Suffix", aaEditedRule.strTypeCode)
{
	Gui, 2:Add, CheckBox, x10 y+10 w400 vf_varValue2, % o_L["DialogRepeatOnEachLine"]
	GuiControl, , f_varValue2, % (aaEditedRule.saVarValues[2] = true)
}

Gui, 2:Add, Button, y+20 vf_btnSave gGuiRuleSave, % o_L["GuiSave"]
Gui, 2:Add, Button, yp vf_btnCancel g2GuiClose, % o_L["GuiCancel"]
GuiCenterButtons(g_strGui2Hwnd, , , , , , "f_btnSave", "f_btnCancel")
Gui, 2:Add, Text, yp+20

Gosub, ShowGui2AndDisableGui1

intPosition := ""
strName := ""
arrWidth1 := ""
arrWidth2 := ""
arrWidth3 := ""
arrWidth4 := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiEditRuleSubStrTypeChanged:
;------------------------------------------------------------
Gui, 2:Submit, NoHide

GuiControl, % (f_blnRadioSubStrFromPosition ? "Enable" : "Disable"), f_intRadioSubStrFromPosition
GuiControl, % (f_blnRadioSubStrFromPosition ? "Enable" : "Disable"), f_lblRadioSubStrFromPosition
GuiControl, % (f_blnRadioSubStrFromBeginText or f_blnRadioSubStrFromEndText ? "Enable" : "Disable"), f_strRadioSubStrFromText
GuiControl, % (f_blnRadioSubStrFromBeginText or f_blnRadioSubStrFromEndText ? "Enable" : "Disable"), f_intSubStrFromPlusMinus
GuiControl, % (f_blnRadioSubStrFromBeginText or f_blnRadioSubStrFromEndText ? "Enable" : "Disable"), f_intFromUpDown

GuiControl, % (f_blnRadioSubStrLength or f_blnRadioSubStrToBeforeEnd ?  "Enable" : "Disable"), f_intSubStrCharacters
GuiControl, % (f_blnRadioSubStrLength or f_blnRadioSubStrToBeforeEnd ?  "Enable" : "Disable"), f_lblSubStrCharacters
GuiControl, % (f_blnRadioSubStrToBeginText or f_blnRadioSubStrToEndText ? "Enable" : "Disable"), f_strRadioSubStrToText
GuiControl, % (f_blnRadioSubStrToBeginText or f_blnRadioSubStrToEndText ? "Enable" : "Disable"), f_intSubStrToPlusMinus
GuiControl, % (f_blnRadioSubStrToBeginText or f_blnRadioSubStrToEndText ? "Enable" : "Disable"), f_intToUpDown

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiRuleSave:
;------------------------------------------------------------
Gui, 2:Submit, NoHide

if InStr(f_strName, "=")
{
	Oops(2, o_L["OopsNoEqualInRuleNames"])
	return
}

strOriginalName := aaEditedRule.strName

aaEditedRule.strName := f_strName
aaEditedRule.strCategory := f_strCategory
aaEditedRule.strNotes := f_strNotes


if !StrLen(f_strName) or (InStr("Replace AutoHotkey Prefix Suffix", aaEditedRule.strTypeCode) and !StrLen(f_varValue1))
{
	Oops(2, o_L["OopsValueMissing"])
	return
}

saValues := Object()
if (aaEditedRule.strTypeCode = "SubStr")
{
	if (f_blnRadioSubStrFromPosition and !StrLen(f_intRadioSubStrFromPosition))
		or ((f_blnRadioSubStrLength or f_blnRadioSubStrToBeforeEnd) and !StrLen(f_intSubStrCharacters))
		or ((f_blnRadioSubStrFromBeginText or f_blnRadioSubStrFromEndText) and !StrLen(f_strRadioSubStrFromText))
		or ((f_blnRadioSubStrToBeginText or f_blnRadioSubStrToEndText) and !StrLen(f_strRadioSubStrToText))
	{
		Oops(2, o_L["OopsValueMissing"])
		return
	}
	
	; int, type of "from" value, intSubStrFromType
	if (f_blnRadioSubStrFromStart)
		saValues[1] := 1
	else if (f_blnRadioSubStrFromPosition)
		saValues[1] := 2
	else if (f_blnRadioSubStrFromBeginText)
		saValues[1] := 3
	else if (f_blnRadioSubStrFromEndText)
		saValues[1] := 4
	saValues[2] := (f_intRadioSubStrFromPosition ? f_intRadioSubStrFromPosition : "") ; intSubStrFromPosition, if from f_blnRadioSubStrFromPosition is true
	saValues[3] := f_strRadioSubStrFromText ; strSubStrFromText, if from f_blnRadioSubStrFromBeginText or f_blnRadioSubStrFromEndText is true
	saValues[4] := f_intSubStrFromPlusMinus ; intSubStrFromPlusMinus, if from f_blnRadioSubStrFromBeginText or f_blnRadioSubStrFromEndText is true

	; int, type of "to" value, intSubStrToType
	if (f_blnRadioSubStrToEnd)
		saValues[5] := 1
	else if (f_blnRadioSubStrLength)
		saValues[5] := 2
	else if (f_blnRadioSubStrToBeforeEnd)
		saValues[5] := 3
	else if (f_blnRadioSubStrToBeginText)
		saValues[5] := 4
	else if (f_blnRadioSubStrToEndText)
		saValues[5] := 5
	saValues[6] := (f_blnRadioSubStrLength ? f_intSubStrCharacters : (f_blnRadioSubStrToBeforeEnd ? -f_intSubStrCharacters : "")) ; intSubStrToLength, positive if length from FromPosition or negative if length from end
	saValues[7] := f_strRadioSubStrToText ; strSubStrToText, if from f_blnRadioSubStrToBeginText or f_blnRadioSubStrToEndText is true
	saValues[8] := f_intSubStrToPlusMinus ; intSubStrToPlusMinus, if from f_blnRadioSubStrToBeginText or f_blnRadioSubStrToEndText is true

	saValues[9] := f_blnSubStrRepeat ; blnSubStrRepeat, execute rule on each line of the Clipboard
}
else if (aaEditedRule.strTypeCode = "AutoHotkey")
	
	saValues[1] := EncodeAutoHokeyCodeForIni(f_varValue1)

else
	Loop, 9
		saValues.Push(EncodeForIni(f_varValue%A_Index%))

if (strAction <> "Edit" and g_aaRulesByName.HasKey(f_strName)) ; when adding or copying
{
	Oops(2, o_L["OopsNameExists"], f_strName)
	return
}

Gosub, BackupRulesToIni
aaEditedRule.SaveRuleToIni(saValues)

if (strAction = "Edit" and strOriginalName <> aaEditedRule.strName)
	IniDelete, % o_Settings.strIniFile, Rules, %strOriginalName%

loop, 9 ; delete form values because Gui:Destroy does not
	GuiControl, , f_varValue%A_Index%
Gosub, 2GuiClose

Gui, 1:Default
Gosub, LoadRulesFromIni ; reload rules
Gosub, BuildRulesMenu ; rebuild rules menu
Gosub, GuiLoadRulesAvailable ; update Available rules listview
Gosub, LaunchQACrules ; relaunch QACrules

strOriginalName := ""
saValues := ""
strAction := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiRuleRemove:
;------------------------------------------------------------

Gui, 1:ListView, f_lvRulesAvailable

if !GetLVPosition(intPosition, o_L["GuiSelectRuleRemove"])
	return

LV_GetText(strName, intPosition, 1)

MsgBox, 52, % o_L["MenuRuleRemove"] . " - " . g_strAppNameText, % L(o_L["DialogRuleRemove"], strName)
IfMsgBox, No
	return

Gosub, BackupRulesToIni
g_aaRulesByName[strName].DeleteRule()
LV_Delete(intPosition)

strName := ""

return
;------------------------------------------------------------


;------------------------------------------------------------
BackupRulesToIni:
;------------------------------------------------------------

o_Settings.WriteIniSection(o_Settings.ReadIniSection("Rules"), "Rules-backup")
GuiControl, 1:Enable, f_btnRuleUndo
Menu, menuBarRule, Enable, % o_L["MenuRuleUndo"]

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiRuleUndo:
;------------------------------------------------------------

MsgBox, 52, % o_L["MenuRuleUndo"] . " - " . g_strAppNameText, % o_L["DialogRuleUndo"]
IfMsgBox, No
	return

o_Settings.WriteIniSection(o_Settings.ReadIniSection("Rules-backup"), "Rules")
o_Settings.DeleteIniSection("Rules-backup")

Gosub, LoadRulesFromIni
Gosub, GuiLoadRulesAvailable
GuiControl, 1:Disable, f_btnRuleUndo
Menu, menuBarRule, Disable, % o_L["MenuRuleUndo"]

return
;------------------------------------------------------------


;------------------------------------------------------------
ShowGui2AndDisableGui1:
;------------------------------------------------------------
Gui, 2:Submit, NoHide

CalculateTopGuiPosition(g_strGui2Hwnd, g_strGui1Hwnd, intX, intY)
Gui, 2:Show, AutoSize x%intX% y%intY%

Gui, 1:+Disabled
if (f_blnAlwaysOnTop)
	WinSet, AlwaysOnTop, Off, % QACGuiTitle()

intX := ""
intY := ""

return
;------------------------------------------------------------


;========================================================================================================================
; END !_030_ADD_EDIT_REMOVE_RULE:
;========================================================================================================================


;========================================================================================================================
!_035_CHECK_UPDATE:
;========================================================================================================================

;------------------------------------------------------------
GuiCheck4Update:
;------------------------------------------------------------
; !! adapt

strChangeLog := Url2Var("https://clipboard.quickaccesspopup.com/changelog/changelog" . (g_strUpdateProdOrBeta <> "prod" ? "-" . g_strUpdateProdOrBeta : "") . ".txt")

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

GuiCenterButtons(g_strGui3Hwnd, 10, 5, 20, , , "f_btnCheck4UpdateDialogChangeLog", "f_btnCheck4UpdateDialogVisit")

if (g_strUpdateProdOrBeta = "prod")
{
	if (g_blnPortableMode)
		Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogDownload gButtonCheck4UpdateDialogDownloadPortable, % o_L["UpdateButtonDownloadPortable"]
	else
		Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogDownload gButtonCheck4UpdateDialogDownloadSetup, % o_L["UpdateButtonDownloadSetup"]

	GuiCenterButtons(g_strGui3Hwnd, 10, 5, 20, , , "f_btnCheck4UpdateDialogDownload")
}

Gui, Update:Add, Button, y+20 x10 vf_btnCheck4UpdateDialogSkipVersion gButtonCheck4UpdateDialogSkipVersion, % o_L["UpdateButtonSkipVersion"]
Gui, Update:Add, Button, yp x+20 vf_btnCheck4UpdateDialogRemind gButtonCheck4UpdateDialogRemind, % o_L["UpdateButtonRemind"]
Gui, Update:Add, Text

GuiCenterButtons(g_strGui3Hwnd, 10, 5, 20, , , "f_btnCheck4UpdateDialogSkipVersion", "f_btnCheck4UpdateDialogRemind")

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

strUrlChangeLog := AddUtm2Url("https://clipboard.quickaccesspopup.com/change-log" . (g_strUpdateProdOrBeta <> "prod" ? "-" . g_strUpdateProdOrBeta . "-version" : "") . "/", A_ThisLabel, "Check4Update")
strUrlDownloadSetup := AddUtm2Url("https://clipboard.quickaccesspopup.com/latest/check4update-download-setup-redirect.html", A_ThisLabel, "Check4Update") ; prod only
strUrlDownloadPortable:= AddUtm2Url("https://clipboard.quickaccesspopup.com/latest/check4update-download-portable-redirect.html", A_ThisLabel, "Check4Update") ; prod only
strUrlAppLandingPageBeta := AddUtm2Url("https://forum.quickaccesspopup.com/forumdisplay.php?fid=28", A_ThisLabel, "Check4Update")

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
; END !_035_CHECK_UPDATE:
;========================================================================================================================


;========================================================================================================================
!_040_EXIT:
;========================================================================================================================

;-----------------------------------------------------------
CleanUpBeforeExit:
;-----------------------------------------------------------
Gui, 1:Submit, NoHide

; kill QACrules.exe
if QACrulesExists()
{
	Process, Close, QACrules.exe
	ToolTip, % L(o_L["RulesRemoved"], g_strAppNameText)
	Sleep, 1000
}

if (o_Settings.Launch.blnDiagMode.IniValue)
	Run, %g_strDiagFile%

DllCall("LockWindowUpdate", Uint, g_strGui1Hwnd) ; lock QAP window while restoring window
if FileExist(o_Settings.strIniFile) ; in case user deleted the ini file to create a fresh one, this avoids creating an ini file with just this value
{
	o_Settings.EditorWindow.blnFixedFont.WriteIni(o_Settings.EditorWindow.blnFixedFont.IniValue)
	o_Settings.EditorWindow.intFontSize.WriteIni(o_Settings.EditorWindow.intFontSize.IniValue)
	o_Settings.EditorWindow.blnAlwaysOnTop.WriteIni(o_Settings.EditorWindow.blnAlwaysOnTop.IniValue)
	o_Settings.EditorWindow.blnUseTab.WriteIni(o_Settings.EditorWindow.blnUseTab.IniValue)

	SaveWindowPosition("EditorPosition", "ahk_id " . g_strGui1Hwnd)
	IniWrite, % GetScreenConfiguration(), % o_Settings.strIniFile, Internal, LastScreenConfiguration
}
DllCall("LockWindowUpdate", Uint, 0)  ; 0 to unlock the window

FileRemoveDir, %g_strTempDir%, 1 ; Remove all files and subdirectories

ExitApp
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
; END !_040_EXIT:
;========================================================================================================================


;========================================================================================================================
!_050_GUI_CLOSE-CANCEL-BK_OBJECTS:
;========================================================================================================================

;------------------------------------------------------------
GuiEscape:
;------------------------------------------------------------

GoSub, GuiCloseCancelFromGuiEscape

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiClose:
;------------------------------------------------------------

GoSub, GuiCloseCancelFromGuiClose

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiCloseCancel:
GuiCloseCancelFromGuiEscape:
GuiCloseCancelFromGuiClose:
GuiCloseCancelAndExitApp:
;------------------------------------------------------------
Gui, Submit, NoHide

if (A_ThisLabel = "GuiCloseCancelAndExitApp")
	ExitApp
; else continue

blnShiftPressed := GetKeyState("Shift")

if (!blnShiftPressed and (EditorUnsaved() or RulesNotApplied()))
{
	Gui, 1:+OwnDialogs
	MsgBox, 36, % L(o_L["DialogCancelTitle"], g_strAppNameText, g_strAppVersion)
		, % (EditorUnsaved() ? o_L["DialogCancelPromptClipboard"] : "")
		. (EditorUnsaved() and RulesNotApplied() ? "`n" : "")
		. (RulesNotApplied() ?  o_L["DialogCancelPromptRules"] : "")
	IfMsgBox, No
		return
}

if (blnShiftPressed and RulesNotApplied())
{
	Gui, 1:ListView, f_lvRulesSelected
	LV_Delete() ; delete all rows
	for intIndex, strName in g_saRulesBackupSelectedOrder
		g_aaRulesByName[strName].ListViewAdd("f_lvRulesSelected")
	
	Gui, 1:ListView, f_lvRulesAvailable
	LV_Delete() ; delete all rows
	for strName, aaRule in g_aaRulesByName
		if !g_saRulesBackupSelectedByName.HasKey(strName)
			aaRule.ListViewAdd("f_lvRulesAvailable") 
	
	g_saRulesBackupSelectedOrder := ""
	g_saRulesBackupSelectedByName := ""
	intIndex := ""
	strName := ""
}

Gosub, DisableSaveAndCancel
Gosub, DisableApplyRulesAndCancel

if !(blnShiftPressed)
	Gui, 1:Cancel ; hide the window

return
;------------------------------------------------------------


;------------------------------------------------------------
EnableSaveAndCancel:
DisableSaveAndCancel:
;------------------------------------------------------------

GuiControl, % (A_ThisLabel = "EnableSaveAndCancel" ? "1:Enable" : "1:Disable"), f_btnGuiSaveEditor
GuiControl, 1:, f_btnGuiCloseCancel, % (A_ThisLabel = "EnableSaveAndCancel" ? o_L["GuiCancel"] : o_L["GuiClose"])

Menu, menuBarFile, % (A_ThisLabel = "EnableSaveAndCancel" ? "Enable" : "Disable"), % o_L["GuiSaveEditor"] . "`tCtrl+S"

if (A_ThisLabel = "DisableSaveAndCancel")
	Gosub, EnableClipboardChangesInEditor
else
	Gosub, DisableClipboardChangesInEditor

return
;------------------------------------------------------------


;------------------------------------------------------------
EnableApplyRulesAndCancel:
DisableApplyRulesAndCancel:
;------------------------------------------------------------

GuiControl, % (A_ThisLabel = "EnableApplyRulesAndCancel" ? "1:Enable" : "1:Disable"), f_btnGuiApplyRules
GuiControl, 1:, f_btnGuiCloseCancel, % (A_ThisLabel = "EnableApplyRulesAndCancel" ? o_L["GuiCancel"] : o_L["GuiClose"])

return
;------------------------------------------------------------


;------------------------------------------------------------
2GuiClose:
2GuiEscape:
;------------------------------------------------------------
Gui, 2:Submit, NoHide

Gui, 1:-Disabled
Gui, 2:Destroy
if (WinExist("A") <> g_strGui1Hwnd)
	WinActivate, ahk_id %g_strGui1Hwnd%

if (f_blnAlwaysOnTop)
	WinSet, AlwaysOnTop, On, % QACGuiTitle()

return
;------------------------------------------------------------


;========================================================================================================================
; END !_050_GUI_CLOSE-CANCEL-BK_OBJECTS:
;========================================================================================================================


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

Gosub, UpdateEditorWithClipboardFromGuiShow
Gosub, DisableSaveAndCancel

; if gui already visible, just activate the window
DetectHiddenWindows, Off ; to detect the gui window only if it is visible (not hidden)
blnExist := WinExist("ahk_id " . g_strGui1Hwnd)
DetectHiddenWindows, On ; revert to app default
if (blnExist) ; keep the gui as-is if it is not closed
{
	WinActivate, ahk_id %g_strGui1Hwnd%
	return
}
; else continue

GetPositionFromMouseOrKeyboard(g_strMenuTriggerLabel, A_ThisHotkey, intActiveX, intActiveY)
if (o_Settings.EditorWindow.blnOpenEditorOnActiveMonitor.IniValue
	and GetWindowPositionOnActiveMonitor("ahk_id " . g_strGui1Hwnd, intActiveX, intActiveY, intPositionX, intPositionY))
	; display at center of active monitor
	Gui, 1:Show, % "x" . intPositionX . " y" . intPositionY
else ; keep existing position
	Gui, 1:Show

return
;------------------------------------------------------------


;------------------------------------------------------------
BackupSelectedRules:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

g_saRulesBackupSelectedOrder := Object()
g_saRulesBackupSelectedByName := Object()

Gui, 1:ListView, f_lvRulesSelected
loop, % LV_GetCount()
{
	LV_GetText(strName, A_Index, 1)
	g_saRulesBackupSelectedOrder.Push(strName)
	g_saRulesBackupSelectedByName[strName] := "foo"
}
return
;------------------------------------------------------------


;------------------------------------------------------------
UpdateEditorWithClipboard:
UpdateEditorWithClipboardFromGuiShow:
;------------------------------------------------------------

strContent := o_L["GuiClipboard"] . ": "
if (A_ThisLabel = "UpdateEditorWithClipboardFromGuiShow" and !StrLen(Clipboard))
	strContent .= o_L["GuiEmptyOrBinary"] ; we can't tell which one it is
else if (g_intClipboardContentType = 2)
	strContent .= o_L["GuiBinary"]
else if (g_intClipboardContentType = 0)
	strContent .= o_L["GuiEmpty"]
else ; Clipboard contains text (g_intClipboardContentType = 1 or StrLen(Clipboard))
	strContent .= (StrLen(Clipboard) = 1 ? o_L["GuiOneCharacter"] : L(o_L["GuiCharacters"], StrLen(Clipboard)))

g_strCliboardBackup := ClipboardAll ; not used...
GuiControl, , f_strClipboardEditor, %Clipboard%
SB_SetText(strContent, 1)

strContent := ""

return
;------------------------------------------------------------


;========================================================================================================================
; END !_060_POPUP:
;========================================================================================================================


;========================================================================================================================
!_065_GUI_CHANGE_HOTKEY:
return
;========================================================================================================================

;------------------------------------------------------------
GuiSelectHotkeyMouse:
GuiSelectHotkeyKeyboard:
;------------------------------------------------------------
; SelectShortcut(P_strActualShortcut, P_strFavoriteName, P_strFavoriteType, P_strFavoriteLocation, P_intShortcutType, P_strDefaultShortcut := "", P_strDescription := "")
; P_intShortcutType: 1 Mouse, 2 Keyboard, 3 Mouse or Keyboard
; returns the new shortcut, "None" if no shortcut or empty string if cancel

o_PopupHotkeys.BackupPopupHotkeys()

if (A_thisLabel = "GuiSelectHotkeyMouse")	
	intHotkeyType := 1 ; Mouse
else ; GuiSelectHotkeyKeyboard
	intHotkeyType := 2 ; Keyboard

o_PopupHotkeys.SA[intHotkeyType].P_strAhkHotkey := SelectShortcut(o_PopupHotkeys.SA[intHotkeyType].P_strAhkHotkey
	, o_PopupHotkeys.SA[intHotkeyType].AA.strPopupHotkeyLocalizedName, intHotkeyType, o_PopupHotkeys.SA[intHotkeyType].AA.strPopupHotkeyDefault
	, o_PopupHotkeys.SA[intHotkeyType].AA.strPopupHotkeyLocalizedDescription)

o_Settings.MenuPopup["str" . o_PopupHotkeys.SA[intHotkeyType].AA.strPopupHotkeyInternalName].WriteIni(o_PopupHotkeys.SA[intHotkeyType].P_strAhkHotkey)
o_PopupHotkeys.EnablePopupHotkeys()

intHotkeyType := ""

return
;------------------------------------------------------------


; Gui in function, see from daniel2 http://www.autohotkey.com/board/topic/19880-help-making-gui-work-inside-a-function/#entry130557

;------------------------------------------------------------
SelectShortcut(P_strActualShortcut, P_strShortcutName, P_intShortcutType, P_strDefaultShortcut := "", P_strDescription := "")
; P_intShortcutType: 1 Mouse, 2 Keyboard, 3 Mouse or Keyboard
; returns the new shortcut, "None" if no shortcut or empty string if cancel
;------------------------------------------------------------
{
	; To create a global variable inside a function without knowing in advance what the variable's name is, the function must be assume-global. (Lexikos)
	; (https://autohotkey.com/board/topic/84822-error-when-creating-gui-with-global-var-as-a-name/#entry540615)
	; Use SS_ prefix in local variable names to avoid conflicts outside the function and empty these variable because the function will not do it.
	global

	SS_aaL := o_L.InsertAmpersand(false, "DialogOK", "GuiCancel", "DialogNone", "GuiResetDefault")
	
	g_blnChangeShortcutInProgress := true
	SS_strModifiersLabels := "Shift|Ctrl|Alt|Win"
	SS_saModifiersLabels := StrSplit(SS_strModifiersLabels, "|")
	SS_strModifiersSymbols := "+|^|!|#"
	SS_saModifiersSymbols := StrSplit(SS_strModifiersSymbols, "|")
	
	o_HotkeyActual := new Triggers.HotkeyParts(P_strActualShortcut) ; global

	SS_strGuiTitle := L(o_L["DialogChangeHotkeyTitle"], g_strAppNameText, g_strAppVersion)
	Gui, 2:New, +Hwndg_strGui2Hwnd, %SS_strGuiTitle%
	Gui, 2:Default
	Gui, +Owner1
	Gui, +OwnDialogs
	
	if (g_blnUseColors)
		Gui, Color, %g_strGuiWindowColor%
	Gui, Font, s10 w700, Verdana
	Gui, Add, Text, x10 y10 w400 center, % L(o_L["DialogChangeHotkeyTitle"], g_strAppNameText)
	Gui, Font

	Gui, Add, Text, y+15 x10, % o_L["DialogTriggerFor"]
	Gui, Font, s8 w700
	Gui, Add, Text, x+5 yp w300 section, % P_strShortcutName . (StrLen(P_strFavoriteType) ? " (" . P_strFavoriteType . ")" : "")
	Gui, Font
	if StrLen(P_strFavoriteLocation)
		Gui, Add, Text, xs y+5 w300, % P_strFavoriteLocation
	if StrLen(P_strDescription)
	{
		P_strDescription := StrReplace(P_strDescription, "<A>") ; remove links from description (already displayed in previous dialog box)
		P_strDescription := StrReplace(P_strDescription, "</A>")
		Gui, Add, Text, xs y+5 w300, %P_strDescription%
	}

	Loop, 4 ; for each modifier add a checkbox
	{
		SS_strModifiersLabel := SS_saModifiersLabels[A_Index]
		Gui, Add, CheckBox, % "y+" (SS_strModifiersLabel = "Shift" ? 20 : 10) . " x50 gModifierClicked vf_bln"
			. SS_saModifiersLabels[A_Index], % o_L["Dialog" . SS_strModifiersLabel . "Short"]
		if (SS_strModifiersLabel = "Shift")
			GuiControlGet, SS_arrTop, Pos, f_blnShift
	}

	if (P_intShortcutType = 1)
		Gui, Add, DropDownList, % "y" . SS_arrTopY . " x150 w200 vf_drpShortcutMouse gMouseChanged", % o_MouseButtons.GetDropDownList(o_HotkeyActual.strMouseButton)
	if (P_intShortcutType = 3)
	{
		Gui, Add, Text, % "y" . SS_arrTopY . " x150 w60", % o_L["DialogMouse"]
		Gui, Add, DropDownList, yp x+10 w200 vf_drpShortcutMouse gMouseChanged, % o_MouseButtons.GetDropDownList(o_HotkeyActual.strMouseButton)
		Gui, Add, Text, % "y" . SS_arrTopY + 20 . " x150", % o_L["DialogOr"]
	}
	if (P_intShortcutType <> 1)
	{
		Gui, Add, Text, % "y" . SS_arrTopY + (P_intShortcutType = 2 ? 0 : 40) . " x150 w60", % o_L["DialogKeyboard"]
		Gui, Add, Hotkey, yp x+10 w200 vf_strShortcutKey gShortcutChanged section
		GuiControl, , f_strShortcutKey, % o_HotkeyActual.strKey
	}
	if (P_intShortcutType <> 1)
		Gui, Add, Link, y+5 xs w200 gShortcutInvisibleKeysClicked, % L(o_L["DialogHotkeyInvisibleKeys"], "Space", "Tab", "Enter", "Esc", "Menu")

	Gui, Add, Button, % "x10 y" . SS_arrTopY + 100 . " vf_btnNoneShortcut gSelectNoneShortcutClicked", % SS_aaL["DialogNone"]
	if StrLen(P_strDefaultShortcut) and (P_strFavoriteType <> "Alternative")
	{
		Gui, Add, Button, % "x10 y" . SS_arrTopY + 100 . " vf_btnResetShortcut gButtonResetShortcut", % SS_aaL["GuiResetDefault"]
		GuiCenterButtons(g_strGui2Hwnd, 10, 5, 20, , , "f_btnNoneShortcut", "f_btnResetShortcut")
	}
	else
	{
		Gui, Add, Text, % "x10 y" . SS_arrTopY + 100
		GuiCenterButtons(g_strGui2Hwnd, 10, 5, 20, , , "f_btnNoneShortcut")
	}
	
	Gui, Add, Text, x10 y+25 w400, % o_L["DialogChangeHotkeyLeftAnyRight"]
	Loop, 4 ; create 4 groups of radio buttons for Right, Any or Left keys
	{
		SS_strModifiersLabel := SS_saModifiersLabels[A_Index]
		Gui, Add, Text, y+10 x10 w60 right, % o_L["Dialog" . SS_strModifiersLabel . "Short"]
		Gui, Font, w700
		Gui, Add, Text, yp x+10 w40 center, % chr(0x2192) ; right arrow
		Gui, Font
		Gui, Add, Radio, % "yp x+10 disabled vf_radLeft" . SS_saModifiersLabels[A_Index], % o_L["DialogChangeHotkeyLeft"]
		Gui, Add, Radio, % "yp x+10 disabled vf_radAny" . SS_saModifiersLabels[A_Index], % o_L["DialogChangeHotkeyAny"]
		Gui, Add, Radio, % "yp x+10 disabled vf_radRight" . SS_saModifiersLabels[A_Index], % o_L["DialogChangeHotkeyRight"]
	}
	Gosub, SetModifiersCheckBoxAndRadio ; set checkboxes and radio buttons according to o_HotkeyActual.strModifiers

	Gui, Add, Button, y+25 x10 vf_btnChangeShortcutOK gButtonChangeShortcutOK, % SS_aaL["DialogOK"]
	Gui, Add, Button, yp x+20 vf_btnChangeShortcutCancel gButtonChangeShortcutCancel, % SS_aaL["GuiCancel"]
	
	GuiCenterButtons(g_strGui2Hwnd, 10, 5, 20, , , "f_btnChangeShortcutOK", "f_btnChangeShortcutCancel")

	Gui, Add, Text
	GuiControl, Focus, f_btnChangeShortcutOK
	CalculateTopGuiPosition(g_strGui2Hwnd, g_strGui2Hwnd, SS_intX, SS_intY)
	Gui, Show, AutoSize x%SS_intX% y%SS_intY%

	Gui, 1:+Disabled
	WinWaitClose, %SS_strGuiTitle% ; waiting for Gui to close
	
	; Clean-up function global variables
	SS_saModifiersLabels := ""
	SS_saModifiersSymbols := ""
	SS_blnAlt := ""
	SS_blnCtrl := ""
	SS_blnShift := ""
	SS_blnThisLeft := ""
	SS_blnThisModifierOn := ""
	SS_blnThisRight := ""
	SS_blnWin := ""
	SS_intReverseIndex := ""
	SS_strHotkeyControl := ""
	SS_strHotkeyControlKey := ""
	SS_strHotkeyControlModifiers := ""
	SS_strKey := ""
	SS_strModifiersLabel := ""
	SS_strModifiersLabels := ""
	SS_strModifiersSymbols := ""
	SS_strMouse := ""
	SS_strMouseControl := ""
	SS_strMouseValue := ""
	SS_strThisLabel := ""
	SS_strThisSymbol := ""
	SS_intX := ""
	SS_intY := ""
	SS_strGuiTitle := ""
	SS_aaL := ""

	return SS_strNewShortcut ; returning value
	
	;------------------------------------------------------------

	;------------------------------------------------------------
	MouseChanged:
	;------------------------------------------------------------
	SS_strMouseControl := A_GuiControl ; hotkey var name
	GuiControlGet, SS_strMouseValue, , %SS_strMouseControl%

	if (SS_strMouseValue = o_L["DialogNone"]) ; this is the translated "None"
	{
		loop, 4 ; uncheck modifiers checkbox
			GuiControl, , % "f_bln" . SS_saModifiersLabels[A_Index], 0
		gosub, ModifierClicked
	}

	if (P_intShortcutType = 3) ; both keyboard and mouse options are available
		; we have a mouse button, empty the hotkey control
		GuiControl, , f_strShortcutKey, None

	return
	;------------------------------------------------------------
	
	;------------------------------------------------------------
	ShortcutChanged:
	;------------------------------------------------------------
	SS_strHotkeyControl := A_GuiControl ; hotkey var name
	SS_strHotkeyControl := %SS_strHotkeyControl% ; hotkey content

	if !StrLen(SS_strHotkeyControl)
		return

	o_HotkeyCheckModifiers := new Triggers.HotkeyParts(SS_strHotkeyControl) ; global

	if StrLen(o_HotkeyCheckModifiers.strModifiers) ; we have a modifier and we don't want it, reset keyboard to none and return
		GuiControl, , %A_GuiControl%, None
	else ; we have a valid key, empty the mouse dropdown and return
		GuiControl, Choose, f_drpShortcutMouse, 0
	
	o_HotkeyCheckModifiers := ""

	return
	;------------------------------------------------------------

	;------------------------------------------------------------
	SelectNoneShortcutClicked:
	;------------------------------------------------------------
	o_HotkeyActual.SplitParts("None")
	
	GuiControl, , f_strShortcutKey, % o_L["DialogNone"]
	GuiControl, Choose, f_drpShortcutMouse, % o_L["DialogNone"]
	Gosub, SetModifiersCheckBoxAndRadio ; set checkboxes and radio buttons according to o_HotkeyActual.strModifiers

	return
	;------------------------------------------------------------

	;------------------------------------------------------------
	ShortcutInvisibleKeysClicked:
	;------------------------------------------------------------
	if (ErrorLevel = "Space")
		GuiControl, , f_strShortcutKey, %A_Space%
	else if (ErrorLevel = "Tab")
		GuiControl, , f_strShortcutKey, %A_Tab%
	else if (ErrorLevel = "Enter")
		GuiControl, , f_strShortcutKey, Enter
	else if (ErrorLevel = "Esc")
		GuiControl, , f_strShortcutKey, Escape
	else ; Menu
		GuiControl, , f_strShortcutKey, AppsKey
	GuiControl, Choose, f_drpShortcutMouse, 0

	return
	;------------------------------------------------------------

	;------------------------------------------------------------
	ButtonResetShortcut:
	;------------------------------------------------------------
	o_HotkeyActual.SplitParts(P_strDefaultShortcut)
	
	GuiControl, , f_strShortcutKey, % o_HotkeyActual.strKey
	GuiControl, Choose, f_drpShortcutMouse, % o_MouseButtons.GetMouseButtonLocalized4InternalName(o_HotkeyActual.strMouseButton, false) ; not short
	Gosub, SetModifiersCheckBoxAndRadio ; set checkboxes and radio buttons according to o_HotkeyActual.strModifiers
	
	return
	;------------------------------------------------------------

	;------------------------------------------------------------
	SetModifiersCheckBoxAndRadio:
	;------------------------------------------------------------
	loop, 4 ; set modifiers checkboxes according to o_HotkeyActual.strModifiers
	{
		SS_strThisLabel := SS_saModifiersLabels[A_Index]
		SS_strThisSymbol := SS_saModifiersSymbols[A_Index]
		
		GuiControl, , % "f_bln" . SS_strThisLabel, % InStr(o_HotkeyActual.strModifiers, SS_strThisSymbol) > 0 ; > 0 required to make sure we have 0 or 1 value
		
		GuiControl, , f_radLeft%SS_strThisLabel%, % InStr(o_HotkeyActual.strModifiers, "<" . SS_strThisSymbol) > 0
		GuiControl, , f_radAny%SS_strThisLabel%, % !InStr(o_HotkeyActual.strModifiers, "<" . SS_strThisSymbol) and !InStr(P_strActualShortcut, ">" . SS_strThisSymbol)
		GuiControl, , f_radRight%SS_strThisLabel%, % InStr(o_HotkeyActual.strModifiers, ">" . SS_strThisSymbol) > 0
	}
	gosub, ModifierClicked
	
	return
	;------------------------------------------------------------

	;------------------------------------------------------------
	ModifierClicked:
	;------------------------------------------------------------
	Loop, 4 ; enable/disable modifiers radio buttons groups for each modifier
	{
		SS_strThisLabel := SS_saModifiersLabels[A_Index]
		SS_strThisSymbol := SS_saModifiersSymbols[A_Index]
		
		GuiControlGet, SS_blnThisModifierOn, , % "f_bln" . SS_saModifiersLabels[A_Index]
		GuiControl, Enable%SS_blnThisModifierOn%, f_radLeft%SS_strThisLabel%
		GuiControl, Enable%SS_blnThisModifierOn%, f_radAny%SS_strThisLabel%
		GuiControl, Enable%SS_blnThisModifierOn%, f_radRight%SS_strThisLabel%
	}
	return
	;------------------------------------------------------------
	
	;------------------------------------------------------------
	ButtonChangeShortcutOK:
	;------------------------------------------------------------
	GuiControlGet, SS_strMouse, , f_drpShortcutMouse
	GuiControlGet, SS_strKey, , f_strShortcutKey
	GuiControlGet, SS_blnWin , ,f_blnWin
	GuiControlGet, SS_blnAlt, , f_blnAlt
	GuiControlGet, SS_blnCtrl, , f_blnCtrl
	GuiControlGet, SS_blnShift, , f_blnShift

	if StrLen(SS_strMouse)
		SS_strMouse := o_MouseButtons.GetMouseButtonInternal4LocalizedName(SS_strMouse) ; get mouse button system name from dropdown localized text
	
	SS_strNewShortcut := Trim(SS_strKey . (SS_strMouse = "None" ? "" : SS_strMouse))
	if !StrLen(SS_strNewShortcut)
		SS_strNewShortcut := "None"
	
	if HasShortcut(SS_strNewShortcut)
		Loop, 4
		{
			SS_intReverseIndex := -(A_Index-5) ; reverse order of modifiers important to keep modifiers labels in correct order
			SS_strThisLabel := SS_saModifiersLabels[SS_intReverseIndex]
			SS_strThisSymbol := SS_saModifiersSymbols[SS_intReverseIndex]
			if (SS_bln%SS_strThisLabel%)
			{
				GuiControlGet, SS_blnThisLeft, , f_radLeft%SS_strThisLabel%
				GuiControlGet, SS_blnThisRight, , f_radRight%SS_strThisLabel%
				SS_strNewShortcut := (SS_blnThisLeft ? "<" : "") . (SS_blnThisRight ? ">" : "") . SS_strThisSymbol . SS_strNewShortcut
			}
		}

	if (SS_strNewShortcut = "LButton")
	{
		Oops(3, o_L["DialogChangeHotkeyMouseCheckLButton"], o_L["DialogShift"], o_L["DialogCtrl"], o_L["DialogAlt"], o_L["DialogWin"])
		SS_strNewShortcut := ""
		return
	}
	else if (SS_blnWin or SS_blnAlt or SS_blnCtrl or SS_blnShift) and (SS_strNewShortcut = "None")
	{
		Oops(3, o_L["DialogChangeHotkeyModifierAndNone"])
		SS_strNewShortcut := ""
		return
	}
	g_blnChangeShortcutInProgress := false
	Gosub, 2GuiClose
	
	return
	;------------------------------------------------------------

	;------------------------------------------------------------
	ButtonChangeShortcutCancel:
	;------------------------------------------------------------

	; called here if user click Cancel, called also directly if user hit Escape
	Gosub, 2GuiEscape
  
	return
	;------------------------------------------------------------
}
;------------------------------------------------------------


;========================================================================================================================
; END !_065_GUI_CHANGE_HOTKEY:
;========================================================================================================================


;========================================================================================================================
!_070_TRAY_MENU_ACTIONS:
;========================================================================================================================

;------------------------------------------------------------
OpenWorkingDirectory:
;------------------------------------------------------------

Run, %A_WorkingDir%

return
;------------------------------------------------------------


;------------------------------------------------------------
ShowSettingsIniFile:
;------------------------------------------------------------

Oops(1, o_L["DialogShowSettingsIniFile"], g_strAppNameText)
Run, % o_Settings.strIniFile

return
;------------------------------------------------------------


;========================================================================================================================
; END !_070_TRAY_MENU_ACTIONS:
;========================================================================================================================


;========================================================================================================================
!_080_VARIOUS_COMMANDS:
return
;========================================================================================================================

;------------------------------------------------------------
DoNothing:
;------------------------------------------------------------

return
;------------------------------------------------------------


;------------------------------------------------------------
GuiAbout:
;------------------------------------------------------------
Gui, 1:Submit, NoHide

intWidthTotal := 680
intWidthHalf := 340
intXCol2 := 360

strGuiTitle := L(o_L["AboutTitle"], g_strAppNameText, g_strAppVersion)
Gui, 2:New, +Hwndg_strGui2Hwnd, %strGuiTitle%
if (g_blnUseColors)
	Gui, 2:Color, %g_strGuiWindowColor%
Gui, 2:+Owner1

; header
Gui, 2:Font, s12 w700, Verdana
Gui, 2:Add, Link, x10 y10 w%intWidthTotal%, % L(o_L["AboutText1"], g_strAppNameText, g_strAppVersion, A_PtrSize * 8) ;  ; A_PtrSize * 8 = 32 or 64
Gui, 2:Font, s8 w400, Verdana
Gui, 2:Add, Link, x10 w%intWidthTotal%, % L(o_L["AboutText2"], g_strAppNameText)
FormatTime, strYear, , yyyy ; current time
Gui, 2:Add, Link, x10 w%intWidthTotal%, % L(o_L["AboutText3"], chr(169), strYear
	, AddUtm2Url("https://clipboard.quickaccesspopup.com/license/", A_ThisLabel, "License"), "www.clipboard.quickaccesspopup.com/license/")

; user info (left)
Gui, 2:Add, Text, x10 w%intWidthHalf% section, % L(o_L["AboutUserComputerName"], A_UserName, A_ComputerName)
Gui, 2:Add, Link, x10 w%intWidthHalf%, % L(o_L["AboutText4"])

; credits translators (left)
Gui, 2:Font, s8 w700, Verdana
Gui, 2:Add, Link, x10 y+10 w%intWidthTotal%, % L(o_L["AboutText5"])
Gui, 2:Font, s8 w400, Verdana
Gui, 2:Add, Link, x10 w%intWidthHalf% section, % L(o_L["AboutText6"], "Lexikos (AutoHotkey_L), Joe Glines (the-Automator.com), RaptorX, Blackholyman, just_me"
	. ", Learning One, Maestrith, Pulover (LV_Rows class), Tank, jeeswg", "https://www.autohotkey.com/boards/")
aaL := o_L.InsertAmpersand(false, "GuiClose")
Gui, 2:Add, Button, y+20 vf_btnAboutClose g2GuiClose, % o_L["GuiClose"]

; contributors (right)
Gui, 2:Add, Link, x%intXCol2% ys w%intWidthHalf%, % L(o_L["AboutText7"], A_AhkVersion)

GuiCenterButtons(g_strGui2Hwnd, , , , , , "f_btnAboutClose")
GuiControl, Focus, f_btnAboutClose
Gosub, ShowGui2AndDisableGui1

strYear := ""
strGuiTitle := ""
aaL := ""
intWidth := ""
intWidthHalf :=
intXCol2 := ""

return
;------------------------------------------------------------
 

;------------------------------------------------------------
RemoveOldTemporaryFolders:
; remove temporary folders older than 5 days
;------------------------------------------------------------

Loop, Files, %g_strTempDirParent%\_QAC_temp_*,  D
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

strUrlCheck4Update := "https://clipboard.quickaccesspopup.com/latest/latest-version-1.php"

g_strUrlAppLandingPage := "https://clipboard.quickaccesspopup.com" ; must be here if user select Check for update from tray menu
strBetaLandingPage := "https://clipboard.quickaccesspopup.com/clipboard/latest/check4update-beta-redirect.html"

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
	. "&setup=" . (blnSetup ? 1 : 0)
	. "&lsys=" . A_Language
	. "&lqac=" . o_Settings.Launch.strLanguageCode.IniValue
	. "&nbi=" . g_aaRulesByName.Count()
strLatestVersions := Url2Var(strQuery)
if !StrLen(strLatestVersions)
	if (A_ThisLabel = "Check4UpdateNow")
	{
		Oops(0, o_L["UpdateError"])
		Gosub, Check4UpdateCleanup
		return ; an error occured during ComObjCreate
	}

strLatestVersions := SubStr(strLatestVersions, InStr(strLatestVersions, "[[") + 2) 
strLatestVersions := SubStr(strLatestVersions, 1, InStr(strLatestVersions, "]]") - 1) 
strLatestVersions := Trim(strLatestVersions, "`n`l") ; remove en-of-line if present
Loop, Parse, strLatestVersions, , 0123456789.| ; strLatestVersions should only contain digits, dots and one pipe (|) between prod and beta versions
	; if we get here, the content returned by the URL above is wrong
	if (A_ThisMenuItem <> aaHelpL["MenuUpdate"])
	{
		Gosub, Check4UpdateCleanup
		return ; return silently
	}
	else
	{
		Oops(0, o_L["UpdateError"]) ; return with an error message
		Gosub, Check4UpdateCleanup
		return
	}

saLatestVersions := StrSplit(strLatestVersions, "|")
strLatestVersionProd := saLatestVersions[1]
strLatestVersionBeta := saLatestVersions[2]
strLatestVersionAlpha := saLatestVersions[3]

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
		; function assigned to Tray menu puts the menu name in first parameter (https://hotkeyit.github.io/v2/docs/commands/Menu.htm#Add_or_Change_Items_in_a_Menu)
		; when called from Tray menu, toggle blnForce
		blnForce := -1
	
	if (g_blnPortableMode)
		blnValueBefore := StrLen(FileExist(A_Startup . "\" . g_strAppNameFile . ".lnk")) ; convert file attribute to numeric (boolean) value
	else
		blnValueBefore := RegistryExist("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", g_strAppNameText)

	blnValueAfter := (blnForce = -1 ? !blnValueBefore : blnForce)

	Menu, Tray, % (blnValueAfter ? "Check" : "Uncheck"), % o_L["MenuRunAtStartup"]
	Menu, menuBarOptions, % (blnValueAfter ? "Check" : "Uncheck"), % o_L["MenuRunAtStartup"]
	
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


;------------------------------------------------------------
OpenQacRulesFile:
;------------------------------------------------------------

if FileExist(g_strRulesPathNameNoExt . ".ahk")
	Run, Notepad %g_strRulesPathNameNoExt%.ahk
else
	Oops(0, "File not found. Rules not enabled.")

return
;------------------------------------------------------------


;------------------------------------------------------------
EnableClipboardChangesInEditor:
DisableClipboardChangesInEditor:
;------------------------------------------------------------

OnClipboardChange("ClipboardContentChanged", (A_ThisLabel = "EnableClipboardChangesInEditor"))
SB_SetText((A_ThisLabel = "DisableClipboardChangesInEditor" ? o_L["DialogClipboardDisconnected"] : ""), 2)
GuiControl, % (A_ThisLabel = "EnableClipboardChangesInEditor" ? "Enable" : "Disable"), f_blnSeeInvisible

return
;------------------------------------------------------------


;------------------------------------------------------------
ExecuteRule:
;------------------------------------------------------------
Gui, Submit, NoHide

Gosub, DisableClipboardChangesInEditor
Clipboard := f_strClipboardEditor ; save current content to editor (rule is executed by QACrules.ahk on the Clipboard, not on the control)

GetSelectedTextPos(intStart, intEnd)
if (intEnd - intStart) ; if text selected, copy it to Clipboard to apply rule only on it
{
	strBefore := SubStr(Clipboard, 1, intStart)
	strAfter := SubStr(Clipboard, intEnd + 1)
	Clipboard := SubStr(Clipboard, intStart + 1, intEnd - intStart)
}

Send_WM_COPYDATA("exec|" . g_aaRulesByName[A_ThisMenuItem].intID, "ahk_pid " . strQacRulesPID) ; apply rule to Clipboard

if (intEnd - intStart) ; rebuild full Clipboard
	Clipboard := strBefore . Clipboard . strAfter

GuiControl, , %g_strEditorControlHwnd%, %Clipboard% ; copy content to Clipboard

SetSelectedTextPos(intStart, intEnd)

Gosub, DisableSaveAndCancel ; do EnableClipboardChangesInEditor

return
;------------------------------------------------------------


;------------------------------------------------------------
RemoveToolTip:
;------------------------------------------------------------

ToolTip

return
;------------------------------------------------------------


;========================================================================================================================
; END !_080_VARIOUS_COMMANDS:
;========================================================================================================================


;========================================================================================================================
!_090_VARIOUS_FUNCTIONS:
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
	
	SysGet, arrCurrentMonitor, Monitor, % GetActiveMonitorForPosition(intRefGuiX, intRefGuiY, intNbMonitors)

	; ###_V(A_ThisFunc, v, g_strRefHwnd, intWindowX, intWindowY, GetActiveMonitorForPosition(intWindowX, intWindowY, intNbMonitors))
	intTopGuiX := (intTopGuiX < arrCurrentMonitorLeft ? arrCurrentMonitorLeft : intTopGuiX)
	intTopGuiY := (intTopGuiY < arrCurrentMonitorTop ? arrCurrentMonitorTop : intTopGuiY)
}
;------------------------------------------------------------


;------------------------------------------------------------
GetSavedEditorWindowPosition(ByRef saEditorPosition)
; use LastScreenConfiguration and window position from ini file
; if screen configuration changed, return -1 instead of the saved position
;------------------------------------------------------------
{
	g_strLastScreenConfiguration := o_Settings.ReadIniValue("LastScreenConfiguration", " ") ; to reset position if screen config changed since last session
	
	strCurrentScreenConfiguration := GetScreenConfiguration()
	if !StrLen(g_strLastScreenConfiguration) or (strCurrentScreenConfiguration <> g_strLastScreenConfiguration)
	{
		IniWrite, %strCurrentScreenConfiguration%, % o_Settings.strIniFile, Internal, LastScreenConfiguration ; always save in case QAP is not closed properly
		arrEditorPosition1 := -1 ; returned value by first ByRef parameter
	}
	else
		if (o_Settings.EditorWindow.blnRememberEditorPosition.IniValue)
		{
			strEditorPosition := o_Settings.ReadIniValue("EditorPosition", -1) ; by default -1 to center at minimal size
			saEditorPosition := StrSplit(strEditorPosition, "|")
		}
		else ; delete Settings position
		{
			IniDelete, % o_Settings.strIniFile, Internal, EditorPosition
			arrEditorPosition1 := -1 ; returned value by first ByRef parameter
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
	if (strThisWindow <> "EditorPosition" or o_Settings.EditorWindow.blnRememberEditorPosition.IniValue)
	; always for Add, Edit, Copy or Move Favorites dialog boxes, only if remember for Settings
	{
		WinGet, intMinMax, MinMax, %strWindowHandle%
		if (intMinMax = 1) ; if window is maximized, restore normal state to get position
			WinRestore, %strWindowHandle%
		
		WinGetPos, intX, intY, intW, intH, %strWindowHandle%
		strPosition := intX . "|" . intY . "|" . intW . "|" . intH . (intMinMax = 1 ? "|M" : "")
		IniWrite, %strPosition%, % o_Settings.strIniFile, Internal, %strThisWindow%
	}
	else ; delete Settings position
		IniDelete, % o_Settings.strIniFile, Internal, %strThisWindow%
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
	
	if (intNbMonitors > 1) and intActiveMonitorForWindow and (intActiveMonitorForWindow <> intActiveMonitorForPosition)
	{
		; calculate Explorer window position relative to center of screen
		SysGet, arrThisMonitor, Monitor, %intActiveMonitorForPosition% ; Left, Top, Right, Bottom
		intWindowX := arrThisMonitorLeft + (((arrThisMonitorRight - arrThisMonitorLeft) - intWindowWidth) / 2)
		intWindowY := arrThisMonitorTop + (((arrThisMonitorBottom - arrThisMonitorTop) - intWindowHeight) / 2)
		
		return true
	}

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
GuiCenterButtons(strWindowHandle, intInsideHorizontalMargin := 10, intInsideVerticalMargin := 0, intDistanceBetweenButtons := 20, intLeftOffset := 0, intRightOffset := 0, arrControls*)
; This is a variadic function. See: http://ahkscript.org/docs/Functions.htm#Variadic
;------------------------------------------------------------
{
	; A_DetectHiddenWindows must be on (app's default); Gui, Show acts on current default gui (1: or 2: , etc)
	Gui, Show, Hide ; hides the window and activates the one beneath it, allows a hidden window to be moved, resized, or given a new title without showing it
	WinGetPos, , , intWidth, , ahk_id %strWindowHandle%
	intWidth := intWidth // (A_ScreenDPI / 96)
	intWidth -= (intLeftOffset + intRightOffset)

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
	intLeftMargin += intLeftOffset

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

	GuiControlGet, blnSaveEditorEnabled, 1:Enabled, f_btnGuiSaveEditor

	return blnSaveEditorEnabled
}
;------------------------------------------------------------


;------------------------------------------------------------
RulesNotApplied()
;------------------------------------------------------------
{
	global

	GuiControlGet, blnApplyRulesEnabled, 1:Enabled, f_btnGuiApplyRules

	return blnApplyRulesEnabled
}
;------------------------------------------------------------


;------------------------------------------------------------
QACGuiTitle()
;------------------------------------------------------------
{
	return L(o_L["GuiTitle"], g_strAppNameText, g_strAppVersion)
}
;------------------------------------------------------------


;------------------------------------------------------------
WM_RBUTTONDOWN()
; see OnMessage(0x204, "WM_RBUTTONDOWN")
;------------------------------------------------------------
{
    if (A_GuiControl = "f_strClipboardEditor")
       return 0
}
;------------------------------------------------------------


;------------------------------------------------------------
WM_RBUTTONUP()
; see OnMessage(0x205, "WM_RBUTTONUP")
;------------------------------------------------------------
{
    if (A_GuiControl = "f_strClipboardEditor")
		Gosub, ShowUpdatedEditorContextMenu
}
;------------------------------------------------------------


;------------------------------------------------------------
GetSelectedTextLenght()
;------------------------------------------------------------
{
	GetSelectedTextPos(intStart, intEnd)
	return (intEnd - intStart)
}
;------------------------------------------------------------


;------------------------------------------------------------
GetSelectedTextPos(ByRef intStart, ByRef intEnd)
; from just me (https://www.autohotkey.com/boards/viewtopic.php?p=27857#p27857)
; returns start and end positions of selected text in control
; if no text is selected, returns caret position in both start and end variables
;------------------------------------------------------------
{
	intStart := 0
	intEnd := 0
	; EM_GETSEL = 0x00B0 -> msdn.microsoft.com/en-us/library/bb761598(v=vs.85).aspx
	DllCall("User32.dll\SendMessage", "Ptr", g_strEditorControlHwnd, "UInt", 0x00B0, "UIntP", intStart, "UIntP", intEnd, "Ptr")
}
;------------------------------------------------------------


;------------------------------------------------------------
SetSelectedTextPos(intStart, intEnd)
; set the selection in edit control to start and end positions
; if start and end values are equal, set the caret to this position
;------------------------------------------------------------
{
	; EM_SETSEL = 0x00B1 -> https://docs.microsoft.com/fr-fr/windows/win32/controls/em-setsel
	Postmessage, 0xB1, intStart, intEnd, , % "ahk_id " . g_strEditorControlHwnd ; SendMessage not working
}
;------------------------------------------------------------


;------------------------------------------------------------
ConvertInvisible(str)
; Invisible chars: https://www.fileformat.info/info/unicode/category/So/list.htm (see U+2400 ...)
;------------------------------------------------------------
{
	; preserve tabs and new lines
	strTabReplacement := "¤¢£"
	str := StrReplace(str, Chr(9), strTabReplacement)
	strLfReplacement := "²¬¼"
	str := StrReplace(str, Chr(10), strLfReplacement)
	
	intUnicodeBase := 0x2400
	loop, 31 ; from 1 to 31 (exclude 32 space)
		if (InStr(str, Chr(A_Index)) or InStr(str, Chr(A_Index + intUnicodeBase)) or A_Index = 9 or A_Index = 10)
		{
			if (A_Index = 9) ; TAB
			{
				strFrom := strTabReplacement
				strTo := Chr(0x21E5) . strTabReplacement ; U+21E8 RIGHTWARDS WHITE ARROW / U+21F0 RIGHTWARDS WHITE ARROW FROM WALL / U+21E5 RIGHTWARDS ARROW TO BAR
				g_intInvisibleChars++
			}
			else if (A_Index = 10) ; LF (`n = LF)
			{
				strFrom := strLfReplacement
				strTo := Chr(0x21B2) . strLfReplacement ; U+21E9 DOWNWARDS WHITE ARROW / U+21A9	LEFTWARDS ARROW WITH HOOK / U+21B2 DOWNWARDS ARROW WITH TIP LEFTWARDS
				g_intInvisibleChars++
			}
			else
			{
				strFrom := Chr(A_Index)
				strTo := Chr(A_Index + intUnicodeBase)
			}
			str := StrReplace(str, strFrom, strTo)
		}
	
	; restore tabs and new lines
	str := StrReplace(str, strTabReplacement, Chr(9))
	str := StrReplace(str, strLfReplacement, Chr(10))
	
	return str
}
;------------------------------------------------------------


;------------------------------------------------------------
GetLVPosition(ByRef intPosition, strMessage)
;------------------------------------------------------------
{
	intPosition := LV_GetNext()
	if !(intPosition) and StrLen(strMessage)
		Oops(1, strMessage)
	return intPosition
}
;------------------------------------------------------------


;------------------------------------------------------------
EncodeForIni(str)
;------------------------------------------------------------
/*
https://rosettacode.org/wiki/Special_characters#AutoHotkey
The escape character defaults to accent/backtick (`).

`, = , (literal comma). Note: Commas that appear within the last parameter of a command do not need to be escaped because the program knows to treat them literally. The same is true for all parameters of MsgBox because it has smart comma handling.
`% = % (literal percent)
`` = ` (literal accent; i.e. two consecutive escape characters result in a single literal character)
`; = ; (literal semicolon). Note: This is necessary only if a semicolon has a space or tab to its left. If it does not, it will be recognized correctly without being escaped.
`n = newline (linefeed/LF)
`r = carriage return (CR)
`b = backspace
`t = tab (the more typical horizontal variety)
`v = vertical tab -- corresponds to Ascii value 11. It can also be manifest in some applications by typing Control+K.
`a = alert (bell) -- corresponds to Ascii value 7. It can also be manifest in some applications by typing Control+G.
`f = formfeed -- corresponds to Ascii value 12. It can also be manifest in some applications by typing Control+L.
Send = When the Send command or Hotstrings are used in their default (non-raw) mode, characters such as {}^!+# have special meaning. Therefore, to use them literally in these cases, enclose them in braces. For example: Send {^}{!}{{}
"" = Within an expression, two consecutive quotes enclosed inside a literal string resolve to a single literal quote. For example: Var := "The color ""red"" was found."

Process only:
`n = newline (linefeed/LF)
`t = tab (the more typical horizontal variety)

No need to process:
- | (pipe) used as separator in favorites lines in ini file are already replaced with the escape sequence "Ð¡þ€"
*/
{
	str := StrReplace(str, "``", "````") ;  replace backticks with double-backticks
	str := StrReplace(str, "`n", "``n")  ; encode end-of-lines
	str := StrReplace(str, "`t", "``t")  ; encode tabs
	
	return str
}
;------------------------------------------------------------


;------------------------------------------------------------
DecodeFromIni(str, blnWithCarriageReturn := false)
; convert from raw content (as from ini file) to display format (when f_blnProcessEOLTab is true) or to paste format
;------------------------------------------------------------
{
	str := StrReplace(str, "````", "!r4nd0mt3xt!")	; preserve double-backticks
	str := StrReplace(str
		, "``n", (blnWithCarriageReturn ? "`r" : "") . "`n")		; decode end-of-lines (with `r only when sending as Snippet)
	str := StrReplace(str, "``t", "`t")				; decode tabs
	str := StrReplace(str, "!r4nd0mt3xt!", "``")		; restore double-backticks
	
	return str
}
;------------------------------------------------------------


;------------------------------------------------------------
EncodeAutoHokeyCodeForIni(str)
; replace TAB and LF characrters with visible replacement for ini file
;------------------------------------------------------------
{
	return StrReplace(StrReplace(str, Chr(9), g_strTab), Chr(10), g_strEol)
}
;------------------------------------------------------------


;------------------------------------------------------------
DecodeAutoHokeyCodeFromIni(str)
; replace visible replacement for TAB and LF characrters with actual character
;------------------------------------------------------------
{
	return StrReplace(StrReplace(str, g_strTab, Chr(9)), g_strEol, Chr(10))
}
;------------------------------------------------------------


;========================================================================================================================
; END !_090_VARIOUS_FUNCTIONS:
;========================================================================================================================


;========================================================================================================================
!_095_ONMESSAGE_FUNCTIONS:
return
;========================================================================================================================

;------------------------------------------------
WM_MOUSEMOVE(wParam, lParam)
; "hook" for image buttons cursor and buttons tooltips
; see http://www.autohotkey.com/board/topic/70261-gui-buttons-hover-cant-change-cursor-to-hand/
; and https://autohotkey.com/board/topic/83045-solved-onmessage-gui-tooltips-issues/#entry528803
;------------------------------------------------
{
	static s_strControl
	static s_strControlPrev
	
	global g_objHandCursor
	global g_blnEditButtonDisabled

	; get window's titte and exit if it is not the Settings window
	WinGetTitle, strCurrentWindow, A
	if (strCurrentWindow <> QACGuiTitle())
		return

	; get hover control name and Static control number
	s_strControlPrev := s_strControl
	MouseGetPos, , , , s_strControl ; Static1, StaticN, Button1, ButtonN
	intControl := StrReplace(s_strControl, "Static")
	
	/* code to use for Static controls
	; display hand cursor over selected buttons
	if InStr(s_strControl, "Static")
	{
		; Static controls to exclude if any
		if (intControl < 1 or intControl > 25 or ((intControl = 2 or intControl = 3 or intControl = 22) and g_blnEditButtonDisabled))
			return
	}
	else if...
	*/
	if !InStr(s_strControl, "Button")
	{
		ToolTip ; turn ToolTip off
		return
	}
	DllCall("SetCursor", "UInt", g_objHandCursor)
	
	; display tooltip for hovered control
	if (s_strControl <> s_strControlPrev) ;  prevent flicker caused by repeating tooltip when mouse moving over the same control
		and StrLen(g_aaToolTipsMessages[s_strControl])
	{
		ToolTip, % g_aaToolTipsMessages[s_strControl] ; display tooltip or remove tooltip if no message for this control
		if StrLen(g_aaToolTipsMessages[s_strControl])
			SetTimer, RemoveToolTip, -2500 ; will remove tooltip if not removed by mouse going hovering elsewhere (required if window become inactive)
	}

	return
}
;------------------------------------------------


;-----------------------------------------------------------
Send_WM_COPYDATA(ByRef strStringToSend, ByRef strTargetScriptTitle) ; ByRef saves a little memory in this case.
; Adapted from AHK documentation (https://autohotkey.com/docs/commands/OnMessage.htm)
; This function sends the specified string to the specified window and returns the reply.
; The reply is 1 if the target window processed the message, or 0 if it ignored it.
;-----------------------------------------------------------
{
    VarSetCapacity(varCopyDataStruct, 3 * A_PtrSize, 0) ; Set up the structure's memory area.
	
    ; First set the structure's cbData member to the size of the string, including its zero terminator:
    intSizeInBytes := (StrLen(strStringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(intSizeInBytes, varCopyDataStruct, A_PtrSize) ; OS requires that this be done.
    NumPut(&strStringToSend, varCopyDataStruct, 2 * A_PtrSize) ; Set lpData to point to the string itself.

	strPrevDetectHiddenWindows := A_DetectHiddenWindows
    intPrevTitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
	
    SendMessage, 0x4a, 0, &varCopyDataStruct, , %strTargetScriptTitle% ; 0x4a is WM_COPYDATA. Must use Send not Post.
	
    DetectHiddenWindows %strPrevDetectHiddenWindows% ; Restore original setting for the caller.
    SetTitleMatchMode %intPrevTitleMatchMode% ; Same.
	
    return ErrorLevel ; Return SendMessage's reply back to our caller.
}
;-----------------------------------------------------------


;------------------------------------------------------------
RECEIVE_QACRULES(wParam, lParam) 
; Adapted from AHK documentation (https://autohotkey.com/docs/commands/OnMessage.htm)
;------------------------------------------------------------
{
	intStringAddress := NumGet(lParam + 2*A_PtrSize) ; Retrieves the CopyDataStruct's lpData member.
	strCopyOfData := StrGet(intStringAddress) ; Copy the string out of the structure.
	
	if (strCopyOfData = "rules_disabled")
	{
		GuiControlGet, blnApplyRulesEnabled, 1:Enabled, f_btnGuiApplyRules
		if !(blnApplyRulesEnabled) ; do not remove selected items if changes are in progress
		{
			Gosub, GuiRuleDeselectAll
			; disable because rules were already removed by QACrules
			GuiControl, Disable, f_btnGuiApplyRules ; do not Gosub, DisableApplyRulesAndCancel to leave Save and Close unchanged
		}
		return 1 ; success
	}
	else
		return 0 ; error
}
;------------------------------------------------------------


;========================================================================================================================
; END !_095_ONMESSAGE_FUNCTIONS:
;========================================================================================================================




;========================================================================================================================
!_100_CLASSES:
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
		
		this.saOptionsGroups := ["General", "Launch", "EditorWindow", "SettingsFile", "LaunchAdvanced", "MenuAdvanced", "AdvancedOther"]
			
		; at first launch quickaccessclipboard.ini does not exist, read language value in quickaccessclipboard-setup.ini (if exist) created by Setup
		this.ReadIniOption("Launch", "strLanguageCode", "LanguageCode", "EN", "General", "", ""
			, (FileExist(this.strIniFile) ? this.strIniFile : A_WorkingDir . "\" . g_strAppNameFile . "-setup.ini"))
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	InitOptionsGroupsLabelNames()
	; called after o_L is initialized
	;---------------------------------------------------------
	{
		this.saOptionsGroupsLabelNames := ["OptionsGeneral", "OptionsLaunch", "OptionsEditorWindow", "OptionsSettingsFile", "OptionsLaunchAdvanced", "OptionsMenuAdvanced", "OptionsAdvancedOther"]
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ReadIniOption(strOptionGroup, strSettingName, strIniValueName, strDefault := "", strGuiGroup := "", strGuiControls := "", strSection := "", strIniFile := "")
	;---------------------------------------------------------
	{
		if !IsObject(this[strOptionGroup])
			this[strOptionGroup] := Object()
		if !IsObject(this.aaGroupItems[strGuiGroup])
			this.aaGroupItems[strGuiGroup] := Object()
		
		if StrLen(strIniValueName) ; for exception f_blnOptionsRunAtStartup having no ini value, but a control in Options gui
			strOutValue := this.ReadIniValue(strIniValueName, strDefault, (StrLen(strSection) ? strSection : strOptionGroup), strIniFile)
		
		oIniValue := new this.IniValue(strIniValueName, strOutValue, strGuiGroup, strGuiControls, (StrLen(strSection) ? strSection : strOptionGroup), strIniFile)
		
		this[strOptionGroup][strSettingName] := oIniValue
		this.aaGroupItems[strGuiGroup].Push(oIniValue)
		
		return oIniValue.IniValue
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ReadIniValue(strIniValueName, strDefault := "", strSection := "Internal", strIniFile := "")
	;---------------------------------------------------------
	{
		IniRead, strOutValue, % (StrLen(strIniFile) ? strIniFile : this.strIniFile), %strSection%, %strIniValueName%
		if (strOutValue = "ERROR")
		{
			IniWrite, %strDefault%, % (StrLen(strIniFile) ? strIniFile : this.strIniFile), %strSection%, %strIniValueName%
			return strDefault
		}
		else
			return strOutValue
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	ReadIniSection(strSection, strIniFile := "")
	;---------------------------------------------------------
	{
		IniRead, strOutValue, % (StrLen(strIniFile) ? strIniFile : this.strIniFile), %strSection%
		return strOutValue
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	WriteIniSection(strInValue, strSection, strIniFile := "")
	;---------------------------------------------------------
	{
		IniWrite, %strInValue%, % (StrLen(strIniFile) ? strIniFile : this.strIniFile), %strSection%
		return !(ErrorLevel)
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	DeleteIniSection(strSection, strIniFile := "")
	;---------------------------------------------------------
	{
		IniDelete, % (StrLen(strIniFile) ? strIniFile : this.strIniFile), %strSection%
		return !(ErrorLevel)
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
		
		strThisBackupFolder := o_Settings.ReadIniValue("BackupFolder", " ", "SettingsFile", strIniFile) ; can be main ini file, alternative ini or external ini file backup folder
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
				, % (StrLen(this.strSection) ? this.strSection : "Internal"), % this.strIniValueName
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
		- strPopupHotkey: mouse (like "^MButton" for Ctrl + MButton) or keyboard (like "^#v" for Ctrl + Win + V) hotkey trigger for a the QAC window
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
			saPopupHotkeyDefaults := StrSplit("^MButton|^#v", "|")
			saOptionsPopupHotkeyLocalizedNames := StrSplit(L(o_L["OptionsPopupHotkeyTitles"], g_strAppNameText), "|")
			saOptionsPopupHotkeyLocalizedDescriptions := StrSplit(L(o_L["OptionsPopupHotkeyTitlesSub"], g_strAppNameText), "|")
			
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
	
	;---------------------------------------------------------
	InsertAmpersand(blnAddNumericShortcut, saIn*)
	; blnAddNumericShortcut
	; saIn:  variadic variables containing keys of o_L["..."] and an optional @ folowed by the text to replace ~1~ with L(...) - only 1 replacement is supported
	;        if the first variable of saIn* starts with "*", it is a list of pre-used letters
	;        ex.: "MenuSave" or "MenuExit@Quick Access Popup"
	; aaOut: value returned containing an associative array with saIn variables as keys including "@" and text (ex.: "LanguageKey" or "LanguageKey@Replacement text")
	;        and with values including replacement text (ex: "Save" or "Exit Quick Access Popup"
	;---------------------------------------------------------
	{
		saContentCleaned := Object() ; contains only letters that can be used as shortcuts (this also excludes "~n~")
		aaOut := Object()
		
		if (SubStr(saIn[1], 1, 1) = "*") ; this is already used letters in strUsed
			aaOut.strUsed := SubStr(saIn.RemoveAt(1), 2) ; remove leading "*" and remove item with "*"
		
		; process items to expand replacement and get strings lengths in order to sort items to process first the shortest labels (those with the least valid shortcut chars)
		Loop, % saIn.MaxIndex()
		{
			saThisContent := StrSplit(saIn[A_Index], "@")
			strThisContentExpanded := L(o_L[saThisContent[1]], saThisContent[2])
			saContentCleaned[A_Index] := RegExReplace(strThisContentExpanded, "[^a-zA-Z]", "")
			; strSort line: 1) length, 2) aa o_L index including "@...", 3) saContentCleaned index, 4) Expanded text
			strSort .= StrLen(saContentCleaned[A_Index]) . "|" . saIn[A_Index] . "|" . A_Index . "|" . strThisContentExpanded . "`n"
		}
		
		strSort := SubStr(strSort, 1, -1)
		Sort, strSort, N
		saSorted := StrSplit(strSort, "`n")
		
		for intKey, strThisStr in saSorted
		{
			saThisStr := StrSplit(strThisStr, "|")
			aaOut[saThisStr[2]] := saThisStr[4] ; backup if not replaced with a ampersand and letter
			if (o_Settings.Menu.blnDisplayNumericShortcuts.IniValue and blnAddNumericShortcut) ; insert ampersand for numeric shortcuts
			{
				Container.s_intMenuShortcutNumber := saThisStr[3] - 1
				aaOut[saThisStr[2]] := Container.MenuNameWithNumericShortcut(aaOut[saThisStr[2]])
			}
			else ; insert ampersand in menu name
				Loop, Parse, % saContentCleaned[saThisStr[3]] ; scan available letters in label 
				{
					if !InStr(aaOut.strUsed, A_LoopField) ; not case sensitive by default
					{
						aaOut.strUsed .= A_LoopField ; use this letter for this label
						aaOut[saThisStr[2]] := StrReplace(saThisStr[4], A_LoopField, "&" . A_LoopField, , 1)
						break
					}
				}
		}
		
		return aaOut
	}
	;---------------------------------------------------------

	;---------------------------------------------------------
	InsertAmpersandInString(strIn)
	; strIn delimited with "|"
	; returns strOut delimited with "|"
	; (this is based on InsertAmpersand but adapted to process the favorite types labels string and avoid having to refactor how these labels are managed)
	;---------------------------------------------------------
	{
		saContentCleaned := Object() ; contains only letters that can be used as shortcuts (this also excludes "~n~")
		saOut := Object()
		
		; sort items to process first the shortest labels (those with the least valid shortcut chars)
		Loop, Parse, strIn, |
		{
			strCleaned := RegExReplace(A_LoopField, "[^a-zA-Z]", "")
			; strSort line: 1) length, 2) cleaned string, 3) original string
			strSort .= StrLen(strCleaned) . "|" . strCleaned . "|" . A_Index . "|" . A_LoopField . "`n"
		}
		
		strSort := SubStr(strSort, 1, -1)
		Sort, strSort, N
		saSorted := StrSplit(strSort, "`n")
		
		for intKey, strThisStr in saSorted
		{
			saThisStr := StrSplit(strThisStr, "|")
			saOut[saThisStr[3]] := saThisStr[4] ; backup will be replaced if a letter can be used
			Loop, Parse, % saThisStr[2] ; scan available letters in label 
			{
				if !InStr(strUsed, A_LoopField) ; not case sensitive by default
				{
					strUsed .= A_LoopField ; use this letter for this label
					saOut[saThisStr[3]] := StrReplace(saThisStr[4], A_LoopField, "&" . A_LoopField, , 1)
					break
				}
			}
		}
		
		for intKey, strValue in saOut
			strOut .= strValue . "|"
		strOut := SubStr(strOut, 1, -1)

		return strOut
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------

;-------------------------------------------------------------
class RuleType
;-------------------------------------------------------------
{
	;---------------------------------------------------------
	__New(strTypeCode, strTypeLabel, strTypeHelp)
	;---------------------------------------------------------
	{
		this.strTypeCode := strTypeCode
		this.strTypeLabel := strTypeLabel
		this.strTypeHelp := strTypeHelp
		
		g_aaRuleTypes[strTypeCode] := this
		this.intID := g_saRuleTypesOrder.Push(this)
	}
	;---------------------------------------------------------
	
}
;-------------------------------------------------------------

;-------------------------------------------------------------
class Rule
;-------------------------------------------------------------
{
	;---------------------------------------------------------
	__New(strName := "", saRuleValues := "")
	; saRuleValues: 1) Type, 2) Category 3) Notes 4+) rules parameters
	;---------------------------------------------------------
	{
		this.strName := strName
		this.strTypeCode := saRuleValues.RemoveAt(1)
		this.strTypeLabel := g_aaRuleTypes[this.strTypeCode].strTypeLabel
		this.strTypeHelp := g_aaRuleTypes[this.strTypeCode].strTypeHelp
		this.strCategory := StrReplace(saRuleValues.RemoveAt(1), g_strPipe, "|")
		this.strNotes := StrReplace(saRuleValues.RemoveAt(1), g_strPipe, "|")
		; saRuleValues is now: 1) first variable value, 2) second variable value, etc.
		this.saVarValues := saRuleValues
		
		if (this.strTypeCode = "ChangeCase")
		{
			this.intCaseType := saRuleValues[1] ; also in this.saVarValues[1]
			this.strFind := ".*"
			this.strReplace := StrSplit("$L0|$U0|$T0", "|")[this.intCaseType]
		}
		else if (this.strTypeCode = "ConvertFormat")
			this.intConvertFormat := saRuleValues[1]
		else if (this.strTypeCode = "Replace")
		{
			this.strFind := StrReplace(saRuleValues[1], g_strPipe, "|") ; also in this.saVarValues[1]
			this.strReplace := StrReplace(saRuleValues[2], g_strPipe, "|") ; also in this.saVarValues[2]
			this.blnReplaceWholeWord := saRuleValues[3] ; also in this.saVarValues[3]
			this.blnReplaceCaseSensitive := saRuleValues[4] ; also in this.saVarValues[4]
		}
		else if (this.strTypeCode = "AutoHotkey")
			this.strCode := StrReplace(saRuleValues[1], g_strPipe, "|") ; also in this.saVarValues[1]
		else if (this.strTypeCode = "SubStr")
		{
			this.intSubStrFromType := saRuleValues[1]
			this.intSubStrFromPosition := saRuleValues[2]
			this.strSubStrFromText := saRuleValues[3]
			this.intSubStrFromPlusMinus := saRuleValues[4]
			
			this.intSubStrToType := saRuleValues[5]
			this.intSubStrToLength := saRuleValues[6] ; positive if length from FromPosition or negative if length from End
			this.strSubStrToText := saRuleValues[7]
			this.intSubStrToPlusMinus := saRuleValues[8]
			
			this.blnSubStrRepeat := saRuleValues[9]
		}
		else if (this.strTypeCode = "Prefix")
			this.strPrefix := StrReplace(saRuleValues[1], g_strPipe, "|") ; also in this.saVarValues[1]
		else if (this.strTypeCode = "Suffix")
			this.strSuffix := StrReplace(saRuleValues[1], g_strPipe, "|") ; also in this.saVarValues[1]
		
		if InStr("Prefix Suffix", this.strTypeCode)
			this.blnSubStrRepeat := saRuleValues[2]
		
		g_aaRulesByName[strName] := this
		this.intID := g_saRulesOrder.Push(this)
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	ListViewAdd(strListView, strOption := "")
	;---------------------------------------------------------
	{
		if (strListView = "f_lvRulesAvailable")
			LV_Add(strOption, this.strName, this.strTypeLabel, this.strCategory, this.strNotes)
		else
			LV_Add(strOption, this.strName)
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	SaveRuleToIni(saValues)
	;---------------------------------------------------------
	{
		; example: Lower case=ChangeCase|Example|Notes|.*|$L0
		strIniLine := this.strTypeCode . "|"
		strIniLine .= StrReplace(this.strCategory, "|", g_strPipe) . "|"
		strIniLine .= StrReplace(this.strNotes, "|", g_strPipe) . "|"
		Loop, 9
			strIniLine .= StrReplace(saValues[A_Index], "|", g_strPipe) . "|"
			; do not remove last | in case we have a space as last character
		
		IniWrite, %strIniLine%, % o_Settings.strIniFile, Rules, % this.strName
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	DeleteRule()
	;---------------------------------------------------------
	{
		IniDelete, % o_Settings.strIniFile, Rules, % this.strName
		g_aaRulesByName.Delete(this.strName)
		g_saRulesOrder.Delete(this.intID)
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	CopyRule()
	;---------------------------------------------------------
	{
		aaCopiedRule := new Rule
		for strProperty, varValue in this
			aaCopiedRule[strProperty] := varValue
		aaCopiedRule.strName .= " (" . o_L["DialogCopy"] . ")"
		
		return aaCopiedRule
	}
	;---------------------------------------------------------
	
	;---------------------------------------------------------
	GetCode()
	;---------------------------------------------------------
	{
		; begin rule
		strCode := "Rule" . this.intID . "(strType) `; " . this.strName . " (" . this.strTypeCode . ")`n{`n"
		strCode .= "`; MsgBox, Execute QACrule: %A_ThisFunc%`n"
		strCode .= "if (strType = 1) `; text`n{`n"
		
		strCode .= "`; strBefore := Clipboard`n"
		if (this.strTypeCode = "ChangeCase")
			strCode .= "Clipboard := RegExReplace(Clipboard, """ . this.strFind . """, """ . this.strReplace . """)"
		if (this.strTypeCode = "ConvertFormat") ; only Text format is supported
			strCode .= "Clipboard := Clipboard"
		else if (this.strTypeCode = "Replace")
		{
			strFind := (this.blnReplaceWholeWord ? "\b" . this.strFind . "\b" : this.strFind) ; \b...\b for whole word boundries
			strFind := (this.blnReplaceCaseSensitive ? "" : "i)") . strFind ; by default, regex are case-sensitive, changed with "i)"
			strCode .= "Clipboard := RegExReplace(Clipboard, """ . strFind . """, """ . this.strReplace . """)"
		}
		else if (this.strTypeCode = "AutoHotkey")
			strCode .= this.strCode
		else if (this.strTypeCode = "SubStr")
		{
			strSubStr := "SubStr(Clipboard, "
			if (this.intSubStrFromType = 1) ; FromStart
				strSubStr .= "1"
			else if (this.intSubStrFromType = 2) ; FromPosition
				strSubStr .= this.intSubStrFromPosition
			else if (this.intSubStrFromType = 3) ; FromBeginText
			{
				strCodeStart := "InStr(Clipboard, """ . this.strSubStrFromText . """) + " . this.intSubStrFromPlusMinus ; used to substract from "to" position
				strSubStr .= strCodeStart
			}
			else if (this.intSubStrFromType = 4) ; FromEndText
			{
				strCodeStart := "InStr(Clipboard, """ . this.strSubStrFromText . """) + StrLen(""" . this.strSubStrFromText . """) + " . this.intSubStrFromPlusMinus ; used to substract from "to" position
				strSubStr .= strCodeStart
			}
			
			if (this.intSubStrToType <> 1)
				strSubStr .= ", "
			
			; if this.intSubStrToType = 1 ToEnd, add nothing
			if (this.intSubStrToType = 2) ; ToLength
				strSubStr .= this.intSubStrToLength
			else if (this.intSubStrToType = 3) ; ToBeforeEnd
				strSubStr .= this.intSubStrToLength ; intSubStrToLength already negative
			else if (this.intSubStrToType = 4) ; ToBeginText
				strSubStr .= "InStr(Clipboard, """ . this.strSubStrToText . """) + " . this.intSubStrToPlusMinus . " - (" . strCodeStart . ")"
			else if (this.intSubStrToType = 5) ; ToEndText
				strSubStr .= "InStr(Clipboard, """ . this.strSubStrToText . """) + StrLen(""" . this.strSubStrToText . """) + " . this.intSubStrToPlusMinus . " - (" . strCodeStart . ")"
			strSubStr .= ")"
			
			if (this.blnSubStrRepeat)
			{
				strSubStr := StrReplace(strSubStr , "Clipboard", "A_LoopField")
				strCode .= "strTemp := """"`n"
					. "Loop, Parse, Clipboard, ``n`n"
					; . "`tstrTemp .= SubStr(A_LoopField, " . intStartingPosition . (StrLen(intLength) ? "," . intLength : "") . ") . " . """``n""`n"
					. "`tstrTemp .= " . strSubStr . " . ""``n""`n"
					. "Clipboard := SubStr(strTemp, 1, -1) `; remove last eol"
				}
			else
				strCode .= "Clipboard := " . strSubStr
		}
		else if InStr("Prefix Suffix", this.strTypeCode)
			if (this.blnSubStrRepeat)
				strCode .= "strTemp := """"`n"
					. "Loop, Parse, Clipboard, ``n`n"
					. "`tstrTemp .=  """ . (this.strTypeCode = "Prefix" ? this.strPrefix : "") . """ . A_LoopField . """ . (this.strTypeCode = "Suffix" ? this.strSuffix : "") . "``n""`n"
					. "Clipboard := SubStr(strTemp, 1, -1) `; remove last eol"
			else
				strCode .= "Clipboard := """ . (this.strTypeCode = "Prefix" ? this.strPrefix : "") . """ . Clipboard . """ . (this.strTypeCode = "Suffix" ? this.strSuffix : "") . """"
		
		strCode .= "`n"
		strCode .= "Sleep, 50`n"
		strCode .= "`; strAfter := Clipboard`n"
		strCode .= "`; MsgBox, %strBefore%``n%strAfter%"
		
		; end rule
		strCode .= "`n}`n}`n`n"
		
		return strCode
	}
	;---------------------------------------------------------
}
;-------------------------------------------------------------

