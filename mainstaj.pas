{"Стаж" - программа для рассчёта стажа по трудовой книжке

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
along with Staj.  If not, see <http://www.gnu.org/licenses/>.}
unit mainstaj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, PrintersDlgs, LR_Class, LR_DSet,
  LR_Desgn, Forms, Controls, Graphics, Dialogs, EditBtn, Spin, StdCtrls,
  Buttons, ExtCtrls, Printers, Grids, ComCtrls, LCLProc;

type

  { TForm1 }
  adateedit = array[1..200] of TDateEdit;

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    DateEdit1: TDateEdit;
    Edit1: TEdit;
    frDesigner1: TfrDesigner;
    frReport1: TfrReport;
    frUserDataset1: TfrUserDataset;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PrintDialog1: TPrintDialog;
    ProgressBar1: TProgressBar;
    ScrollBox1: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpinEdit1: TSpinEdit;
    Splitter1: TSplitter;
    StringGrid1: TStringGrid;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DateEdit1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure frReport1GetValue(const ParName: string; var ParValue: variant);
    procedure frUserDataset1CheckEOF(Sender: TObject; var EOF: boolean);
    procedure frUserDataset1First(Sender: TObject);
    procedure frUserDataset1Next(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1KeyPress(Sender: TObject; var Key: char);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
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

uses resource, versiontypes, versionresource, stajabout, stajnastrprint;

function Translate(Name, Value: ansistring; Hash: longint; arg: pointer): ansistring;
begin
  case StringCase(Value, ['&Yes', '&No', 'Cancel']) of
    0: Result := '&Да';
    1: Result := '&Нет';
    2: Result := 'Отмена';
    else
      Result := Value;
  end;
end;

{$R *.lfm}

function resourceVersionInfo: string;
var
  Stream: TResourceStream;
  vr: TVersionResource;
  fi: TVersionFixedInfo;
begin
  Result := '';
  try
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
end;

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

  TPromejutok = record
    d, m, g: word;
  end;

var
  i: integer;
  p1, p2, p: TPromejutok;

  procedure DativPromejutok(dot, ddo: TDate; var p: TPromejutok);
  var
    ptemp: TPromejutok;
  begin
    DecodeDate(dot, ptemp.g, ptemp.m, ptemp.d);
    DecodeDate(ddo, p.g, p.m, p.d);
    if p.d - ptemp.d + 1 < 0 then
    begin
      Inc(p.d, 30);
      Dec(p.m);
    end;
    Inc(p.d);
    Dec(p.d, ptemp.d);
    if (p.m - ptemp.m) < 0 then
    begin
      Inc(p.m, 12);
      Dec(p.g);
    end;
    Dec(p.m, ptemp.m);
    Dec(p.g, ptemp.g);
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

  procedure resultat(p: TPromejutok; var nadpis: TLabel);
  begin
    if (p.d = 0) and (p.m = 0) and (p.g = 0) then
      nadpis.Caption := ''
    else
    begin
      p.m := p.m + (p.d div 30);
      p.g := p.g + (p.m div 12);
      p.m := (p.m mod 12);
      p.d := p.d mod 30;
      nadpis.Caption := IntToStr(p.g) + ' ' + FormaGDM(god, p.g) +
        ' ' + IntToStr(p.m) + ' ' + FormaGDM(mesats, p.m) + ' ' +
        IntToStr(p.d) + ' ' + FormaGDM(den, p.d);
    end;
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

  Подсчет   продолжительности   каждого   периода,   включаемого
  (засчитываемого) в страховой стаж, производится путем вычитания  из
  даты окончания соответствующего периода даты начала этого периода с
  прибавлением одного дня.
  }

  {
  Приказ Минздравсоцразвития РФ от 06.02.2007 N 91 (ред. от 11.09.2009)
  "Об утверждении Правил подсчета и подтверждения страхового стажа для
  определения размеров пособий по временной нетрудоспособности, по
  беременности и родам" (Зарегистрировано в Минюсте РФ 14.03.2007 N 9103)

  III. Порядок подсчета страхового стажа

  21. Исчисление периодов работы (службы, деятельности) производится в
  календарном порядке из расчета полных месяцев (30 дней) и полного года
  (12 месяцев). При этом каждые 30 дней указанных периодов переводятся в
  полные месяцы, а каждые 12 месяцев этих периодов переводятся в полные годы.

  ПИСЬМО
  от 30.10.12 N 15-03-09/12-3065П

  Департамент страхования на случай временной нетрудоспособности и в связи
  с материнством Фонда социального страхования Российской Федерации рассмотрел
  обращении от 11.09.2012 N 28, поступившее из Министерства труда и социальной
  защиты Российской Федерации, по вопросу исчисления страхового стажа для
  определения размера пособий по временной нетрудоспособности, и сообщает.

  Согласно пункту 21 Правил подсчета и подтверждения страхового стажа для
  определения размеров пособий по временной нетрудоспособности, по беременности
  и родам, утвержденных приказом Минздравсоцразвития России от 06.02.2007 N 91,
  исчисление периодов работы (службы, деятельности) производится в календарном
  порядке из расчета полных месяцев (30 дней) и полного года (12 месяцев).
  При этом каждые 30 дней указанных периодов переводятся в полные месяцы, а
  каждые 12 месяцев этих периодов переводятся в полные годы.

  При расчете страхового стажа перевод каждых 30 дней указанных периодов в
  полные месяцы, а каждых 12 месяцев этих периодов в полные годы
  предусматривается только для неполных календарных месяцев и неполных
  календарных лет.

  В случае, если календарный месяц или календарный год отработан работником
  полностью, то делить количество отработанных дней на 30 дней и соответственно
  12 месяцев не нужно.

  Ещё:
  http://www.consultant.ru/document/cons_doc_LAW_66787/
  http://www.consultant.ru/law/ref/poleznye-sovety/bolnichyi-list/stag-dlya-rascheta/
  }
  p.d := 0;
  p.m := 0;
  p.g := 0;
  p1.d := 0;
  p1.m := 0;
  p1.g := 0;
  p2.d := 0;
  p2.m := 0;
  p2.g := 0;
  for i := 1 to kol do
  begin
    if (length(trim(DateEditDO[i].Text)) > 4) and
      (length(trim(DateEditOT[i].Text)) > 4) then
    begin
      if round(DateEditDO[i].Date - DateEditOT[i].Date) >= 0 then
      begin
        DativPromejutok(DateEditOT[i].Date, DateEditDO[i].Date, p);
        resultat(p, srok[i]);
        if CheckRas[i].Checked then
        begin
          Inc(p1.d, p.d);
          Inc(p1.m, p.m);
          Inc(p1.g, p.g);
        end;
        if CheckDop[i].Checked then
        begin
          Inc(p2.d, p.d);
          Inc(p2.m, p.m);
          Inc(p2.g, p.g);
        end;
      end;
    end;
  end;
  resultat(p1, Label1);
  resultat(p2, Label2);
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var
  i, sindex, j: integer;
begin
  if ListBox1.Count > 0 then
  begin
    Form3.ShowModal;
    sindex := ListBox1.ItemIndex;
    StringGrid1.RowCount := ListBox1.Items.Count + 1;
    ProgressBar1.Min := 0;
    ProgressBar1.Max := ListBox1.Items.Count - 1;
    ProgressBar1.Visible := True;
    for i := 0 to ListBox1.Items.Count - 1 do
    begin
      ProgressBar1.Position := i;
      if i mod 10 = 0 then
        ProgressBar1.Update;
      Edit1.Text := ListBox1.Items[i];
      SpeedButton2Click(Sender);
      if Form3.CheckBox1.Checked then
      begin
        //Form3.CheckBox1.Checked:=false;
        for j := kol downto 1 do
        begin
          if (Length(Trim(DateEditDO[j].Text)) > 4) or (j = 1) then
          begin
            DateEditDO[j].Text := Form3.DateEdit1.Text;
            break;
          end;
        end;
        Button1Click(Sender);
      end;
      StringGrid1.Cells[0, i] := Edit1.Text;
      StringGrid1.Cells[1, i] := Label1.Caption;
      StringGrid1.Cells[2, i] := Label2.Caption;
    end;
    ProgressBar1.Visible := False;
    frReport1.ShowReport;
    if sindex >= 0 then
    begin
      ListBox1.ItemIndex := sindex;
      Edit1.Text := ListBox1.Items[sindex];
      SpeedButton2Click(Sender);
      //Button1Click(Sender);
    end;
  end;

  {if PrintDialog1.Execute then
  begin
    try
      Printer.BeginDoc;
      Printer.Canvas.Font.Size := 10;
      Printer.Canvas.Font.Color := clBlack;
      v := Round(1.2 * Abs(Printer.Canvas.TextHeight('I')));
      for i := 0 to ListBox1.Items.Count - 1 do
      begin
        Edit1.Text := ListBox1.Items[i];
        SpeedButton2Click(Sender);
        Button1Click(Sender);
        Printer.Canvas.TextOut(10, (i + 1) * v, Edit1.Text + ' общий стаж: ' +
          Label1.Caption + '; выделенный стаж: ' + Label2.Caption);
      end;
    finally
      Printer.EndDoc;
    end;
  end;}
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
  frReport1.LoadFromFile(UTF8ToSys('отчёт.lrf'));
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

procedure TForm1.frReport1GetValue(const ParName: string; var ParValue: variant);
begin
  if ParName = 'ФИО' then
    ParValue := StringGrid1.Cells[0, StringGrid1.Row]
  else if ParName = 'Стаж' then
    ParValue := StringGrid1.Cells[1, StringGrid1.Row]
  else if ParName = 'Выделенный стаж' then
    ParValue := StringGrid1.Cells[2, StringGrid1.Row];
end;

procedure TForm1.frUserDataset1CheckEOF(Sender: TObject; var EOF: boolean);
begin
  EOF := StringGrid1.Row >= (StringGrid1.RowCount - 1);
end;

procedure TForm1.frUserDataset1First(Sender: TObject);
begin
  StringGrid1.Row := 0;
end;

procedure TForm1.frUserDataset1Next(Sender: TObject);
begin
  StringGrid1.Row := StringGrid1.Row + 1;
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
    Label4.Caption := Edit1.Text;
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
  if Edit1.Text = '' then
  begin
    ShowMessage('Укажите что загружать!');
    exit;
  end;
  {if MessageDlg('Подтверждение', 'Открыть даты под именем "' + edit1.Text +
    '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then}
  begin
    Button2Click(Sender);
    Label4.Caption := Edit1.Text;
    Memo1.Clear;
    try
      Memo1.Lines.LoadFromFile(UTF8ToSys('dat/' + Edit1.Text + '.dat'));
      SpinEdit1.Value := StrToInt(Memo1.Lines.Strings[0]);
      SpinEdit1Change(Sender);
      for i := 1 to kol do
      begin
        DateEditOT[i].Text := memo1.Lines.Strings[i * 4 - 3];
        DateEditDO[i].Text := memo1.Lines.Strings[i * 4 - 2];
        CheckRas[i].Checked := StrToBool(memo1.Lines.Strings[i * 4 - 1]);
        CheckDop[i].Checked := StrToBool(memo1.Lines.Strings[i * 4]);
      end;
      Button1Click(Sender);
    except
      ShowMessage('Проблема с загрузкой файла');
    end;
  end;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
var
  a: TForm2;
begin
  a := TForm2.Create(Form1);
  try
    a.ShowModal;
  finally
    a.Free;
  end;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  frReport1.DesignReport;
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

initialization
  SetResourceStrings(@Translate, nil);

end.
