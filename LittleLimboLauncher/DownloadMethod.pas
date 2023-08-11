unit DownloadMethod;

interface

uses
  System.Net.HttpClient, System.Net.HttpClientComponent, System.Generics.Collections, JSON,
  SysUtils, Classes, Math, Windows, Threading;

procedure DownloadStart(url, SavePath, RootPath: String; BiggestThread, SelectMode, LoadSource: Integer; isShowList: Boolean = true; isShowProgress: Boolean = true);

implementation

uses
  DownloadProgressForm, MainMethod, LanguageMethod;

type
  TDownloadMethod = class
  protected
    function GetFileSize(aurl: String): Integer;
    function GetHTTPNormal(url: String): TStringStream;
    procedure ReceiveData(const Sender: TObject;
      AContentLength, AReadCount: Int64; var AAbort: Boolean);
    function GetHTTPRange(url: String; tstart, tend: Integer;
      showProg: Boolean): TStringStream;
  end;

var
  url, SavePath, RootPath, TempPath: String;
  BiggestThread, SelectMode: Integer;
  isShowList, isShowProgress: Boolean;
  dm: TDownloadMethod;
//�ڵ��߳����ص�ʱ���������ʾ���ؽ��ȡ�
procedure TDownloadMethod.ReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var AAbort: Boolean);
begin
  form_progress.progressbar_progress_download_bar.Max := AContentLength;
  var jd: Currency := 100 * AReadCount / AContentLength; //�������ؽ��ȡ�������100��������sfȻ���������̡߳���������ﵽ��������߳�һ���Ļ�����ô�ͻ�ﵽ100��
  if isShowProgress then form_progress.label_progress_download_progress.Caption := Concat('���ؽ��ȣ�', floattostr(SimpleRoundTo(jd)), '% | ', inttostr(AReadCount), '/', inttostr(AContentLength));//������ؽ��ȡ���һ����ǩ������ؽ��ȡ�ʹ���˱�����λС����
  if isShowList then form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(Concat('Ŀǰ�Ѿ����ص���', inttostr(AReadCount)));
  if isShowProgress then form_progress.progressbar_progress_download_bar.Position := AReadCount;
end;
//��ȡ�ض�λ�õ�Http��
function TDownloadMethod.GetHTTPRange(url: String; tstart, tend: Integer;
  showProg: Boolean): TStringStream;
begin
  var http := TNetHttpClient.Create(nil); //��ʼ��
  var strt := TStringStream.Create('', TEncoding.UTF8, False); //��ʼ��һ����
  result := nil; //��result����Ϊһ��nil����Ϊ����ֵ����һ������
  try
    with http do begin //����������һ����
      AcceptCharSet := 'utf-8';
      AcceptEncoding := '65001';
      AcceptLanguage := 'en-US';
      ResponseTimeout := 200000;
      ConnectionTimeout := 200000;
      SendTimeout := 200000;
      SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];
      HandleRedirects := True;
      if showProg then OnReceiveData := ReceiveData;
    end;
    try
      http.GetRange(url, tstart, tend, strt);  //��ȡ�����ļ�����Ҫ�洢������������档start��end�����м�
      result := strt; //��Get�������Ϊ����ֵ���ء���
    except end;
  finally
    http.Free; //�ͷ���Դ
  end;
end;
//��ȡhttps���أ�����ͷ�в���������Χ�����ǿ�����ʾ���ȣ�
function TDownloadMethod.GetHTTPNormal(url: String): TStringStream;
begin
  var http := TNetHttpClient.Create(nil); //����ʼ������ֵ
  var strt := TStringStream.Create('', TEncoding.UTF8, False);
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
      OnReceiveData := ReceiveData;
    end;
    try
      var h := http.Get(url, strt);  //��ȡ�����ı�
      result := strt; //����������ֵΪ�����ı��ı���������
      if h.StatusCode = 404 then result := nil;
    except  //����޷���ȡ�����׳�����
      result := nil;
    end;
  finally
    http.Free; //�ͷ���Դ
  end;
end;
//��ȡ�ļ���С
function TDownloadMethod.GetFileSize(aurl: String): Integer;
begin
  var http := TNetHTTPClient.Create(nil); //�������ҳ�ʼ��һ��TNetHTTPClient��
  result := 0; //�趨��ʼ����ֵΪ0
  try
    with http do begin
      AcceptCharSet := 'utf-8'; //���ô������Ϊutf-8
      AcceptEncoding := '65001'; //���ô���������Ϊ65501
      AcceptLanguage := 'en-US'; //���ô�������ΪӢ���ȻҲ����Ϊ����zh-CN�����ǲ����顣��
      ResponseTimeout := 200000; //���ô��䳬ʱΪ3��20�롣��ʵ����20����롣
      ConnectionTimeout := 200000; //�������ӳ�ʱΪ3��20��
      SendTimeout := 200000; //���÷��ͳ�ʱΪ3��20�롾������ʵ����Ҫ���ã���Ϊ����ֻ�ǻ�ȡ��С��������ʹ��Put���䡣Post��Get������Ҫ��������������ѡŶ����
      SecureProtocols := [THTTPSecureProtocol.SSL3, THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13]; //���ô���Э�飬����д�ܶ������������д�꣡
      HandleRedirects := True;  //������ַ�ض���
    end;
    try
      form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.judge_can_multi_thread_download'));
      var st := http.Head(aURL);
      if st.ContentLength < BiggestThread then begin
        form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.url_donot_support_download_in_launcher'));
        result := -3;
        exit;
      end;
      if st.StatusCode <> 206 then begin
        form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.url_statucode_is_not_206_and_try_to_cut'));
        var ss := GetHTTPRange(aURL, 1, 10, true);
        if ss.Size > 10 then begin
          ss.SaveToFile(savepath);
          form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.not_allow_cut_use_single_thread_download'));
          result := -3;
          exit;
        end else if ss.Size < 10 then begin  //������ΪʲôCurseForge�����������ͷ�а�����ȡ��Χ�ģ���ֱ�ӷ���0������
          ss := dm.GetHTTPNormal(aurl);
          if ss <> nil then begin
            ss.SaveToFile(savepath);
            form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.not_allow_cut_use_single_thread_download'));
            result := -3;
            exit;
          end else begin
            raise Exception.Create('Download Error...');
          end;
        end;
      end;
      result := st.ContentLength;
    except
      form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.input_url_error_and_this_url_doesnot_has_file'));
      form_progress.button_progress_clean_download_list.Enabled := true;
      result := -3;
      abort;
    end;
  finally
    http.Free;
  end;
end;
//�����Զ����ļ�
procedure DownloadCustomFile;
var
  DownloadTask: array of ITask;
begin
  var time := GetTickCount;
  SetLength(DownloadTask, BiggestThread);
  if BiggestThread = 1 then begin
    form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.thread_one_to_single_thread_download'));
    var ss := dm.GetHTTPNormal(url);
    if ss = nil then begin
      form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.single_thread_download_error'));
      abort;
    end;
    ss.SaveToFile(savepath);
    exit;
  end;
  var filesize := dm.GetFileSize(url);
  if filesize = -3 then begin
    exit;
  end;
  if isShowList then form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.url_allow_multi_thread_download'));
  if isShowList then form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.url_file_size').Replace('${url_file_size}', inttostr(filesize)));
  form_progress.progressbar_progress_download_bar.Max := BiggestThread;
  form_progress.progressbar_progress_download_bar.Position := 0;
  form_progress.label_progress_download_progress.Caption := GetLanguageText('label_progress_download_progress.caption').Replace('${download_progress}', '0').Replace('${download_current_count}', '0').Replace('${download_all_count}', '0');
  var fileavg := trunc(filesize / BiggestThread); //��¼�����ļ���������̺߳��ƽ��ֵ��
  var sc := 0;
  var sf := 0;
  var cc := 0;
  if not DirectoryExists(Concat(TempPath, 'LLLauncher\downloadtmp')) then
    ForceDirectories(Concat(TempPath, 'LLLauncher\downloadtmp'));
  var DownloadProc := procedure(dt, tstart, tend: Integer)
  label
    Retry;
  begin
    var TempSavePath := Concat(TempPath, 'LLLauncher\downloadtmp', ChangeFileExt(ExtractFileName(savepath), ''), '-', inttostr(dt), '.tmp');
    Retry: ;
    var stt: TStringStream := dm.GetHttpRange(url, tstart, tend, false); //Get�ض�λ�õ�����
    if stt = nil then begin
      if IsShowList then form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.single_thread_download_error').Replace('${cut_download_count}', inttostr(dt)));
      inc(cc);
      if cc <= 3 then begin //���Բ���
        form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.cut_download_retry').Replace('${cut_download_retry}', inttostr(cc)));
        goto Retry;
      end;
      for var c := 1 to BiggestThread do deleteFile(pchar(Concat(TempPath, 'LLLauncher\downloadtmp', ChangeFileExt(ExtractFileName(savepath), ''), '-', inttostr(c), '.tmp'))); //ɾ������tmp�ļ�
      form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.retry_threetime_error'));
      form_progress.button_progress_clean_download_list.Enabled := true;
      abort;
    end else begin
      stt.SaveToFile(TempSavePath);
      if IsShowList then form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add(GetLanguageText('downloadlist.custom.single_thread_download_success').Replace('${cut_download_count}', inttostr(dt)));
    end;
    inc(sf);
    if isShowProgress then form_progress.progressbar_progress_download_bar.Position := sf;
    var jd: Currency := 100 * sf / BiggestThread;
    if isShowProgress then form_progress.label_progress_download_progress.Caption := GetLanguageText('label_progress_download_progress.caption').Replace('${download_progress}', floattostr(SimpleRoundTo(jd))).Replace('${download_current_count}', inttostr(sf)).Replace('${download_all_count}', inttostr(BiggestThread));
  end;
  var downp: TProc := procedure
  begin
    inc(sc);
    var tstart := fileavg * (sc - 1);
    var tend := fileavg * sc - 1;
    if sc = BiggestThread then tend := filesize;
    DownloadProc(sc, tstart, tend);
  end;
  for var I := 0 to BiggestThread - 1 do begin //ѭ�����ɡ�����߳�������������
    DownloadTask[I] := TTask.Run(downp);
  end;
  TTask.WaitForAll(DownloadTask);
  var mStream1 := TMemoryStream.Create;
  var mStream2 := TMemoryStream.Create;
  try
    for var I := 1 to BiggestThread do begin
      var tmpfile := Concat(TempPath, 'LLLauncher\downloadtmp', ChangeFileExt(ExtractFileName(savepath), ''), '-', inttostr(i), '.tmp');
      if not FileExists(tmpfile) then begin
        form_progress.listbox_progress_download_list.ItemIndex := form_progress.listbox_progress_download_list.Items.Add('�Ѽ����ļ����ز�������������ʧ�ܣ�');
        mStream1.Free;
        mStream2.Free;
        abort; //�˳�����
      end;
      mStream2.LoadFromFile(tmpfile);
      mStream1.Seek(mStream1.Size, soFromBeginning);
      mStream1.CopyFrom(mStream2, mStream2.Size);
      mStream2.Clear;
    end;
    mStream1.SaveToFile(savepath);
  finally
    mStream1.Free; //�ͷ���Դ
    mStream2.Free;
  end;
end;
//����Minecraft
procedure DownloadMinecraft;
begin
  var time := GetTickCount;
  var SourceJSON := TJSONObject.ParseJSONValue(url) as TJsonObject;

end;
//����Java
procedure DownloadJava;
begin
  // TODO
end;
//����Forge
procedure DownloadForge;
begin
  // TODO
end;
//���ú���
//��һ��url���������ӣ����LoadSource��1��2��3�Ļ�������ҪΪ��Ӧ��json��
//�ڶ���SavePath�Ǳ���·����
//������RootPath�Ǹ�·����ֻ��LoadSourceΪ1��3��ʱ������Ҫָ����Ӧ��.minecraft�ļ��У�savepathΪversions�ļ��С�
//���ĸ�BiggestThread������̡߳�
//�����SelectMode������Դ��ֻ��1��2��3�����Ϊ1�����ǹٷ�����Դ��2Ϊbmclapi��3ΪMCBBS������ǹ�����Ĭ��ȫ������1���޷�ʹ��2��3
//������LoadSource�Ǽ���˳��1Ϊ�����Զ����ļ���2Ϊ����Minecraft��3Ϊ����Java��4Ϊ����Forge��
//���߸�isShowListΪ�Ƿ�չʾ�����б��
//�ڰ˸�isShowProgressΪ�Ƿ�չʾ���ؽ��ȿ�
procedure DownloadStart(url, SavePath, RootPath: String; BiggestThread, SelectMode, LoadSource: Integer; isShowList: Boolean = true; isShowProgress: Boolean = true);
var
  TempTemp: array [0..255] of char;
begin
  form_progress.button_progress_clean_download_list.Enabled := false;
  DownloadMethod.url := url;
  DownloadMethod.SavePath := SavePath;
  DownloadMethod.BiggestThread := BiggestThread;
  DownloadMethod.SelectMode := SelectMode;
  DownloadMethod.isShowList := isShowList;
  DownloadMethod.isShowProgress := isShowProgress;
  DownloadMethod.RootPath := RootPath;
  case LoadSource of
    0: DownloadCustomFile;
    1: DownloadMinecraft;
    2: DownloadJava;
    3: DownloadForge;
  end;
  form_progress.button_progress_clean_download_list.Enabled := true;
  GetTempPath(255, @TempTemp);
  TempPath := strpas(TempTemp);
end;

end.
