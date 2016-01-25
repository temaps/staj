{
Copyright 2015, 2016 Проскурнев Артем Сергеевич

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
}
unit mainstaj;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  Spin, StdCtrls, Buttons, MaskEdit, ExtCtrls;

type

  { TForm1 }
  adateedit = array[1..200] of TDateEdit;

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    ScrollBox1: TScrollBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpinEdit1: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DateEdit1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
  private
    { private declarations }
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

{$R *.lfm}

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
var
  i: integer;
  d1, d2, m1, m2, g1, g2, d, m, l, dp, mp, lp: integer;
  datestr: string;
begin
  d := 0;
  m := 0;
  l := 0;
  dp := 0;
  mp := 0;
  lp := 0;
  for i := 1 to kol do
  begin
    datestr := DateEditOT[i].Text;
    d1 := StrToIntDef(Copy(datestr, 1, 2), 0);
    m1 := StrToIntDef(copy(datestr, 4, 2), 0);
    g1 := StrToIntDef(copy(datestr, 7, 4), 0);
    datestr := DateEditDO[i].Text;
    d2 := StrToIntDef(Copy(datestr, 1, 2), 0);
    m2 := StrToIntDef(copy(datestr, 4, 2), 0);
    g2 := StrToIntDef(copy(datestr, 7, 4), 0);
    if g2 >= g1 then
    begin
      d2 := d2 - d1;
      if d2 < 0 then
      begin
        Dec(m2);
        Inc(d2, 30);
      end;
      if m2 < 0 then
      begin
        Dec(g2);
        Inc(m2, 12);
      end;
      m2 := m2 - m1;
      if m2 < 0 then
      begin
        Dec(g2);
        Inc(m2, 12);
      end;
      g2 := g2 - g1;
    end
    else
      g2 := -1;
    if g2 >= 0 then
      srok[i].Caption := IntToStr(g2) + ' лет ' + IntToStr(m2) +
        ' мес. ' + IntToStr(d2) + ' дней ';


    if CheckRas[i].Checked then
    begin
      if g2 >= 0 then
      begin
        l := l + g2;
        m := m + m2;
        if m >= 12 then
        begin
          Inc(l);
          Dec(m, 12);
        end;
        d := d + d2;
        if d >= 30 then
        begin
          Inc(m);
          Dec(d, 30);
        end;
        if m >= 12 then
        begin
          Inc(l);
          Dec(m, 12);
        end;
      end;
    end;
    if CheckDop[i].Checked then
    begin
      if g2 >= 0 then
      begin
        lp := lp + g2;
        mp := mp + m2;
        if mp >= 12 then
        begin
          Inc(lp);
          Dec(mp, 12);
        end;
        dp := dp + d2;
        if dp >= 30 then
        begin
          Inc(mp);
          Dec(dp, 30);
        end;
        if m >= 12 then
        begin
          Inc(lp);
          Dec(mp, 12);
        end;
      end;
    end;
  end;
  Label1.Caption := IntToStr(l) + ' лет ' + IntToStr(m) + ' месяцев ' +
    IntToStr(d) + ' дней ';
  Label2.Caption := IntToStr(lp) + ' лет ' + IntToStr(mp) + ' месяцев ' +
    IntToStr(dp) + ' дней ';
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
  kol := 1;
  try
    nomer[1] := TLabel.Create(ScrollBox1);
    nomer[1].Parent := ScrollBox1;
    nomer[1].Left := 2;
    nomer[1].Top := 12;
    nomer[1].Caption := '1.';
  except
    nomer[1].Free;
  end;
  try
    DateEditOT[1] := TDateEdit.Create(ScrollBox1);
    DateEditOT[1].Parent := ScrollBox1;
    //DateEditOT[1].Width:=115;
    DateEditOT[1].Left := 8 + 12;
    DateEditOT[1].Top := 8;
    DateEditOT[1].TabOrder := 0;
    DateEditOT[1].DateOrder := doDMY;
    DateEditOT[1].OnKeyPress := @DateEdit1KeyPress;
    DateEditOT[1].ButtonOnlyWhenFocused := True;
  except
    DateEditOT[1].Free;
  end;
  try
    DateEditDO[1] := TDateEdit.Create(ScrollBox1);
    DateEditDO[1].Parent := ScrollBox1;
    //DateEditDO[1].Width:=115;
    DateEditDO[1].Left := 120 + 12;
    DateEditDO[1].Top := 8;
    DateEditDO[1].TabOrder := 1;
    DateEditDO[1].DateOrder := doDMY;
    DateEditDO[1].OnKeyPress := @DateEdit1KeyPress;
    DateEditDO[1].ButtonOnlyWhenFocused := True;
  except
    DateEditDO[1].Free;
  end;
  try
    CheckRas[1] := TCheckBox.Create(ScrollBox1);
    CheckRas[1].Parent := ScrollBox1;
    CheckRas[1].Left := 230 + 12;
    CheckRas[1].Top := 8;
    CheckRas[1].Caption := '';
    CheckRas[1].TabStop := False;
    CheckRas[1].Checked := True;
  except
    CheckRas[1].Free;
  end;
  try
    CheckDop[1] := TCheckBox.Create(ScrollBox1);
    CheckDop[1].Parent := ScrollBox1;
    CheckDop[1].Left := 250 + 12;
    CheckDop[1].Top := 8;
    CheckDop[1].Caption := '';
    CheckDop[1].TabStop := False;
  except
    CheckDop[1].Free;
  end;
  try
    srok[1] := TLabel.Create(ScrollBox1);
    srok[1].Parent := ScrollBox1;
    srok[1].Left := 280 + 12;
    srok[1].Top := 12;
    srok[1].Caption := '';
  except
    srok[1].Free;
  end;
  SpinEdit1.Value := 20;
  SpinEdit1Change(Sender);
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
  Edit1.Text := ListBox1.Items.Strings[ListBox1.ItemIndex];
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
  if MessageDlg('Подтверждение', 'Открыть даты под именем "' + edit1.Text +
    '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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
      v := 8 + (8 + DateEditOT[1].Height) * (i - 1);
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
        //DateEditOT[i].Width:=115;
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
        //DateEditDO[i].Width:=115;
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
        CheckRas[i].Left := 230 + 12;
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
        CheckDop[i].Left := 250 + 12;
        CheckDop[i].Top := v;
        CheckDop[i].Caption := '';
        CheckDop[i].TabStop := False;
      except
        CheckDop[i].Free;
      end;
      try
        srok[i] := TLabel.Create(ScrollBox1);
        srok[i].Parent := ScrollBox1;
        srok[i].Left := 280 + 12;
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
