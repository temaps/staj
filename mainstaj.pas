{
Copyright 2015, 2016 Проскурнев Артем Сергеевич

Этот файл — часть программы Стаж.

Стаж - свободная программа: вы можете перераспространять ее и/или
изменять ее на условиях Стандартной общественной лицензии GNU в том виде,
в каком она была опубликована Фондом свободного программного обеспечения;
либо версии 3 лицензии, либо (по вашему выбору) любой более поздней
версии.

Стаж распространяется в надежде, что она будет полезной,
но БЕЗО ВСЯКИХ ГАРАНТИЙ; даже без неявной гарантии ТОВАРНОГО ВИДА
или ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННЫХ ЦЕЛЕЙ. Подробнее см. в Стандартной
общественной лицензии GNU.

Вы должны были получить копию Стандартной общественной лицензии GNU
вместе с этой программой. Если это не так, см.
<http://www.gnu.org/licenses/>.

This file is part of Staj.

Staj is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Staj is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Staj.  If not, see <http://www.gnu.org/licenses/>.
}
unit mainstaj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls,
  Graphics, Dialogs, EditBtn, Spin, StdCtrls, Buttons, MaskEdit, ExtCtrls;

type

  { TForm1 }
  adateedit = array[1..200] of TDateEdit;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ScrollBox1: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpinEdit1: TSpinEdit;
    Splitter1: TSplitter;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DateEdit1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1KeyPress(Sender: TObject; var Key: char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
  private
    { private declarations }
    tf: TFormatSettings;
  public
    DateEditOT: adateedit;
    DateEditDO: adateedit;
    CheckRas: array[1..200] of TCheckBox;
    CheckDop: array[1..200] of TCheckBox;
    nomer: array[1..200] of TLabel;
    srok: array[1..200] of TLabel;
    { public declarations }
  end;

var
  Form1: TForm1;
  kol: integer;

implementation

uses resource, versiontypes, versionresource;

{$R *.lfm}

function resourceVersionInfo: string;

  (* Unlike most of AboutText (below), this takes significant activity at run-    *)
  (* time to extract version/release/build numbers from resource information      *)
  (* appended to the binary.                                                      *)

var
  Stream: TResourceStream;
  vr: TVersionResource;
  fi: TVersionFixedInfo;

begin
  Result := '';
  try

    (* This raises an exception if version info has not been incorporated into the  *)
    (* binary (Lazarus Project -> Project Options -> Version Info -> Version        *)
    (* numbering).                                                                  *)

    Stream := TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
    try
      vr := TVersionResource.Create;
      try
        vr.SetCustomRawDataStream(Stream);
        fi := vr.FixedInfo;
        Result := IntToStr(fi.FileVersion[0]) + '.' + IntToStr(fi.FileVersion[1]) +
          '.' + IntToStr(fi.FileVersion[2]) + '.' + IntToStr(fi.FileVersion[3]);
        vr.SetCustomRawDataStream(nil)
      finally
        vr.Free
      end
    finally
      Stream.Free
    end
  except
  end;
end { resourceVersionInfo };

{ TForm1 }

procedure TForm1.DateEdit1KeyPress(Sender: TObject; var Key: char);
begin
  if (length((Sender as TDateEdit).Text) = 10) and
    ((Sender as TDateEdit).SelStart = 9) and (Key in ['0'..'9']) then
  begin
    Form1.SelectNext(ActiveControl, True, True);
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
type
  TElementDati = (god, mesats, den);
var
  i: integer;
  dm, d, m, g, ds, dp: integer;

  procedure DvGMD(dm: integer; var g, m, d: integer);
  begin
    g := dm div 360;
    m := (dm mod 360) div 30;
    d := dm mod 30;
  end;

  function FormaGDM(e: TElementDati; k: integer): string;
  const
    mform: array [god..den, 1..3] of
      string = (('год', 'года', 'лет'), ('месяц', 'месяца', 'месяцев'),
      ('день', 'дня', 'дней'));
  var
    fs: byte;//Форма слова
  begin
    if ((k mod 100) div 10) = 1 then
      fs := 3
    else
    begin
      case k mod 10 of
        1: fs := 1;
        2..4: fs := 2;
        else
          fs := 3;
      end;
    end;
    Result := mform[e, fs];
  end;

begin
  {
                           ПОСТАНОВЛЕНИЕ
                    от 2 октября 2014 г. N 1015
                              МОСКВА
          Об утверждении Правил подсчета и подтверждения
        страхового стажа для установления страховых пенсий
  VIII. Порядок подсчета страхового стажа

       47. Исчисление продолжительности периодов работы, в том  числе
  на основании свидетельских показаний, и (или) иной  деятельности  и
  иных  периодов  производится  в  календарном  порядке  из   расчета
  полного года (12 месяцев). При этом каждые 30 дней периодов  работы
  и (или) иной деятельности и иных периодов переводятся в  месяцы,  а
  каждые 12 месяцев этих периодов переводятся в полные годы.
  }
  ds := 0;
  dp := 0;
  for i := 1 to kol do
  begin
    {Подсчет   продолжительности   каждого   периода,   включаемого
    (засчитываемого) в страховой стаж, производится путем вычитания  из
    даты окончания соответствующего периода даты начала этого периода с
    прибавлением одного дня.}
    dm := round(DateEditDO[i].Date - DateEditOT[i].Date);
    if (DateEditDO[i].Date > 0) and (DateEditOT[i].Date > 0) then
      Inc(dm);
    if dm >= 0 then
    begin
      DvGMD(dm, g, m, d);
      srok[i].Caption := IntToStr(g) + ' ' + FormaGDM(god, g) + ' ' +
        IntToStr(m) + ' ' + FormaGDM(mesats, m) + ' ' + IntToStr(d) +
        ' ' + FormaGDM(den, d) + ' ';
      if CheckRas[i].Checked then
        Inc(ds, dm);
      if CheckDop[i].Checked then
        Inc(dp, dm);
    end;
  end;
  DvGMD(ds, g, m, d);
  Label1.Caption := IntToStr(g) + ' ' + FormaGDM(god, g) + ' ' +
    IntToStr(m) + ' ' + FormaGDM(mesats, m) + ' ' + IntToStr(d) +
    ' ' + FormaGDM(den, d) + ' ';
  DvGMD(dp, g, m, d);
  Label2.Caption := IntToStr(g) + ' ' + FormaGDM(god, g) + ' ' +
    IntToStr(m) + ' ' + FormaGDM(mesats, m) + ' ' + IntToStr(d) +
    ' ' + FormaGDM(den, d) + ' ';
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
begin
  Label1.Caption := 'Стаж';
  Label2.Caption := 'Дополнительно';
  for i := 1 to kol do
  begin
    DateEditOT[i].Text := '';
    DateEditDO[i].Text := '';
    CheckRas[i].Checked := True;
    CheckDop[i].Checked := False;
    srok[i].Caption := '';
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  searchResult: TSearchRec;
  s: string;
begin
  Form1.Caption := Form1.Caption + ' ' + resourceVersionInfo;
  tf.DateSeparator := '.';
  tf.ShortDateFormat := 'dd/mm/yyyy';
  if FindFirst('dat/*.dat', faAnyFile, searchResult) = 0 then
  begin
    repeat
      s := searchResult.Name;
      if FileExists('dat/' + s) then
      begin
        ListBox1.Items.add(UTF8Encode(copy(s, 1, length(s) - 4)));
      end;
    until FindNext(searchResult) <> 0;
    FindClose(searchResult);
  end;
  kol := 0;
  SpinEdit1.Value := 20;
  SpinEdit1Change(Sender);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  Edit1.Text := ListBox1.Items.Strings[ListBox1.ItemIndex];
end;

procedure TForm1.ListBox1KeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    SpeedButton2Click(Sender);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  i: integer;
begin
  if edit1.Text = '' then
  begin
    ShowMessage('Укажите имя!');
    exit;
  end;
  if MessageDlg('Подтверждение', 'Сохранить даты под именем "' +
    edit1.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Memo1.Clear;
    Memo1.Lines.Append(IntToStr(kol));
    for i := 1 to kol do
    begin
      memo1.Lines.Append(DateEditOT[i].Text);
      memo1.Lines.Append(DateEditDO[i].Text);
      memo1.Lines.Append(BoolToStr(CheckRas[i].Checked));
      memo1.Lines.Append(BoolToStr(CheckDop[i].Checked));
    end;
    Memo1.Lines.SaveToFile(UTF8ToSys('dat/' + edit1.Text + '.dat'));
    if (ListBox1.Count = 0) or (ListBox1.ItemIndex < 0) or
      (Edit1.Text <> ListBox1.Items.Strings[ListBox1.ItemIndex]) then
      ListBox1.Items.Append(Edit1.Text);
  end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  i: integer;
begin
  if edit1.Text = '' then
  begin
    ShowMessage('Укажите что загружать!');
    exit;
  end;
  {if MessageDlg('Подтверждение', 'Открыть даты под именем "' + edit1.Text +
    '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then}
  begin
    Button2Click(Sender);
    Memo1.Clear;
    Memo1.Lines.LoadFromFile(UTF8Decode('dat/' + edit1.Text + '.dat'));
    SpinEdit1.Value := StrToInt(Memo1.Lines.Strings[0]);
    SpinEdit1Change(Sender);
    for i := 1 to kol do
    begin
      DateEditOT[i].Text := memo1.Lines.Strings[i * 4 - 3];
      DateEditDO[i].Text := memo1.Lines.Strings[i * 4 - 2];
      CheckRas[i].Checked := StrToBool(memo1.Lines.Strings[i * 4 - 1]);
      CheckDop[i].Checked := StrToBool(memo1.Lines.Strings[i * 4]);
    end;
  end;
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
var
  i, v: integer;
begin
  if SpinEdit1.Value < 1 then
    SpinEdit1.Value := 1;
  if SpinEdit1.Value > 100 then
    SpinEdit1.Value := 100;
  if SpinEdit1.Value > kol then
  begin
    for i := kol + 1 to SpinEdit1.Value do
    begin
      v := 8 + (8 + DateEdit1.Height) * (i - 1);
      try
        nomer[i] := TLabel.Create(ScrollBox1);
        nomer[i].Parent := ScrollBox1;
        nomer[i].Left := 2;
        nomer[i].Top := v + 4;
        nomer[i].Caption := IntToStr(i) + '.';
      except
        nomer[i].Free;
      end;
      try
        DateEditOT[i] := TDateEdit.Create(ScrollBox1);
        DateEditOT[i].Parent := ScrollBox1;
        DateEditOT[i].Width := 110;
        DateEditOT[i].Left := 8 + 12;
        DateEditOT[i].Top := v;
        DateEditOT[i].TabOrder := (i - 1) * 2;
        DateEditOT[i].DateOrder := doDMY;
        DateEditOT[i].OnKeyPress := @DateEdit1KeyPress;
        DateEditOT[i].ButtonOnlyWhenFocused := True;
      except
        DateEditOT[i].Free;
      end;
      try
        DateEditDO[i] := TDateEdit.Create(ScrollBox1);
        DateEditDO[i].Parent := ScrollBox1;
        DateEditDO[i].Width := 110;
        DateEditDO[i].Left := 120 + 12;
        DateEditDO[i].Top := v;
        DateEditDO[i].TabOrder := (i - 1) * 2 + 1;
        DateEditDO[i].DateOrder := doDMY;
        DateEditDO[i].OnKeyPress := @DateEdit1KeyPress;
        DateEditDO[i].ButtonOnlyWhenFocused := True;
      except
        DateEditDO[i].Free;
      end;
      try
        CheckRas[i] := TCheckBox.Create(ScrollBox1);
        CheckRas[i].Parent := ScrollBox1;
        CheckRas[i].Left := 230 + 15;
        CheckRas[i].Top := v;
        CheckRas[i].Caption := '';
        CheckRas[i].TabStop := False;
        CheckRas[i].Checked := True;
      except
        CheckRas[i].Free;
      end;
      try
        CheckDop[i] := TCheckBox.Create(ScrollBox1);
        CheckDop[i].Parent := ScrollBox1;
        CheckDop[i].Left := 250 + 15;
        CheckDop[i].Top := v;
        CheckDop[i].Caption := '';
        CheckDop[i].TabStop := False;
      except
        CheckDop[i].Free;
      end;
      try
        srok[i] := TLabel.Create(ScrollBox1);
        srok[i].Parent := ScrollBox1;
        srok[i].Left := 280 + 15;
        srok[i].Top := v + 4;
        srok[i].Caption := '';
      except
        srok[i].Free;
      end;
    end;
  end;
  if SpinEdit1.Value < kol then
  begin
    for i := kol downto SpinEdit1.Value + 1 do
    begin
      nomer[i].Free;
      DateEditOT[i].Free;
      DateEditDO[i].Free;
      CheckRas[i].Free;
      CheckDop[i].Free;
      srok[i].Free;
    end;
  end;
  kol := SpinEdit1.Value;
end;

end.
