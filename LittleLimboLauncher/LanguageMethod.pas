unit LanguageMethod;

interface

uses
  SysUtils, Classes, Forms, JSON, Dialogs, Generics.Collections;

procedure InitLanguage();
procedure SetLanguage(lang: String);
function GetLanguageText(key: String): String;

implementation

uses
  MainMethod, MainForm;

var
  langjson: TJSONObject;

procedure SetLanguage(lang: String);
begin                                                                                          
  if lang = '' then lang := 'zh_cn';
  var langpath := Concat(ExtractFilePath(Application.ExeName), 'LLLauncher\lang\', lang, '.json');
  langjson := TJSONObject.ParseJSONValue(GetFile(langpath)) as TJSONObject;
  //����Ϊҳ
  form_mainform.tabsheet_mainpage_part.Caption := GetLanguageText('tabsheet_mainpage_part.caption');   
  form_mainform.tabsheet_account_part.Caption := GetLanguageText('tabsheet_account_part.caption');
  form_mainform.tabsheet_playing_part.Caption := GetLanguageText('tabsheet_playing_part.caption');
  form_mainform.tabsheet_download_part.Caption := GetLanguageText('tabsheet_download_part.caption');
  form_mainform.tabsheet_online_part.Caption := GetLanguageText('tabsheet_online_part.caption');
  form_mainform.tabsheet_background_part.Caption := GetLanguageText('tabsheet_background_part.caption');
  form_mainform.tabsheet_launch_part.Caption := GetLanguageText('tabsheet_launch_part.caption');
  form_mainform.tabsheet_version_part.Caption := GetLanguageText('tabsheet_version_part.caption');
  form_mainform.tabsheet_account_offline_part.Caption := GetLanguageText('tabsheet_account_offline_part.caption');
  form_mainform.tabsheet_account_microsoft_part.Caption := GetLanguageText('tabsheet_account_microsoft_part.caption');
  form_mainform.tabsheet_account_thirdparty_part.Caption := GetLanguageText('tabsheet_account_thirdparty_part.caption');
  form_mainform.tabsheet_playing_download_part.Caption := GetLanguageText('tabsheet_playing_download_part.caption');
  form_mainform.tabsheet_playing_manage_part.Caption := GetLanguageText('tabsheet_playing_manage_part.caption');
  form_mainform.tabsheet_download_custom_part.Caption := GetLanguageText('tabsheet_download_custom_part.caption');
  form_mainform.tabsheet_download_modloader_part.Caption := GetLanguageText('tabsheet_download_modloader_part.caption');
  form_mainform.tabsheet_online_ipv6_part.Caption := GetLanguageText('tabsheet_online_ipv6_part.caption');
  form_mainform.tabsheet_version_control_part.Caption := GetLanguageText('tabsheet_version_control_part.caption');
  form_mainform.tabsheet_version_isolation_part.Caption := GetLanguageText('tabsheet_version_isolation_part.caption');            
  form_mainform.tabsheet_version_export_part.Caption := GetLanguageText('tabsheet_version_export_part.caption');   
  //����Ϊ�˵���              
  form_mainform.n_misc.Caption := GetLanguageText('menu_misc.caption');                
  form_mainform.n_message_board.Caption := GetLanguageText('menu_misc_board.caption');                
  form_mainform.n_answer_book.Caption := GetLanguageText('menu_misc_answer.caption');                
  form_mainform.n_intro_self.Caption := GetLanguageText('menu_misc_intro.caption');                
  form_mainform.n_lucky_today.Caption := GetLanguageText('menu_misc_lucky.caption');                
  form_mainform.n_puzzle_game.Caption := GetLanguageText('menu_misc_puzzle.caption');                
  form_mainform.n_official.Caption := GetLanguageText('menu_official.caption');                
  form_mainform.n_entry_official_website.Caption := GetLanguageText('menu_official_entry.caption');                
  form_mainform.n_support_author.Caption := GetLanguageText('menu_official_support.caption');                
  form_mainform.n_support_bmclapi.Caption := GetLanguageText('menu_official_bmclapi.caption');                
  form_mainform.n_manual.Caption := GetLanguageText('menu_manual.caption');                
  form_mainform.n_reset_launcher.Caption := GetLanguageText('menu_manual_reset.caption');                
  form_mainform.n_export_argument.Caption := GetLanguageText('menu_manual_export.caption');                
  form_mainform.n_current_version.Caption := GetLanguageText('menu_manual_version.caption');                
  form_mainform.n_check_update.Caption := GetLanguageText('menu_manual_update.caption');                
  form_mainform.n_test_button.Caption := GetLanguageText('menu_manual_test.caption');
  //����Ϊ������
  form_mainform.button_launch_game.hint := GetLanguageText('button_launch_game.hint');                             
  form_mainform.image_refresh_background_image.hint := GetLanguageText('image_refresh_background_image.hint');     
  form_mainform.image_refresh_background_music.hint := GetLanguageText('image_refresh_background_music.hint');
  form_mainform.image_open_download_prograss.hint := GetLanguageText('image_open_download_prograss.hint');
  form_mainform.image_exit_running_mc.hint := GetLanguageText('image_exit_running_mc.hint');     
  //����Ϊ��������         
  form_mainform.label_background_tip.caption := GetLanguageText('label_background_tip.caption');   
  form_mainform.label_standard_color.caption := GetLanguageText('label_standard_color.caption');   
  form_mainform.button_grass_color.caption := GetLanguageText('button_grass_color.caption');   
  form_mainform.button_sun_color.caption := GetLanguageText('button_sun_color.caption');   
  form_mainform.button_sultan_color.caption := GetLanguageText('button_sultan_color.caption');   
  form_mainform.button_sky_color.caption := GetLanguageText('button_sky_color.caption');   
  form_mainform.button_cute_color.caption := GetLanguageText('button_cute_color.caption');   
  form_mainform.button_normal_color.caption := GetLanguageText('button_normal_color.caption');   
  form_mainform.buttoncolor_custom_color.caption := GetLanguageText('buttoncolor_custom_color.caption');    
  form_mainform.label_background_window_alpha.caption := GetLanguageText('label_background_window_alpha.caption');  
  form_mainform.label_background_control_alpha.caption := GetLanguageText('label_background_control_alpha.caption');  
  form_mainform.groupbox_background_music_setting.caption := GetLanguageText('groupbox_background_music_setting.caption');  
  form_mainform.button_background_play_music.caption := GetLanguageText('button_background_play_music.caption');  
  form_mainform.button_background_play_music.hint := GetLanguageText('button_background_play_music.hint');  
  form_mainform.button_background_pause_music.caption := GetLanguageText('button_background_pause_music.caption');  
  form_mainform.button_background_pause_music.hint := GetLanguageText('button_background_pause_music.hint');  
  form_mainform.button_background_stop_music.caption := GetLanguageText('button_background_stop_music.caption');    
  form_mainform.button_background_stop_music.hint := GetLanguageText('button_background_stop_music.hint');       
  form_mainform.radiobutton_background_music_open.caption := GetLanguageText('radiobutton_background_music_open.caption');
  form_mainform.radiobutton_background_music_launch.caption := GetLanguageText('radiobutton_background_music_launch.caption'); 
  form_mainform.radiobutton_background_music_not.caption := GetLanguageText('radiobutton_background_music_not.caption'); 
  form_mainform.groupbox_background_launch_setting.caption := GetLanguageText('groupbox_background_launch_setting.caption'); 
  form_mainform.radiobutton_background_launch_hide.caption := GetLanguageText('radiobutton_background_launch_hide.caption'); 
  form_mainform.radiobutton_background_launch_show.caption := GetLanguageText('radiobutton_background_launch_show.caption'); 
  form_mainform.radiobutton_background_launch_exit.caption := GetLanguageText('radiobutton_background_launch_exit.caption'); 
  form_mainform.label_background_mainform_title.caption := GetLanguageText('label_background_mainform_title.caption'); 
  form_mainform.groupbox_background_gradient.caption := GetLanguageText('groupbox_background_gradient.caption'); 
  form_mainform.toggleswitch_background_gradient.StateCaptions.CaptionOn := GetLanguageText('toggleswitch_background_gradient.on.caption'); 
  form_mainform.toggleswitch_background_gradient.StateCaptions.CaptionOff := GetLanguageText('toggleswitch_background_gradient.off.caption'); 
  form_mainform.label_background_gradient_value.caption := GetLanguageText('label_background_gradient_value.caption'); 
  form_mainform.label_background_gradient_step.caption := GetLanguageText('label_background_gradient_step.caption'); 
end;

procedure InitLanguage();
begin
  if not FileExists(Concat(ExtractFilePath(Application.ExeName), 'LLLauncher\lang\zh_cn.json')) then begin
    var zhcnjson := TJSONObject.Create
      .AddPair('file_language_title', '���ģ����壩')
      //����Ϊҳ
      .AddPair('__pagecontrol_comment', '������ҳ��ؼ�����')
      .AddPair('tabsheet_mainpage_part.caption', '������')
      .AddPair('tabsheet_account_part.caption', '�˺Ų���')
      .AddPair('tabsheet_playing_part.caption', '�淨����')
      .AddPair('tabsheet_download_part.caption', '���ز���')
      .AddPair('tabsheet_online_part.caption', '��������')
      .AddPair('tabsheet_background_part.caption', '��������')
      .AddPair('tabsheet_launch_part.caption', '��������')
      .AddPair('tabsheet_version_part.caption', '�汾����')
      .AddPair('tabsheet_account_offline_part.caption', '���ߵ�¼')
      .AddPair('tabsheet_account_microsoft_part.caption', '΢���¼')
      .AddPair('tabsheet_account_thirdparty_part.caption', '���õ�¼')
      .AddPair('tabsheet_playing_download_part.caption', '�����淨')
      .AddPair('tabsheet_playing_manage_part.caption', '�淨�������')
      .AddPair('tabsheet_download_minecraft_part.caption', '����Minecraft')
      .AddPair('tabsheet_download_custom_part.caption', '�����Զ����ļ�')
      .AddPair('tabsheet_download_modloader_part.caption', '����ģ��������ֶ���װ��')
      .AddPair('tabsheet_online_ipv6_part.caption', 'IPv6����')
      .AddPair('tabsheet_version_control_part.caption', '�汾����')
      .AddPair('tabsheet_version_isolation_part.caption', '��������')
      .AddPair('tabsheet_version_export_part.caption', '�������ϰ�') 
      //����Ϊ�˵���
      .AddPair('__mainmenu_comment', '�����ǲ˵�������')  
      .AddPair('menu_misc.caption', '����')               
      .AddPair('menu_misc_board.caption', '���԰�')
      .AddPair('menu_misc_answer.caption', '��֮��')
      .AddPair('menu_misc_intro.caption', '���ҽ���')
      .AddPair('menu_misc_lucky.caption', '������Ʒ')
      .AddPair('menu_misc_puzzle.caption', '������Ϸ')      
      .AddPair('menu_official.caption', '����')
      .AddPair('menu_official_entry.caption', '�������')
      .AddPair('menu_official_support.caption', '��������')
      .AddPair('menu_official_bmclapi.caption', '����BMCLAPI')   
      .AddPair('menu_manual.caption', '�ֶ�')
      .AddPair('menu_manual_reset.caption', '����������')
      .AddPair('menu_manual_export.caption', '�ֶ�������������')
      .AddPair('menu_manual_version.caption', '��ǰ�汾')
      .AddPair('menu_manual_update.caption', '������')
      .AddPair('menu_manual_test.caption', '���԰�ť')
      //����Ϊ��Ϣ��
      .AddPair('__messagebox_comment', '��������Ϣ������')
      .AddPair('messagebox_button_yes.caption', '��')
      .AddPair('messagebox_button_ok.caption', 'ȷ��')
      .AddPair('messagebox_button_no.caption', '��')
      .AddPair('messagebox_button_cancel.caption', 'ȡ��')
      .AddPair('messagebox_button_retry.caption', '����')
      .AddPair('messagebox_button_abort.caption', '��ֹ')
      .AddPair('messagebox_button_ignore.caption', '����')
      .AddPair('inputbox_button_yes.caption', 'ȷ��')
      .AddPair('inputbox_button_no.caption', 'ȡ��')
      .AddPair('picturebox_button_ok.caption', 'ȷ��')
      .AddPair('messagebox_background_reset_image.success.text', Concat('����ͼƬˢ�³ɹ���', #13#10, '���ƣ�${background_image_filename}'))
      .AddPair('messagebox_background_reset_image.success.caption', 'ˢ�³ɹ�')
      .AddPair('messagebox_background_reset_image.not_found.text', '����ͼƬˢ��ʧ�ܣ���δ�����ļ���')
      .AddPair('messagebox_background_reset_image.not_found.caption', 'ˢ��ʧ��')
      .AddPair('messagebox_background_reset_music.success.text', Concat('��������ˢ�³ɹ���', #13#10, '���ƣ�${background_music_filename}'))
      .AddPair('messagebox_background_reset_music.success.caption', 'ˢ�³ɹ�')
      .AddPair('messagebox_background_reset_music.not_found.text', '��������ˢ��ʧ�ܣ���δ�����ļ���')
      .AddPair('messagebox_background_reset_music.not_found.caption', 'ˢ��ʧ��')
//      .AddPair('messagebox_account_offline_error.cannot_name.text', '������ߵ�¼���Ʋ������룬��������벻Ҫ�������ģ�Ҳ��Ҫ����16���ַ�����ҪΪ�ա�')
//      .AddPair('messagebox_account_offline_error.cannot_name.caption', '���󾯸�')
      //����Ϊ�����б��
      .AddPair('downloadlist.custom.judge_can_multi_thread_download', '�����ж��Ƿ���Զ��߳����ء�')
      .AddPair('downloadlist.custom.url_donot_support_download_in_launcher', '����ַ��֧�����������أ���ʹ����������ذɣ�')
      .AddPair('downloadlist.custom.input_url_error_and_this_url_doesnot_has_file', '��ַ������󣬸���ַ�����κ��ļ���')
      .AddPair('downloadlist.custom.url_statucode_is_not_206_and_try_to_cut', '����վ������벻Ϊ206�����ڶ�����зֶΡ���')
      .AddPair('downloadlist.custom.not_allow_cut_use_single_thread_download', '����վ������ֶ����أ����õ��߳̽����ļ�����������')
      .AddPair('downloadlist.custom.url_allow_multi_thread_download', '����վ֧�ֶ��߳����أ�')
//      .AddPair('label_progress_download_progress.caption', '���ؽ��ȣ�${download_progress}')
      .AddPair('downloadlist.custom.url_file_size', '�ļ����ȣ�${download_progress}')
      .AddPair('downloadlist.custom.thread_one_to_single_thread_download', '������ѡ����߳��ǵ��̣߳����ڽ�ֱ�Ӳ�ȡ���̵߳����ط�ʽ��')
      .AddPair('downloadlist.custom.single_thread_download_error', '���߳�����ʧ�ܣ������ԡ�')
      .AddPair('downloadlist.custom.cut_download_error', '�ֶ�����������ʧ�ܣ�${cut_download_count}')
      .AddPair('downloadlist.custom.cut_download_retry', '����ʧ�ܣ���������${cut_download_retry}��')
      .AddPair('downloadlist.custom.retry_threetime_error', '����3�κ�����ʧ�ܣ�����ʧ�ܣ�')
      .AddPair('downloadlist.custom.cut_download_success', '�ֶ�������������ɣ�${cut_download_count}')
      .AddPair('label_progress_download_progress.caption', '���ؽ��ȣ�${download_progress}% | ${download_current_count}/${download_all_count}')
      //����Ϊ������
      .AddPair('__mainform_comment', '����������������')
      .AddPair('label_account_view.caption.absence', '�㻹��δ��¼�κ�һ���˺ţ���¼�󼴿�������鿴��ӭ�')
      .AddPair('label_account_view.caption.have', '��ð���${account_view}��ף���и�����һ�죡')
      .AddPair('label_open_launcher_time.caption', '��������ʱ�䣺${open_launcher_time}')
      .AddPair('label_open_launcher_number.caption', '��������������${open_launcher_number}')
      .AddPair('label_launch_game_number.caption', '������Ϸ�Ĵ�����${launch_game_number}')
      .AddPair('button_launch_game.caption.error.cannot_find_json', '������δ�ҵ�JSON��')
      .AddPair('button_launch_game.caption.error.missing_inherits_version', '������ȱ��ǰ�ð汾��')
      .AddPair('button_launch_game.caption.isolation', '��������')
      .AddPair('button_launch_game.caption.absence', Concat('��ʼ��Ϸ', #13#10, '�㻹��δѡ��һ���汾Ŷ��'))
      .AddPair('button_launch_game.caption', Concat('��ʼ��Ϸ', #13#10, '${launch_version_name}'))
      .AddPair('button_launch_game.hint', '��ʼ��MC��')
      .AddPair('image_refresh_background_image.hint', 'ˢ����ı���ͼƬ')
      .AddPair('image_refresh_background_music.hint', 'ˢ����ı�������')
      .AddPair('image_open_download_prograss.hint', '�����ؽ��Ƚ���')
      .AddPair('image_exit_running_mc.hint', '����taskkill������ǿ�ƽ����㵱ǰ�������е�MC')
      //����Ϊ��������
      .AddPair('__background_comment', '�����Ǳ�����������')
      .AddPair('label_background_tip.caption', '�����Ǳ������֣������ѡ���Լ�ϲ���ı�����ɫ��˵ʵ��ֻ�Ǳ߿������������')
      .AddPair('label_standard_color.caption', '�����Ǳ�׼��ɫ����һ��ֱ��Ӧ��')
      .AddPair('button_grass_color.caption', 'С����')
      .AddPair('button_sun_color.caption', '�����')
      .AddPair('button_sultan_color.caption', '�յ���')
      .AddPair('button_sky_color.caption', '�����')
      .AddPair('button_cute_color.caption', '�ɰ���')
      .AddPair('button_normal_color.caption', 'Ĭ�ϰ�')
      .AddPair('buttoncolor_custom_color.caption', '�Զ�����ɫ')
      .AddPair('label_background_window_alpha.caption', '���ô���͸���ȡ�ֻ����127~255����Ϊ���ͻᵼ��������������')
      .AddPair('label_background_window_current_alpha.caption', '��ǰѡ�У�${window_alpha}')
      .AddPair('label_background_control_alpha.caption', '���ÿؼ�͸���ȡ�ֻ����63~195����Ϊ���߻ᵼ�±���ͼƬ���������ͻᵼ�¿ؼ�������')
      .AddPair('label_background_control_current_alpha.caption', '��ǰѡ�У�${control_alpha}')
      .AddPair('groupbox_background_music_setting.caption', '������������')
      .AddPair('button_background_play_music.caption', '��������')
      .AddPair('button_background_play_music.hint', '�ֶ������ϱ��������Ѿ���������֣����δ��������ˢ��������������������һ�Ρ�')
      .AddPair('button_background_pause_music.caption', '��ͣ����')
      .AddPair('button_background_pause_music.hint', '���ֻ�ǻὫ������ͣ������������ֺ󽫻ᰴ���ϴ���ͣʱ�����Ų��š�')
      .AddPair('button_background_stop_music.caption', 'ֹͣ����')
      .AddPair('button_background_stop_music.hint', '��˻��¼��mp3�ļ������ٵ����������ʱ���ͷ���š�')
      .AddPair('radiobutton_background_music_open.caption', '��������ʱ����')
      .AddPair('radiobutton_background_music_launch.caption', '������Ϸʱ����')
      .AddPair('radiobutton_background_music_not.caption', '���Զ�����')
      .AddPair('groupbox_background_launch_setting.caption', '������Ϸ���ò���')
      .AddPair('radiobutton_background_launch_hide.caption', '����MCʱ���ش���')
      .AddPair('radiobutton_background_launch_show.caption', '����MCʱ��ʾ����')
      .AddPair('radiobutton_background_launch_exit.caption', '����MCʱ�˳�����')
      .AddPair('label_background_mainform_title.caption', '��������������')
      .AddPair('groupbox_background_gradient.caption', '���ڽ������')
      .AddPair('toggleswitch_background_gradient.on.caption', '��������')
      .AddPair('toggleswitch_background_gradient.off.caption', '�رս���')
      .AddPair('label_background_gradient_value.caption', '����ֵ')       
      .AddPair('label_background_gradient_current_value.caption', '��ǰѡ�У�${gradient_value}')
      .AddPair('label_background_gradient_step.caption', '���䲽��')         
      .AddPair('label_background_gradient_current_step.caption', '��ǰѡ�У�${gradient_step}'); 
    SetFile(Concat(ExtractFilePath(Application.ExeName), 'LLLauncher\lang\zh_cn.json'), zhcnjson.Format);
  end;
end;

//���ݶ�������ԣ���ȡ��Ӧ�ı�
function GetLanguageText(key: String): String;
begin
  try
    result := langjson.GetValue(key).Value;
  except
    result := '';
  end;
end;

end.
