unit AccountMethod;

interface

uses
  SysUtils, JSON, Generics.Collections, System.RegularExpressions, Threading, Classes, NetEncoding, ExtCtrls, PngImage;

procedure InitAuthlib();
procedure InitAccount();
procedure SaveAccount;
procedure OfflineLogin(offline_name, offline_uuid: String);

var
  AccountJSON: TJsonObject;

implementation

uses
  Log4Delphi, MainForm, MainMethod, MyCustomWindow;

var
  mauthlib_download: String;
  maccount_logintype: Integer;

const
  Steve =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAAHMSURBVHhe7dsxS0JRHAVwr099WqQRYVIgzUHQ1tSsEA3RF6iGICForKmmigja6hPUFC1FNIRfpCAsoYJCUMSe+p41nPHvfW' +
'BDw/n/lnMWBc/jwlXQzE5nehELP0DpwzFRNFnb76LJul0fTRaN2t8/HnPQZD3rp/t9fyQtHQBJSwdA0tIBkLTMTN5+D/grNxFDk6Vd+zMIQp7RV8NDk/lByD0DSUsHQNLSAZC0dAAkrdB7wOHWKposEU+gyVLJNJqs1ayj9eHYn1Ht4w1NdnJ1hybTI4CkpQMgaekASFr0A5iLvU3r' +
'PSDlumiylmf/Pu449tfX6jU0WX4iiyarVB7RBqNHAElLB0DS0gGQtOgHMNcH29Z7wPLuKZpsqXiEJluff0WTuSPDaLLzhzE02c39Dprscr+EJtMjgKSlAyBp6QBIWvQDmLONRes9IJubQpPF3Qya7LZcRhvMSnEBTVZ9eUKTPb9/osn0CCBp6QBIWjoAkhb9AOZ4rWC9BySM/Q8DlW' +
'oD7X/kJofQZI1mB02mRwBJSwdA0tIBkLToBzClwpz1HhAE9nvA+Kj994AwXqeNJku5SbTBtLxvNJkeASQtHQBJSwdA0iIfIBL5AYycVHLWJ+hEAAAAAElFTkSuQmCC';
  Alex =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABg0lEQVR4nO2asUoDQRRFZ5zRjSBYWqbVTqzstEvvJ9hYWVv4G4KkyWf4CZbaqZWdhY2iKLohQf/gPpZFDrj3tG9n9nB58DKbyU/TyU9SfHzLctoY6Xq0PqLv/sH6lY46/w4HQAvQOABagMYB0AI09c/nfLD+a/4p6+' +
't6995+g+8AB0AL0DgAWoDGAdACNJWe85uHZ3r/gPn1Ra/1g+8AB0AL0DgAWoDGAdACNDWa02kt2KHnnG+aRtbf3171+/eOZTnfzGR98B3gAGgBGgdAC9A4AFqApo72T+UDW7tHsr59siPrtxM951PR3xMOLs9l/WF6L+vP+u3uAAdAC9A4AFqAxgHQAjT55e5K3hPMZVVuULK+ZhjN' +
'+bQM/nfIRZYXi4Ws15JlffAd4ABoARoHQAvQOABagKbWWvUTJTjPB3N8+Rh81w8oY31TMJrzbdvK+uA7wAHQAjQOgBagcQC0AE3wIyDF5/XgvF/GXXS67x8RXD9wBzgAWoDGAdACNA6AFqD5BVHZQDbja48HAAAAAElFTkSuQmCC';
  Zuri =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABZ0lEQVR4nO2bPUoDURSFM/ok+JOIELG0tdQijWBjpWDjKqziHtyC6xDcgY0gQjYgWA3YSAJi4g9BRXuL85BL/NB3vvbkDV8OF+4ww1TtVH02ArRaSzJvzqXI5RuTt3eZj8dPoevPhE7/A1wALUDjAmgBGhdAC9Bkl/' +
'Th9obM2wtNma8s6jzHw/NE5qMXnZ9f3ci8+AlwAbQAjQugBWhcAC1AU/X2NuXzgOgep8ndRxQ/AS6AFqBxAbQAjQugBWjSX9/zOXL/r/gJcAG0AI0LoAVoXAAtQJN9L3Bydi3z3fVZme90uz8z+sZlvy/zi/pD5sf7WzIvfgJcAC1A4wJoARoXQAvQVKdHB/K9wHA4+C2XqdDprMq8' +
'+AlwAbQAjQugBWhcAC1Ak6a951/vH0Pn59eWQ+dv6zuZFz8BLoAWoHEBtACNC6AFaFI9GMkfRL8HiO7xHNHvCYqfABdAC9C4AFqAxgXQAjRfq1A1NTxw6xsAAAAASUVORK5CYII=';
  Sunny =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABbklEQVR4nO2ZMUrEUBRF50sgBEwREYS4ALXKEmYBugRBcAm2Y+msw8YljPazC12AAUEMOELSxdbqPeQhB/n3tDf/5+TyYH4mqeu6eWFQVZUVL8ZxNHNvfdM0Zt73fWh/z2/PTDNABdACNCqAFqBRAbQATRHdoG1bMx' +
'+GIXoLk3k2jzEu2U+ACqAFaFQALUCjAmgBGvcc4L1Pe+/z3nqPsizNfJqm0P7ZT4AKoAVoVAAtQKMCaAGaYrfbmRfUdW3m3vu+t/9f490/+wlQAbQAjQqgBWhUAC1AUzxdn5kXnKw2Zp5SMvPnu/NfS/3k9PbRzL3vAi/rCzPPfgJUAC1AowJoARoVQAvQpM/7q9gH9n9O9hOgAmgB' +
'GhVAC9CoAFqApuhf380L2uPD0A3WD9vQ+tXlMrTee77sJ0AF0AI0KoAWoFEBtABN2t4szf8Djg72zQ2i54Qo3u/828eXmWc/ASqAFqBRAbQAjQqgBWi+Ab8TQ/22ShIlAAAAAElFTkSuQmCC';
  Noor =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABeElEQVR4nO2bu0rEUBRFEw0KCpIECwuZxtJHYSUM2AgWfoAi2FhZ+gl+zqCNpWgvfoCPzkatVDLTKCiI1jb7ECIs8O7Vbm6ysjlwLyTJV+ZmvjPB1MS4irP3zy+ZL87XMr99amTe9f7R+jGZJoALoAVoXAAtQOMCaA' +
'GafK1XyXPA4fqqvEA9PSnz5u0DXX90diXz5CfABdACNC6AFqBxAbQATT7Y25DngGifna0rmb82w/ZWf0h0jkh+AlwALUDjAmgBGhdAC9AU0T4/Go465WVVtjNqef2IOrh/8hPgAmgBGhdAC9C4AFqApoj22e3jS5nvLvdkvt8vWyr95vTuUeaD6weZn+z0ZZ78BLgAWoDGBdACNC6A' +
'FqDJzw+25HuB/07yE+ACaAEaF0AL0LgAWoCm6PodXsTFzX2n9ZtLC53W+/uAABdAC9C4AFqAxgXQAjTF84v+by/L9H9/0Tmh6z4eEe3z0fMlPwEugBagcQG0AI0LoAVofgCvVkbgvjJEUQAAAABJRU5ErkJggg==';
  Makena =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABhklEQVR4nO2azUrDQBhFE0mbSFMstURE3Na6ciPiC/Ql+qq+gTtX/mwVxFJLsWlpUNGtq/spQz2L+c72NpnTy8BMJkmH/eorEWw+3lWcDDpdmVvMVkuZF1lL5mVeyLxuNjLfkWkEeAG0AI0XQAvQeAG0AE3WyfOtDm' +
'Ct88OTg6D7z5/WMrf2CdHPAC+AFqDxAmgBGi+AFqDJVk0jf7Dbasu8vfcp86LRz/MP9y8yt/YJ1vjzqT7PiH4GeAG0AI0XQAvQeAG0AE3Wr4xz924ZNEAZ9trgF/e3BtDnEdHPAC+AFqDxAmgBGi+AFqDJrHX06vpW5meHqcyr49GfpX4yfbyT+c2z/LwhGV+cyjz6GeAF0AI0XgAt' +
'QOMF0AI06WR8LhfS6aL+L5etUPX0eUb0M8ALoAVovABagMYLoAVo0svRkdwH2OfumtnrIuj6wX4v6Pp66e8FJF4ALUDjBdACNF4ALUCTva3DnvetfULoOm5hrfPW/4t+BngBtACNF0AL0HgBtADNN4fxPOYStPLFAAAAAElFTkSuQmCC';
  Kai =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABXklEQVR4nO2bvU4CURBGWUFJICExtpb0FDRqQucboPEFKHgdOxKo6Px9Aqy1oTC2dppY0YEJP2ZpKchM4O56ivuddrjLyckku5tAspzcpgWL1B4Xfhf2vFq25zAHtACNAtACNApAC9AoAC1AU3I/4d3nK0cZqWxnMv' +
'4MOn/SrJvz6DdAAWgBGgWgBWgUgBag8Z8Dcn6f/+i/mPPjWiXo+slFy5xHvwEKQAvQKAAtQKMAtACN+xyQ93069Hwo0W+AAtACNApAC9AoAC1Ak6ym9+YPAIrVa/MCl90rcz5oHO5utUHnfWnOR71Hc/43ezDn0W+AAtACNApAC9AoAC1A4z4HfA2f/8slF05vzs159BugALQAjQLQ' +
'AjQKQAvQlNL5T65f0Ht6CzrfbZ9lZLKd6DdAAWgBGgWgBWgUgBagSdz/DTp8371m5bIX3vu+R/QboAC0AI0C0AI0CkAL0KwBFfMxwHR5oEgAAAAASUVORK5CYII=';
  Efe =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABpklEQVR4nO2bsUrDUBiFrcaGJoLFahA3cRILLro6uNTZVTc3fQ8Xwa26OfgAruqiD6CLUHB0E6k2ZmmCSYuu4nB+StAD3vOtJ9x8HH64SbipHO4ef44BvGoVxSZhLYB5P0tLrR/3ujCfaUQwHy9193+ACmALsFEBbA' +
'E2KoAtwMazLsjSPsxnG3Mwf+u9wrwWhJYCJE7w+noOMFABbAE2KoAtwEYFsAXYeNb7fjEoYD49PId5tDAF86dkC+bW+/7G8iPMn/MVmDs/ASqALcBGBbAF2KgAtgAbb5Dn8IKl+iXM/QDv8xaL9Ssjt1bA988S/D3D+QlQAWwBNiqALcBGBbAF2JjfA3ZOb2G+31yH+WZrfmSp79xc' +
'v8D8pHMH86O9NsydnwAVwBZgowLYAmxUAFuATaV9cAbPCUb+xV+5/Ardj22YOz8BKoAtwEYFsAXYqAC2ABvznGCRDmE+GUzA/P6hM5rRD9ZWmzC3/PwQn0N0fgJUAFuAjQpgC7BRAWwBNp71315Ux/u8hbWPl8V6Donf8f8Ezk+ACmALsFEBbAE2KoAtwOYLUodFeDw82gEAAAAASU' +
'VORK5CYII=';
  Ari =
'iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAABcElEQVR4nO2aMUoDQRhGExmSLSKIrGBjGRFsPILgDVJZeAZ7C0HxAsEzWHsDwUsIYi5gEYvAIksIaCsI388yLg+Z77X/7vLyGJhJssObk92vgeBgb0eNB5/rjZxHzE7P5Pzx+Snr+RFbvT79H+AAtACNA9ACNA5AC9' +
'Ck8XgkL4j2+Wgfn9TbnaW6PD86J3ysGjkvfgU4AC1A4wC0AI0D0AI0aVLpc0C0D9dH07/0+UVV78v5LLg/OicUvwIcgBagcQBagMYBaAGaFF3Q9z6fS+jnc4DGAWgBGgegBWgcgBagSU27lheMzq/kfJr0UeLl4a6z1E+OL67lfLHR/1s083s5L34FOAAtQOMAtACNA9ACNMPV7aV8' +
'TzCiOtS/2/dN+/aedX/xK8ABaAEaB6AFaByAFqBJfe/jy9dF1v3R7/65/sWvAAegBWgcgBagcQBagCa1S/19OnpPL4J+vyD6fMWvAAegBWgcgBagcQBagOYblfMz+bzIKgUAAAAASUVORK5CYII=';
var g: Boolean = false;
//����UUID�ж���š�
function UUIDToAvatar(uuid: String): Integer;
begin
  result := UUIDToHashCode(uuid) mod 18;
end;
//������Ż�ȡUUID��
function AvatarToUUID(num: Integer): String;
var
  uid: TGuid;
begin
  while True do begin
    CreateGuid(uid);
    var str := GuidToString(uid).Replace('{', '').Replace('}', '').Replace('-', '').ToLower;
    if UUIDToAvatar(str) = num then begin
      result := str;
      break;
    end;
  end;
end;
//�и�Base64��ͼ������ͼ���base64���룬Ȼ���������ϵĶ������ϵ������µĶ������µ�����ͼ��Ŀ�Ⱥ͸߶ȡ�
//����ֵΪһ���µ�base64���롣
//����ü�ֵ����ԭͼ�񳤿���Ĭ�Ϸ���zstop~��ͣ�����zsleft~���ҵȡ�Ȼ�󽫸�ͼ���յȱ������ų�xwidth��xheight�ġ�
function CutBase64Image(ig: String; zstop, zsleft, yxtop, yxleft, xwidth, xheight: Integer): String;
begin
  var pic := TImage.Create(nil);
  var png := TPngImage.Create;
  var png2 := TPngImage.Create;
  var s := TStringStream.Create;
  var c := TStringStream.Create('');
  try
    var ss := TNetEncoding.Base64.DecodeStringToBytes(ig);
    png.LoadFromStream(TBytesStream.Create(ss));
    with pic do begin
      Width := xwidth;
      Height := xheight;
      Canvas.CopyRect(Rect(0, 0, Width, Height), png.Canvas, Rect(zsleft, zstop, yxleft, yxtop));
    end;
    png2.Assign(pic.Picture.Graphic);
    png2.SaveToStream(s);
    s.Position := 0;
    TNetEncoding.Base64.Encode(s, c);
    result := c.DataString.Replace(#13, '').Replace(#10, '');
  finally
    pic.Free;
    png.Free;
    png2.Free;
    s.Free;
    c.Free;
  end;
end;
//���ߵ�¼
procedure OfflineLogin(offline_name, offline_uuid: String);
var
  uid: TGuid;
begin
  if (offline_name = '') or (not TRegex.IsMatch(offline_name, '^[a-zA-Z0-9_]+$')) or (offline_name.Length > 16) or (offline_name.Length < 3) then begin
    MyMessagebox('���󾯸�', '������ߵ�¼���Ʋ������룬��������벻Ҫ�������ģ�Ҳ��Ҫ����16���ַ�����ҪΪ�ա�', MY_ERROR, [mybutton.myOK]);
  end;
  offline_uuid := offline_uuid.ToLower;
  if offline_uuid = '' then begin
    CreateGuid(uid);
    offline_uuid := GuidToString(uid).Replace('{', '').Replace('}', '').Replace('-', '').ToLower;
  end;
  if not TRegex.IsMatch(offline_uuid, '^[a-f0-9]{32}') then begin
    MyMessagebox('���󾯸�', '������ߵ�¼UUID�������������һ����32λ�޷���UUID�����߲�����ȴ��������', MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  TTask.Run(procedure begin
    var skin := '';
    form_mainform.label_account_return_value.Caption := '���ڳ��Ը���UUID��ȡ�û���ͷ��';
    form_mainform.button_add_account.Enabled := false;
    form_mainform.button_refresh_account.Enabled := false;
    form_mainform.combobox_all_account.Enabled := false;
    var db := TJsonObject.ParseJSONValue(GetWebText(Concat('https://sessionserver.mojang.com/session/minecraft/profile/', offline_uuid))) as TJsonObject;
    try
      var prop := db.GetValue('properties') as TJsonArray;
      for var I in prop do begin
        var J := I as TJsonObject;
        if J.GetValue('name').Value = 'textures' then begin
          var skinbase := J.GetValue('value').Value;
          var sj2 := TNetEncoding.Base64.Decode(skinbase);
          var surl := (((TJsonObject.ParseJSONValue(sj2) as TJsonObject).GetValue('textures') as TJsonObject).GetValue('SKIN') as TJsonObject).GetValue('url').Value;
          var pic := GetWebStream(surl);
          var ss := TStringStream.Create;
          TNetEncoding.Base64.Encode(pic, ss);
          skin := CutBase64Image(ss.DataString, 8, 8, 16, 16, 64, 64);
        end;
      end;
    except
      case UUIDToAvatar(offline_uuid) of
        0: skin := alex;
        1: skin := ari;
        2: skin := efe;
        3: skin := kai;
        4: skin := makena;
        5: skin := noor;
        6: skin := steve;
        7: skin := sunny;
        8: skin := zuri;
        9: skin := alex;
        10: skin := ari;
        11: skin := efe;
        12: skin := kai;
        13: skin := makena;
        14: skin := noor;
        15: skin := steve;
        16: skin := sunny;
        17: skin := zuri;
        else raise Exception.Create('No Offline Skin Found!');
      end;
    form_mainform.label_account_return_value.Caption := '��ӳɹ�����ͨ��UUID��ȡ����Ƥ����';
    end; //������Ŀ����ӵ������ļ���д��Json
    (AccountJson.GetValue('account') as TJsonArray).Add(TJsonObject.Create
      .AddPair('type', 'offline')
      .AddPair('name', offline_name)
      .AddPair('uuid', offline_uuid)
      .AddPair('head_skin', skin)
    );
    form_mainform.combobox_all_account.ItemIndex := form_mainform.combobox_all_account.Items.Add(Concat(offline_name, '�����ߣ�')); //�����������Ԫ�أ�˳�㸳ֵ������ֵ��
    form_mainform.edit_offline_name.Text := '';//��Edit����Ϊ��
    form_mainform.edit_offline_uuid.Text := '';
    form_mainform.button_add_account.Enabled := true;
    form_mainform.button_refresh_account.Enabled := true;
    form_mainform.combobox_all_account.Enabled := true;
    form_mainform.combobox_all_accountChange(TObject.Create);
    TThread.Queue(nil, procedure begin
      MyMessagebox('��ӳɹ�', '��ӳɹ���', MY_INFORMATION, [mybutton.myOK]);
    end);
  end);
end;
//��ʼ����������¼
procedure InitAuthlib();
begin
  if g then exit;
  g := true;
  //��Ҫ���ز��֡���
end;
var f: Boolean = false;
//��ʼ���˺Ų���
procedure InitAccount();
begin
  if f then exit;
  f := true;
  Log.Write('���ڳ�ʼ���˺Ų��ִ��롭��', LOG_INFO);
  if not SysUtils.FileExists(Concat(AppData, '\LLLauncher\', 'AccountJson.json')) then begin //��Json������ֵ����һ��account��JsonArray
    Log.Write('δ�ҵ�AccountJson�ļ������Զ�������ʼ��һ����', LOG_ERROR);
    AccountJson.AddPair('account', TJsonArray.Create);
    var j := AccountJson.Format;  //��Json��ʽ��
    SetFile(Concat(AppData, '\LLLauncher\', 'AccountJson.json'), j);
  end else begin //�������ִ��
    Log.Write('���ҵ�AccountJson�ļ������ڵ����С���', LOG_INFO);
    var j := GetFile(Concat(AppData, '\LLLauncher\', 'AccountJson.json'));
    AccountJson := TJsonObject.ParseJSONValue(j) as TJsonObject; //��Account���ϳ�ֵ��
  end;
  try
    Log.Write('����Ϊ�˺Ų�������������˺š�', LOG_INFO);//����Json����
    for var I in (AccountJson.GetValue('account') as TJsonArray) do begin //����ҵ���typeΪoffline����ô���Ϊ���ߵ�¼�������⵽microsoft����ô���Ϊ΢�������¼��
      var tpe := I.GetValue<String>('type');
      if tpe = 'offline' then form_mainform.combobox_all_account.Items.Add(Concat(I.GetValue<String>('name'), '�����ߣ�'))
      else if (tpe = 'microsoft') or (tpe = 'oauth') then form_mainform.combobox_all_account.Items.Add(Concat(I.GetValue<String>('name'), '��΢��'))
      else if tpe = 'authlib-injector' then form_mainform.combobox_all_account.Items.Add(Concat(I.GetValue<String>('name'), '�����ã�'))
      else raise Exception.Create('Format Exception');
    end;
  except
    Log.Write('�Ѽ����˺Ų����ѱ��޸ģ������̸��Ļ�����', LOG_ERROR);
    form_mainform.combobox_all_account.ItemIndex := -1;
  end;
  try
    Log.Write('�ж�����Դ������Authlib-Injector', LOG_INFO);
    var ds := strtoint(LLLini.ReadString('Version', 'SelectDownloadSouece', ''));
    if ds = 1 then mauthlib_download := 'https://authlib-injector.yushi.moe/'
    else if ds = 2 then mauthlib_download := 'https://bmclapi2.bangbang93.com/mirrors/authlib-injector/'
    else if ds = 3 then mauthlib_download := 'https://download.mcbbs.net/mirrors/authlib-injector/'
    else raise Exception.Create('Format Exception');
  except
    Log.Write('����Դ�ж�ʧ�ܣ����Զ�����Ϊ�ٷ�����Դ��', LOG_ERROR);
    LLLini.WriteString('Version', 'SelectDownloadSouece', '1');
    mauthlib_download := 'https://authlib-injector.yushi.moe/';
  end;
  try  //�жϵ�¼���˺�
    Log.Write('����Դ�ж���ϣ��������ж���һ�ε�¼���˺���ʲô��', LOG_INFO);
    var acc := Otherini.ReadString('Account', 'SelectAccount', '');
    if not (acc = '0') and not (strtoint(acc) > (AccountJson.GetValue('account') as TJsonArray).Count) then  //����˺Ų�Ϊ�գ�
    begin  //������Ϲ涨����ִ�С�
      form_mainform.combobox_all_account.ItemIndex := strtoint(acc) - 1; //����Ϊ��һ�ε�¼����������ʽ
      var tm: String := form_mainform.combobox_all_account.Items[form_mainform.combobox_all_account.ItemIndex]; //��tm��ʱ������ֵ��
      tm := tm.Replace('��΢��', '').Replace('�����ã�', '').Replace('�����ߣ�', ''); //��tmȥ��΢���ǩ��
      form_mainform.label_account_return_value.Caption := Concat('�ѵ�¼��������ƣ�', tm); //��Label�����ѵ�¼
      Log.Write(Concat('�жϳɹ������¼�������Ϸ���ǣ�', tm), LOG_INFO);
    end else raise Exception.Create('Format Exception');
  except
    Log.Write('�ж�ʧ�ܣ��������˺ŵ�ѡ��', LOG_ERROR);
    Otherini.WriteString('Account', 'SelectAccount', '0'); //���û�У���ֵ����д���ļ�
    form_mainform.combobox_all_account.ItemIndex := -1;
    form_mainform.label_account_return_value.Caption := 'δ��¼';
  end;
  try //����¼��ʽ���и�ֵ��
    Log.Write(Concat('�˺�ѡ���ж���ϣ����ڿ�ʼ�ж�ѡ���¼��ʽ��'), LOG_INFO);
    maccount_logintype := strtoint(LLLini.ReadString('Account', 'SelectLoginMode', ''));
    case maccount_logintype of
      1: form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_offline_part;
      2: form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_microsoft_part;
      3: form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_thirdparty_part;
      else raise Exception.Create('Format Exception');
    end;
  except  //�����¼��ʽ���������׳�����
    Log.Write(Concat('��¼��ʽ�ж�ʧ�ܣ������õ�¼��ʽΪ���ߵ�¼��'), LOG_ERROR);
    LLLini.WriteString('Account', 'SelectLoginMode', '1');
    form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_offline_part;
    maccount_logintype := 1;
  end;
end;

procedure SaveAccount;
begin
  if AccountJson = nil then begin
    exit;
  end;
  SetFile(Concat(AppData, '\LLLauncher\AccountJson.json'), AccountJson.Format);
  Otherini.WriteString('Account', 'SelectAccount', inttostr(form_mainform.combobox_all_account.ItemIndex + 1));
  LLLini.WriteString('Account', 'SelectLoginMode', inttostr(maccount_logintype));
  if form_mainform.combobox_all_account.ItemIndex = -1 then
    form_mainform.label_account_view.Caption := '�㻹��δ��¼�κ�һ���˺ţ���¼�󼴿�������鿴��ӭ�'
  else begin
    var player_name := form_mainform.combobox_all_account.Items[form_mainform.combobox_all_account.ItemIndex];
    player_name := player_name.Replace('��΢��', '').Replace('�����ã�', '').Replace('�����ߣ�', '');
    form_mainform.label_account_view.Caption := Concat('��ð���', player_name, '��ף���и�����һ�죡');
  end;
end;

end.
