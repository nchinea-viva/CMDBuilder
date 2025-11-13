unit SQLPrettyPrint;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, System.Generics.Collections;

function PrettyPrintSQL(const SQLString: string): string;

implementation

type
  TTokenType = (ttKeyword, ttIdentifier, ttOperator, ttValue, ttWhitespace, ttComment);

function PrettyPrintSQL(const SQLString: string): string;
var
  Output: TStringBuilder;
  Input: string;
  I, IndentLevel: Integer;
  CurrentToken: string;
  InString, InComment, InLineComment: Boolean;
  C: Char;
  Keywords: TArray<string>;
  MajorKeywords: TArray<string>;
  MinorKeywords: TArray<string>;

  function IsKeyword(const Token: string; const KeywordList: TArray<string>): Boolean;
  var
    Keyword: string;
  begin
    Result := False;
    for Keyword in KeywordList do
    begin
      if SameText(Token, Keyword) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  procedure FlushToken;
  var
    UpperToken: string;
    Indent: string;
    JoinKeywords: TArray<string>;
    IsJoinKeyword: Boolean;
  begin
    if CurrentToken = '' then
      Exit;

    UpperToken := UpperCase(Trim(CurrentToken));
    Indent := StringOfChar(' ', IndentLevel * 2);

    // Parole chiave di JOIN da tenere sulla stessa riga
    JoinKeywords := TArray<string>.Create('JOIN', 'INNER', 'LEFT', 'RIGHT', 'FULL', 'CROSS', 'OUTER', 'WITH');
    IsJoinKeyword := IsKeyword(UpperToken, JoinKeywords);

    // Parole chiave principali (nuova riga prima)
    if IsKeyword(UpperToken, MajorKeywords) and not IsJoinKeyword then
    begin
      if Output.Length > 0 then
        Output.Append(sLineBreak);
      Output.Append(Indent);
      Output.Append(UpperToken);
      Output.Append(' ');
    end
    // JOIN keywords - nuova riga ma continuano sulla stessa riga tra loro
    else if IsJoinKeyword then
    begin
      // Se è il primo JOIN o dopo altro contenuto, vai a capo
      if (UpperToken = 'JOIN') or
         ((UpperToken = 'INNER') or (UpperToken = 'LEFT') or (UpperToken = 'RIGHT') or
          (UpperToken = 'FULL') or (UpperToken = 'WITH') or (UpperToken = 'CROSS')) then
      begin
        // Solo se non è già dopo un altro keyword di join
        if (Output.Length > 0) and not (Output.ToString.EndsWith('INNER ') or
           Output.ToString.EndsWith('LEFT ') or Output.ToString.EndsWith('RIGHT ') or
           Output.ToString.EndsWith('FULL ') or Output.ToString.EndsWith('CROSS ')) then
          Output.Append(sLineBreak + Indent);
      end;
      Output.Append(UpperToken);
      Output.Append(' ');
    end
    // Parole chiave secondarie (nuova riga prima con indentazione)
    else if IsKeyword(UpperToken, MinorKeywords) then
    begin
      Output.Append(sLineBreak);
      Output.Append(Indent);
      Output.Append('  '); // Indentazione extra
      Output.Append(UpperToken);
      Output.Append(' ');
    end
    // Altri token
    else
    begin
      Output.Append(CurrentToken);
    end;

    CurrentToken := '';
  end;

begin
  // Definisci le parole chiave SQL
  MajorKeywords := TArray<string>.Create(
    'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'ALTER', 'DROP',
    'FROM', 'WHERE', 'GROUP', 'HAVING', 'ORDER', 'LIMIT', 'OFFSET',
    'JOIN', 'INNER', 'LEFT', 'RIGHT', 'FULL', 'CROSS', 'OUTER',
    'UNION', 'INTERSECT', 'EXCEPT', 'INTO', 'VALUES', 'SET', 'WITH'
  );

  MinorKeywords := TArray<string>.Create(
    'AND', 'OR', 'NOT', 'IN', 'EXISTS', 'BETWEEN', 'LIKE', 'IS', 'NULL',
    'ON', 'USING', 'AS', 'BY', 'ASC', 'DESC', 'DISTINCT', 'ALL', 'CASE',
    'WHEN', 'THEN', 'ELSE', 'END'
  );

  Input := Trim(SQLString);
  Output := TStringBuilder.Create;
  try
    IndentLevel := 0;
    CurrentToken := '';
    InString := False;
    InComment := False;
    InLineComment := False;

    I := 1;
    while I <= Length(Input) do
    begin
      C := Input[I];

      // Gestione stringhe
      if C = '''' then
      begin
        if not InComment and not InLineComment then
        begin
          CurrentToken := CurrentToken + C;
          InString := not InString;
        end;
        Inc(I);
        Continue;
      end;

      // Se siamo in una stringa, aggiungi tutto
      if InString then
      begin
        CurrentToken := CurrentToken + C;
        Inc(I);
        Continue;
      end;

      // Gestione commenti multi-linea /* */
      if (C = '/') and (I < Length(Input)) and (Input[I + 1] = '*') and not InLineComment then
      begin
        FlushToken;
        InComment := True;
        Output.Append('/*');
        Inc(I, 2);
        Continue;
      end;

      if InComment then
      begin
        Output.Append(C);
        if (C = '*') and (I < Length(Input)) and (Input[I + 1] = '/') then
        begin
          Output.Append('/');
          InComment := False;
          Inc(I);
        end;
        Inc(I);
        Continue;
      end;

      // Gestione commenti di linea --
      if (C = '-') and (I < Length(Input)) and (Input[I + 1] = '-') then
      begin
        FlushToken;
        InLineComment := True;
        Output.Append('--');
        Inc(I, 2);
        Continue;
      end;

      if InLineComment then
      begin
        Output.Append(C);
        if (C = #13) or (C = #10) then
          InLineComment := False;
        Inc(I);
        Continue;
      end;

      // Gestione parentesi
      if C = '(' then
      begin
        FlushToken;
        Output.Append('(');
        Inc(IndentLevel);
        Inc(I);
        Continue;
      end;

      if C = ')' then
      begin
        FlushToken;
        Dec(IndentLevel);
        if IndentLevel < 0 then
          IndentLevel := 0;
        Output.Append(')');
        Inc(I);
        Continue;
      end;

      // Gestione virgole
      if C = ',' then
      begin
        FlushToken;
        Output.Append(',');
        Output.Append(sLineBreak);
        Output.Append(StringOfChar(' ', IndentLevel * 2));
        Output.Append('  ');
        Inc(I);
        Continue;
      end;

      // Gestione operatori
      if C in ['+', '-', '*', '/', '=', '<', '>', '!', '|', '&'] then
      begin
        FlushToken;
        Output.Append(' ');
        Output.Append(C);
        Output.Append(' ');
        Inc(I);
        Continue;
      end;

      // Gestione spazi bianchi
      if C in [' ', #9, #13, #10] then
      begin
        FlushToken;
        Inc(I);
        Continue;
      end;

      // Aggiungi carattere al token corrente
      CurrentToken := CurrentToken + C;
      Inc(I);
    end;

    // Flush ultimo token
    FlushToken;

    Result := Trim(Output.ToString);
  finally
    Output.Free;
  end;
end;

end.
