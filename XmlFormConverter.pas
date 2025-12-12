unit XmlFormConverter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AdvMemo, Advmxml,  Vcl.Clipbrd,
  AdvmSQLS, Vcl.ExtCtrls, SyntaxHighlighter, Vcl.ComCtrls;

type
  TFConvert = class(TForm)
    Button1: TButton;
    AdvXMLMemoStyler: TAdvXMLMemoStyler;
    XmlMemo: TAdvMemo;
    Button3: TButton;
    CheckBox1: TCheckBox;
    AdvSQLMemoStyler: TAdvSQLMemoStyler;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    RichEdit1: TRichEdit;
    Button2: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FAutoConvert: Boolean;
    FHighlighter: TSyntaxHighlighter;
  public
    { Public declarations }
    Property AutoConvert : Boolean read FAutoConvert write FAutoConvert;
  end;

var
  FConvert: TFConvert;

implementation

{$R *.dfm}

Uses XMLMultirefConverter, SQLFormatter;

procedure TFConvert.Button1Click(Sender: TObject);
Var lMemoLine: String;
begin
  lMemoLine := Trim(XmlMemo.Lines.Text);
  if lMemoLine = '' then
    exit;
  if lMemoLine[1] = '''' then
    lMemoLine[1] := ' ';
  if lMemoLine[Length(lMemoLine)] = '''' then
    lMemoLine[Length(lMemoLine)] := ' ';
  lMemoLine := Trim(lMemoLine);
  XmlMemo.Lines.Clear;
  if XmlMemo.SyntaxStyles = AdvXMLMemoStyler then
    XmlMemo.Lines.Text := ResolveMultiref(lMemoLine, CheckBox1.Checked)
  else
  begin
    lMemoLine := StringReplace(lMemoLine, '''#$D#$A''', ' ', [rfReplaceAll, rfIgnoreCase]);
    lMemoLine := StringReplace(lMemoLine, '''#$D#$A#$D#$A''', ' ', [rfReplaceAll, rfIgnoreCase]);

    XmlMemo.Lines.Text := PrettyPrintSQL(lMemoLine, CheckBox1.Checked);
  end;
end;

procedure TFConvert.Button2Click(Sender: TObject);
begin
  FHighlighter.ApplySyntaxHighlighting(stXML);
  Var lMemoLine := Trim(RichEdit1.Lines.Text);
  RichEdit1.Lines.Text := ResolveMultiref(lMemoLine, false);
end;

procedure TFConvert.Button3Click(Sender: TObject);
begin
  close;
end;

procedure TFConvert.Button4Click(Sender: TObject);
begin
  RichEdit1.SelectAll;
  RichEdit1.SelAttributes.Color := clBlack;
  RichEdit1.SelAttributes.Style := [];
  RichEdit1.SelLength := 0;
end;

procedure TFConvert.Button5Click(Sender: TObject);
begin
  FHighlighter.ApplySyntaxHighlighting(stSQL);
end;

procedure TFConvert.FormCreate(Sender: TObject);
begin
  FHighlighter := TSyntaxHighlighter.Create(RichEdit1);

  // Esempio XML
  RichEdit1.Lines.Add('<?xml version="1.0" encoding="UTF-8"?>');
  RichEdit1.Lines.Add('<!-- Commento XML -->');
  RichEdit1.Lines.Add('<root>');
  RichEdit1.Lines.Add('  <elemento attributo="valore">Testo</elemento>');
  RichEdit1.Lines.Add('</root>');
end;

procedure TFConvert.FormShow(Sender: TObject);
begin
  if FAutoConvert then
  begin
    XmlMemo.Lines.Clear;
    XmlMemo.Lines.Text := Clipboard.AsText;
    Button1Click(Nil);
  end;
end;

end.


