unit LaunchMethod;

interface

uses
  SysUtils, Classes, Windows, IOUtils, StrUtils, JSON;

function GetMCRealPath(path, suffix: string): String;
function GetMCInheritsFrom(selpath, inheritsorjar: String): String;

implementation

uses
  MainMethod;
// ��ȡMC����ʵ�ļ�·����
function GetMCRealPath(path, suffix: string): String;
var
  Files: TArray<String>;
begin
  result := '';
  if DirectoryExists(path) then begin // �ж��ļ����Ƿ����
    Files := TDirectory.GetFiles(path); // �ҵ������ļ�
    for var I in Files do begin // �����ļ�
      if I.IndexOf(suffix) <> -1 then begin // �Ƿ��������
        if suffix = '.json' then begin
          var god := GetFile(I);
          try
            var Root := TJsonObject.ParseJSONValue(god) as TJsonObject;
            var tmp := Root.GetValue('libraries').ToString;
            var ttt := Root.GetValue('mainClass').Value;
            result := I;
            exit;
          except
            continue;
          end;
        end else begin
          result := I;
          exit;
        end;
      end;
    end;
  end;
end;
//��ȡMC��InheritsFrom��jar��������Ӧ��MC�ļ��С������MC������InheritsFrom��jar�����򷵻�ԭ������ֵ������Ҳ���Json�ļ����򷵻ؿա�����ҵ���InheritsFrom������ȴ�Ҳ���ԭ�����ļ��У���Ҳͬ�����ؿա���һ�ж������ʱ���򷵻��ҵ����Json�ļ���ַ����
function GetMCInheritsFrom(selpath, inheritsorjar: String): String;
var
  Dirs: TArray<String>;
  Files: TArray<String>;
begin
  result := '';
  if DirectoryExists(selpath) then begin
    var ph := GetMCRealPath(selpath, '.json');
    if FileExists(ph) then begin
      var Rt := TJsonObject.ParseJSONValue(GetFile(ph)) as TJsonObject;
      try
        var ihtf := Rt.GetValue(inheritsorjar).Value;
        if ihtf = '' then raise Exception.Create('Judge Json Error');
        var vdir := ExtractFileDir(selpath);
        Dirs := TDirectory.GetDirectories(vdir);
        for var I in Dirs do begin
          Files := TDirectory.GetFiles(I);
          for var J in Files do begin
            if RightStr(J, 5) = '.json' then begin
              try
                var Rt2 := TJsonObject.ParseJSONValue(GetFile(J)) as TJsonObject;
                var jid := Rt2.GetValue('id').Value;
                var tmp := Rt2.GetValue('libraries').ToString;
                var ttt := Rt2.GetValue('mainClass').Value;
                if jid = ihtf then begin
                  result := I;
                  exit;
                end;
                continue;
              except
                continue;
              end;
            end;
          end;
        end;
      except
        result := selpath;
        if inheritsorjar = 'jar' then result := '';
      end;
    end;
  end;
end;
end.

