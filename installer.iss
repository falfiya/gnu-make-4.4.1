#define MyAppName "GNU Make"
#define MyAppVersion "4.4.1"
#define MyAppPublisher "Endiatx"
#define MyAppURL "https://www.gnu.org/software/make/"
#define MyAppExeName "make.exe"
#define GUID "{03A0F6F4-85D8-4C23-AD4F-2AAECE22E899}"

[Setup]
AppId={{#GUID}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ChangesEnvironment=yes
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=.\LICENSE.txt
OutputDir=.
OutputBaseFilename=GNU_Make_4.4.1_Installer
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: ".\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Tasks]
Name: "addPath"; Description: "Add to System PATH"

[Code]

#include "installer.pas"
