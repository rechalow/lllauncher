﻿unit AccountMethod;

interface

uses
  SysUtils, JSON, Generics.Collections, System.RegularExpressions, Threading, Classes, NetEncoding, ExtCtrls, PngImage, Dialogs,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, StrUtils, Forms, ShellAPI, Windows,
  ClipBrd;

procedure InitAuthlib();
procedure InitAccount();
procedure SaveAccount;
procedure OfflineLogin(offline_name, offline_uuid: String);
function AvatarToUUID(num: Integer): String;
function UUIDToAvatar(uuid: String): Integer;
function JudgeOfflineSkin(choNumber: Integer; isSlim: Boolean): String;
function DeleteAccount(index: Integer): Integer;
procedure ThirdPartyLogin(server, account, password: String);
procedure JudgeJSONSkin(index: Integer);
procedure RefreshAccount(index: Integer);
procedure OAuthLogin;

type
  TAccount = class
  private
  //现在只提供微软OAuth登录了，不提供浏览器登录了。。
    username, accesstoken, uuid, refreshtoken, avatar: String;
    thirdclienttoken, thirdbase64: String;
    function JudgeThirdSkin(web, uuid: String): String;
  public
    constructor InitializeAccount(token, client_id, rr: String); overload; //构造函数
    constructor InitializeAccount(servername, username, password, clienttoken, uuid, rr: String); overload; //构造函数
    function GetUserName: String;
    function GetAccessToken: String;
    function GetUUID: String;
    function GetRefreshToken: String;
    function GetAvatar: String;
    function GetThirdClientToken: String;
    function GetThirdBase64: String;
    class function GetHttpf(key, web: String; that: Boolean = false): String;
    class function GetHttph(key, web: String): String;
  end;

var
  AccountJSON: TJsonObject;

implementation

uses
  Log4Delphi, MainForm, MainMethod, MyCustomWindow, LanguageMethod, DownloadMethod, PrivacyMethod;

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

//切割Base64的图像，填入图像的base64编码，然后填入左上的顶，左上的左，右下的顶和右下的左，新图象的宽度和高度。
//返回值为一个新的base64编码。
//如果裁剪值高于原图像长宽，则默认返回zstop~最低，或者zsleft~最右等。然后将该图像按照等比例缩放成xwidth和xheight的。
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
//Post网络，但是需要请求头
class function TAccount.GetHttpf(key, web: string; that: Boolean = false): string;
begin
  var ss := TStringStream.Create('', TEncoding.UTF8, False);
  var http := TNetHTTPClient.Create(nil);
  try
    ss.WriteString(key); //写入流
    ss.Position := 0;
    with http do begin
      AcceptCharSet := 'utf-8'; //设置网络请求编码
      AcceptEncoding := '65001'; //设置编码代号
      AcceptLanguage := 'en-US'; //设置网络请求语言
      ResponseTimeout := 200000; //设置请求时长
      ConnectionTimeout := 200000; //设置连接时长
      SendTimeout := 200000; //设置发送时长【完美的英文理解】，以下为设置请求协议。
      SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
      HandleRedirects := True;  //可以网址重定向
      if that then begin
        ContentType := Concat('application/x-www-form-urlencoded;charset=utf-8'); //如果that为true，则设定请求类型为form，反之则为json
      end else begin
        ContentType := Concat('application/json;charset=utf-8');
      end;
      try
        var res := Post(web, ss);
        if res.StatusCode = 404 then result := '' else
        result := res.ContentAsString;
      except
        result := '';
      end;
    end;
  finally
    http.Free; //释放资源。以下两个皆如此
    ss.Free;
  end;
end;
//Get网络，但是需要请求头
class function TAccount.GetHttph(key, web: string): string;
begin
  var ss := TStringStream.Create('', TEncoding.UTF8, False);
  var http := TNetHTTPClient.Create(nil);
  try
    with http do begin
      AcceptCharSet := 'utf-8';
      AcceptEncoding := '65001';
      AcceptLanguage := 'en-US';
      ResponseTimeout := 200000;
      ConnectionTimeout := 200000;
      SendTimeout := 200000;
      SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
      HandleRedirects := True;
      CustomHeaders['Authorization'] := Concat('Bearer ', key); //设置自定义头。
      try
        var res := Get(web, ss);
        if res.StatusCode = 404 then result := '' else
        result := ss.DataString;
      except
        result := '';
      end;
    end;
  finally
    http.Free;
    ss.Free;
  end;
end;
//获取皮肤大头像。
function TAccount.JudgeThirdSkin(web, uuid: String): String;
begin
  var sj := GetWebText(Concat(web, 'sessionserver/session/minecraft/profile/', uuid));
  if sj = '' then begin
    result := '';
    exit;
  end;
  var prop := (TJsonObject.ParseJSONValue(sj) as TJsonObject).GetValue('properties') as TJsonArray;
  for var I in prop do begin
    var o := I as TJsonObject;
    if o.GetValue('name').Value = 'textures' then begin
      var value := o.GetValue('value').Value;
      var sj2 := TNetEncoding.Base64.Decode(value);
      var surl := (((TJsonObject.ParseJSONValue(sj2) as TJsonObject).GetValue('textures') as TJsonObject).GetValue('SKIN') as TJsonObject).GetValue('url').Value;
      var pic := GetWebStream(surl);
      if pic = nil then begin
        result := '';
        exit;
      end;
      var ss := TStringStream.Create;
      TNetEncoding.Base64.Encode(pic, ss);
      result := CutBase64Image(ss.DataString, 8, 8, 16, 16, 64, 64);
    end;
  end;
end;
//初始化微软登录
constructor TAccount.InitializeAccount(token, client_id, rr: string);
const
  micro = 'https://login.live.com/oauth20_token.srf';
  oauth = 'https://login.microsoftonline.com/consumers/oauth2/v2.0/token';
  xbox = 'https://user.auth.xboxlive.com/user/authenticate';
  xsts = 'https://xsts.auth.xboxlive.com/xsts/authorize';
  mc = 'https://api.minecraftservices.com/authentication/login_with_xbox';
  ishas = 'https://api.minecraftservices.com/minecraft/profile';
var
  k1: String;
  t1: String;
begin
  if client_id = '' then begin
    if rr = 'refresh' then begin
      k1 := Concat('client_id=00000000402b5328',
        '&refresh_token=', token,
        '&grant_type=refresh_token',
        '&redirect_uri=https://login.live.com/oauth20_desktop.srf',
        '&scope=service::user.auth.xboxlive.com::MBI_SSL');
    end else begin
      k1 := Concat('client_id=00000000402b5328',
        '&code=', token,
        '&grant_type=authorization_code',
        '&redirect_uri=https%3A%2F%2Flogin.live.com%2Foauth20_desktop.srf',
        '&scope=service%3A%3Auser.auth.xboxlive.com%3A%3AMBI_SSL');
    end;
    t1 := micro;
  end else begin
    if rr = 'refresh' then begin
      k1 := Concat('grant_type=refresh_token',
      '&client_id=', client_id,
      '&refresh_token=', token);
    end else begin
      k1 := Concat('grant_type=urn:ietf:params:oauth:grant-type:device_code',
      '&client_id=', client_id,
      '&device_code=', token);
    end;
    t1 := oauth;
  end;
  Log.Write('正在请求microsoft中……', LOG_ACCOUNT, LOG_INFO);
  form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.post_microsoft');
  //这里是请求microsoft的。
  var g1 := TAccount.GetHttpf(k1, t1, true);  //传值进方法并将返回值设置。
  var j1 := TJsonObject.ParseJSONValue(g1) as TJsonObject; //设置json
  var w1 := '';
  try
    w1 := j1.GetValue('access_token').Value; //获取assets_token，下面继续设置请求参数。
  except
    var e1 := (j1.GetValue('error_codes') as TJsonArray)[0].GetValue<Integer>;
    if e1 = 70016 then begin
      Log.Write('你暂未完善你的登录验证流程，请重试……', LOG_ACCOUNT, LOG_ERROR);
      MyMessagebox(GetLanguage('messagebox_account_microsoft_error.not_complete_oauth_login.caption'), GetLanguage('messagebox_account_microsoft_error.not_complete_oauth_login.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.microsoft_not_complete_oauth_login');
      self.accesstoken := 'noneaccount';
      exit;
    end else if e1 = 70020 then begin
      Log.Write('你在登录过程中超时了，请重试……', LOG_ACCOUNT, LOG_ERROR);
      MyMessagebox(GetLanguage('messagebox_account_microsoft_error.login_timeout.caption'), GetLanguage('messagebox_account_microsoft_error.login_timeout.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.microsoft_login_timeout');
      self.accesstoken := 'noneaccount';
      exit;
    end else raise Exception.Create('Not support script');
  end;
  Log.Write('请求完毕microsoft，正在请求xbox中……', LOG_ACCOUNT, LOG_INFO);
  form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.post_xbox');
  //这里是请求xbox的
  var k2 := Concat('{"Properties":{"AuthMethod":"RPS","SiteName":"user.auth.xboxlive.com","RpsTicket":"d=', w1, '"},"RelyingParty":"http://auth.xboxlive.com","TokenType":"JWT"}');
  var t2 := TAccount.GetHttpf(k2, xbox);
  var j2 := TJsonObject.ParseJSONValue(t2) as TJsonObject;
  var w2 := j2.GetValue('Token').Value;
  //这里将获取到uhs的值。
  var r1 := j2.GetValue('DisplayClaims') as TJsonObject;
  var uhs := ((r1.GetValue('xui') as TJsonArray)[0] as TJsonObject).GetValue('uhs').Value;
  Log.Write('请求完毕xbox，正在请求xsts中……', LOG_ACCOUNT, LOG_INFO);
  form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.post_xsts');
  //这里是请求xsts的
  var k3 := Concat('{"Properties":{"SandboxId":"RETAIL","UserTokens":["', w2, '"]},"RelyingParty":"rp://api.minecraftservices.com/","TokenType":"JWT"}');
  var t3 := TAccount.GetHttpf(k3, xsts);
  var j3 := TJsonObject.ParseJSONValue(t3) as TJsonObject;
  var w3 := j3.GetValue('Token').Value;
  //这里将判断uhs是否一致【基本上都会一致的，没有存在不一致的情况。。。】
  var rr1 := j3.GetValue('DisplayClaims') as TJsonObject;
  var uhs2 := ((rr1.GetValue('xui') as TJsonArray)[0] as TJsonObject).GetValue('uhs').Value;
  try
    if uhs <> uhs2 then raise Exception.Create('Error Message');
  except
    Log.Write('xbox与xsts的uhs不一致，请立刻将此Log反馈给作者！……', LOG_ACCOUNT, LOG_ERROR);
    MyMessagebox(GetLanguage('messagebox_account_microsoft_error.uhs_not_same.caption'), GetLanguage('messagebox_account_microsoft_error.uhs_not_same.text'), MY_ERROR, [mybutton.myOK]);
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.microsoft_uhs_not_same');
    self.accesstoken := 'noneaccount';
    exit;
  end;
  Log.Write('请求完毕xsts，正在请求mc中……', LOG_ACCOUNT, LOG_INFO);
  form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.post_mc');
  //这一步是请求mc的。
  var k4 := Concat('{"identityToken":"XBL3.0 x=', uhs, ';', w3, '"}');
  var t4 := TAccount.GetHttpf(k4, mc);
  var j4 := TJsonObject.ParseJSONValue(t4) as TJsonObject;
  var w4 := j4.GetValue('access_token').Value; //获取到accesstoken。
  Log.Write('请求完毕mc，正在获取是否拥有游戏中……', LOG_ACCOUNT, LOG_INFO);
  form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.get_has_mc');
  var t5 := TAccount.GetHttph(w4, ishas);
  var j5 := TJsonObject.ParseJSONValue(t5) as TJsonObject;
  try
    self.username := j5.GetValue('name').Value;
    self.uuid := j5.GetValue('id').Value;
    self.refreshtoken := j1.GetValue('refresh_token').Value;
    self.accesstoken := j4.GetValue('access_token').Value;
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.microsoft_get_avatar');
    var skurl := ((j5.GetValue('skins') as TJsonArray)[0] as TJsonObject).GetValue('url').Value;
    var ss := TStringStream.Create;
    var stre := GetWebStream(skurl);
    TNetEncoding.Base64.Encode(stre, ss);
    self.avatar := CutBase64Image(ss.DataString, 8, 8, 16, 16, 64, 64);
//    Log.Write('登录成功！', LOG_ACCOUNT, LOG_INFO);
//    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.microsoft_login_success');
  except
    Log.Write('登录失败，您暂未拥有游戏。', LOG_ACCOUNT, LOG_ERROR);
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.not_buy_mc');
    if MyMessagebox(GetLanguage('messagebox_account_microsoft_error.not_buy_mc.caption'), GetLanguage('messagebox_account_microsoft_error.not_buy_mc.text'), MY_ERROR, [mybutton.myNo, mybutton.myYes]) = 6 then begin
      ShellExecute(Application.Handle, nil,
        'https://www.minecraft.net/zh-hans/store/minecraft-java-edition',
        nil, nil, SW_SHOWNORMAL)
    end;
  end;
end;
//初始化外置登录（servername一定是【https://example.com/api/yggdrasil/】形式的，且最后一定要接一个/符号。）
constructor TAccount.InitializeAccount(servername, username, password, clienttoken, uuid, rr: string);
begin
  Log.Write('正在请求皮肤站元数据链接。', LOG_ACCOUNT, LOG_INFO);
  var metadata := GetWebText(servername);
  if metadata = '' then begin
    Log.Write('皮肤站元数据链接请求失败，请重试。', LOG_ACCOUNT, LOG_ERROR);
    MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.cannot_get_metadata.caption'), GetLanguage('messagebox_account_thirdparty_error.cannot_get_metadata.text'), MY_ERROR, [mybutton.myOK]);
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.thirdparty_cannot_get_metadata');
    accesstoken := 'noneaccount';
    exit;
  end;
  var res := servername;
  var basecode := TNetEncoding.Base64.Encode(metadata);
  if rr = 'refresh' then begin
    res := Concat(res, 'authserver/refresh');
    var k1 := Concat('{"accessToken":"', username, '","clientToken":"', password, '","requestUser":false,"selectedProfile":{"id":"', clienttoken, '","name":"', uuid, '"}}');
    Log.Write('正在使用当前账号以及角色重置外置登录。', LOG_ACCOUNT, LOG_INFO);
    var t1 := TAccount.GetHttpf(k1, res);
    if t1 = '' then begin abort; end;
    var j1 := TJsonObject.ParseJSONValue(t1) as TJsonObject;
    try //以上为直接post得到后的json，然后解析json。下面为直接获取json，如果没有皮肤，则换。但绝大概率是有皮肤的。
      var j2 := TJsonObject.ParseJSONValue(j1.GetValue('selectedProfile').ToString) as TJsonObject;
      self.username := j2.GetValue('name').Value;
      self.uuid := j2.GetValue('id').Value;
      self.accesstoken := j1.GetValue('accessToken').Value;
      self.thirdclienttoken := j1.GetValue('clientToken').Value;
      self.thirdbase64 := basecode;
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.add_account_success_and_get_avatar');
      self.avatar := JudgeThirdSkin(servername, self.uuid);
    except
      Log.Write('你在重置外置登录时，可能官网上已经删掉了该皮肤，建议重新尝试后再继续！', LOG_ACCOUNT, LOG_ERROR);
      MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.refresh_skin_error.caption'), GetLanguage('messagebox_account_thirdparty_error.refresh_skin_error.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.thirdparty_cannot_refresh_skin');
      accesstoken := 'noneaccount';
      exit;
    end;
  end else begin
    res := Concat(res, 'authserver/authenticate');
    var k1 := Concat('{"username":"', username, '","password":"', password, '","clientToken":"', clienttoken, '","requestUser":false,"agent":{"name":"Minecraft","version":1}}');
    Log.Write('正在使用账号密码进行外置登录。', LOG_ACCOUNT, LOG_INFO);
    var t1 := TAccount.GetHttpf(k1, res);
    if t1 = '' then abort;
    var j1 := TJsonObject.ParseJSONValue(t1) as TJsonObject;
    try //如果邮箱与账号不匹配，则返回。
      j1.GetValue('accessToken').ToString;
    except
      Log.Write('输入的邮箱与密码不匹配，请重新输入。', LOG_ACCOUNT, LOG_ERROR);
      MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.username_or_password_nottrue.caption'), GetLanguage('messagebox_account_thirdparty_error.username_or_password_nottrue.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.thirdparty_username_or_password_nottrue');
      accesstoken := 'noneaccount';
      exit;
    end;//查询邮箱，如果邮箱里没有皮肤，则执行
    var r1 := j1.GetValue('availableProfiles') as TJsonArray;
    if r1.Count = 0 then begin
      Log.Write('登录成功！但是你还未在皮肤站中选择任何一个角色，请试图选择一个角色之后再进行登录吧。', LOG_ACCOUNT, LOG_ERROR);
      MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.not_choose_any_skin.caption'), GetLanguage('messagebox_account_thirdparty_error.not_choose_any_skin.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.thirdparty_not_choose_skin');
      accesstoken := 'noneaccount';
      exit;
    end else if r1.Count = 1 then begin
      var j2 := r1[0] as TJsonObject;
      self.uuid := j2.GetValue('id').Value;
      self.username := j2.GetValue('name').Value;
      self.accesstoken := j1.GetValue('accessToken').Value;
      self.thirdclienttoken := j1.GetValue('clientToken').Value;
      self.thirdbase64 := basecode;
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.add_account_success_and_get_avatar');
      self.avatar := JudgeThirdSkin(servername, self.uuid);
    end else begin
      var st := '';
      for var I := 0 to r1.Count - 1 do
      begin
        var j2 := r1[I] as TJsonObject;
        st := Concat(st, #13#10, inttostr(i + 1), '. ', j2.GetValue('name').Value);
      end;
      Log.Write('现在开始输入角色序号。', LOG_ACCOUNT, LOG_INFO);
      var input := MyInputBox(GetLanguage('inputbox_account_thirdparty.choose_a_role.caption'), GetLanguage('inputbox_account_thirdparty.choose_a_role.text').Replace('${role_group}', st), MY_INFORMATION);
      try
        if (strtoint(input) < 1) or (strtoint(input) > r1.Count) then raise Exception.Create('Entry Error');
      except
        Log.Write('不要尝试在选择角色的时候输入错误的字符。', LOG_ACCOUNT, LOG_ERROR);
        MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.dont_entry_other_char.caption'), GetLanguage('messagebox_account_thirdparty_error.dont_entry_other_char.text'), MY_ERROR, [mybutton.myOK]);
        form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.thirdparty_entry_other_char');
        accesstoken := 'noneaccount';
        exit;
      end;
      var sa := strtoint(input) - 1;
      var j3 := r1[sa] as TJsonObject;
      self.uuid := j3.GetValue('id').Value;
      self.username := j3.GetValue('name').Value;
      self.accesstoken := j1.GetValue('accessToken').Value;
      self.thirdclienttoken := j1.GetValue('clientToken').Value;
      self.thirdbase64 := basecode;
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.add_account_success_and_get_avatar');
      self.avatar := JudgeThirdSkin(servername, self.uuid);
    end;
  end;
end;
function TAccount.GetUserName: string;
begin
  result := username;
end;
function TAccount.GetAccessToken: string;
begin
  result := accesstoken;
end;
function TAccount.GetUUID: string;
begin
  result := uuid;
end;
function TAccount.GetRefreshToken: string;
begin
  result := refreshtoken
end;
function TAccount.GetAvatar: string;
begin
  result := avatar;
end;
function TAccount.GetThirdClientToken: string;
begin
  result := thirdclienttoken;
end;
function TAccount.GetThirdBase64: string;
begin
  result := thirdbase64;
end;
//根据UUID判断序号。
function UUIDToAvatar(uuid: String): Integer;
begin
  result := UUIDToHashCode(uuid) mod 18;
end;
//根据序号获取UUID。
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
//判断离线模式皮肤。
function JudgeOfflineSkin(choNumber: Integer; isSlim: Boolean): String;
begin
  if isSlim then begin
    result := AvatarToUUID(choNumber);
  end else begin
    result := AvatarToUUID(choNumber + 9);
  end;
end;
//更换皮肤
procedure JudgeJSONSkin(index: Integer);
begin
  try
    var pla := ((AccountJson.Values['account'] as TJsonArray)[index] as TJsonObject);
    var pls := pla.GetValue('head_skin').Value;
    var base := TNetEncoding.Base64.DecodeStringToBytes(pls);
    var png := TPngImage.Create;
    try
      png.LoadFromStream(TBytesStream.Create(base));
      form_mainform.image_login_avatar.Picture.Assign(png);
    finally
      png.Free;
    end;
  except end;
end;
//离线登录
procedure OfflineLogin(offline_name, offline_uuid: String);
var
  uid: TGuid;
begin
  if (offline_name = '') or (not TRegex.IsMatch(offline_name, '^[a-zA-Z0-9_]+$')) or (offline_name.Length > 16) or (offline_name.Length < 3) then begin
    MyMessagebox(GetLanguage('messagebox_account_offline_error.cannot_name.caption'), GetLanguage('messagebox_account_offline_error.cannot_name.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  offline_uuid := offline_uuid.ToLower;
  if offline_uuid = '' then begin
    CreateGuid(uid);
    offline_uuid := GuidToString(uid).Replace('{', '').Replace('}', '').Replace('-', '').ToLower;
  end;
  if not TRegex.IsMatch(offline_uuid, '^[a-f0-9]{32}') then begin
    MyMessagebox(GetLanguage('messagebox_account_offline_error.cannot_uuid.caption'), GetLanguage('messagebox_account_offline_error.cannot_uuid.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  TTask.Run(procedure begin
    var skin := '';
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.offline_get_avatar');
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
    end; //将所有目标添加到配置文件，写入Json
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.add_offline_success');
    (AccountJson.GetValue('account') as TJsonArray).Add(TJsonObject.Create
      .AddPair('type', 'offline')
      .AddPair('name', offline_name)
      .AddPair('uuid', offline_uuid)
      .AddPair('head_skin', skin)
    );
    form_mainform.combobox_all_account.ItemIndex := form_mainform.combobox_all_account.Items.Add(Concat(offline_name, GetLanguage('combobox_all_account.offline_tip'))); //给下拉框添加元素，顺便赋值给最终值。
    form_mainform.edit_offline_name.Text := '';//给Edit设置为空
    form_mainform.edit_offline_uuid.Text := '';
    form_mainform.button_add_account.Enabled := true;
    form_mainform.button_refresh_account.Enabled := true;
    form_mainform.combobox_all_account.Enabled := true;
    form_mainform.combobox_all_accountChange(TObject.Create);
    MyMessagebox(GetLanguage('messagebox_account_offline.add_account_success.caption'), GetLanguage('messagebox_account_offline.add_account_success.text'), MY_PASS, [mybutton.myOK]);
  end);
end;
//删除账号
function DeleteAccount(index: Integer): Integer;
begin
  result := index;
  if index = -1 then begin
    MyMessagebox(GetLanguage('messagebox_account.cannot_get_account.caption'), GetLanguage('messagebox_account.cannot_get_account.text'), MY_ERROR, [mybutton.myOK]);
    result := index;
    exit;
  end;
  if MyMessagebox(GetLanguage('messagebox_account.is_remove_account.caption'), GetLanguage('messagebox_account.is_remove_account.text'), MY_WARNING, [mybutton.myNo, mybutton.myYes]) = 2 then begin
    result := -1;
    (AccountJson.GetValue('account') as TJsonArray).Remove(form_mainform.combobox_all_account.ItemIndex);
    form_mainform.combobox_all_account.Items.Delete(form_mainform.combobox_all_account.ItemIndex);
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.not_login');
    form_mainform.image_login_avatar.Picture := nil;
    LLLini.WriteString('Account', 'SelectAccount', '0');
  end;
end;
//第三方登录函数
procedure ThirdPartyLogin(server, account, password: String);
var
  uid: TGuid;
begin
  if (account = '') or (password = '') or (server = '') then begin
    MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.account_or_password_empty.caption'), GetLanguage('messagebox_account_thirdparty_error.account_or_password_empty.text'), MY_ERROR, [mybutton.myOK]);
    exit;
  end;
  if LeftStr(server, 5) <> 'https' then begin
    server := server.Replace('http', 'https');
  end;
  if LeftStr(server, 8) <> 'https://' then begin
    server := Concat('https://', server);
  end;
  if RightStr(server, 1) <> '/' then begin
    server := Concat(server, '/');
  end;
  if RightStr(server, 14) <> 'api/yggdrasil/' then begin
    server := Concat(server, 'api/yggdrasil/');
  end;
  CreateGuid(uid);
  var clienttoken := GuidToString(uid).Replace('{', '').Replace('}', '').Replace('-', '');
  form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.thirdparty_login_start');
  TTask.Run(procedure begin
    Log.Write('正在添加外置登录。', LOG_ACCOUNT, LOG_INFO);
    form_mainform.button_add_account.Enabled := false;
    form_mainform.button_refresh_account.Enabled := false;
    form_mainform.combobox_all_account.Enabled := false;
    var taccm: TAccount;
    try
      taccm := TAccount.InitializeAccount(server, account, password, clienttoken, '', 'post');
    except
      MyMessagebox(GetLanguage('messagebox_account_thirdparty_error.connect_error.caption'), GetLanguage('messagebox_account_thirdparty_error.connect_error.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.button_add_account.Enabled := true;
      form_mainform.button_refresh_account.Enabled := true;
      form_mainform.combobox_all_account.Enabled := true;
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.connect_error');
      exit;
    end;
    var tat := taccm.GetAccessToken; //线程重启
    if taccm.accesstoken = 'noneaccount' then begin
      form_mainform.button_add_account.Enabled := true;
      form_mainform.button_refresh_account.Enabled := true;
      form_mainform.combobox_all_account.Enabled := true;
      exit;
    end;
    var tct := taccm.GetThirdClientToken;
    var tun := taccm.GetUserName;
    var tuu := taccm.GetUUID;
    var tbs := taccm.GetThirdBase64;
    var tsk := taccm.GetAvatar;
    (AccountJson.GetValue('account') as TJsonArray).Add(TJsonObject.Create
      .AddPair('type', 'authlib-injector')
      .AddPair('server', server)
      .AddPair('name', tun)
      .AddPair('uuid', tuu)
      .AddPair('access_token', tat)
      .AddPair('client_token', tct)
      .AddPair('base_code', tbs)
      .AddPair('head_skin', tsk)
    ); //给下拉框添加元素
    form_mainform.combobox_all_account.ItemIndex := form_mainform.combobox_all_account.Items.Add(Concat(tun, GetLanguage('combobox_all_account.thirdparty_tip')));
    form_mainform.edit_thirdparty_server.Text := '';
    form_mainform.edit_thirdparty_account.Text := '';
    form_mainform.edit_thirdparty_password.Text := '';
    form_mainform.button_add_account.Enabled := true;
    form_mainform.button_refresh_account.Enabled := true;
    form_mainform.combobox_all_account.Enabled := true;
    form_mainform.combobox_all_accountChange(TObject.Create);
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.add_thirdparty_success');
    MyMessagebox(GetLanguage('messagebox_account_thirdparty.add_account_success.caption'), GetLanguage('messagebox_account_thirdparty.add_account_success.text'), MY_PASS, [mybutton.myOK]);
  end);
end;
//微软OAuth登录
procedure OAuthLogin;
const
  dcurl = 'https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode?mkt=zh-CN';
begin
  form_mainform.button_add_account.Enabled := false;
  form_mainform.button_refresh_account.Enabled := false;
  form_mainform.combobox_all_account.Enabled := false;
  TTask.Run(procedure begin
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.get_oauth_user_code');
    Log.Write('正在获取用户代码……', LOG_ACCOUNT, LOG_INFO);
    var k1 := Concat('client_id=', MS_CLIENT_ID, '&scope=XboxLive.signin%20offline_access');  //此处使用了私有函数中的MS_CLIENT_ID
    var w1 := TAccount.GetHttpf(k1, dcurl, true);
    if w1 = '' then begin
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.cannot_get_user_code');
      MyMessagebox(GetLanguage('messagebox_account_microsoft_error.cannot_get_user_code.caption'), GetLanguage('messagebox_account_microsoft_error.cannot_get_user_code.caption'), MY_ERROR, [mybutton.myOK]);
      form_mainform.button_add_account.Enabled := true;
      form_mainform.button_refresh_account.Enabled := true;
      form_mainform.combobox_all_account.Enabled := true;
      exit;
    end;
    var json := TJsonObject.ParseJSONValue(w1) as TJsonObject;
    var usercode := json.GetValue('user_code').Value;
    var link := json.GetValue('verification_uri').Value;
    ClipBoard.SetTextBuf(pchar(usercode));
    ShellExecute(Application.Handle, nil, pchar(TrimStrm(link)), nil, nil, SW_SHOWNORMAL);
    MyInputBox(GetLanguage('inputbox_account_microsoft.start_login.caption'), GetLanguage('inputbox_account_microsoft.start_login.text'), MY_INFORMATION, usercode);
    var devicecode := json.GetValue('device_code').Value; //获取device_code。
    var accm: TAccount;
    try
      accm := TAccount.InitializeAccount(devicecode, MS_CLIENT_ID, 'post');
    except
      MyMessagebox(GetLanguage('messagebox_account_microsoft_error.connect_error.caption'), GetLanguage('messagebox_account_microsoft_error.connect_error.text'), MY_ERROR, [mybutton.myOK]);
      form_mainform.button_add_account.Enabled := true;
      form_mainform.button_refresh_account.Enabled := true;
      form_mainform.combobox_all_account.Enabled := true;
      form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.connect_error');
      exit;
    end;
    var at := accm.GetAccessToken;
    if at = 'noneaccount' then begin
      form_mainform.button_add_account.Enabled := true;
      form_mainform.button_refresh_account.Enabled := true;
      form_mainform.combobox_all_account.Enabled := true;
      exit;
    end;//如果at没有账号，则为返回方法。
    var rt := accm.GetRefreshToken;  //获取RefreshToken刷新秘钥
    var un := accm.GetUserName;   //获取玩家名字
    var ud := accm.GetUUID;       //获取UUID
    var sk := accm.GetAvatar;
    (AccountJson.GetValue('account') as TJsonArray).Add(TJsonObject.Create
      .AddPair('type', 'oauth')
      .AddPair('name', un)
      .AddPair('uuid', ud)
      .AddPair('access_token', at)
      .AddPair('refresh_token', rt)
      .AddPair('head_skin', sk)
    );
    form_mainform.combobox_all_account.ItemIndex := form_mainform.combobox_all_account.Items.Add(Concat(un, GetLanguage('combobox_all_account.microsoft_tip')));
    form_mainform.label_account_return_value.Caption := GetLanguage('label_account_return_value.caption.add_microsoft_success');
    form_mainform.button_add_account.Enabled := true;
    form_mainform.button_refresh_account.Enabled := true;
    form_mainform.combobox_all_account.Enabled := true;
    form_mainform.combobox_all_accountChange(TObject.Create);
    MyMessagebox(GetLanguage('messagebox_account_microsoft.add_account_success.caption'), GetLanguage('messagebox_account_microsoft.add_account_success.text'), MY_PASS, [mybutton.myOK]);
  end)
end;
//刷新账号
procedure RefreshAccount(index: Integer);
begin
  //
end;
//初始化第三方登录
var g: Boolean = false;
procedure InitAuthlib();
begin
  if g then exit;
  g := true;
  //需要下载部分……
end;
//初始化账号部分
var f: Boolean = false;
procedure InitAccount();
begin
  if f then exit;
  f := true;
  Log.Write('正在初始化账号部分代码……', LOG_INFO, LOG_START);
  if not SysUtils.FileExists(Concat(AppData, '\LLLauncher\', 'AccountJson.json')) then begin //给Json变量初值附上一个account的JsonArray
    Log.Write('未找到AccountJson文件，已自动帮您初始化一个。', LOG_ERROR, LOG_START);
    AccountJson.AddPair('account', TJsonArray.Create);
    var j := AccountJson.Format;  //将Json格式化
    SetFile(Concat(AppData, '\LLLauncher\', 'AccountJson.json'), j);
  end else begin //如果有则执行
    Log.Write('已找到AccountJson文件，正在导入中……', LOG_INFO, LOG_START);
    var j := GetFile(Concat(AppData, '\LLLauncher\', 'AccountJson.json'));
    AccountJson := TJsonObject.ParseJSONValue(j) as TJsonObject; //给Account附上初值。
  end;
  try
    Log.Write('正在为账号部分下拉框添加账号。', LOG_INFO, LOG_START);//遍历Json数组
    for var I in (AccountJson.GetValue('account') as TJsonArray) do begin //如果找到的type为offline，那么添加为离线登录，如果检测到microsoft，那么添加为微软正版登录。
      var tpe := I.GetValue<String>('type');
      if tpe = 'offline' then form_mainform.combobox_all_account.Items.Add(Concat(I.GetValue<String>('name'), GetLanguage('combobox_all_account.offline_tip')))
      else if (tpe = 'microsoft') or (tpe = 'oauth') then form_mainform.combobox_all_account.Items.Add(Concat(I.GetValue<String>('name'), GetLanguage('combobox_all_account.microsoft_tip')))
      else if tpe = 'authlib-injector' then form_mainform.combobox_all_account.Items.Add(Concat(I.GetValue<String>('name'), GetLanguage('combobox_all_account.thirdparty_tip')))
      else raise Exception.Create('Format Exception');
    end;
  except
    Log.Write('已检测出账号部分已被修改，请立刻更改回来！', LOG_ERROR, LOG_START);
    form_mainform.combobox_all_account.ItemIndex := -1;
  end;
  try
    Log.Write('判断下载源以下载Authlib-Injector', LOG_INFO, LOG_START);
    var ds := strtoint(LLLini.ReadString('Version', 'SelectDownloadSouece', ''));
    if ds = 1 then mauthlib_download := 'https://authlib-injector.yushi.moe/'
    else if ds = 2 then mauthlib_download := 'https://bmclapi2.bangbang93.com/mirrors/authlib-injector/'
    else if ds = 3 then mauthlib_download := 'https://download.mcbbs.net/mirrors/authlib-injector/'
    else raise Exception.Create('Format Exception');
  except
    Log.Write('下载源判断失败，已自动重置为官方下载源。', LOG_ERROR, LOG_START);
    LLLini.WriteInteger('Version', 'SelectDownloadSouece', 1);
    mauthlib_download := 'https://authlib-injector.yushi.moe/';
  end;
  try  //判断登录的账号
    Log.Write('下载源判断完毕，现在是判断上一次登录的账号是什么。', LOG_INFO, LOG_START);
    var acc := Otherini.ReadString('Account', 'SelectAccount', '');
    if not (acc = '0') and not (strtoint(acc) > (AccountJson.GetValue('account') as TJsonArray).Count) then  //如果账号不为空，
    begin  //如果符合规定，则执行。
      form_mainform.combobox_all_account.ItemIndex := strtoint(acc) - 1; //设置为上一次登录的下拉框样式
      var tm: String := form_mainform.combobox_all_account.Items[form_mainform.combobox_all_account.ItemIndex]; //将tm临时变量赋值。
      tm := tm.Replace(GetLanguage('combobox_all_account.microsoft_tip'), '').Replace(GetLanguage('combobox_all_account.thirdparty_tip'), '').Replace(GetLanguage('combobox_all_account.offline_tip'), ''); //给tm去除微软标签。
      form_mainform.label_account_return_value.Caption := Concat('已登录，玩家名称：', tm); //给Label设置已登录
      Log.Write(Concat('判断成功，你登录的玩家游戏名是：', tm), LOG_INFO, LOG_START);
    end else raise Exception.Create('Format Exception');
  except
    Log.Write('判断失败，已重置账号的选择。', LOG_ERROR, LOG_START);
    Otherini.WriteString('Account', 'SelectAccount', '0'); //如果没有，则赋值重新写入文件
    form_mainform.combobox_all_account.ItemIndex := -1;
    form_mainform.label_account_return_value.Caption := '未登录';
  end;
  try //给登录方式进行赋值。
    Log.Write(Concat('账号选择判断完毕，现在开始判断选择登录方式。'), LOG_INFO, LOG_START);
    maccount_logintype := strtoint(LLLini.ReadString('Account', 'SelectLoginMode', ''));
    case maccount_logintype of
      1: form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_offline_part;
      2: form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_microsoft_part;
      3: form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_thirdparty_part;
      else raise Exception.Create('Format Exception');
    end;
  except  //如果登录方式不合理，则抛出报错。
    Log.Write(Concat('登录方式判断失败，已重置登录方式为离线登录。'), LOG_ERROR, LOG_START);
    LLLini.WriteString('Account', 'SelectLoginMode', '1');
    form_mainform.pagecontrol_account_part.ActivePage := form_mainform.tabsheet_account_offline_part;
    maccount_logintype := 1;
  end;
  form_mainform.combobox_all_accountChange(TObject.Create);
  TTask.Run(procedure begin
    InitAuthlib;
  end);
end;
//保存账号部分
procedure SaveAccount;
begin
  if AccountJson = nil then begin
    exit;
  end;
  SetFile(Concat(AppData, '\LLLauncher\AccountJson.json'), AccountJson.Format);
  Otherini.WriteString('Account', 'SelectAccount', inttostr(form_mainform.combobox_all_account.ItemIndex + 1));
  LLLini.WriteString('Account', 'SelectLoginMode', inttostr(maccount_logintype));
  if form_mainform.combobox_all_account.ItemIndex = -1 then begin
    form_mainform.label_account_view.Caption := GetLanguage('label_account_view.caption.absence')
  end else begin
    var player_name := form_mainform.combobox_all_account.Items[form_mainform.combobox_all_account.ItemIndex];
    player_name := player_name.Replace(GetLanguage('combobox_all_account.microsoft_tip'), '').Replace(GetLanguage('combobox_all_account.thirdparty_tip'), '').Replace(GetLanguage('combobox_all_account.offline_tip'), '');
    form_mainform.label_account_view.Caption := GetLanguage('label_account_view.caption.have').Replace('${account_view}', player_name);
  end;
end;

end.
