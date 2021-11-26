;
; DO NOT RUN FROM INNO SETUP EDITOR
; THIS SCRIPT REQUIRES ENVIRONMENT VARIABLES FROM BATCH
; C:\Dropbox\AutoHotkey\QuickAccessClipboard\Setup Script files\Compile.bat
;

#define MyBetaProd GetEnv('QACBETAPROD')
#define MyAppVersionNumber GetEnv('QACVERSIONNUMBER') ; exemple "1.2.3.4"
#define MyAppVersion GetEnv('QACVERSIONTEXT') ; exemple "v1.2.3.4 BETA"
#define MyVersionFileName GetEnv('QACVERSIONFILE') ; exemple "1_2_3_4 ou 1_2_3_4-beta"

#define MyAppName "Quick Access Clipboard"
#define MyAppNameNoSpace "QuickAccessClipboard"
#define MyAppNameLower "quickaccessclipboard"
#define MyAppPublisher "Jean Lalonde"
#define MyAppURL "http://Clipboard.QuickAccessPopup.com"
#define MyAppExeName "QuickAccessClipboard.exe"
#define MyDateYearString GetDateTimeString('yyyy', '', '');
#define MyAppCopyright "Copyright (c) Jean Lalonde 2021-"
#define MyAppDescription "Quick Access Clipboard (Windows software)"
#define QACmessengerVersionFileName "QACmessenger-0_1-32-bit.exe"
#define JLdir "JeanLalonde"
#define JLicons "JLicons-1_6_3.dll"
#define QACrules "QACrules.exe"

[CustomMessages]
; Example
; VariableName=Text
; Filename: "https://clipboard.quickaccesspopup.com/example/"; Description: "{cm:VariableName}"; Flags: postinstall shellexec unchecked
HelpMePayExpenses=&HELP me pay EXPENSES for making QAC
; dutch.HelpMePayExpenses=&Help me om de uitgaven te betalen om QAC
; french.HelpMePayExpenses=&Aidez-moi à payer mes frais
PaypalCredit=(Paypal or credit cards)
; dutch.PaypalCredit=(Paypal of creditcards)
; french.PaypalCredit=(Paypal ou cartes de crédit)

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{96D5C838-2CE5-4C7E-A581-8A266994171F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright={#MyAppCopyright}{#MyDateYearString}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\license.txt
OutputDir=C:\Temp\QAC_Compile\
OutputBaseFilename={#MyAppNameLower}-setup{#MyBetaProd}
SetupIconFile=C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#MyAppNameNoSpace}{#MyBetaProd}.ico
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
; AppMutex={#MyAppNameNoSpace}Mutex -> do not use AppMutex - Use instead automatic closing when install and [Code] section when uninstall
; DisableWelcomePage=yes -> keep default and display (make it is displayed)
DisableWelcomePage=no
; DisableReadyPage=yes -> keep default and display
; display Dir page only at first install but show dir on ready page
DisableDirPage=auto
AlwaysShowDirOnReadyPage=yes
; display Group page only at first install but show group on ready page
DisableProgramGroupPage=auto
AlwaysShowGroupOnReadyPage=yes
; PLUS UTILISÃ‰ SignTool=JeanLalondeCustom sign /t http://timestamp.digicert.com /a $f
; NE FONCTIONNE PAS SignTool=JeanLalondeCustom sign /t http://timestamp.digicert.com /f "C:\Temp\InnoSetup-OutputDir\Certificat-Sectigo.p12" /p Iabdd2019! $f
; Signatures faites avant et aprÃ¨s Inno Setup
VersionInfoVersion={#MyAppVersionNumber}
VersionInfoCopyright={#MyAppCopyright}{#MyDateYearString}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
; Name: "french"; MessagesFile: "compiler:Languages\French.isl"
; Name: "german"; MessagesFile: "compiler:Languages\German.isl"
; Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
; Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
; Name: "swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
; Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
; Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
; Name: "brazilportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
; Name: "chinesetraditional"; MessagesFile: "compiler:Languages\ChineseTraditional.isl"
; Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
; Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Dirs]
; repository for files to be copied to "{userdocs}\\{#MyAppName}" at first QAC execution with quickaccessclipboard.ini and _temp subfolder
Name: "{commonappdata}\{#MyAppName}" 

[Files]
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\build{#MyBetaProd}\{#MyAppNameNoSpace}-64-bit.exe"; DestDir: "{app}"; DestName: "{#MyAppNameNoSpace}.exe"; Check: IsWin64; Flags: 64bit ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\build{#MyBetaProd}\{#MyAppNameNoSpace}-32-bit.exe"; DestDir: "{app}"; DestName: "{#MyAppNameNoSpace}.exe"; Check: "not IsWin64"; Flags: 32bit ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#QACmessengerVersionFileName}"; DestDir: "{app}"; DestName: "QACmessenger.exe"; Flags: ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\Setup-Only\_do_not_remove_or_rename.txt"; DestDir: "{app}"; DestName: "_do_not_remove_or_rename.txt"; Flags: ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#MyAppNameNoSpace}.ico"; DestDir: "{app}"; DestName: "{#MyAppNameNoSpace}.ico"; Flags: ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#JLicons}"; DestDir: "{commonappdata}\{#JLdir}"; DestName: "JLicons.dll"; Flags: sharedfile ignoreversion signonce
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\Setup-Only\_JeanLalonde_read-me.txt"; DestDir: "{commonappdata}\{#JLdir}"; DestName: "_read-me.txt"; Flags: sharedfile ignoreversion
Source: "C:\Dropbox\AutoHotkey\{#MyAppNameNoSpace}\Distribution-files\{#QACrules}"; DestDir: "{commonappdata}\{#MyAppName}"; DestName: "_read-me.txt"; Flags: sharedfile ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[INI]
Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "EN"; Languages: english
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "FR"; Languages: french
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "DE"; Languages: german
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "NL"; Languages: dutch
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "KO"; Languages: korean
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "SV"; Languages: swedish
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "IT"; Languages: italian
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "ES"; Languages: spanish
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "PT-BR"; Languages: brazilportuguese
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "ZH-TW"; Languages: chinesetraditional
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "PT"; Languages: portuguese
; Filename: "{commonappdata}\{#MyAppName}\{#MyAppNameLower}-setup.ini"; Section: "Global"; Key: "LanguageCode"; String: "ZH-CN"; Languages: chinesesimplified

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{commonappdata}\{#MyAppName}"; Tasks: startmenu
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"; Tasks: startmenu
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Tasks: startmenu

[Registry]
; --- SETUP KEYS ---
; APP PATH - setup regardless of SetupExplorerContextMenus()
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\{#MyAppExeName}"; ValueType: string; ValueName: "Path"; ValueData: "{app}"; Flags: uninsdeletekey

; DELETE Run (startup) value in current user (do not create but delete when uninstall)
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: none; ValueName: "{#MyAppName}"; Flags: dontcreatekey uninsdeletevalue
; DELETE Software key (including WorkingFolder value) in current user (do not create but delete when uninstall)
Root: HKCU; Subkey: "Software\Jean Lalonde\Quick Access Clipboard"; ValueType: none; Flags: dontcreatekey uninsdeletekey

[Run]
Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{commonappdata}\{#MyAppName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: waituntilidle postinstall skipifsilent
Filename: "https://www.paypal.com/donate?hosted_button_id=MKS3LBZSUGT6N"; Description: "{cm:HelpMePayExpenses} {cm:PaypalCredit}"; Flags: postinstall shellexec unchecked

[Tasks]
Name: startmenu; Description: "Create a Start Menu folder";

[UninstallDelete]
Type: files; Name: "{userstartup}\{#MyAppNameLower}.lnk"

[Code]
function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // if the page that is asked to be skipped is the licence page, then...
  if (PageID = wpLicense) or (PageID = wpSelectTasks) then
  begin
    // if the app was already installed, skip the page
    Result := (Length(WizardForm.PrevAppDir) > 0);
  end
  else
  begin
    // do not skip other pages (not necessary, but safer)
    Result := False;
  end;
end;

function IsProcessRunning(FileName: String): Boolean;
var
  objSWbemLocator, objSWbemServices: Variant;
begin
  try
    objSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  except
    ShowExceptionMessage;
    Exit;
  end;
  objSWbemServices := objSWbemLocator.ConnectServer();
  objSWbemServices.Security_.ImpersonationLevel := 3;
  Result := (objSWbemServices.ExecQuery('SELECT * FROM Win32_Process WHERE Name="' + FileName + '"').Count > 0);
end;

function InitializeUninstall(): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  while IsProcessRunning('{#MyAppExeName}') do begin
    case MsgBox('{#MyAppName} must be closed before uninstall'+#13#13+'Press OK to close it automatically or CANCEL to close it manually.', mbError, MB_OKCANCEL) of
      IDCANCEL:
      begin
        Result := False;
        Break;
      end;
      IDOK:
      begin
        Exec(ExpandConstant('{sys}\taskkill.exe'), '/im "{#MyAppExeName}" /f', '', SW_HIDE, ewWaitUntilTerminated, ResultCode); 
        if ResultCode = 0 then
        begin
          Result := True;
        end
        else
        begin
          Result := False;
          MsgBox('An error occurred while closing {#MyAppExeName} process.', mbError, MB_OK);
        end;
      end;
    end;
  end;
end;
