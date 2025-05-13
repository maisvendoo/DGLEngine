{********************************************************}
{                                                        }
{             Модуль: IniFile.pas                        }
{      Copyright (c) 2003 Vasily V. Altunin              }
{                                                        }
{  Описание      : Содержит описания и реализации        }
{                  базового класса для работы            }
{                  для работы с INI-файлами              }
{  Разработчик   : Алтунин Василий                       }
{                  (skyr@users.sourceforge.net)          }
{  Модифицирован : 11.12.2003                            }
{  Версия        : 0.02                                  }
{  Сайт проекта  : http://sky3d.sourceforge.net          }
{  Вы можете изменять и использовать код приведенный     }
{  ниже ТОЛЬКО при условии СОХРАНЕНИЯ этого блока.       }
{  Лицензионное соглашение вы можете найти в файлах      }
{  'License' и 'License_rus'.                            }
{                                                        }
{********************************************************}

unit IniFile;

interface

type

  TIniString = Array of string; //Динамический массив для храненияя строк


TIniKeyValue=class // Класс для хранения значения key=value
  Key:String; // Ключ
  Value:String; // Значение

  constructor Create(DataString:String); // Конструктор класса

end;


// Класс для хранения информации о секции Ini файла
TIniSection=class
  SectionName : string; //Название секции Внимание! Значение - слово без '[' и ']'
  Items       : array of TIniKeyValue; //Массив ключей и значений
  ItemNo      : Integer; //Количество значений в секции

  constructor Create(SectioName:String);//Конструктор класса

end;


{
  TiniFile

  Базовый класс в который загружается вся информации о Ini файле
  Внимание! В класс не загружаются комментарии, т.е. строки начинающиеся
  с символов '#' и ';'
  Данная версия модуля не может работать с комментриями в строках
  названий секции и ключ=значения
  Например " x=15 ;Такой комментрий неопустим! "
  Данная возможность будет реализованна в будующих версиях модуля
}

TiniFile=class

  BadIniFile   : Boolean; // Флаг указывающий является ли файл ini-файлом
  IniStrNum    : Integer; // Количество строк Ini-файла
  IniFileName  : String; // Имя ini-файла
  SectionNum   : Integer; // Количество секций в Ini-файле
  IniSections  : Array of TIniSection; // Содержимое секций Ini-файла

  constructor Create(FileName : String);

  // Сохраняет содержимое класса как Ini-файл
  procedure SaveToFile;
  // Определяет, является ли файл - Ini-файлом
  function IsIniFile : boolean;
  // Проверяет, сущетвует ли секция Ini-файла
  function IsIniSection(SectionName : String) : boolean;
  // Проверяет, сущетвует ли ключ секции Ini-файла
  function IsIniSectionKey(SectionName, KeyName : String) : boolean;
  // Возвращает значение ключа в секции Ini-файла
  function GetIniSectionKeyValue(SectionName, KeyName : String) : string;
  // Устанавливает/создает значение ключа в секции Ini-файла
  function SetIniSectionKeyValue(SectionName, KeyName, Value : String) : string;
  // Создает секцию Ini-файла
  function CreateIniSection(SectionName : String) : boolean;
  // Возвращает количество строк Ini-файла
  function GetIniStrNum() : Integer;
  // Считывает содержимое Ini-файла в класс
  procedure ReadIniToArray();
end;

implementation

uses SysUtils;

//====================================================================

{
  Конструктор класса TIniKeyValue
  В качестве значения получает строку 'ключ=значение'
  Производит парсинг в результате которого помещает
  'ключ' и 'значение' в свойства класса key и value
}
constructor TIniKeyValue.Create(DataString:String);
var
  I    : Integer;
  ISep : Boolean; // Флаг показывающий был ли встречен знак =
begin
  key:='';
  value:='';
  ISep:=False;
  for i:=1 to length(DataString) do
  begin
  if (Copy(dataString,i,1)='=') then
    ISep:=True;
  if (not ISep) then
    key:=key+Copy(dataString,i,1)
  else
    if (Copy(dataString,I,1)<>'=') then
      { Если разделитель десятичный,
        то ставим правильный десятичный разделитель }
      if ( (Copy(dataString,I,1)='.') or (Copy(dataString,I,1)='.') ) then
        value:=value+DecimalSeparator
      else
        value:=value+Copy(dataString,I,1);
  end;
end;

//====================================================================

{
  Конструктор класса TIniSection
  В качестве значения получает строку с названием секции
  и устанавливает свойство класса SectionName
}
constructor TIniSection.Create(SectioName:String);
begin
  SectionName:=SectioName;
end;

//====================================================================

{
  Конструктор класса TIniFile
  В качестве значения получает строку с именем Ini-файла
}
constructor TIniFile.Create(FileName:String);
begin

IniFileName:=FileName;

BadIniFile:=False; // По-умолчанию файл "правильный"

// Подсчитываем количество строк в файле, если он не существует, то
// создаем пустой
IniStrNum:=GetIniStrNum();

if (not IsIniFile()) then // Если формат файла не подходит выставляем флаг
   BadIniFile:=True;

// если строк больше чем 0, они НЕ пустые и НЕ из пробелов, считываем их в класс
If (IniStrNum>0) then
   ReadIniToArray();

end;

//====================================================================

{
  IsIniFile
  Определяет является подходит ли файл по формат Ini-файла
}
function TIniFile.IsIniFile:boolean;
var
  F    : TextFile;
  Buf  : String; // Буфер для чтения из файла
begin
    AssignFile(F,IniFileName);
    Reset(F);
    while (not eof(F)) do
    begin
      ReadLn(F,Buf);
      // Если первая строка начинается с '[' или пустая
      // то файл подходит
      if ( (Copy(Buf,1,1)='[') or (Trim(Buf)='') ) then
      begin
        result:=True;
        CloseFile(F);
        exit;
      end;
      // Если строка начинается не с '#' или ';' то файл не подходит
      if ( (Copy(Buf,1,1)<>'#') and (Copy(Buf,1,1)<>';') ) then
      begin
        result:=False;
        CloseFile(F);
        exit;
      end;
    end;
    CloseFile(F);
    result:=True; // файл нам подходит
end;

//====================================================================

{
  SaveToFile
  Сохраняет класс как Ini-файл
}
procedure TIniFile.SaveToFile;
var
F   : TextFile;
I,J : Integer;
begin
    AssignFile(F,IniFileName);
    Rewrite(F);
    if (IniStrNum>0) then
      for I:=0 to SectionNum-1 do
      begin
        WriteLn(F,'['+IniSections[I].SectionName+']'); // пишем секцию
        for J:=0 to IniSections[I].ItemNo-1 do // А потом все ключи и значения
          WriteLn(F,IniSections[I].Items[J].Key+
                    '='+IniSections[I].Items[J].Value);
      end;
      CloseFile(F);
end;

//====================================================================

{
  IsIniSection
  Проверяет, сущетвует ли секция Ini-файла
}
function TiniFile.IsIniSection(SectionName : String) : boolean;
var
  I : Integer;
begin
  if (IniStrNum>0) then // Если есть в файле строки
  begin
    if (SectionNum=0) then
    begin
      result:=False;
      exit;
    end;
    for I:=0 to SectionNum-1 do // Проверяем название каждой секции
      if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
        begin
          result:=True;
          exit;
        end;
  end;
  result:=False;
end;

//====================================================================

{
  IsIniSectionKey
  Проверяет, сущетвует ли ключ секции Ini-файла
}

function TiniFile.IsIniSectionKey(SectionName, KeyName : String) : boolean;
var
I,J : Integer; 
begin
  if (IsIniSection(SectionName)) then
    if (IniStrNum>0) then
      for I:=0 to SectionNum-1 do
        if (IniSections[I].ItemNo>0) then
          for J:=0 to IniSections[I].ItemNo-1 do
            if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
              if (IniSections[I].Items[J].Key=KeyName) then
              begin
                result:=True;
                exit;
              end;
  result:=False;
end;

//====================================================================

{
  GetIniSectionKeyValue
  Возвращает значение ключа в секции Ini-файла
}

function TiniFile.GetIniSectionKeyValue(SectionName, KeyName : String) : string;
var
  I,J : Integer;
begin
  if IsIniSectionKey(SectionName, KeyName) then
  begin
    for I:=0 to SectionNum do
      for J:=0 to IniSections[I].ItemNo-1 do
      begin
        if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
          if (UpperCase(IniSections[I].Items[J].Key)=UpperCase(KeyName)) then
          begin
            result:=IniSections[I].Items[J].Value;
            exit;
          end;
      end;
  end
  else
    result:='-1'; //Иначе -1
end;

//====================================================================

{
  SetIniSectionKeyValue
  Устанавливает/создает значение ключа в секции Ini-файла
}

function TiniFile.SetIniSectionKeyValue(SectionName, KeyName, Value : String) : string;
var
  I,J : Integer;
begin
  if (IsIniSectionKey(SectionName, KeyName)) then
  begin
    for I:=0 to SectionNum do
      for J:=0 to IniSections[I].ItemNo-1 do
      begin
        if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
          if (UpperCase(IniSections[I].Items[J].Key)=UpperCase(KeyName)) then
          begin
            IniSections[I].Items[J].Value:=Value;
            result:=IniSections[I].Items[J].Value;
            exit;
          end;
      end;
  end
  else
  begin
    if (SectionNum=0) then
      CreateIniSection(SectionName)
    else
      if (not IsIniSection(SectionName)) then
        CreateIniSection(SectionName);
      for I:=0 to SectionNum-1 do
        if (UpperCase(IniSections[I].SectionName)=UpperCase(SectionName)) then
          begin
            if (Length(IniSections[I].Items)=0) then
              J:=0
            else
              J:=Length(IniSections[I].Items);
            SetLength(IniSections[I].Items,J+1);
            IniSections[I].Items[J]:=TIniKeyValue.Create(KeyName+'='+Value);
            IniSections[I].ItemNo:=IniSections[I].ItemNo+1;
          end;
  end;
end;

//====================================================================

{
  GetIniStrNum
  Возвращает количество строк Ini-файла
}

function TiniFile.GetIniStrNum() : Integer;
var
  strnum    : Integer;
  F         : TextFile;
  Buf       : string;
begin
    if FileExists(IniFileName) then
    begin
      AssignFile(F,IniFileName);
      reset(F);
      strnum:=0;
      while not eof(F) do
      begin
        readln(F,Buf);
        if (Trim(Buf)<>'') then
          Inc(strnum);
      end;
      closefile(F);
      result := strnum;
    end
    else
    begin
      AssignFile(F,IniFileName);
      rewrite(F);
      Closefile(F);
      result:=0;
    end;
end;


//====================================================================

{
  ReadIniToArray
  Считывает содержимое Ini-файла
}

procedure TiniFile.ReadIniToArray();
var
  F   : TextFile;
  Buf : String;
  K : Integer;
begin
    AssignFile(F,IniFileName);
    Reset(F);
    SectionNum:=0;
    K:=0;
    while (not eof(F)) do
    begin
      ReadLn(F,Buf);
      if (Trim(Buf)<>'') then
        if ((Copy(Buf,1,1)<>';') and (Copy(Buf,1,1)<>'#')) then
        begin
          if ( (Copy(Buf,1,1)='[') and (Copy(Buf,length(Buf),1)=']')) then//Создаем секцию
          begin
            SectionNum:=SectionNum+1;
            SetLength(IniSections, Length(IniSections)+1);
            IniSections[SectionNum-1]:=TIniSection.Create(Copy(Buf,2,length(Buf)-2));
            IniStrNum:=IniStrNum+1;
            K:=0;
          end
          else
          begin
            SetLength(IniSections[SectionNum-1].Items,Length(IniSections[SectionNum-1].Items)+1);
            IniSections[SectionNum-1].Items[K]:=TIniKeyValue.Create(Buf);
            IniSections[SectionNum-1].ItemNo:=IniSections[SectionNum-1].ItemNo+1;
            IniStrNum:=IniStrNum+1;
            K:=K+1;
          end;
        end;
    end;
    closefile(F);
end;

//====================================================================

{
  CreateIniSection
  Создает секцию Ini-файла
}

function TiniFile.CreateIniSection(SectionName : String) : boolean;
begin
  if (not IsIniSection(SectionName)) then
  begin
    SetLength(IniSections, Length(IniSections)+1);
    IniSections[SectionNum]:=TIniSection.Create(SectionName);
    SectionNum:=SectionNum+1;
    IniStrNum:=IniStrNum+1;
    Result:=True;
    exit;
  end;
  Result:=False;
end;

//====================================================================

end.
