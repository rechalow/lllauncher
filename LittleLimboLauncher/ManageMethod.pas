﻿unit ManageMethod;

interface

uses
  SysUtils, Classes, IOUtils, StrUtils, Winapi.Messages, ShellAPI, Windows, Forms, JSON,
  pngimage, NetEncoding, Generics.Collections, Vcl.Clipbrd;

function InitManage: Boolean;
procedure DragFileInWindow(var Msg: TMessage);
procedure ClearDatSelect;
procedure ManageChangeMap;
procedure ManageDisableresource;
procedure ManageEnableresource;
procedure ManageDeleteresource;
procedure ManageRenameresource;
procedure ManageOpenresource;
procedure CheckModInfo();

implementation

uses
  LauncherMethod, MainForm, MyCustomWindow, LanguageMethod, MainMethod, ProgressMethod;

type
  TIni2File = class
  private var
    rf: TStringList;
  public
    constructor Create(path: String);
    function ReadString(key, default: String): String;
    function ReadInteger(key: String; default: Integer): Integer;
  end;

var
  ModSelect: TStringList;
  SavSelect: TStringList;
  ResSelect: TStringList;
  ShaSelect: TStringList;
  DatSelect: TStringList;
  PluSelect: TStringList;
  mcrlpth: String;
//自制Ini读取
function TIni2File.ReadInteger(key: String; default: Integer): Integer;
begin
  result := -1;
  var b := false;
  var c := false;
  for var I in rf do begin
    if I.Trim.IndexOf('#') = 0 then continue;
    var ss := SplitString(I, '=');
    if ss[0].Trim.Equals(key) then begin
      try
        result := strtoint(ss[1].Trim);
        c := true;
      except
        b := true;
      end;
      break;
    end;
  end;
  if b or not c then result := default;
end;
function TIni2File.ReadString(key, default: String): String;
begin
  result := '';
  for var I in rf do begin
    if I.Trim.IndexOf('#') = 0 then continue;
    var ss := SplitString(I, '=');
    if ss[0].Trim.Equals(key) then begin
      result := ss[1].Trim;
      break;
    end;
  end;
  if result.IsEmpty then result := default;
end;
constructor TIni2File.Create(path: String);
begin
  rf := TStringList.Create;
  rf.DefaultEncoding := TEncoding.UTF8;
  rf.LoadFromFile(path)
end;
//导入整合包函数，按照键值对来获取
function JudgeException(ModInfo: TJSONObject; index: Integer; key: String; isemp: Boolean): String; overload;
begin
  try
    case index of
      1: begin
        result := ModInfo.GetValue(key).Value;
      end;
      2: begin
        var dep := ModInfo.GetValue('dependencies') as TJSONObject;
        result := dep.GetValue(key).Value;
      end;
      3: begin
        var dep := ModInfo.GetValue('dependencies') as TJSONObject;
        result := dep.Pairs[strtoint(key)].JsonString.Value;
      end;
      4..5: begin
        var dep := ModInfo.GetValue('components') as TJSONArray;
        var ml := dep[index - 4] as TJSONObject;
        result := ml.GetValue(key).Value;
      end;
      7..8: begin
        var dep := ModInfo.GetValue('addons') as TJSONArray;
        var ml := dep[index - 7] as TJSONObject;
        result := ml.GetValue(key).Value;
      end;
      10: begin
        var dep := ModInfo.GetValue('serverInfo') as TJSONObject;
        result := dep.GetValue(key).Value;
      end;
      11: begin
        var dep := ModInfo.GetValue('minecraft') as TJSONObject;
        result := dep.GetValue(key).Value;
      end;
      12..13: begin
        var dep := ModInfo.GetValue('minecraft') as TJSONObject;
        var elr := dep.GetValue(key) as TJSONArray;
        var eur := elr[0] as TJSONObject;
        var id := eur.GetValue('id').Value;
        result := id.Split(['-'])[index - 12];
      end;
    end;
  except
    if isemp then result := '' else
    result := GetLanguage('picturebox_resource.has_no_data');
  end;
end;
function JudgeException(ModInfo: TJSONObject; index: Integer; key: TArray<String>): String; overload;
begin
  try
    case index of
      1: begin
        result := ModInfo.GetValue(key[0]).Value.Replace('\', '');
      end;
      2: begin
        result := ModInfo.GetValue(key[0]).Format.Replace('\', '');
      end;
      3: begin
        var Rt := ModInfo.GetValue(key[0]) as TJSONObject;
        for var I := 1 to Length(key) - 2 do begin
          Rt := Rt.GetValue(key[i]) as TJSONObject;
        end;
        result := Rt.GetValue(key[Length(key) - 1]).Value.Replace('\', '');
      end;
      4: begin
        var Rt := ModInfo.GetValue(key[0]) as TJSONObject;
        for var I := 1 to Length(key) - 2 do begin
          Rt := Rt.GetValue(key[i]) as TJSONObject;
        end;
        result := Rt.GetValue(key[Length(key) - 1]).Format.Replace('\', '');
      end;
      5: begin
        var ss := '';
        for var I in key do begin
          if ModInfo.TryGetValue<String>(I, ss) then begin
            result := ss;
          end;
        end;
        if Result.IsEmpty then raise Exception.Create('Has no key');
      end;
    end;
  except
    result := GetLanguage('picturebox_resource.has_no_data');
  end;
end;
//查看模组信息
procedure CheckModInfo();
begin
  var S := '';
  if form_mainform.listbox_manage_import_mod.ItemIndex <> -1 then S := ModSelect[form_mainform.listbox_manage_import_mod.ItemIndex] else begin
    MyMessagebox(GetLanguage('messagebox_manage.disable_resource_not_choose.caption'), GetLanguage('messagebox_manage.disable_resource_not_choose.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  var E := Concat(LocalTemp, 'LLLauncher\YourCheckModInfo');
  if  not UnzipFile(S, 'fabric.mod.json', E) and
      not UnzipFile(S, 'quilt.mod.json', E) and
      not UnzipFile(S, 'mcmod.info', E) and
      not UnzipFile(S, 'META-INF/mods.toml', E) then begin
    MyMessagebox(GetLanguage('messagebox_manage.cannot_unzip_modpack.caption'), GetLanguage('messagebox_manage.cannot_unzip_modpack.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  try
    if FileExists(Concat(E, '\fabric.mod.json')) then begin
      var mi := GetFile(Concat(E, '\fabric.mod.json'));
      var ModInfoMetaData := TJSONObject.ParseJSONValue(mi) as TJSONObject;
      var env := JudgeException(ModInfoMetaData, 1, ['environment']);
      var depends := JudgeException(ModInfoMetaData, 2, ['depends']);
      var suggests := JudgeException(ModInfoMetaData, 2, ['suggests']);
      var modname := JudgeException(ModInfoMetaData, 1, ['name']);
      var icon := JudgeException(ModInfoMetaData, 1, ['icon']);
      var ss := TStringStream.Create;
      if not icon.Equals(GetLanguage('picturebox_resource.has_no_data')) then begin
        if UnzipFile(S, icon.Replace('/', '\').Replace('.\', ''), E) then begin
          ss.LoadFromFile(Concat(E, '\', icon.Replace('/', '\').Replace('.\', '')));
        end else begin
          ss := nil;
        end;
      end else begin
        ss := nil;
      end;
      MyPictureBox(modname, GetLanguage('picturebox_manage.check_mod_info_fabric.text')
        .Replace('${mod_game}', 'Fabric')
        .Replace('${mod_env}', env)
        .Replace('${mod_depends}', depends)
        .Replace('${mod_suggests}', suggests)
        .Replace('${mod_id}', JudgeException(ModInfoMetaData, 1, ['id']))
        .Replace('${mod_version}', JudgeException(ModInfoMetaData, 1, ['version']))
        .Replace('${mod_name}', JudgeException(ModInfoMetaData, 1, ['name']))
        .Replace('${mod_description}', JudgeException(ModInfoMetaData, 1, ['description']))
        .Replace('${mod_contact}', JudgeException(ModInfoMetaData, 2, ['contact']))
        .Replace('${mod_author}', JudgeException(ModInfoMetaData, 2, ['authors']))
        .Replace('${mod_contributor}', JudgeException(ModInfoMetaData, 2, ['contributors']))
        .Replace('${mod_license}', JudgeException(ModInfoMetaData, 2, ['license'])), ss)
    end else if FileExists(Concat(E, '\quilt.mod.json')) then begin
      var mi := GetFile(Concat(E, '\quilt.mod.json'));
      var ModInfoMetaData := TJSONObject.ParseJSONValue(mi) as TJSONObject;
      var group := JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'group']);
      var depends := JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'depends']);
      var suggests := JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'suggests']);
      var modname := JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'metadata', 'name']);
      var icon := JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'metadata', 'icon']);
      var ss := TStringStream.Create;
      if not icon.Equals(GetLanguage('picturebox_resource.has_no_data')) then begin
        if UnzipFile(S, icon.Replace('/', '\').Replace('.\', ''), E) then begin
          ss.LoadFromFile(Concat(E, '\', icon.Replace('/', '\').Replace('.\', '')));
        end else begin
          ss := nil;
        end;
      end else begin
        ss := nil;
      end;
      MyPictureBox(modname, GetLanguage('picturebox_manage.check_mod_info_fabric.text')
        .Replace('${mod_game}', 'Quilt')
        .Replace('${mod_group}', group)
        .Replace('${mod_depends}', depends)
        .Replace('${mod_suggests}', suggests)
        .Replace('${mod_id}', JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'id']))
        .Replace('${mod_version}', JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'version']))
        .Replace('${mod_name}', modname)
        .Replace('${mod_description}', JudgeException(ModInfoMetaData, 3, ['quilt_loader', 'metadata', 'description']))
        .Replace('${mod_contact}', JudgeException(ModInfoMetaData, 4, ['quilt_loader', 'metadata', 'contact']))
        .Replace('${mod_contributor}', JudgeException(ModInfoMetaData, 4, ['quilt_loader', 'metadata', 'contributors'])), ss)
    end else if FileExists(Concat(E, '\mcmod.info')) then begin
      var mi := GetFile(Concat(E, '\mcmod.info'));
      var ModInfoMetaData := TJSONObject.ParseJSONValue(mi) as TJSONArray;
      var modname := JudgeException(((ModInfoMetaData as TJSONArray)[0] as TJSONObject), 1, ['name']);
      var icon := JudgeException(((ModInfoMetaData as TJSONArray)[0] as TJSONObject), 1, ['logoFile']);
      var ss := TStringStream.Create;
      if not icon.Equals(GetLanguage('picturebox_resource.has_no_data')) then begin
        if UnzipFile(S, icon.Replace('/', '\').Replace('.\', ''), E) then begin
          ss.LoadFromFile(Concat(E, '\', icon.Replace('/', '\').Replace('.\', '')));
        end else begin
          ss := nil;
        end;
      end else begin
        ss := nil;
      end;
      var all := '';
      for var I in ModInfoMetaData as TJSONArray do begin
        var J := I as TJSONObject;
        all := Concat(all, GetLanguage('picturebox_manage.check_mod_info_forge12d.text')
          .Replace('${mod_game}', 'Forge <= 1.13.2')
          .Replace('${mod_depends}', JudgeException(J, 2, ['dependencies']))
          .Replace('${mod_id}', JudgeException(J, 1, ['modid']))
          .Replace('${mod_name}', JudgeException(J, 1, ['name']))
          .Replace('${mod_description}', JudgeException(J, 1, ['description']))
          .Replace('${mod_version}', JudgeException(J, 1, ['version']))
          .Replace('${mod_mcversion}', JudgeException(J, 1, ['mcversion']))
          .Replace('${mod_url}', JudgeException(J, 1, ['url']).Replace('\', ''))
          .Replace('${mod_updateurl}', JudgeException(J, 5, ['updateUrl', 'updateJSON']).Replace('\', ''))
          .Replace('${mod_author}', JudgeException(J, 2, ['authorList']))
          .Replace('${mod_credits}', JudgeException(J, 1, ['credits']))
          , #13#10, '-----------------------------------------------------------------------------------------------------------------------', #13#10
        );
      end;
      MyPictureBox(modname, all, ss);
    end else if FileExists(Concat(E, '\META-INF\mods.toml')) then begin
      var mi := GetFile(Concat(E, '\META-INF\mods.toml'));
      var resjson := '';
      if not TTomlParser.TomlToJSON(mi, resjson) then begin
        MyMessageBox(GetLanguage('messagebox_manage.found_modtoml_error.caption').Replace('${error_info}', resjson), GetLanguage('messagebox_manage.found_modtoml_error.text'), MY_ERROR, [mybutton.myOK]);
        exit;
      end;
      var ModInfoMetaData := TJSONObject.ParseJSONValue(resjson) as TJSONObject;
      var modss :=  (ModInfoMetaData as TJSONObject).GetValue('mods') as TJSONArray;
      var modnamew := JudgeException(modss[0] as TJSONObject, 1, ['displayName']);
      var logofile := JudgeException(modss[0] as TJSONObject, 1, ['logoFile']);
      var all := '';
      for var i in modss do begin
        var mods := i as TJSONObject;
        var modid := mods.GetValue('modId').Value;
        var deps := ((ModInfoMetaData as TJSONObject).GetValue('dependencies') as TJSONObject).GetValue(modid) as TJSONArray;
        var modtemp := '';
        var modgame := '';
        var modrange := '';
        var mcrange := '';
        for var depw in deps do begin
          var dep := depw as TJSONObject;
          if not dep.TryGetValue<String>('modId', modtemp) then begin
            MyMessageBox(GetLanguage('messagebox_manage.cannot_pause_modgame.caption'), GetLanguage('messagebox_manage.cannot_pause_modgame.text'), MY_ERROR, [mybutton.myYes]);
            exit;
          end;
          if modtemp.Equals('neoforge') or modtemp.Equals('forge') then begin
            modgame := modtemp;
            modrange := dep.GetValue<String>('versionRange');
          end else if modtemp.Equals('minecraft') then begin
            mcrange := dep.GetValue<String>('versionRange');
          end;
        end;
        all := Concat(all, GetLanguage('picturebox_manage.check_mod_info_forge13u.text')
          .Replace('${mod_game}', modgame)
          .Replace('${mod_range}', modrange)
          .Replace('${mc_range}', mcrange)
          .Replace('${mod_id}', modid)
          .Replace('${mod_name}', JudgeException(mods, 1, ['displayName']))
          .Replace('${mod_description}', JudgeException(mods, 1, ['description']))
          .Replace('${mod_version}', JudgeException(mods, 1, ['version']))
          .Replace('${mod_url}', JudgeException(mods, 1, ['displayURL']))
          .Replace('${mod_updateurl}', JudgeException(mods, 1, ['updateJSONURL']))
          .Replace('${mod_author}', JudgeException(mods, 1, ['authors']))
          .Replace('${mod_credits}', JudgeException(mods, 1, ['credits']))
          .Replace('${mod_license}', JudgeException(ModInfoMetaData, 1, ['license']))
          .Replace('${mod_issue}', JudgeException(ModInfoMetaData, 1, ['issueTrackerURL']))
          ,#13#10, '-----------------------------------------------------------------------------------------------------------------------', #13#10
        );
      end;
      var ss := TStringStream.Create;
      if not logofile.Equals(GetLanguage('picturebox_resource.has_no_data')) then begin
        if UnzipFile(S, logofile.Replace('/', '\').Replace('.\', ''), E) then begin
          ss.LoadFromFile(Concat(E, '\', logofile.Replace('/', '\').Replace('.\', '')));
        end else begin
          ss := nil;
        end;
      end else begin
        ss := nil;
      end;
      MyPictureBox(modnamew, all, ss);
    end;
  finally
    DeleteDirectory(Concat(LocalTemp, 'LLLauncher'));
  end;
end;
//导入整合包函数
procedure ImportModPack(path: String);
begin
  if not Unzip(path, Concat(LocalTemp, 'LLLauncher\importmodpack')) then begin
    MyMessagebox(GetLanguage('messagebox_manage.cannot_unzip_modpack.caption'), GetLanguage('messagebox_manage.cannot_unzip_modpack.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  try
    if FileExists(Concat(LocalTemp, 'LLLauncher\importmodpack\modrinth.index.json')) then begin
      var mi := GetFile(Concat(LocalTemp, 'LLLauncher\importmodpack\modrinth.index.json'));
      var ModPackMetadata := TJSONObject.ParseJSONValue(mi) as TJSONObject;
      var mcv := JudgeException(ModPackMetadata, 2, 'minecraft', false);
      var ml := JudgeException(ModPackMetadata, 3, '1', true);
      var mlv := JudgeException(ModPackMetadata, 2, ml, true);
      if MyPicMsgBox(JudgeException(ModPackMetadata, 1, 'name', false), GetLanguage('picturebox_manage.import_modrinth_modpack.text')
        .Replace('${modpack_game}', 'Modrinth')
        .Replace('${modpack_version}', JudgeException(ModPackMetadata, 1, 'versionId', false))
        .Replace('${modpack_name}', JudgeException(ModPackMetadata, 1, 'name', false))
        .Replace('${modpack_summary}', JudgeException(ModPackMetadata, 1, 'summary', false))
        .Replace('${modpack_mcversion}', mcv)
        .Replace('${modpack_modloader}', ml)
        .Replace('${modpack_modloader_version}', mlv), nil) then begin
        try
          var mccp := (((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\MCJson.json'))) as TJsonObject).GetValue('mc') as TJsonArray)[LLLini.ReadInteger('MC', 'SelectMC', -1) - 1] as TJsonObject).GetValue('path').Value;
          var jpth := ((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\JavaJson.json'))) as TJSONObject).GetValue('java') as TJSONArray)[LLLini.ReadInteger('Java', 'SelectJava', -1) - 1].Value;
          var mcsp := Concat(mccp, '\versions\', JudgeException(ModPackMetadata, 1, 'name', false));
          if DirectoryExists(mcsp) then DeleteDirectory(mcsp);
          ForceDirectories(mcsp);
          form_mainform.pagecontrol_mainpage.ActivePage := form_mainform.tabsheet_download_progress_part;
          TThread.CreateAnonymousThread(procedure begin
            form_mainform.button_progress_clean_download_list.Enabled := false;
            DownloadStart(Concat('Modrinth@', mcv, '@', ml, '@', mlv), mcsp, mccp, mbiggest_thread, mdownload_source, 5, jpth, mcv);
            form_mainform.button_progress_clean_download_list.Enabled := true;
            MyMessagebox(GetLanguage('messagebox_manage.import_modpack_success.caption'), GetLanguage('messagebox_manage.import_modpack_success.text'), MY_PASS, [mybutton.myOK]);
          end).Start;
        except
          MyMessagebox(GetLanguage('messagebox_manage.read_config_error.caption'), GetLanguage('messagebox_manage.read_config_error.text'), MY_ERROR, [mybutton.myYes]);
          exit;
        end;
      end else exit;
    end else if FileExists(Concat(LocalTemp, 'LLLauncher\importmodpack\mmc-pack.json')) and FileExists(Concat(LocalTemp, 'LLLauncher\importmodpack\instance.cfg')) then begin
      var mi := GetFile(Concat(LocalTemp, 'LLLauncher\importmodpack\mmc-pack.json'));
      var mo := TIni2File.Create(Concat(LocalTemp, 'LLLauncher\importmodpack\instance.cfg'));
      var ModPackMetadata := TJSONObject.ParseJSONValue(mi) as TJSONObject;
      var mcv := JudgeException(ModPackMetadata, 4, 'version', false);
      var ml := JudgeException(ModPackMetadata, 5, 'uid', true);
      var mlv := JudgeException(ModPackMetadata, 5, 'version', true);
      var pls := JudgeException(ModPackMetadata, 1, 'icon', true);
      var ss := Base64ToStream(pls);
      if MyPicMsgBox(mo.ReadString('name', ''), GetLanguage('picturebox_manage.import_multimc_modpack.text')
        .Replace('${modpack_game}', 'MultiMC')
        .Replace('${modpack_name}', mo.ReadString('name', ''))
        .Replace('${modpack_summary}', mo.ReadString('notes', '').Replace('\n', #13#10))
        .Replace('${modpack_mcversion}', mcv)
        .Replace('${modpack_modloader}', ml)
        .Replace('${modpack_modloader_version}', mlv), ss) then begin
        try
          var mccp := (((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\MCJson.json'))) as TJsonObject).GetValue('mc') as TJsonArray)[LLLini.ReadInteger('MC', 'SelectMC', -1) - 1] as TJsonObject).GetValue('path').Value;
          var jpth := ((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\JavaJson.json'))) as TJSONObject).GetValue('java') as TJSONArray)[LLLini.ReadInteger('Java', 'SelectJava', -1) - 1].Value;
          var mcsp := Concat(mccp, '\versions\', mo.ReadString('name', ''));
          if DirectoryExists(mcsp) then DeleteDirectory(mcsp);
          ForceDirectories(mcsp);
          form_mainform.pagecontrol_mainpage.ActivePage := form_mainform.tabsheet_download_progress_part;
          TThread.CreateAnonymousThread(procedure begin
            form_mainform.button_progress_clean_download_list.Enabled := false;
            DownloadStart(Concat('MultiMC@', mcv, '@', ml, '@', mlv), mcsp, mccp, mbiggest_thread, mdownload_source, 5, jpth, mcv);
            form_mainform.button_progress_clean_download_list.Enabled := true;
            DeleteDirectory(Concat(LocalTemp, 'LLLauncher\importmodpack'));
            MyMessagebox(GetLanguage('messagebox_manage.import_modpack_success.caption'), GetLanguage('messagebox_manage.import_modpack_success.text'), MY_PASS, [mybutton.myOK]);
          end).Start;
        except
          MyMessagebox(GetLanguage('messagebox_manage.read_config_error.caption'), GetLanguage('messagebox_manage.read_config_error.text'), MY_ERROR, [mybutton.myYes]);
          exit;
        end;
      end;
    end else if FileExists(Concat(LocalTemp, 'LLLauncher\importmodpack\mcbbs.packmeta')) then begin
      var mi := GetFile(Concat(LocalTemp, 'LLLauncher\importmodpack\mcbbs.packmeta'));
      var ModPackMetadata := TJSONObject.ParseJSONValue(mi) as TJSONObject;
      var pls := JudgeException(ModPackMetadata, 1, 'icon', true);
      var ss := Base64ToStream(pls);
      var mcv := JudgeException(ModPackMetadata, 7, 'version', false);
      var ml := JudgeException(ModPackMetadata, 8, 'id', true);
      var mlv := JudgeException(ModPackMetadata, 8, 'version', true);
      if MyPicMsgBox(JudgeException(ModPackMetadata, 1, 'name', false), GetLanguage('picturebox_manage.import_mcbbs_modpack.text')
        .Replace('${modpack_game}', 'MCBBS')
        .Replace('${modpack_name}', JudgeException(ModPackMetadata, 1, 'name', false))
        .Replace('${modpack_version}', JudgeException(ModPackMetadata, 1, 'version', false))
        .Replace('${modpack_author}', JudgeException(ModPackMetadata, 1, 'author', false))
        .Replace('${modpack_summary}', Concat(#13#10, JudgeException(ModPackMetadata, 1, 'description', false).Replace(#13, #13#10).Replace(#10, #13#10)))
        .Replace('${modpack_update_url}', JudgeException(ModPackMetadata, 1, 'fileApi', false))
        .Replace('${modpack_official_url}', JudgeException(ModPackMetadata, 1, 'url', false))
        .Replace('${modpack_server}', JudgeException(ModPackMetadata, 10, 'authlibInjectorServer', false))
        .Replace('${modpack_mcversion}', mcv)
        .Replace('${modpack_modloader}', ml)
        .Replace('${modpack_modloader_version}', mlv), ss) then begin
        try
          var mccp := (((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\MCJson.json'))) as TJsonObject).GetValue('mc') as TJsonArray)[LLLini.ReadInteger('MC', 'SelectMC', -1) - 1] as TJsonObject).GetValue('path').Value;
          var jpth := ((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\JavaJson.json'))) as TJSONObject).GetValue('java') as TJSONArray)[LLLini.ReadInteger('Java', 'SelectJava', -1) - 1].Value;
          var mcsp := Concat(mccp, '\versions\', JudgeException(ModPackMetadata, 1, 'name', false));
          if DirectoryExists(mcsp) then DeleteDirectory(mcsp);
          ForceDirectories(mcsp);
          form_mainform.pagecontrol_mainpage.ActivePage := form_mainform.tabsheet_download_progress_part;
          TThread.CreateAnonymousThread(procedure begin
            form_mainform.button_progress_clean_download_list.Enabled := false;
            DownloadStart(Concat('MCBBS@', mcv, '@', ml, '@', mlv), mcsp, mccp, mbiggest_thread, mdownload_source, 5, jpth, mcv);
            form_mainform.button_progress_clean_download_list.Enabled := true;
            DeleteDirectory(Concat(LocalTemp, 'LLLauncher\importmodpack'));
            MyMessagebox(GetLanguage('messagebox_manage.import_modpack_success.caption'), GetLanguage('messagebox_manage.import_modpack_success.text'), MY_PASS, [mybutton.myOK]);
          end).Start;
        except
          MyMessagebox(GetLanguage('messagebox_manage.read_config_error.caption'), GetLanguage('messagebox_manage.read_config_error.text'), MY_ERROR, [mybutton.myYes]);
          exit;
        end;
      end;
    end else if FileExists(Concat(LocalTemp, 'LLLauncher\importmodpack\manifest.json')) then begin
      var mi := GetFile(Concat(LocalTemp, 'LLLauncher\importmodpack\manifest.json'));
      var ModPackMetadata := TJSONObject.ParseJSONValue(mi) as TJSONObject;
      var mcv := JudgeException(ModPackMetadata, 11, 'version', false);
      var ml := JudgeException(ModPackMetadata, 12, 'modLoaders', true);
      var mlv := JudgeException(ModPackMetadata, 13, 'modLoaders', true);
      if MyPicMsgBox(JudgeException(ModPackMetadata, 1, 'name', false), GetLanguage('picturebox_manage.import_curseforge_modpack.text')
        .Replace('${modpack_game}', 'CurseForge')
        .Replace('${modpack_version}', JudgeException(ModPackMetadata, 1, 'version', false))
        .Replace('${modpack_name}', JudgeException(ModPackMetadata, 1, 'name', false))
        .Replace('${modpack_author}', JudgeException(ModPackMetadata, 1, 'author', false))
        .Replace('${modpack_mcversion}', mcv)
        .Replace('${modpack_modloader}', ml)
        .Replace('${modpack_modloader_version}', mlv), nil) then begin
        try
          var mccp := (((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\MCJson.json'))) as TJsonObject).GetValue('mc') as TJsonArray)[LLLini.ReadInteger('MC', 'SelectMC', -1) - 1] as TJsonObject).GetValue('path').Value;
          var jpth := ((TJsonObject.ParseJSONValue(GetFile(Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\configs\JavaJson.json'))) as TJSONObject).GetValue('java') as TJSONArray)[LLLini.ReadInteger('Java', 'SelectJava', -1) - 1].Value;
          var mcsp := Concat(mccp, '\versions\', JudgeException(ModPackMetadata, 1, 'name', false));
          if DirectoryExists(mcsp) then DeleteDirectory(mcsp);
          ForceDirectories(mcsp);
          form_mainform.pagecontrol_mainpage.ActivePage := form_mainform.tabsheet_download_progress_part;
          TThread.CreateAnonymousThread(procedure begin
            form_mainform.button_progress_clean_download_list.Enabled := false;
            DownloadStart(Concat('CurseForge@', mcv, '@', ml, '@', mlv), mcsp, mccp, mbiggest_thread, mdownload_source, 5, jpth, mcv);
            form_mainform.button_progress_clean_download_list.Enabled := true;
            DeleteDirectory(Concat(LocalTemp, 'LLLauncher\importmodpack'));
            MyMessagebox(GetLanguage('messagebox_manage.import_modpack_success.caption'), GetLanguage('messagebox_manage.import_modpack_success.text'), MY_PASS, [mybutton.myOK]);
          end).Start;
        except
          MyMessagebox(GetLanguage('messagebox_manage.read_config_error.caption'), GetLanguage('messagebox_manage.read_config_error.text'), MY_ERROR, [mybutton.myYes]);
          exit;
        end;
      end;
    end else begin
      MyMessagebox(GetLanguage('messagebox_manage.not_support_modpack_type.caption'), GetLanguage('messagebox_manage.not_support_modpack_type.text'), MY_ERROR, [mybutton.myYes]);
      exit;
    end;
  finally
    DeleteDirectory(Concat(LocalTemp, 'LLLauncher\importmodpack'));
  end;
end;
//复制文件夹
function CopyDir(source, target: string): Boolean;
var
  sop: TSHFileOpStruct;
begin
  with sop do begin
    Wnd := 0;
    wFunc := FO_COPY;
    pFrom := pchar(source);
    pTo := pchar(target);
    fFlags := FOF_ALLOWUNDO;
    hNameMappings := nil;
    lpszProgressTitle := nil;
    fAnyOperationsAborted := false;
  end;
  Result := SHFileOperation(sop) = 0;
end;
//回收文件
function RecycleFile(fileName: String): Boolean;
var
  sop: TSHFileOpStruct;
begin
  with sop do begin
    Wnd := 0;
    wFunc := FO_DELETE;
    pFrom := pchar(filename);
    pTo := '';
    fFlags := FOF_ALLOWUNDO;
  end;
  Result := SHFileOperation(sop) = 0;
end;
//查询玩法文件夹，然后添加到列表框。
procedure SelectresourceDir();
begin
  form_mainform.listbox_manage_import_mod.Clear;
  ModSelect.Clear;
  form_mainform.listbox_manage_import_map.Clear;
  SavSelect.Clear;
  form_mainform.listbox_manage_import_resourcepack.Clear;
  ResSelect.Clear;
  form_mainform.listbox_manage_import_shader.Clear;
  ShaSelect.Clear;
  form_mainform.listbox_manage_import_datapack.Clear;
  DatSelect.Clear;
  form_mainform.listbox_manage_import_plugin.Clear;
  PluSelect.Clear;
  try //模组
    var rpath := Concat(mcrlpth, '\mods');
    if DirectoryExists(rpath) then begin
      SearchDirProc(rpath, false, true, function(T: String): Boolean begin
        var ex := ExtractFileName(T);
        if (RightStr(ex, 4) = '.jar') or (RightStr(ex, 4) = '.zip') then begin
          ModSelect.Add(T);
          form_mainform.listbox_manage_import_mod.Items.Add(ex.Substring(0, ex.Length - 4));
        end else if (RightStr(ex, 13) = '.jar.disabled') or (RightStr(ex, 13) = '.zip.disabled') then begin
          ModSelect.Add(T);
          form_mainform.listbox_manage_import_mod.Items.Add(Concat('[禁用]', ex.Substring(0, ex.Length - 13)));
        end;
        result := false;
      end);
    end;
  except end;
  try //地图
    var rpath := Concat(mcrlpth, '\saves');
    if DirectoryExists(rpath) then begin
      SearchDirProc(rpath, true, true, function(T: String): Boolean begin
        SavSelect.Add(T);
        form_mainform.listbox_manage_import_map.Items.Add(ExtractFilename(T));
        result := false;
      end);
    end;
  except end;
  try //纹理
    var rpath := Concat(mcrlpth, '\resourcepacks');
    if DirectoryExists(rpath) then begin
      SearchDirProc(rpath, false, true, function(T: String): Boolean begin
        var ex := ExtractFileName(T);
        if (RightStr(ex, 4) = '.zip') then begin
          ResSelect.Add(T);
          form_mainform.listbox_manage_import_resourcepack.Items.Add(ex.Substring(0, ex.Length - 4));
        end;
        result := false;
      end);
    end;
  except end;
  try //光影
    var rpath := Concat(mcrlpth, '\shaderpacks');
    if DirectoryExists(rpath) then begin
      SearchDirProc(rpath, false, true, function(T: String): Boolean begin
        var ex := ExtractFileName(T);
        if (RightStr(ex, 4) = '.zip') then begin
          ShaSelect.Add(T);
          form_mainform.listbox_manage_import_shader.Items.Add(ex.Substring(0, ex.Length - 4));
        end;
        result := false;
      end);
    end;
  except end;
  try //插件
    var rpath := Concat(mcrlpth, '\plugins');
    if DirectoryExists(rpath) then begin
      SearchDirProc(rpath, false, true, function(T: String): Boolean begin
        var ex := ExtractFileName(T);
        if (RightStr(ex, 4) = '.jar') or (RightStr(ex, 4) = '.zip') then begin
          PluSelect.Add(T);
          form_mainform.listbox_manage_import_plugin.Items.Add(ex.Substring(0, ex.Length - 4));
        end else if (RightStr(ex, 13) = '.jar.disabled') or (RightStr(ex, 13) = '.zip.disabled') then begin
          PluSelect.Add(T);
          form_mainform.listbox_manage_import_plugin.Items.Add(Concat('[禁用]', ex.Substring(0, ex.Length - 13)));
        end;
        result := false;
      end);
    end;
  except end;
end;
//禁用玩法
procedure ManageDisableresource;
begin
  var S := '';
  if form_mainform.listbox_manage_import_mod.ItemIndex <> -1 then S := ModSelect[form_mainform.listbox_manage_import_mod.ItemIndex] else
  if form_mainform.listbox_manage_import_plugin.ItemIndex <> -1 then S := PluSelect[form_mainform.listbox_manage_import_plugin.ItemIndex] else begin
    MyMessagebox(GetLanguage('messagebox_manage.disable_resource_not_choose.caption'), GetLanguage('messagebox_manage.disable_resource_not_choose.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  if (RightStr(S, 13) = '.jar.diasbled') or (RightStr(S, 13) = '.zip.disabled') then begin
    MyMessagebox(GetLanguage('messagebox_manage.resource_already_disable.caption'), GetLanguage('messagebox_manage.resource_already_disable.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  RenameFile(S, Concat(S, '.disabled'));
  SelectresourceDir();
end;
//启用玩法
procedure ManageEnableresource;
begin
  var S := '';
  if form_mainform.listbox_manage_import_mod.ItemIndex <> -1 then S := ModSelect[form_mainform.listbox_manage_import_mod.ItemIndex] else
  if form_mainform.listbox_manage_import_plugin.ItemIndex <> -1 then S := PluSelect[form_mainform.listbox_manage_import_plugin.ItemIndex] else begin
    MyMessagebox(GetLanguage('messagebox_manage.enable_resource_not_choose.caption'), GetLanguage('messagebox_manage.enable_resource_not_choose.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  if (RightStr(S, 4) = '.jar') or (RightStr(S, 4) = '.zip') then begin
    MyMessagebox(GetLanguage('messagebox_manage.resource_already_enable.caption'), GetLanguage('messagebox_manage.resource_already_enable.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  RenameFile(S, S.Substring(0, S.LastIndexOf('.')));
  SelectresourceDir();
end;
procedure ClearDatSelect;
begin
  DatSelect.Clear;
end;
//删除玩法
procedure ManageDeleteresource;
begin
  var S := '';
  if form_mainform.listbox_manage_import_datapack.ItemIndex <> -1 then S := DatSelect[form_mainform.listbox_manage_import_datapack.ItemIndex]
  else if form_mainform.listbox_manage_import_mod.ItemIndex <> -1 then S := ModSelect[form_mainform.listbox_manage_import_mod.ItemIndex]
  else if form_mainform.listbox_manage_import_map.ItemIndex <> -1 then S := SavSelect[form_mainform.listbox_manage_import_map.ItemIndex]
  else if form_mainform.listbox_manage_import_resourcepack.ItemIndex <> -1 then S := ResSelect[form_mainform.listbox_manage_import_resourcepack.ItemIndex]
  else if form_mainform.listbox_manage_import_shader.ItemIndex <> -1 then S := ShaSelect[form_mainform.listbox_manage_import_shader.ItemIndex]
  else if form_mainform.listbox_manage_import_plugin.ItemIndex <> -1 then S := PluSelect[form_mainform.listbox_manage_import_plugin.ItemIndex]
  else begin
    MyMessagebox(GetLanguage('messagebox_manage.delete_resource_not_choose.caption'), GetLanguage('messagebox_manage.delete_resource_not_choose.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  if MyMessagebox(GetLanguage('messagebox_manage.resource_is_delete.caption'), GetLanguage('messagebox_manage.resource_is_delete.text'), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then exit;
  RecycleFile(S);
  SelectresourceDir;
end;
//重命名玩法
procedure ManageRenameresource;
begin
  var S := '';
  if form_mainform.listbox_manage_import_datapack.ItemIndex <> -1 then S := DatSelect[form_mainform.listbox_manage_import_datapack.ItemIndex]
  else if form_mainform.listbox_manage_import_mod.ItemIndex <> -1 then S := ModSelect[form_mainform.listbox_manage_import_mod.ItemIndex]
  else if form_mainform.listbox_manage_import_map.ItemIndex <> -1 then S := SavSelect[form_mainform.listbox_manage_import_map.ItemIndex]
  else if form_mainform.listbox_manage_import_resourcepack.ItemIndex <> -1 then S := ResSelect[form_mainform.listbox_manage_import_resourcepack.ItemIndex]
  else if form_mainform.listbox_manage_import_shader.ItemIndex <> -1 then S := ShaSelect[form_mainform.listbox_manage_import_shader.ItemIndex]
  else if form_mainform.listbox_manage_import_plugin.ItemIndex <> -1 then S := PluSelect[form_mainform.listbox_manage_import_plugin.ItemIndex]
  else begin
    MyMessagebox(GetLanguage('messagebox_manage.rename_resource_not_choose.caption'), GetLanguage('messagebox_manage.rename_resource_not_choose.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  var rs := MyInputBox(GetLanguage('inputbox_manage.rename_new_name.caption'), GetLanguage('inputbox_manage.rename_new_name.text'), MY_INFORMATION);
  if rs = '' then exit;
  if (form_mainform.listbox_manage_import_map.ItemIndex <> -1) and (form_mainform.listbox_manage_import_datapack.ItemIndex = -1) then begin
    var C := Concat(ExtractFilePath(S), rs);
    RenDirectory(S, C);
  end else begin
    if RightStr(S, 9) = '.disabled' then begin
      var nod := ChangeFileExt(S, '');
      var osuf := nod.Substring(nod.LastIndexOf('.'));
      var ald := Concat(ExtractFilePath(S), rs, osuf, '.disabled');
      RenameFile(S, ald);
    end else begin
      var osuf := S.Substring(S.LastIndexOf('.'));
      var ald := Concat(ExtractFilePath(S), rs, osuf);
      RenameFile(S, ald);
    end;
  end;
  SelectresourceDir;
end;
//打开文件夹
procedure ManageOpenresource;
begin
  var S := '';
  if form_mainform.listbox_manage_import_datapack.ItemIndex <> -1 then S := Concat(SavSelect[form_mainform.listbox_manage_import_map.ItemIndex], '\datapacks')
  else if form_mainform.listbox_manage_import_mod.ItemIndex <> -1 then S := Concat(mcrlpth, '\mods')
  else if form_mainform.listbox_manage_import_map.ItemIndex <> -1 then S := Concat(mcrlpth, '\saves')
  else if form_mainform.listbox_manage_import_resourcepack.ItemIndex <> -1 then S := Concat(mcrlpth, '\resourcepacks')
  else if form_mainform.listbox_manage_import_shader.ItemIndex <> -1 then S := Concat(mcrlpth, '\shaderpacks')
  else if form_mainform.listbox_manage_import_plugin.ItemIndex <> -1 then S := Concat(mcrlpth, '\plugins')
  else begin
    MyMessagebox(GetLanguage('messagebox_manage.open_no_choose_resource.caption'), GetLanguage('messagebox_manage.open_no_choose_resource.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  if not DirectoryExists(S) then ForceDirectories(S);
  ShellExecute(Application.Handle, 'open', 'explorer.exe', pchar(S), nil, SW_SHOWNORMAL);
end;
//拖动到窗口的方法
procedure DragFileInWindow(var Msg: TMessage);
var
  P: array[0..255] of Char;
  i: Word;
  d: TArray<String>;
begin
  i := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);
  var cc: TPoint;
  DragQueryPoint(Msg.WParam, cc);
  var lmod: TPoint;
  lmod.X := 0;
  lmod.Y := 0;
  lmod := form_mainform.listbox_manage_import_mod.ClientToScreen(lmod);
  lmod := form_mainform.ScreenToClient(lmod);
  var lmap: TPoint;
  lmap.X := 0;
  lmap.Y := 0;
  lmap := form_mainform.listbox_manage_import_map.ClientToScreen(lmap);
  lmap := form_mainform.ScreenToClient(lmap);
  var lres: TPoint;
  lres.X := 0;
  lres.Y := 0;
  lres := form_mainform.listbox_manage_import_resourcepack.ClientToScreen(lres);
  lres := form_mainform.ScreenToClient(lres);
  var lsha: TPoint;
  lsha.X := 0;
  lsha.Y := 0;
  lsha := form_mainform.listbox_manage_import_shader.ClientToScreen(lsha);
  lsha := form_mainform.ScreenToClient(lsha);
  var ldat: TPoint;
  ldat.X := 0;
  ldat.Y := 0;
  ldat := form_mainform.listbox_manage_import_datapack.ClientToScreen(ldat);
  ldat := form_mainform.ScreenToClient(ldat);
  var lplu: TPoint;
  lplu.X := 0;
  lplu.Y := 0;
  lplu := form_mainform.listbox_manage_import_plugin.ClientToScreen(lplu);
  lplu := form_mainform.ScreenToClient(lplu);
  var lpak: TPoint;
  lpak.X := 0;
  lpak.Y := 0;
  lpak := form_mainform.listbox_manage_import_modpack.ClientToScreen(lpak);
  lpak := form_mainform.ScreenToClient(lpak);
  var ic := 0;
  //模组
  if (cc.Y > lmod.Y) and
  (cc.Y < lmod.Y + form_mainform.listbox_manage_import_mod.Height) and
  (cc.X > lmod.X) and
  (cc.X < lmod.X + form_mainform.listbox_manage_import_mod.Width) then begin
    for var j := 0 to i - 1 do begin
      DragQueryFile(Msg.WParam, j, @P, sizeof(P));
      var ne := StrPas(P);
      if (RightStr(ExtractFileName(ne), 4) = '.jar') or (RightStr(ExtractFileName(ne), 4) = '.zip') then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_file_mod.caption'), GetLanguage('messagebox_manage.drag_file_mod.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then continue;
        var dire := Concat(mcrlpth, '\mods');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetFiles(dire);
        var boo := False;
        for var k in d do begin
          if ExtractFileName(k) = ExtractFileName(ne) then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_mod_repeat.caption'), GetLanguage('messagebox_manage.drag_mod_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then boo := true;
            break;
          end;
        end;
        if boo then continue;
        CopyFile(pchar(ne), pchar(Concat(dire, '\', ExtractFileName(ne))), false);
        inc(ic);
      end else begin
        MyMessagebox(GetLanguage('messagebox_manage.drag_mod_format_error.caption'), GetLanguage('messagebox_manage.drag_mod_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
      end;
    end;
  //地图
  end else if (cc.Y > lmap.Y) and
  (cc.Y < lmap.Y + form_mainform.listbox_manage_import_map.Height) and
  (cc.X > lmap.X) and
  (cc.X < lmap.X + form_mainform.listbox_manage_import_map.Width) then begin
    for var j := 0 to i - 1 do begin
      DragQueryFile(Msg.WParam, j, @P, sizeof(P));
      var ne := StrPas(P);
      if (RightStr(ne, 4) = '.zip') then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_map_zip.caption'), GetLanguage('messagebox_manage.drag_map_zip.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNO, mybutton.myYes]) = 1 then continue;
        var dire := Concat(mcrlpth, '\saves');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetDirectories(dire);
        var boo := false;
        for var k in d do begin
          if ExtractFileName(k) = ChangeFileExt(ExtractFileName(ne), '') then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_map_zip_repeat.caption'), GetLanguage('messagebox_manage.drag_map_zip_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNO, mybutton.myYes]) = 1 then boo := true else
            DeleteDirectory(k);
            break;
          end;
        end;
        if boo then continue;
        if not Unzip(ne, Concat(dire, '\', ChangeFileExt(ExtractFileName(ne), ''))) then begin
          MyMessagebox(GetLanguage('messagebox_manage.drag_map_unzip_error.caption'), GetLanguage('messagebox_manage.drag_map_unzip_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
          continue;
        end;
        inc(ic);
      end else if (DirectoryExists(ne)) then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_map_dir.caption'), GetLanguage('messagebox_manage.drag_map_dir.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNO, mybutton.myYes]) = 1 then continue;
        var dire := Concat(mcrlpth, '\saves');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetDirectories(dire);
        var boo := false;
        for var k in d do begin
          if ExtractFileName(k) = ChangeFileExt(ExtractFileName(ne), '') then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_map_dir_repeat.caption'), GetLanguage('messagebox_manage.drag_map_dir_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNO, mybutton.myYes]) = 1 then boo := true;
            DeleteDirectory(k);
            break;
          end;
        end;
        if boo then continue;
        if not DirectoryExists(Concat(dire, '\', ExtractFileName(ne))) then ForceDirectories(Concat(dire, '\', ExtractFileName(ne)));
        CopyDir(ne, Concat(dire, '\', ExtractFileName(ne)));
        inc(ic);
      end else begin
        MyMessagebox(GetLanguage('messagebox_manage.drag_map_format_error.caption'), GetLanguage('messagebox_manage.drag_map_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
      end;
    end;
  //纹理
  end else if (cc.Y > lres.Y) and
  (cc.Y < lres.Y + form_mainform.listbox_manage_import_resourcepack.Height) and
  (cc.X > lres.X) and
  (cc.X < lres.X + form_mainform.listbox_manage_import_resourcepack.Width) then begin
    for var j := 0 to i - 1 do begin
      DragQueryFile(Msg.WParam, j, @P, sizeof(P));
      var ne := StrPas(P);
      if RightStr(ne, 4) = '.zip' then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_resourcepack.caption'), GetLanguage('messagebox_manage.drag_resourcepack.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then continue;
        var dire := Concat(mcrlpth, '\resourcepacks');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetFiles(dire);
        var boo := false;
        for var k in d do begin
          if ExtractFileName(k) = ExtractFileName(ne) then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_resourcepack_repeat.caption'), GetLanguage('messagebox_manage.drag_resourcepack_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then boo := true;
            break;
          end;
        end;
        if boo then continue;
        CopyFile(pchar(ne), pchar(Concat(dire, '\', ExtractFileName(ne))), False);
        inc(ic);
      end else begin
        MyMessagebox(GetLanguage('messagebox_manage.drag_resourcepack_format_error.caption'), GetLanguage('messagebox_manage.drag_resourcepack_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
      end;
    end;
  //光影
  end else if (cc.Y > lsha.Y) and
  (cc.Y < lsha.Y + form_mainform.listbox_manage_import_shader.Height) and
  (cc.X > lsha.X) and
  (cc.X < lsha.X + form_mainform.listbox_manage_import_shader.Width) then begin
    for var j := 0 to i - 1 do begin
      DragQueryFile(Msg.WParam, j, @P, sizeof(P));
      var ne := StrPas(P);
      if RightStr(ne, 4) = '.zip' then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_shader.caption'), GetLanguage('messagebox_manage.drag_shader.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then continue;
        var dire := Concat(mcrlpth, '\shaderpacks');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetFiles(dire);
        var boo := false;
        for var k in d do begin
          if ExtractFileName(k) = ExtractFileName(ne) then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_shader_repeat.caption'), GetLanguage('messagebox_manage.drag_shader_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then boo := true;
            break;
          end;
        end;
        if boo then continue;
        CopyFile(pchar(ne), pchar(Concat(dire, '\', ExtractFileName(ne))), False);
        inc(ic);
      end else begin
        MyMessagebox(GetLanguage('messagebox_manage.drag_shader_format_error.caption'), GetLanguage('messagebox_manage.drag_shader_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
      end;
    end;
  //数据包
  end else if (cc.Y > ldat.Y) and
  (cc.Y < ldat.Y + form_mainform.listbox_manage_import_datapack.Height) and
  (cc.X > ldat.X) and
  (cc.X < ldat.X + form_mainform.listbox_manage_import_datapack.Width) then begin
    if form_mainform.listbox_manage_import_map.ItemIndex = -1 then begin
      MyMessagebox(GetLanguage('messagebox_manage.drag_datapack_no_choose_map_error.caption'), GetLanguage('messagebox_manage.drag_datapack_no_choose_map_error.text'), MY_ERROR, [mybutton.myOK]);
      exit;
    end;
    for var j := 0 to i - 1 do begin
      DragQueryFile(Msg.WParam, j, @P, sizeof(P));
      var ne := StrPas(P);
      if (RightStr(ne, 4) = '.zip') then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_datapack.caption'), GetLanguage('messagebox_manage.drag_datapack.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then continue;
        var dire := Concat(SavSelect[form_mainform.listbox_manage_import_map.ItemIndex], '\datapacks');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetFiles(dire);
        var boo := false;
        for var k in d do begin
          if ExtractFileName(k) = ExtractFileName(ne) then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_datapack_repeat.caption'), GetLanguage('messagebox_manage.drag_datapack_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then boo := true;
            break;
          end;
        end;
        if boo then continue;
        CopyFile(pchar(ne), pchar(Concat(dire, '\', ExtractFileName(ne))), False);
        inc(ic);
      end else begin
        MyMessagebox(GetLanguage('messagebox_manage.drag_shader_format_error.caption'), GetLanguage('messagebox_manage.drag_shader_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
      end;
    end;
  //插件
  end else if (cc.Y > lplu.Y) and
  (cc.Y < lplu.Y + form_mainform.listbox_manage_import_plugin.Height) and
  (cc.X > lplu.X) and
  (cc.X < lplu.X + form_mainform.listbox_manage_import_plugin.Width) then begin
    for var j := 0 to i - 1 do begin
      DragQueryFile(Msg.WParam, j, @P, sizeof(P));
      var ne := StrPas(P);
      if (RightStr(ne, 4) = '.jar') or (RightStr(ne, 4) = '.zip') then begin
        if MyMessagebox(GetLanguage('messagebox_manage.drag_plugin.caption'), GetLanguage('messagebox_manage.drag_plugin.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then continue;
        var dire := Concat(mcrlpth, '\plugins');
        if not DirectoryExists(dire) then ForceDirectories(dire);
        d := TDirectory.GetFiles(dire);
        var boo := false;
        for var k in d do begin
          if ExtractFileName(k) = ExtractFileName(ne) then begin
            if MyMessagebox(GetLanguage('messagebox_manage.drag_plugin_repeat.caption'), GetLanguage('messagebox_manage.drag_plugin_repeat.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_INFORMATION, [mybutton.myNo, mybutton.myYes]) = 1 then boo := true;
            break;
          end;
        end;
        if boo then continue;
        CopyFile(pchar(ne), pchar(Concat(dire, '\', ExtractFileName(ne))), False);
        inc(ic);
      end else begin
        MyMessagebox(GetLanguage('messagebox_manage.drag_plugin_format_error.caption'), GetLanguage('messagebox_manage.drag_plugin_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
      end;
    end;
  //整合包
  end else if (cc.Y > lpak.Y) and
  (cc.Y < lpak.Y + form_mainform.listbox_manage_import_modpack.Height) and
  (cc.X > lpak.X) and
  (cc.X < lpak.X + form_mainform.listbox_manage_import_modpack.Width) then begin
    if i > 1 then begin
      MyMessagebox(GetLanguage('messagebox_manage.drag_modpack_only_one_file.caption'), GetLanguage('messagebox_manage.drag_modpack_only_one_file.text'), MY_ERROR, [mybutton.myOK]);
    end;
    DragQueryFile(Msg.WParam, 0, @P, sizeof(P));
    var ne := strpas(p);
    if (RightStr(ne, 7) = '.mrpack') or (RightStr(ne, 4) = '.zip') then begin
      ImportModPack(ne);
    end else begin
      MyMessagebox(GetLanguage('messagebox_manage.drag_modpack_format_error.caption'), GetLanguage('messagebox_manage.drag_modpack_format_error.text').Replace('${drag_file_name}', ExtractFileName(ne)), MY_ERROR, [mybutton.myOK]);
    end;
  end;
  SelectresourceDir;
  if ic > 0 then MyMessagebox(GetLanguage('messagebox_manage.drag_file_finish.caption'), GetLanguage('messagebox_manage.drag_file_finish.text'), MY_PASS, [mybutton.myOK]);
end;
//点击地图列表框事件
procedure ManageChangeMap;
begin
  DatSelect.Clear;
  try
    var rpath := Concat(SavSelect[form_mainform.listbox_manage_import_map.ItemIndex], '\datapacks\');
    SearchDirProc(rpath, false, true, function(T: String): Boolean begin
      if RightStr(T, 4) = '.zip' then begin
        DatSelect.Add(T);
        form_mainform.listbox_manage_import_datapack.Items.Add(ChangeFileExt(ExtractFileName(T), ''));
      end;
      result := false;
    end);
  except end;
end;
//初始化玩法管理界面方法
var f: Boolean = false;
function InitManage: Boolean;
begin
  result := true;
  if f then begin
    try
      mcrlpth := JudgeIsolation;
    except
      result := false;
      exit;
    end;
    SelectresourceDir;
  end else begin
    ModSelect := TStringList.Create;
    SavSelect := TStringList.Create;
    ResSelect := TStringList.Create;
    ShaSelect := TStringList.Create;
    DatSelect := TStringList.Create;
    PluSelect := TStringList.Create;
    try
      mcrlpth := JudgeIsolation;
//      mcrlpth := 'D:\testdir';
    except
      result := false;
      exit;
    end;
    f := true;
    SelectresourceDir;
  end;
end;

end.
