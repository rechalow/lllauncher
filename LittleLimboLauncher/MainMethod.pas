unit MainMethod;

interface         

uses
  SysUtils, Classes, Windows, IOUtils, StrUtils, JSON, Forms, JPEG, PngImage, GIFImg;

function TrimStrM(str: String): String;  
function GetFile(path: String): String;
procedure SetFile(path, content: String);     
function isX64: Boolean;                           
function GetDirectoryFileCount(Dir: String; suffix: String): TStringList;
function IsVersionError(path: String): Boolean;
procedure ResetBackImage(resume: Boolean);
procedure ResetBackMusic(resume: Boolean);

implementation

uses
  MainForm, Log4Delphi;

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
      messagebox(form_mainform.Handle, '����ͼƬˢ��ʧ�ܣ���δ�����ļ���', 'ˢ��ʧ��', MB_ICONERROR);
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
    messagebox(form_mainform.Handle, pchar(Concat('����ͼƬˢ�³ɹ���', #13#10, '���ƣ�', ExtractFileName(imgpth))), 'ˢ�³ɹ�', MB_ICONINFORMATION);
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
      messagebox(form_mainform.Handle, '��������ˢ��ʧ�ܣ���δ�����ļ���', 'ˢ��ʧ��', MB_ICONERROR);
    exit;
  end;
  v.FileName := mic;
  Log.Write('���������ѱ�������ء�', LOG_INFO);
  if resume then begin
    messagebox(form_mainform.Handle, pchar(Concat('��������ˢ�³ɹ���', #13#10, '���ƣ�', ExtractFileName(mic))), 'ˢ�³ɹ�', MB_ICONINFORMATION);
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
