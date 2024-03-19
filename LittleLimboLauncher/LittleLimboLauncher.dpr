program LittleLimboLauncher;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {form_mainform},
  LaunchMethod in 'LaunchMethod.pas',
  MainMethod in 'MainMethod.pas',
  Log4Delphi in 'Log4Delphi.pas',
  BackgroundMethod in 'BackgroundMethod.pas',
  LanguageMethod in 'LanguageMethod.pas',
  MyCustomWindow in 'MyCustomWindow.pas',
  AccountMethod in 'AccountMethod.pas',
  ProgressMethod in 'ProgressMethod.pas',
  PrivacyMethod in 'PrivacyMethod.pas',
  ResourceMethod in 'ResourceMethod.pas',
  ManageMethod in 'ManageMethod.pas',
  LauncherMethod in 'LauncherMethod.pas',
  DownloadMethod in 'DownloadMethod.pas',
  CustomDlMethod in 'CustomDlMethod.pas',
  VersionMethod in 'VersionMethod.pas',
  ExportMethod in 'ExportMethod.pas',
  OnlineIPv6Method in 'OnlineIPv6Method.pas',
  MultiPluginMethod in 'MultiPluginMethod.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tform_mainform, form_mainform);
  Application.Run;
end.
