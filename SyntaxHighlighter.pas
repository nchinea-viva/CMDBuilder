unit SyntaxHighlighter;

interface

uses
  System.SysUtils, System.Classes, Vcl.ComCtrls, Vcl.Graphics, System.RegularExpressions;

type
  TSyntaxType = (stNone, stXML, stSQL);

  TSyntaxHighlighter = class
  private
    FRichEdit: TRichEdit;
    FSyntaxType: TSyntaxType;
    procedure HighlightXML;
    procedure HighlightSQL;
  public
    constructor Create(ARichEdit: TRichEdit);
    procedure ApplySyntaxHighlighting(ASyntaxType: TSyntaxType);
    property SyntaxType: TSyntaxType read FSyntaxType write FSyntaxType;
  end;

implementation

constructor TSyntaxHighlighter.Create(ARichEdit: TRichEdit);
begin
  inherited Create;
  FRichEdit := ARichEdit;
  FSyntaxType := stNone;
end;

procedure TSyntaxHighlighter.ApplySyntaxHighlighting(ASyntaxType: TSyntaxType);
begin
  FSyntaxType := ASyntaxType;

  FRichEdit.Lines.BeginUpdate;
  try
    case FSyntaxType of
      stXML: HighlightXML;
      stSQL: HighlightSQL;
    end;
  finally
    FRichEdit.Lines.EndUpdate;
  end;
end;

procedure TSyntaxHighlighter.HighlightXML;
var
  Text: string;
  Regex: TRegEx;
  Match: TMatch;
begin
  FRichEdit.Text := StringReplace(FRichEdit.Text, sLineBreak, ' ', [rfReplaceAll]);
  Text := FRichEdit.Text;

  // Reset formattazione
  FRichEdit.SelectAll;
  FRichEdit.SelAttributes.Color := clBlack;
  FRichEdit.SelAttributes.Style := [];
  FRichEdit.SelLength := 0;

  // Commenti XML <!-- --> (prima dei tag per priorità)
  Regex := TRegEx.Create('<!--[\s\S]*?-->', [roMultiLine]);
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index-1;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clGray;
    FRichEdit.SelAttributes.Style := [fsItalic];
  end;

  // Tag XML (es: <tag>, </tag>, <tag/>, <tag attr="val">)
  Regex := TRegEx.Create('<[^>]+>', [roMultiLine]);
  for Match in Regex.Matches(Text) do
  begin
    // Verifica che non sia un commento
    if not Match.Value.StartsWith('<!--') then
    begin
      FRichEdit.SelStart := Match.Index-1;
      FRichEdit.SelLength := Match.Length;
      FRichEdit.SelAttributes.Color := clBlue;
      FRichEdit.SelAttributes.Style := [fsBold];
    end;
  end;

  // Attributi XML (es: nome="valore")
  Regex := TRegEx.Create('[a-zA-Z][a-zA-Z0-9\-_:]*\s*=', [roMultiLine]);
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index-1;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clRed;
    FRichEdit.SelAttributes.Style := [];
  end;

  // Stringhe tra virgolette
  Regex := TRegEx.Create('"[^"]*"', [roMultiLine]);
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index-1;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clGreen;
    FRichEdit.SelAttributes.Style := [];
  end;

  FRichEdit.SelLength := 0;
  //FRichEdit.Text := StringReplace(FRichEdit.Text, '|', sLineBreak, [rfReplaceAll]);
end;

procedure TSyntaxHighlighter.HighlightSQL;
var
  Text: string;
  Regex: TRegEx;
  Match: TMatch;
  Keywords: TArray<string>;
  Keyword: string;
begin
  Text := FRichEdit.Text;

  // Reset formattazione
  FRichEdit.SelectAll;
  FRichEdit.SelAttributes.Color := clBlack;
  FRichEdit.SelLength := 0;

  // Parole chiave SQL
  Keywords := ['SELECT', 'FROM', 'WHERE', 'INSERT', 'UPDATE', 'DELETE',
               'CREATE', 'TABLE', 'ALTER', 'DROP', 'JOIN', 'INNER', 'LEFT',
               'RIGHT', 'ON', 'AND', 'OR', 'NOT', 'NULL', 'AS', 'ORDER',
               'BY', 'GROUP', 'HAVING', 'DISTINCT', 'TOP', 'LIMIT', 'INTO',
               'VALUES', 'SET', 'BEGIN', 'END', 'IF', 'ELSE', 'WHILE'];

  for Keyword in Keywords do
  begin
    Regex := TRegEx.Create('\b' + Keyword + '\b', [roIgnoreCase]);
    for Match in Regex.Matches(Text) do
    begin
      FRichEdit.SelStart := Match.Index;
      FRichEdit.SelLength := Match.Length;
      FRichEdit.SelAttributes.Color := clBlue;
      FRichEdit.SelAttributes.Style := [fsBold];
    end;
  end;

  // Stringhe tra apici
  Regex := TRegEx.Create('''[^'']*''');
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clGreen;
    FRichEdit.SelAttributes.Style := [];
  end;

  // Numeri
  Regex := TRegEx.Create('\b\d+(\.\d+)?\b');
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clMaroon;
    FRichEdit.SelAttributes.Style := [];
  end;

  // Commenti SQL -- e /* */
  Regex := TRegEx.Create('--.*?$', [roMultiLine]);
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clGray;
    FRichEdit.SelAttributes.Style := [fsItalic];
  end;

  Regex := TRegEx.Create('/\*.*?\*/', [roSingleLine]);
  for Match in Regex.Matches(Text) do
  begin
    FRichEdit.SelStart := Match.Index;
    FRichEdit.SelLength := Match.Length;
    FRichEdit.SelAttributes.Color := clGray;
    FRichEdit.SelAttributes.Style := [fsItalic];
  end;

  FRichEdit.SelLength := 0;
end;

end.
