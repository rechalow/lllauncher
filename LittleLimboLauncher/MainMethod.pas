unit MainMethod;

interface         

uses
  SysUtils, Classes, Windows, IOUtils, StrUtils, JSON, Forms, JPEG, PngImage, GIFImg, Dialogs, RegularExpressions, Math,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, NetEncoding;

function GetWebStream(url: String): TStringStream;
function GetWebText(url: String): String;
function TrimStrM(str: String): String;  
function GetFile(path: String): String;
procedure SetFile(path, content: String);     
function isX64: Boolean;                           
function GetDirectoryFileCount(Dir: String; suffix: String): TStringList;
function IsVersionError(path: String): Boolean;
procedure ResetBackImage(resume: Boolean);
procedure ResetBackMusic(resume: Boolean);
procedure PlayMusic;
function UUIDToHashCode(UUID: String): Int64;
procedure JudgeJSONSkin;

implementation

uses
  MainForm, Log4Delphi, LanguageMethod, MyCustomWindow, AccountMethod;

//����Ƥ��
procedure JudgeJSONSkin;
begin
  var pla := ((AccountJson.Values['account'] as TJsonArray)[form_mainform.combobox_all_account.ItemIndex] as TJsonObject);
  var pls := pla.GetValue('head_skin').Value;
  var base := TNetEncoding.Base64.DecodeStringToBytes(pls);
  var png := TPngImage.Create;
  try
    png.LoadFromStream(TBytesStream.Create(base));
    form_mainform.image_login_avatar.Picture.Assign(png);
  finally
    png.Free;
  end;
end;
//��UUIDǿת��HashCode��
function UUIDToHashCode(UUID: String): Int64;
begin
  result := -1;
  if TRegex.IsMatch(UUID, '^[a-f0-9]{32}') then begin
    var most := UUID.Substring(0, 16);
    var least := UUID.Substring(16, 16);
    var mostbin := '';
    var leastbin := '';
    for var I in most do begin
      if I = '0' then mostbin := mostbin + '0000'
      else if I = '1' then mostbin := mostbin + '0001'
      else if I = '2' then mostbin := mostbin + '0010'
      else if I = '3' then mostbin := mostbin + '0011'
      else if I = '4' then mostbin := mostbin + '0100'
      else if I = '5' then mostbin := mostbin + '0101'
      else if I = '6' then mostbin := mostbin + '0110'
      else if I = '7' then mostbin := mostbin + '0111'
      else if I = '8' then mostbin := mostbin + '1000'
      else if I = '9' then mostbin := mostbin + '1001'
      else if I = 'a' then mostbin := mostbin + '1010'
      else if I = 'b' then mostbin := mostbin + '1011'
      else if I = 'c' then mostbin := mostbin + '1100'
      else if I = 'd' then mostbin := mostbin + '1101'
      else if I = 'e' then mostbin := mostbin + '1110'
      else if I = 'f' then mostbin := mostbin + '1111'
    end;
    for var I in least do begin
      if I = '0' then leastbin := leastbin + '0000'
      else if I = '1' then leastbin := leastbin + '0001'
      else if I = '2' then leastbin := leastbin + '0010'
      else if I = '3' then leastbin := leastbin + '0011'
      else if I = '4' then leastbin := leastbin + '0100'
      else if I = '5' then leastbin := leastbin + '0101'
      else if I = '6' then leastbin := leastbin + '0110'
      else if I = '7' then leastbin := leastbin + '0111'
      else if I = '8' then leastbin := leastbin + '1000'
      else if I = '9' then leastbin := leastbin + '1001'
      else if I = 'a' then leastbin := leastbin + '1010'
      else if I = 'b' then leastbin := leastbin + '1011'
      else if I = 'c' then leastbin := leastbin + '1100'
      else if I = 'd' then leastbin := leastbin + '1101'
      else if I = 'e' then leastbin := leastbin + '1110'
      else if I = 'f' then leastbin := leastbin + '1111'
    end;
    var xor1 := '';
    for var I := 1 to mostbin.Length do begin
      if mostbin[I] = leastbin[I] then begin
        xor1 := xor1 + '0';
      end else begin
        xor1 := xor1 + '1';
      end;
    end;
    var mostx := xor1.Substring(0, 32);
    var leastx := xor1.Substring(32, 32);
    var xor2 := '';
    for var I := 1 to mostx.Length do begin
      if mostx[I] = leastx[I] then begin
        xor2 := xor2 + '0';
      end else begin
        xor2 := xor2 + '1';
      end;
    end;
    var ten: Int64 := 0;
    for var I := 1 to xor2.Length do begin
      if xor2[I] = '1' then begin
        ten := ten + Trunc(IntPower(2, xor2.Length - I));
      end;
    end;
    result := ten;
  end;
end;
function GetWebStream(url: String): TStringStream;
begin
  var http := TNetHttpClient.Create(nil); //����ʼ������ֵ
  var strt := TStringStream.Create('', TEncoding.UTF8, False);
  result := nil;
  try
    with http do begin
      AcceptCharSet := 'utf-8';
      AcceptEncoding := '65001';
      AcceptLanguage := 'en-US';
      ResponseTimeout := 200000;
      ConnectionTimeout := 200000;
      SendTimeout := 200000;
      ContentType := 'text/html';
      SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
      HandleRedirects := True;  //������ַ�ض���
    end;
    try
      var h := http.Get(url, strt);  //��ȡ�����ı�
      result := strt; //����������ֵΪ�����ı��ı���������
      if h.StatusCode = 404 then result := nil;
    except  //����޷���ȡ�����׳�����
    end;
  finally
    http.Free; //�ͷ���Դ
  end;
end;
//��ȡ�����ļ�
function GetWebText(url: String): String;
begin
  var http := TNetHTTPClient.Create(nil); //����ʼ������ֵ
  var strt := TStringStream.Create('', TEncoding.UTF8, False);
  result := '';
  try
    with http do begin
      AcceptCharSet := 'utf-8';
      AcceptEncoding := '65001';
      AcceptLanguage := 'en-US';
      ResponseTimeout := 200000;
      ConnectionTimeout := 200000;
      SendTimeout := 200000;
      ContentType := 'text/html';
      SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
      HandleRedirects := True;  //������ַ�ض���
    end;
    try
      var h := http.Get(url, strt);  //��ȡ�����ı�
      result := strt.DataString; //����������ֵΪ�����ı��ı���������
      if h.StatusCode = 404 then result := '';
    except  //����޷���ȡ�����׳�����
    end;
  finally
    http.Free; //�ͷ���Դ
    strt.Free;
  end;
end;
//��������
procedure PlayMusic;
begin
  if v.FileName <> '' then
  begin
    v.Open;
    v.Play;
  end;
end;
//���ñ���ͼƬ�ķ�����
procedure ResetBackImage(resume: Boolean);
var
  Files: TArray<String>;
begin
  randomize;
  var jrr := 0;
  var MList := TStringList.Create;  //�����ļ����µ�BackGround�ļ��С�
  var path := Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\BackGroundImage');
  if SysUtils.DirectoryExists(path) then begin //����ļ����ڣ���ִ��
    Files := TDirectory.GetFiles(path);
    for var I in Files do begin  //��Ӳ��ֺ�׺���ļ�
      var J := ExtractFileExt(I);
      if (J = '.jpg') or (J = '.png') or (J = '.gif') or (J = '.bmp') or (J = '.jpeg') then begin
        MList.Add(I); //���б���ӡ�
        inc(jrr);
      end;
    end;
  end;
  var imgpth: String; //���б�·�����Ͽ�ֵ
  if jrr <> 0 then begin
    imgpth := MList[random(jrr)]; //���������Ԫ�أ���ִ�С�
    Log.Write('����ͼƬ�ѱ�������ء�', LOG_INFO);
  end else begin
    if resume then
      MyMessageBox(GetLanguageText('messagebox_background_reset_image.not_found.caption'), GetLanguageText('messagebox_background_reset_image.not_found.text'), MY_ERROR, [mybutton.myYes]);
    exit;  //û��Ԫ�أ���������
  end;
  var suffix := ExtractFileExt(imgpth);
  if (suffix = '.jpg') or (suffix = '.jpeg') then begin
    var jpg := TJpegImage.Create;
    jpg.LoadFromFile(imgpth);
    form_mainform.image_mainpage_background_image.Picture.Assign(jpg);
    jpg.Free;
  end else if suffix = '.bmp' then
    form_mainform.image_mainpage_background_image.Picture.Bitmap.LoadFromFile(imgpth)
  else if suffix = '.png' then begin
    var png := TPngImage.Create;
    png.LoadFromFile(imgpth);
    form_mainform.image_mainpage_background_image.Picture.Assign(png);
    png.Free;
  end else if suffix = '.gif' then begin
    var gif := TGifImage.Create;
    gif.LoadFromFile(imgpth);
//    gif.Animate := true;
//    gif.Transparent := true;
    form_mainform.image_mainpage_background_image.Picture.Assign(gif);
    gif.Free;
  end;
  if resume then
    MyMessageBox(GetLanguageText('messagebox_background_reset_image.success.caption'), GetLanguageText('messagebox_background_reset_image.success.text').Replace('${background_image_filename}', ExtractFileName(imgpth)), MY_INFORMATION, [mybutton.myYes]);
end;
//���ñ������ֵķ�����
procedure ResetBackMusic(resume: Boolean);
var
  Files: TArray<String>;
begin
  randomize;
  var jrr := 0;
  var MList := TStringList.Create;
  var path := Concat(ExtractFileDir(Application.ExeName), '\LLLauncher\BackGroundMusic');
  if SysUtils.DirectoryExists(path) then begin
    Files := TDirectory.GetFiles(path);
    for var I in Files do begin //����
      var J := I.Substring(I.LastIndexOf('.'), I.Length - I.LastIndexOf('.'));
      if (J = '.mp3') or (J = '.wav') or (J = 'm4a') then begin
        MList.Add(I);
        inc(jrr);
      end;
    end;
  end;
  var mic: String;
  if jrr <> 0 then begin
    mic := MList[random(jrr)];
  end else begin
    if resume then
      MyMessageBox(GetLanguageText('messagebox_background_reset_music.not_found.caption'), GetLanguageText('messagebox_background_reset_music.not_found.text'), MY_ERROR, [mybutton.myYes]);
    exit;
  end;
  v.FileName := mic;
  Log.Write('���������ѱ�������ء�', LOG_INFO);
  if resume then begin
    MyMessageBox(GetLanguageText('messagebox_background_reset_music.success.caption'), GetLanguageText('messagebox_background_reset_music.success.text').Replace('${background_music_filename}', ExtractFileName(mic)), MY_INFORMATION, [mybutton.myYes]);
    PlayMusic;
  end;
end;
//�жϰ汾�Ƿ�����
function IsVersionError(path: String): Boolean;
var
  Files: TArray<String>;
begin
  result := true;
  if DirectoryExists(path) then // �ж��ļ����Ƿ����
  begin
    Files := TDirectory.GetFiles(path); // �ҵ������ļ�
    for var I in Files do begin // �����ļ�
      if I.IndexOf('.json') <> -1 then begin
        var god := GetFile(I);
        try
          var Root := TJsonObject.ParseJSONValue(god) as TJsonObject;
          Root.GetValue('id');
          Root.GetValue('libraries');
          result := false;
          exit;
        except
          continue;
        end;
      end;
    end;
  end;
end;
//ȥ���ַ����ո�
function TrimStrM(str: String): String;
var
  i: Integer;
begin
  repeat  //ʹ��ѭ�������ַ���
    i := pos(' ', str); //��ȡ�ո��ַ����ַ�����λ�á�
    var j := length(str); //��ȡ�ַ����ĳ���
    if i > 0 then  //����ַ������пո�
      str := copy(str, 1, i - 1) + copy(str, i + 1, j - i); //ǰ��Ϊ�����ַ���ǰ����ַ���
  until i = 0;
  str := str.Replace(#13, '').Replace(#10, '');
  Result := str;
end; 
//��ȡ�ļ�    
function GetFile(path: String): String;
begin
  result := '';
  if not FileExists(path) then exit;
  var ss := TStringStream.Create('', TEncoding.UTF8, False);
  try
    ss.LoadFromFile(path); //ֱ�Ӷ�ȡ
    result := ss.DataString;
  finally
    ss.Free;
  end;
end;
//�����ļ�
procedure SetFile(path, content: String);
begin
  if not SysUtils.DirectoryExists(ExtractFilePath(path)) then
    SysUtils.ForceDirectories(ExtractFilePath(path));
  var ss := TStringStream.Create('', TEncoding.UTF8, False);
  try
    ss.WriteString(content);
    ss.SaveToFile(path);
  finally
    ss.Free;
  end;
end;        
//��ȡ����ϵͳ�Ƿ�Ϊ64λ��   
function isX64: Boolean;
var
  si: SYSTEM_INFO;
begin
  GetNativeSystemInfo(&si); // = 9 ��ʾ���� AMD64
  if(si.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64 {9}) or
    (si.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64) then
    Result := True
  else
    Result := False;
end;          
//��ȡ�ļ�������������һ������Ϊ�ļ��У��ڶ�������Ϊ���ļ�������������ֵ�Ǹ��ļ����ļ��б�����
function GetDirectoryFileCount(Dir: String; suffix: String): TStringList;
var
  d: TArray<String>;
begin
  result := TStringList.Create;
  if not DirectoryExists(Dir) then exit;
  d := TDirectory.GetFiles(dir);
  for var I in d do begin
    if RightStr(I, suffix.Length) = suffix then begin
      result.Add(I);
    end;
  end;
end;

end.
