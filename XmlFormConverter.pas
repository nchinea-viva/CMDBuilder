unit XmlFormConverter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, AdvMemo, Advmxml,  Vcl.Clipbrd,
  AdvmSQLS, Vcl.ExtCtrls;

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
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FAutoConvert: Boolean;
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
    lMemoLine := StringReplace(lMemoLine, '#10#13', ' ', [rfReplaceAll, rfIgnoreCase]);
    XmlMemo.Lines.Text := PrettyPrintSQL(lMemoLine, CheckBox1.Checked);
  end;
end;

procedure TFConvert.Button3Click(Sender: TObject);
begin
  close;
end;

procedure TFConvert.FormCreate(Sender: TObject);
begin
  //
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


