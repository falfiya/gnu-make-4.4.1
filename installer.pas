// Credit to https://stackoverflow.com/a/46609047

const RegUninstaller = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + '{#GUID}' + '_is1';
function AlreadyInstalled(): boolean;
begin
   result := RegKeyExists(HKEY_LOCAL_MACHINE, RegUninstaller)
end;

function MakeInPath(): boolean;
var
   resultCode: integer;
   previousCWD: string;
begin
   result := false;

   previousCWD := GetCurrentDir();
   SetCurrentDir(GetTempDir());
   if Exec('make', '--version', '', SW_SHOW, ewWaitUntilTerminated, resultCode) then
      if resultCode = 0 then
         result := true;
   SetCurrentDir(previousCWD);
end;

function InitializeSetup(): Boolean;
begin
   if AlreadyInstalled() then
   begin
      MsgBox('GNU Make 4.4.1 has already been installed previously!', mbInformation, MB_OK);
      result := false;
      exit;
   end;

   if MakeInPath() then
      if MsgBox('"make" was already found in the System %PATH%'#10'Do you want to install anyways?', mbConfirmation, MB_YESNO) <> IDYES then
      begin
         result := false;
         exit;
      end;

   result := true;
end;

const RegEnvironment = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
function GetPath(): string;
begin
   if not RegQueryStringValue(HKEY_LOCAL_MACHINE, RegEnvironment, 'Path', result) then
      result := '';
end;

procedure SetPath(NewPath: string);
begin
   RegWriteStringValue(HKEY_LOCAL_MACHINE, RegEnvironment, 'Path', NewPath);
end;

// This function removes one GNU Make path entry if it can find it.
// It returns true on success.
function RemoveGNUMakePathEntry(): boolean;
var
   path: string;
   pathLength: integer;
   gnuMakePath: string;
   gnuMakeStart: integer;
   gnuMakeLength: integer;
   idx: integer;
begin
   path := GetPath();
   pathLength := Length(path);
   gnuMakePath := ExpandConstant('{app}');
   gnuMakeStart := Pos(gnuMakePath, path);
   gnuMakeLength := 0;

   if gnuMakeStart = 0 then
   begin
      result := false
      exit;
   end;

   // Imagine gnuMakePath is C:\GNUMake. There are three separate cases we need
   // to handle.
   //
   // Start
   //    C:\GNUMake;C:\Windows;C:\Windows\System32
   //    -----------
   // Middle
   //    C:\Windows;C:\GNUMake;C:\Windows\System32
   //               -----------
   // End
   //    C:\Windows;C:\Windows\System32;C:\GNUMake
   //                                  -----------

   while true do
   begin
      idx := gnuMakeStart + gnuMakeLength;
      if idx > pathLength then
      begin
         // We have reached the end.
         // Bump gnuMakeStart backwards once to get the preceding semi.
         gnuMakeStart := gnuMakeStart - 1;
         gnuMakeLength := gnuMakeLength + 1;
         break;
      end;

      if path[idx] = ';' then
      begin
         gnuMakeLength := gnuMakeLength + 1;
         break;
      end;

      gnuMakeLength := gnuMakeLength + 1;
   end;

   Delete(path, gnuMakeStart, gnuMakeLength);
   SetPath(path);
   result := true;
end;

// To remove all GNU Make path entries, we should call RemoveGNUMakePathEntry
// until it finally doesn't find an offending GNU Make path entry.
procedure RemoveGNUMakePathEntries();
begin
   while RemoveGNUMakePathEntry() do
end;

procedure AddGNUMakePathEntry();
begin
   SetPath(GetPath() + ';' + ExpandConstant('{app}'));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
   if CurStep = ssPostInstall then
      if WizardIsTaskSelected('addPath') then
      begin
         RemoveGNUMakePathEntries(); // just to be cautious
         AddGNUMakePathEntry();
      end
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
   if CurUninstallStep = usPostUninstall then
      RemoveGNUMakePathEntries();
end;
