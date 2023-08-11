unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Forms, DateUtils, Dialogs,
  StdCtrls, pngimage, WinXCtrls, ComCtrls, VCLTee.TeCanvas, CheckLst, JSON, ShellAPI,
  IniFiles, Menus, ExtCtrls, Controls, Vcl.MPlayer, Log4Delphi, Vcl.Imaging.jpeg,
  Vcl.Buttons;

type
  Tform_mainform = class(TForm)
    mainmenu_mainpage: TMainMenu;
    n_misc: TMenuItem;
    n_message_board: TMenuItem;
    n_answer_book: TMenuItem;
    n_intro_self: TMenuItem;
    n_lucky_today: TMenuItem;
    n_puzzle_game: TMenuItem;
    popupmenu_view_minecraft_info: TPopupMenu;
    n_view_minecraft_info: TMenuItem;
    popupmenu_view_mod_info: TPopupMenu;
    n_view_mod_website: TMenuItem;
    n_view_mod_profile: TMenuItem;
    n_view_mod_mcmod: TMenuItem;
    pagecontrol_mainpage: TPageControl;
    tabsheet_mainpage_part: TTabSheet;
    label_account_view: TLabel;
    label_open_launcher_time: TLabel;
    label_open_launcher_number: TLabel;
    label_launch_game_number: TLabel;
    label_launch_tips: TLabel;
    image_refresh_background_music: TImage;
    image_refresh_background_image: TImage;
    image_exit_running_mc: TImage;
    image_open_download_prograss: TImage;
    button_launch_game: TButton;
    tabsheet_account_part: TTabSheet;
    label_login_avatar: TLabel;
    image_login_avatar: TImage;
    label_all_account: TLabel;
    label_account_return_value: TLabel;
    combobox_all_account: TComboBox;
    button_add_account: TButton;
    button_delete_account: TButton;
    button_refresh_account: TButton;
    button_account_get_uuid: TButton;
    pagecontrol_account_part: TPageControl;
    tabsheet_account_offline_part: TTabSheet;
    label_offline_name: TLabel;
    label_offline_uuid: TLabel;
    groupbox_offline_skin: TGroupBox;
    radiobutton_steve: TRadioButton;
    radiobutton_alex: TRadioButton;
    radiobutton_zuri: TRadioButton;
    radiobutton_sunny: TRadioButton;
    radiobutton_noor: TRadioButton;
    radiobutton_makena: TRadioButton;
    radiobutton_kai: TRadioButton;
    radiobutton_efe: TRadioButton;
    radiobutton_ari: TRadioButton;
    checkbox_slim: TCheckBox;
    edit_offline_name: TEdit;
    edit_offline_uuid: TEdit;
    button_offline_name_to_uuid: TButton;
    button_offline_uuid_to_name: TButton;
    tabsheet_account_microsoft_part: TTabSheet;
    label_microsoft_callback_link: TLabel;
    button_microsoft_oauth_login: TButton;
    button_microsoft_external_browser: TButton;
    edit_microsoft_callback_link: TEdit;
    tabsheet_account_thirdparty_part: TTabSheet;
    label_thirdparty_server: TLabel;
    label_thirdparty_account: TLabel;
    label_thirdparty_password: TLabel;
    edit_thirdparty_server: TEdit;
    edit_thirdparty_account: TEdit;
    edit_thirdparty_password: TEdit;
    tabsheet_playing_part: TTabSheet;
    label_playing_tip: TLabel;
    pagecontrol_playing_part: TPageControl;
    tabsheet_playing_download_part: TTabSheet;
    label_playing_search_name: TLabel;
    label_playing_search_version: TLabel;
    label_playing_return_value: TLabel;
    label_playing_search_category_modrinth_tip: TLabel;
    label_playing_search_version_tip: TLabel;
    label_playing_search_category_curseforge_tip: TLabel;
    label_playing_search_mode_tip: TLabel;
    label_playing_search_source_tip: TLabel;
    label_playing_search_name_tip: TLabel;
    listbox_playing_search_name: TListBox;
    listbox_playing_search_version: TListBox;
    button_playing_name_previous_page: TButton;
    button_playing_name_next_page: TButton;
    button_playing_version_previous_page: TButton;
    button_playing_version_next_page: TButton;
    edit_playing_search_name: TEdit;
    combobox_playing_search_source: TComboBox;
    combobox_playing_search_mode: TComboBox;
    combobox_playing_search_category_curseforge: TComboBox;
    combobox_playing_search_version: TComboBox;
    checklistbox_playing_search_category_modrinth: TCheckListBox;
    button_open_download_website: TButton;
    button_playing_start_search: TButton;
    button_playing_start_download: TButton;
    tabsheet_playing_manage_part: TTabSheet;
    tabsheet_download_part: TTabSheet;
    label_download_tip: TLabel;
    pagecontrol_download_part: TPageControl;
    tabsheet_download_minecraft_part: TTabSheet;
    label_choose_view_mode: TLabel;
    label_minecraft_version_name: TLabel;
    label_select_minecraft: TLabel;
    label_select_modloader: TLabel;
    label_download_return_value: TLabel;
    label_download_biggest_thread: TLabel;
    checklistbox_choose_view_mode: TCheckListBox;
    radiogroup_choose_download_source: TRadioGroup;
    edit_minecraft_version_name: TEdit;
    radiogroup_choose_mod_loader: TRadioGroup;
    listbox_select_minecraft: TListBox;
    button_reset_download_part: TButton;
    listbox_select_modloader: TListBox;
    button_load_modloader: TButton;
    button_download_start_download_minecraft: TButton;
    scrollbar_download_biggest_thread: TScrollBar;
    tabsheet_download_custom_part: TTabSheet;
    label_custom_download_url: TLabel;
    label_custom_download_name: TLabel;
    label_custom_download_path: TLabel;
    label_custom_download_path_enter: TLabel;
    edit_custom_download_url: TEdit;
    edit_custom_download_name: TEdit;
    button_custom_download_choose_path: TButton;
    button_custom_download_open_path: TButton;
    button_custom_download_start: TButton;
    tabsheet_download_modloader_part: TTabSheet;
    label_download_modloader_forge: TLabel;
    label_download_modloader_fabric: TLabel;
    label_download_modloader_quilt: TLabel;
    label_download_modloader_neoforge: TLabel;
    listbox_download_modloader_forge: TListBox;
    listbox_download_modloader_fabric: TListBox;
    listbox_download_modloader_quilt: TListBox;
    listbox_download_modloader_neoforge: TListBox;
    button_download_modloader_download: TButton;
    button_download_modloader_refresh: TButton;
    tabsheet_online_part: TTabSheet;
    label_online_tip: TLabel;
    pagecontrol_online_part: TPageControl;
    tabsheet_online_ipv6_part: TTabSheet;
    button_check_ipv6_ip: TButton;
    label_online_ipv6_return_value: TLabel;
    listbox_view_all_ipv6_ip: TListBox;
    label_online_ipv6_port: TLabel;
    edit_online_ipv6_port: TEdit;
    button_copy_ipv6_ip_and_port: TButton;
    button_online_ipv6_tip: TButton;
    label_manage_import_modpack: TLabel;
    listbox_manage_import_modpack: TListBox;
    listbox_manage_import_mod: TListBox;
    listbox_manage_import_map: TListBox;
    listbox_manage_import_resourcepack: TListBox;
    listbox_manage_import_shader: TListBox;
    listbox_manage_import_datapack: TListBox;
    listbox_manage_import_plugin: TListBox;
    label_manage_import_mod: TLabel;
    label_manage_import_map: TLabel;
    label_manage_import_resourcepack: TLabel;
    label_manage_import_shader: TLabel;
    label_manage_import_datapack: TLabel;
    label_manage_import_plugin: TLabel;
    button_disable_choose_playing: TButton;
    button_enable_choose_playing: TButton;
    button_delete_choose_playing: TButton;
    button_rename_choose_playing: TButton;
    button_open_choose_playing: TButton;
    tabsheet_background_part: TTabSheet;
    image_mainpage_background_image: TImage;
    n_official: TMenuItem;
    n_entry_official_website: TMenuItem;
    n_support_author: TMenuItem;
    n_support_bmclapi: TMenuItem;
    n_manual: TMenuItem;
    n_export_argument: TMenuItem;
    n_current_version: TMenuItem;
    n_check_update: TMenuItem;
    n_test_button: TMenuItem;
    n_languages: TMenuItem;
    n_plugins: TMenuItem;
    label_background_tip: TLabel;
    label_standard_color: TLabel;
    button_grass_color: TButton;
    button_sun_color: TButton;
    button_sultan_color: TButton;
    button_sky_color: TButton;
    button_cute_color: TButton;
    button_normal_color: TButton;
    buttoncolor_custom_color: TButtonColor;
    scrollbar_background_window_alpha: TScrollBar;
    label_background_window_alpha: TLabel;
    label_background_window_current_alpha: TLabel;
    groupbox_background_music_setting: TGroupBox;
    button_background_play_music: TButton;
    button_background_pause_music: TButton;
    button_background_stop_music: TButton;
    radiobutton_background_music_open: TRadioButton;
    radiobutton_background_music_launch: TRadioButton;
    radiobutton_background_music_not: TRadioButton;
    groupbox_background_launch_setting: TGroupBox;
    radiobutton_background_launch_hide: TRadioButton;
    radiobutton_background_launch_show: TRadioButton;
    radiobutton_background_launch_exit: TRadioButton;
    groupbox_background_gradient: TGroupBox;
    toggleswitch_background_gradient: TToggleSwitch;
    label_background_mainform_title: TLabel;
    edit_background_mainform_title: TEdit;
    label_background_control_alpha: TLabel;
    scrollbar_background_control_alpha: TScrollBar;
    label_background_control_current_alpha: TLabel;
    tabsheet_launch_part: TTabSheet;
    label_launch_window_size: TLabel;
    label_launch_window_default_tip: TLabel;
    label_launch_java_path: TLabel;
    combobox_launch_select_java_path: TComboBox;
    label_launch_java_logic: TLabel;
    button_launch_full_scan_java: TButton;
    button_launch_basic_scan_java: TButton;
    button_launch_manual_import: TButton;
    button_launch_remove_java: TButton;
    button_launch_download_java_8: TButton;
    button_launch_download_java_17: TButton;
    button_launch_download_java_16: TButton;
    button_launch_official_java: TButton;
    label_launch_custom_info: TLabel;
    edit_launch_custom_info: TEdit;
    label_launch_custom_info_default: TLabel;
    label_launch_game_title: TLabel;
    edit_launch_game_title: TEdit;
    label_launch_game_title_default: TLabel;
    label_launch_pre_launch_script: TLabel;
    edit_launch_pre_launch_script: TEdit;
    button_launch_pre_launch_script_tip: TButton;
    label_launch_default_jvm_argument: TLabel;
    edit_launch_default_jvm_argument: TEdit;
    button_launch_default_jvm_argument_tip: TButton;
    label_launch_additional_jvm_argument: TLabel;
    edit_launch_additional_jvm_argument: TEdit;
    button_launch_additional_jvm_argument_tip: TButton;
    label_launch_additional_game_argument: TLabel;
    edit_launch_additional_game_argument: TEdit;
    button_launch_additional_game_argument_tip: TButton;
    tabsheet_version_part: TTabSheet;
    pagecontrol_version_part: TPageControl;
    label_version_tip: TLabel;
    tabsheet_version_control_part: TTabSheet;
    tabsheet_version_isolation_part: TTabSheet;
    label_select_game_version: TLabel;
    label_select_file_list: TLabel;
    combobox_select_game_version: TComboBox;
    combobox_select_file_list: TComboBox;
    label_version_name: TLabel;
    button_version_choose_any_directory: TButton;
    button_version_create_minecraft: TButton;
    label_version_add_mc_path: TLabel;
    label_version_choose_path: TLabel;
    edit_version_name: TEdit;
    label_version_current_path: TLabel;
    tabsheet_version_export_part: TTabSheet;
    radiogroup_partition_version: TRadioGroup;
    button_add_version_to_list: TButton;
    button_version_complete: TButton;
    button_clear_version_list: TButton;
    button_rename_version_list: TButton;
    button_remove_version_list: TButton;
    button_rename_game_version: TButton;
    button_delete_game_version: TButton;
    label_isolation_current_version: TLabel;
    label_is_open_isolation: TLabel;
    toggleswitch_is_open_isolation: TToggleSwitch;
    label_isolation_java_path: TLabel;
    edit_isolation_java_path: TEdit;
    button_isolation_choose_java: TButton;
    label_isolation_custom_info: TLabel;
    edit_isolation_custom_info: TEdit;
    edit_isolation_window_title: TEdit;
    label_isolation_window_title: TLabel;
    label_isolation_window_size: TLabel;
    label_launch_game_memory: TLabel;
    scrollbar_launch_game_memory: TScrollBar;
    label_launch_current_memory: TLabel;
    label_isolation_game_memory: TLabel;
    scrollbar_isolation_game_memory: TScrollBar;
    label_isolation_current_memory: TLabel;
    toggleswitch_isolation_open_memory: TToggleSwitch;
    label_isolation_partition: TLabel;
    toggleswitch_isolation_open_partition: TToggleSwitch;
    radiobutton_isolation_open_partition: TRadioButton;
    radiobutton_isolation_close_partition: TRadioButton;
    toggleswitch_isolation_choose_java: TToggleSwitch;
    label_isolation_additional_game: TLabel;
    edit_isolation_additional_game: TEdit;
    label_isolation_additional_jvm: TLabel;
    edit_isolation_additional_jvm: TEdit;
    label_isolation_pre_launch_script: TLabel;
    edit_isolation_pre_launch_script: TEdit;
    label_isolation_tip: TLabel;
    label_export_current_version: TLabel;
    label_export_mode: TLabel;
    radiobutton_export_mcbbs: TRadioButton;
    edit_export_modpack_name: TEdit;
    radiobutton_export_multimc: TRadioButton;
    label_export_mode_more: TLabel;
    label_export_modpack_name: TLabel;
    edit_export_modpack_author: TEdit;
    label_export_modpack_author: TLabel;
    label_export_modpack_version: TLabel;
    edit_export_modpack_version: TEdit;
    edit_export_update_link: TEdit;
    label_export_update_link: TLabel;
    label_export_official_website: TLabel;
    edit_export_official_website: TEdit;
    label_export_mcbbs_tid: TLabel;
    edit_export_mcbbs_tid: TEdit;
    label_export_authentication_server: TLabel;
    edit_export_authentication_server: TEdit;
    label_export_additional_game: TLabel;
    edit_export_additional_game: TEdit;
    label_export_additional_jvm: TLabel;
    edit_export_additional_jvm: TEdit;
    label_export_memory: TLabel;
    scrollbar_export_max_memory: TScrollBar;
    memo_export_modpack_profile: TMemo;
    label_export_modpack_profile: TLabel;
    treeview_export_keep_file: TTreeView;
    label_export_keep_file: TLabel;
    button_export_start: TButton;
    label_export_current_memory: TLabel;
    timer_all_ticks: TTimer;
    timer_form_gradient_tick: TTimer;
    scrollbar_background_gradient_value: TScrollBar;
    label_background_gradient_value: TLabel;
    label_background_gradient_current_value: TLabel;
    scrollbar_background_gradient_step: TScrollBar;
    label_background_gradient_step: TLabel;
    label_background_gradient_current_step: TLabel;
    scrollbar_launch_window_width: TScrollBar;
    scrollbar_launch_window_height: TScrollBar;
    label_launch_window_current_height: TLabel;
    label_launch_window_current_width: TLabel;
    label_launch_download_java: TLabel;
    label_launch_window_height_tip: TLabel;
    label_launch_window_width_tip: TLabel;
    scrollbar_isolation_window_height: TScrollBar;
    toggleswitch_isolation_window_height: TToggleSwitch;
    scrollbar_isolation_window_width: TScrollBar;
    toggleswitch_isolation_window_width: TToggleSwitch;
    label_isolation_window_current_width: TLabel;
    label_isolation_window_current_height: TLabel;
    label_isolation_window_width_tip: TLabel;
    label_isolation_window_height_tip: TLabel;
    n_reset_launcher: TMenuItem;
    procedure button_launch_gameClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pagecontrol_mainpageChange(Sender: TObject);
    procedure pagecontrol_mainpageChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure scrollbar_background_window_alphaChange(Sender: TObject);
    procedure scrollbar_background_control_alphaChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure image_refresh_background_musicClick(Sender: TObject);
    procedure image_refresh_background_imageClick(Sender: TObject);
    procedure radiobutton_background_music_openClick(Sender: TObject);
    procedure radiobutton_background_music_launchClick(Sender: TObject);
    procedure radiobutton_background_music_notClick(Sender: TObject);
    procedure radiobutton_background_launch_hideClick(Sender: TObject);
    procedure radiobutton_background_launch_showClick(Sender: TObject);
    procedure radiobutton_background_launch_exitClick(Sender: TObject);
    procedure toggleswitch_background_gradientClick(Sender: TObject);
    procedure scrollbar_background_gradient_valueChange(Sender: TObject);
    procedure scrollbar_background_gradient_stepChange(Sender: TObject);
    procedure buttoncolor_custom_colorClick(Sender: TObject);
    procedure button_grass_colorClick(Sender: TObject);
    procedure button_sun_colorClick(Sender: TObject);
    procedure button_sultan_colorClick(Sender: TObject);
    procedure button_sky_colorClick(Sender: TObject);
    procedure button_cute_colorClick(Sender: TObject);
    procedure button_normal_colorClick(Sender: TObject);
    procedure edit_background_mainform_titleChange(Sender: TObject);
    procedure timer_form_gradient_tickTimer(Sender: TObject);
    procedure button_background_play_musicClick(Sender: TObject);
    procedure button_background_pause_musicClick(Sender: TObject);
    procedure button_background_stop_musicClick(Sender: TObject);
    procedure button_add_accountClick(Sender: TObject);
    procedure combobox_all_accountChange(Sender: TObject);
    procedure button_delete_accountClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  LauncherVersion = '0.1.3-Beta-3';

var
  form_mainform: Tform_mainform;
  LLLini, OtherIni: TIniFile;
  AppData: String;
  Log: Log4D;
  crash_count: Integer = 0;
  mcpid: Integer = 0;
  Cave, Answer, Lucky: TStringList;
  Intro: array of array of String;
  v: TMediaPlayer;
var
  mopen_time, maccount_view: String;
  mopen_number, mlaunch_number: Integer;
  mred, mgreen, mblue, mwindow_alpha, mcontrol_alpha: Integer;
  mgradient_value, mgradient_step: Integer;
  mis_gradient: Boolean;

implementation

uses
  MainMethod, LaunchMethod, BackgroundMethod, LanguageMethod, AccountMethod, MyCustomWindow;

{$R *.dfm}
//�������ã��Զ�����ɫ��ť
procedure Tform_mainform.buttoncolor_custom_colorClick(Sender: TObject);
begin
  Color := buttoncolor_custom_color.SymbolColor;
  mred := Color and $FF;
  mgreen := (Color and $FF00) shr 8;
  mblue := (Color and $FF0000) shr 16;
end;
//�˺Ų��֣�����˺�
procedure Tform_mainform.button_add_accountClick(Sender: TObject);
begin
  if combobox_all_account.Items.Count > 32 then begin
    MyMessagebox('��¼���˺�̫����', '���¼���˺ų���32���ˣ���ɾ��һЩ֮�������µ�¼�ɣ�', MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  if pagecontrol_account_part.ActivePage = tabsheet_account_offline_part then begin
    OfflineLogin(edit_offline_name.Text, edit_offline_uuid.Text);
  end;
end;
//�������ã���ͣ����
procedure Tform_mainform.button_background_pause_musicClick(Sender: TObject);
begin
  if v.FileName = '' then
    exit;
  v.Pause;
end;
//�������ã���������
procedure Tform_mainform.button_background_play_musicClick(Sender: TObject);
begin
  if v.FileName = '' then begin
    ResetBackMusic(true);
  end else begin
    if v.Mode = mpPaused then
      v.Resume
    else
      PlayMusic;
  end;
end;
//�������ã�ֹͣ����
procedure Tform_mainform.button_background_stop_musicClick(Sender: TObject);
begin
  if v.FileName = '' then
    exit;
  v.Stop;
  v.Position := 0;
end;
//�������ã��ɰ���
procedure Tform_mainform.button_cute_colorClick(Sender: TObject);
begin
  mred := 255;
  mgreen := 110;
  mblue := 180;
  Color := rgb(mred, mgreen, mblue);
  buttoncolor_custom_color.SymbolColor := Color;
end;
//ɾ���˺�
procedure Tform_mainform.button_delete_accountClick(Sender: TObject);
begin
  //
end;
//�������ã�С����
procedure Tform_mainform.button_grass_colorClick(Sender: TObject);
begin
  mred := 50;
  mgreen := 205;
  mblue := 50;
  Color := rgb(mred, mgreen, mblue);
  buttoncolor_custom_color.SymbolColor := Color;
end;
//�����棺������Ϸ��ť
procedure Tform_mainform.button_launch_gameClick(Sender: TObject);
begin
//  var mm := TTabSheet.Create(pagecontrol_mainpage);
//  with mm do begin
//    mm.Parent := pagecontrol_mainpage;
//  end;
//  pagecontrol_mainpage.ActivePage := mm;
//  image_finish_running_mc.Cursor := crHelp;
//  mm.Show;
//  pagecontrol_mainpage.ActivePage := mm;
//  ���ؼ��Ĵ�����ʽ����Ϊ WS_EX_LAYERED

//  ʹ�� SetLayeredWindowAttributes �������ÿؼ���͸����
//  showmessage('finish!!');
//  self.Color := buttonColor1.SymbolColor;
//  self.Color := 0;
//  var MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
//  if SetProcessWorkingSetSize(GetCurrentProcess, 1024 * 1024, 1024 * 4096) then begin
//    showmessage('OK')
//  end else showmessage('NO');
//  CloseHandle(MainHandle);
//  try
//    var MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
//    if SetProcessWorkingSetSize(GetCurrentProcess, $FFFFFFFF, $FFFFFFFF) then showmessage('OK1');
//    CloseHandle(MainHandle);
//    showmessage('OK2');
//  except
//    // �����쳣
//    showmessage('NO');
//  end;
end;
//�������ã�Ĭ�ϰ�
procedure Tform_mainform.button_normal_colorClick(Sender: TObject);
begin
  mred := 240;
  mgreen := 240;
  mblue := 240;
  Color := rgb(mred, mgreen, mblue);
  buttoncolor_custom_color.SymbolColor := Color;
end;
//�������ã������
procedure Tform_mainform.button_sky_colorClick(Sender: TObject);
begin
  mred := 0;
  mgreen := 191;
  mblue := 255;
  Color := rgb(mred, mgreen, mblue);
  buttoncolor_custom_color.SymbolColor := Color;
end;
//�������ã��յ���
procedure Tform_mainform.button_sultan_colorClick(Sender: TObject);
begin
  mred := 189;
  mgreen := 0;
  mblue := 0;
  Color := rgb(mred, mgreen, mblue);
  buttoncolor_custom_color.SymbolColor := Color;
end;
//�������ã������
procedure Tform_mainform.button_sun_colorClick(Sender: TObject);
begin
  mred := 255;
  mgreen := 215;
  mblue := 0;
  Color := rgb(mred, mgreen, mblue);
  buttoncolor_custom_color.SymbolColor := Color;
end;
//�˺Ų��֣������˺�������ı��¼�
procedure Tform_mainform.combobox_all_accountChange(Sender: TObject);
begin
  var pla := ((AccountJson.Values['account'] as TJsonArray)[combobox_all_account.ItemIndex] as TJsonObject);
  var pln := pla.GetValue('name').Value;
  JudgeJSONSkin;
  label_account_return_value.Caption := Concat('�ѵ�¼��������ƣ�', pln);
end;
//�������ã����ڱ���
procedure Tform_mainform.edit_background_mainform_titleChange(Sender: TObject);
begin
  Caption := edit_background_mainform_title.Text;
end;

//�����棺���ڹر��¼�
procedure Tform_mainform.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveBackground;
  SaveAccount;
  ShellExecute(Application.Handle, 'open', 'taskkill.exe', '/F /IM LittleLimboLauncher.exe', nil, SW_HIDE);
end;
//�����棺���ڴ����¼�
procedure Tform_mainform.FormCreate(Sender: TObject);
begin
  Log := Log4D.Create;
  Log.Write('���ڴ�����', LOG_INFO);
  AppData := GetEnvironmentVariable('AppData');
  Cave := TStringList.Create;
  Answer := TStringList.Create;
  Lucky := TStringList.Create;
  v := TMediaPlayer.Create(nil);
  Log.Write('��ʼ������1��ϡ�', LOG_INFO);
  LLLini := TIniFile.Create(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\LittleLimboLauncher.ini'));
  OtherIni := TIniFile.Create(Concat(AppData, '\LLLauncher\Other.ini'));
  if not SysUtils.DirectoryExists(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher')) then
    SysUtils.ForceDirectories(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher'));
  if not SysUtils.DirectoryExists(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\plugins')) then
    SysUtils.ForceDirectories(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\plugins'));
  if not SysUtils.DirectoryExists(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\BackGroundMusic')) then
    SysUtils.ForceDirectories(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\BackGroundMusic'));
  if not SysUtils.DirectoryExists(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\BackGroundImage')) then
    SysUtils.ForceDirectories(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\BackGroundImage'));
  if not SysUtils.DirectoryExists(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs')) then
    SysUtils.ForceDirectories(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs'));
  if not SysUtils.DirectoryExists(Concat(AppData, '\LLLauncher\')) then
    SysUtils.ForceDirectories(Concat(AppData, '\LLLauncher\'));
  if not SysUtils.FileExists(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\', 'LittleLimboLauncher.ini')) then
  begin
    LLLini.WriteString('Version', 'CustomInfo', 'LLL');
    LLLini.WriteBool('Version', 'ShowRelease', True);
    LLLini.WriteBool('Version', 'ShowSnapshot', False);
    LLLini.WriteBool('Version', 'ShowOldBeta', False);
    LLLini.WriteBool('Version', 'ShowOldAlpha', False);
    LLLini.WriteInteger('Version', 'SelectDownloadSource', 1);
    LLLini.WriteInteger('Version', 'SelectIsolation', 4);
    LLLini.WriteInteger('Version', 'ThreadBiggest', 32);
    LLLini.WriteInteger('Mod', 'SelectModSource', 1);
    LLLini.WriteInteger('Mod', 'SelectModMode', 1);
    LLLini.WriteInteger('Mod', 'SelectModCategory', 1);
    LLLini.WriteString('Mod', 'SelectModVersion', '');
    LLLini.WriteInteger('Mod', 'SelectModLoader', 1);
    LLLini.WriteInteger('Document', 'WindowsHeight', 480);
    LLLini.WriteInteger('Document', 'WindowsWidth', 854);
    LLLini.WriteInteger('Document', 'MaxMemory', 1024);
    LLLini.WriteInteger('Misc', 'Red', 240);
    LLLini.WriteInteger('Misc', 'Green', 240);
    LLLini.WriteInteger('Misc', 'Blue', 240);
    LLLini.WriteInteger('Misc', 'WindowAlpha', 255);
    LLLini.WriteInteger('Misc', 'ControlAlpha', 191);
    LLLini.WriteInteger('Misc', 'WindowControl', 2);
    LLLini.WriteInteger('Misc', 'SelectType', 3);
    LLLini.WriteBool('Misc', 'IsGradient', False);
    LLLini.WriteInteger('Misc', 'GradientValue', 20);
    LLLini.WriteString('Misc', 'LauncherName', 'Little Limbo Launcher');
    LLLini.WriteInteger('Account', 'SelectLoginMode', 1);
    LLLini.WriteString('Language', 'SelectLanguageFile', 'zh_cn');
  end;
  if not FileExists(Concat(AppData, '\LLLauncher\Other.ini')) then begin
    Otherini.WriteString('Other', 'Random', inttostr(random(2000000) + 1));
    Otherini.WriteString('Misc', 'Launcher', '0');
    Otherini.WriteString('Misc', 'StartGame', '0');
  end;
  Log.Write('��ʼ������2��ϡ�', LOG_INFO); //���Log
  Log.Write('�ж���ɴ��ڴ����¼���', LOG_INFO);
  InitLanguage;
end;
//�����棺����չʾ�¼�
procedure Tform_mainform.FormShow(Sender: TObject);
begin
  pagecontrol_mainpage.ActivePage := tabsheet_mainpage_part;
  pagecontrol_account_part.ActivePage := tabsheet_account_offline_part;
  pagecontrol_playing_part.ActivePage := tabsheet_playing_download_part;
  pagecontrol_download_part.ActivePage := tabsheet_download_minecraft_part;
  pagecontrol_online_part.ActivePage := tabsheet_online_ipv6_part;
  pagecontrol_version_part.ActivePage := tabsheet_version_control_part;
  v.ParentWindow := Handle;
  v.Visible := False;
  Log.Write('���ڶ�ȡ�����ļ�����', LOG_INFO);
  var langtle := LLLini.ReadString('Language', 'SelectLanguageFile', '');
  SetLanguage(langtle);
  Log.Write('��ʼ�жϴ�����ʾ�¼���', LOG_INFO);
  try  //�жϴ��������Ĵ���
    Log.Write('��ʼ�жϴ�������������', LOG_INFO);
    mopen_number := Otherini.ReadInteger('Misc', 'Launcher', -1) + 1;
    if mopen_number < 1 then raise Exception.Create('Format Exception');
    Otherini.WriteString('Misc', 'Launcher', inttostr(mopen_number));
    Log.Write(Concat('�жϳɹ���������������Ϊ', inttostr(mopen_number), '�Ρ�'), LOG_INFO);
  except
    mopen_number := 1;
    Log.Write('�жϴ�����������ʧ�ܣ�Ĭ�Ͻ�Ϊ1�Ρ�', LOG_ERROR);
    Otherini.WriteString('Misc', 'Launcher', inttostr(mopen_number));
  end;
  label_open_launcher_number.Caption := GetLanguageText('label_open_launcher_number.caption').Replace('${open_launcher_number}', inttostr(mopen_number));
  try  //�ж�������Ϸ�Ĵ���
    Log.Write(Concat('��ʼ�ж�������Ϸ�Ĵ�����'), LOG_INFO);
    mlaunch_number := Otherini.ReadInteger('Misc', 'StartGame', -1);
    if mlaunch_number < 0 then raise Exception.Create('Format Exception');
    Log.Write(Concat('�жϳɹ���������Ϸ����Ϊ', inttostr(mlaunch_number), '�Ρ�'), LOG_INFO);
  except
    mlaunch_number := 0;
    Log.Write(Concat('�ж�������Ϸ����ʧ�ܣ�Ĭ�Ͻ�Ϊ1�Ρ�'), LOG_ERROR);
    Otherini.WriteString('Misc', 'StartGame', inttostr(mlaunch_number));
  end;
  label_launch_game_number.Caption := GetLanguageText('label_launch_game_number.caption').Replace('${launch_game_number}', inttostr(mlaunch_number));
  Log.Write(Concat('��ʾ���մ������������ڡ�'), LOG_INFO);//��ʾ��������
  label_open_launcher_time.Caption := GetLanguageText('label_open_launcher_time.caption').Replace('${open_launcher_time}', Now.Format('yyyy/mm/dd HH:nn:ss'));
  try //�����˺Ų���ֵ
    Log.Write(Concat('��ʼ�����˺Ų����Ƿ���Ϲ涨��'), LOG_INFO);
    var json := GetFile(Concat(AppData, '\LLLauncher\AccountJson.json'));
    var s := strtoint(OtherIni.ReadString('Account', 'SelectAccount', '')) - 1;
    if s <= -1 then raise Exception.Create('Format Exception');
    maccount_view := (((TJsonObject.ParseJSONValue(json) as TJsonObject).GetValue('account') as TJsonArray)[s] as TJsonObject).GetValue('name').Value;
    Log.Write(Concat('�˺��ж���ϣ���ӭ', maccount_view, '��'), LOG_INFO);
    label_account_view.Caption := GetLanguageText('label_account_view.caption.have').Replace('${account_view}', maccount_view);
  except
    maccount_view := '';
    Log.Write(Concat('�˺��ж�ʧ�ܣ�������δ��¼һ���˺š�'), LOG_ERROR);
    label_account_view.Caption := GetLanguageText('label_account_view.caption.absence');
  end;
  try  //��ѯ�汾�Ƿ���������Ҳ���������δѡ��汾��
    Log.Write('��ʼ�ж���Ϸ�汾��', LOG_INFO);
    var ssj := strtoint(LLLini.ReadString('MC', 'SelectVer', ''));
    var sjn := GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\MCSelJson.json'));
    var svr := ((TJsonObject.ParseJSONValue(sjn) as TJsonObject).GetValue('mcsel') as TJsonArray)[ssj - 1] as TJsonObject;
    var svv := svr.GetValue('name').Value;
    var svp := svr.GetValue('path').Value;
    if IsVersionError(svp) then begin
      Log.Write('��Ϸ�汾������δ�ҵ�Json��', LOG_ERROR);
      svv := Concat(svv, GetLanguageText('button_launch_game.caption.error.cannot_find_json'));
    end else if GetMCInheritsFrom(svp, 'inheritsFrom') = '' then begin
      Log.Write('��Ϸ�汾������ȱ��ǰ�ð汾��', LOG_ERROR);
      svv := Concat(svv, GetLanguageText('button_launch_game.caption.error.missing_inherits_version'));
    end;
    var IltIni := TIniFile.Create(Concat(svp, '\LLLauncher.ini'));
    if IltIni.ReadString('Isolation', 'IsIsolation', '') = 'True' then svv := Concat(svv, GetLanguageText('button_launch_game.caption.isolation'));
    Log.Write(Concat('��Ϸ�汾����ȷ������ѡ�汾Ϊ��', svv), LOG_INFO);
    button_launch_game.Caption := GetLanguageText('button_launch_game.caption').Replace('${launch_version_name}', svv);
  except
    Log.Write('��Ϸ�汾���Ҳ�����ѡVersion�ļ��У��ж�Ϊ��δѡ��һ���汾��', LOG_ERROR);
    button_launch_game.Caption := GetLanguageText('button_launch_game.caption.absence');
  end;
  Log.Write(Concat('��ʼ�жϴ�����ɫ��'), LOG_INFO);
  try //�ж�RGBA
    mred := LLLini.ReadInteger('Misc', 'Red', -1);
    if (mred > 255) or (mred < 0) then raise Exception.Create('Format Exception');
  except
    Log.Write(Concat('������ɫ����λ�ã�Ini�ļ���Red��ɫλ�á�'), LOG_ERROR);
    mred := 240;
    LLLini.WriteInteger('Misc', 'Red', mred);
  end;
  try
    mgreen := LLLini.ReadInteger('Misc', 'Green', -1);
    if (mgreen > 255) or (mgreen < 0) then raise Exception.Create('Format Exception');
  except
    Log.Write(Concat('������ɫ����λ�ã�Ini�ļ���Green��ɫλ�á�'), LOG_ERROR);
    mgreen := 240;
    LLLini.WriteInteger('Misc', 'Green', mgreen);
  end;
  try
    mblue := LLLini.ReadInteger('Misc', 'Blue', -1);
    if (mblue > 255) or (mblue < 0) then raise Exception.Create('Format Exception');
  except
    Log.Write(Concat('������ɫ����λ�ã�Ini�ļ���Blue��ɫλ�á�'), LOG_ERROR);
    mblue := 240;
    LLLini.WriteInteger('Misc', 'Blue', mblue);
  end;
  Caption := LLLini.ReadString('Misc', 'LauncherName', '');
  try
    mwindow_alpha := LLLini.ReadInteger('Misc', 'WindowAlpha', -1);
    if (mwindow_alpha > 255) or (mwindow_alpha < 127) then raise Exception.Create('Format Exception');
  except
    Log.Write(Concat('����͸��������λ�ã�Ini�ļ���WindowAlphaλ�á�'), LOG_ERROR);
    mwindow_alpha := 255;
    LLLini.WriteInteger('Misc', 'WindowAlpha', mwindow_alpha);
  end;
  AlphaBlendValue := mwindow_alpha;
  try
    mcontrol_alpha := LLLini.ReadInteger('Misc', 'ControlAlpha', -1);
    if (mcontrol_alpha < 63) or (mcontrol_alpha > 191) then raise Exception.Create('Format Exception');
  except
    Log.Write(Concat('����͸��������λ�ã�Ini�ļ���ControlAlphaλ�á�'), LOG_ERROR);
    mcontrol_alpha := 191;
    LLLini.WriteInteger('Misc', 'ControlAlpha', mcontrol_alpha);
  end;
  mis_gradient := LLLini.ReadBool('Misc', 'IsGradient', False);
  mgradient_value := LLLini.ReadInteger('Misc', 'GradientValue', -1);
  try
    if (mgradient_value > 100) or (mgradient_value < 1) then raise Exception.Create('Format Exception');
  except
    mgradient_value := 20;
    LLLini.WriteInteger('Misc', 'GradientValue', mgradient_value);
  end;
  mgradient_step := LLLini.ReadInteger('Misc', 'GradientStep', -1);
  try
    if (mgradient_step > 10) or (mgradient_step < 1) then raise Exception.Create('Format Exception');
  except
    mgradient_step := 10;
    LLLini.WriteInteger('Misc', 'GradientStep', mgradient_step);
  end;
  timer_form_gradient_tick.Interval := mgradient_value;
  SetWindowLong(pagecontrol_mainpage.Handle, GWL_EXSTYLE, GetWindowLong(pagecontrol_mainpage.Handle, GWL_EXSTYLE) or WS_EX_LAYERED);
  SetLayeredWindowAttributes(pagecontrol_mainpage.Handle, RGB(255, 255, 255), mcontrol_alpha, LWA_ALPHA);
  Log.Write(Concat('���ж���ɣ���ʼӦ�ô�����ɫ��'), LOG_INFO);
  Color := rgb(mred, mgreen, mblue); //ʵװRGBA��
  ResetBackImage(false);
end;
//�����棺ͼƬ�л���ť
procedure Tform_mainform.image_refresh_background_imageClick(Sender: TObject);
begin
  ResetBackImage(true);
end;
//�����棺�����л���ť
procedure Tform_mainform.image_refresh_background_musicClick(Sender: TObject);
begin
  ResetBackMusic(true);
end;
//�����棺�����л�ҳ
procedure Tform_mainform.pagecontrol_mainpageChange(Sender: TObject);
begin
  if pagecontrol_mainpage.ActivePage = tabsheet_background_part then
    InitBackground
  else if pagecontrol_mainpage.ActivePage = tabsheet_account_part then
    InitAccount;
end;
//�����棺�л���ҳǰ
procedure Tform_mainform.pagecontrol_mainpageChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if pagecontrol_mainpage.ActivePage = tabsheet_background_part then
    SaveBackground
  else if pagecontrol_mainpage.ActivePage = tabsheet_account_part then
    SaveAccount;
end;
//�������ã�������Ϸʱ�˳����ڵĵ�ѡ��
procedure Tform_mainform.radiobutton_background_launch_exitClick(
  Sender: TObject);
begin
  mwindow_control := 3;
end;
//�������ã�������Ϸʱ���ش��ڵĵ�ѡ��
procedure Tform_mainform.radiobutton_background_launch_hideClick(
  Sender: TObject);
begin
  mwindow_control := 1;
end;
//�������ã�������Ϸʱ��ʾ���ڵĵ�ѡ��
procedure Tform_mainform.radiobutton_background_launch_showClick(
  Sender: TObject);
begin
  mwindow_control := 2;
end;
//�������ã�������Ϸʱ�������ֵĵ�ѡ��
procedure Tform_mainform.radiobutton_background_music_launchClick(
  Sender: TObject);
begin
  mselect_type := 2;
end;
//�������ã����������ֵĵ�ѡ��
procedure Tform_mainform.radiobutton_background_music_notClick(Sender: TObject);
begin
  mselect_type := 3;
end;
//�������ã���������ʱ�������ֵĵ�ѡ��
procedure Tform_mainform.radiobutton_background_music_openClick(
  Sender: TObject);
begin
  mselect_type := 1;
end;
//�������ã��ؼ�͸���Ȼ�����
procedure Tform_mainform.scrollbar_background_control_alphaChange(
  Sender: TObject);
begin
  mcontrol_alpha := scrollbar_background_control_alpha.Position;
  label_background_control_current_alpha.Caption := GetLanguageText('label_background_control_current_alpha.caption').Replace('${control_alpha}', inttostr(mcontrol_alpha));
  SetLayeredWindowAttributes(pagecontrol_mainpage.Handle, RGB(255, 255, 255), mcontrol_alpha, LWA_ALPHA);
end;
//�������ã����ڽ����������������
procedure Tform_mainform.scrollbar_background_gradient_stepChange(
  Sender: TObject);
begin
  mgradient_step := scrollbar_background_gradient_step.Position;
  label_background_gradient_current_step.Caption := GetLanguageText('label_background_gradient_current_step.caption').Replace('${gradient_step}', inttostr(mgradient_step));
end;
//�������ã����ڽ������ֵ������
procedure Tform_mainform.scrollbar_background_gradient_valueChange(
  Sender: TObject);
begin
  mgradient_value := scrollbar_background_gradient_value.Position;
  label_background_gradient_current_value.Caption := GetLanguageText('label_background_gradient_current_value.caption').Replace('${gradient_value}', inttostr(mgradient_value));
end;
//�������ã�����͸���Ȼ�����
procedure Tform_mainform.scrollbar_background_window_alphaChange(
  Sender: TObject);
begin
  mwindow_alpha := scrollbar_background_window_alpha.Position;
  label_background_window_current_alpha.Caption := GetLanguageText('label_background_window_current_alpha.caption').Replace('${window_alpha}', inttostr(mwindow_alpha));
  AlphaBlendValue := mwindow_alpha;
end;
//�����ڣ����ڽ��������ʱ��
var mgradient_temp: Integer = 0;
procedure Tform_mainform.timer_form_gradient_tickTimer(Sender: TObject);
begin
  if mis_gradient then begin
    mgradient_temp := mgradient_temp + mgradient_step;
    if mgradient_temp >= mwindow_alpha then begin
      timer_form_gradient_tick.Enabled := False;
      AlphaBlendValue := LLLini.ReadInteger('Misc', 'WindowAlpha', -1);
    end else AlphaBlendValue := mgradient_temp;
  end else timer_form_gradient_tick.Enabled := false;
end;
//�������ã����ڽ����������
procedure Tform_mainform.toggleswitch_background_gradientClick(Sender: TObject);
begin
  if toggleswitch_background_gradient.IsOn then begin
    scrollbar_background_gradient_value.Enabled := true;
  end else begin
    scrollbar_background_gradient_value.Enabled := false;
  end;
  scrollbar_background_gradient_step.Enabled := scrollbar_background_gradient_value.Enabled;
  mis_gradient := scrollbar_background_gradient_value.Enabled;
end;

end.
