unit SQLFormatter;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  /// <summary>
  /// Formatta query SQL con stile leggibile e indentazione
  /// </summary>
  TSQLFormatter = class
  private type
    TTokenType = (ttKeyword, ttIdentifier, ttSymbol, ttString, ttWhitespace);

    TToken = record
      Value: string;
      TokenType: TTokenType;
      constructor Create(const AValue: string; AType: TTokenType);
    end;

    TKeywordType = (ktSelect, ktFrom, ktWhere, ktJoin, ktOn, ktGroupBy,
                    ktOrderBy, ktHaving, ktUnion, ktWith, ktNone);
  private
    FIndentSize: Integer;
    FTokens: TList<TToken>;
    FOutput: TStringBuilder;
    FCurrentIndent: Integer;
    FNewProperty: Integer;

    // Tokenization
    procedure Tokenize(const SQL: string);
    function IsKeyword(const Value: string): Boolean;
    function GetKeywordType(const Value: string): TKeywordType;
    function CombineMultiWordKeywords: TList<TToken>;

    // Formatting
    procedure FormatTokens;
    procedure ProcessKeyword(KeywordType: TKeywordType; TokenIndex: Integer;
      var CurrentIndex: Integer);
    procedure ProcessSelectClause(var Index: Integer);
    procedure ProcessFromClause(var Index: Integer);
    procedure ProcessWhereClause(var Index: Integer);
    procedure ProcessJoinClause(const JoinKeyword: string; var Index: Integer);
    procedure ProcessOnClause(var Index: Integer);
    procedure ProcessGroupByOrOrderBy(const Keyword: string; var Index: Integer);

    // Utilities
    procedure WriteLine(const Line: string; IndentLevel: Integer = -1);
    function CollectUntilKeyword(var Index: Integer;
      const StopKeywords: array of TKeywordType): string;
    function GetIndent(Level: Integer): string;
    function IsBreakKeyword(KeywordType: TKeywordType): Boolean;
    procedure SkipWhitespace(var Index: Integer);
    Procedure Copy2ClipBoard(AValue: String);
  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// Formatta una query SQL
    /// </summary>
    function Format(const SQL: string; ACopy2Clip: Boolean): string;

    /// <summary>
    /// Dimensione indentazione (default: 2 spazi)
    /// </summary>
    property IndentSize: Integer read FIndentSize write FIndentSize;
    property NewProperty: Integer read FNewProperty write FNewProperty;
  end;

/// <summary>
/// Funzione helper per formattazione rapida
/// </summary>
function PrettyPrintSQL(const SQL: string; ACopy2Clip: Boolean): string;

implementation

uses
  System.Character, System.StrUtils, Vcl.Clipbrd;

{ TSQLFormatter.TToken }

constructor TSQLFormatter.TToken.Create(const AValue: string; AType: TTokenType);
begin
  Value := AValue;
  TokenType := AType;
end;

{ TSQLFormatter }

constructor TSQLFormatter.Create;
begin
  inherited;
  FIndentSize := 2;
  FTokens := TList<TToken>.Create;
  FOutput := TStringBuilder.Create;
  FCurrentIndent := 0;
end;

destructor TSQLFormatter.Destroy;
begin
  FTokens.Free;
  FOutput.Free;
  inherited;
end;

function TSQLFormatter.Format(const SQL: string; ACopy2Clip: Boolean): string;
begin
  FTokens.Clear;
  FOutput.Clear;
  FCurrentIndent := 0;

  if Trim(SQL) = '' then
    Exit('');

  Tokenize(SQL);
  FormatTokens;

  Result := Trim(FOutput.ToString);

  if ACopy2Clip then
    Copy2ClipBoard(Result);
end;

procedure TSQLFormatter.Tokenize(const SQL: string);
var
  I, Len: Integer;
  Ch: Char;
  Token: TStringBuilder;
  InString: Boolean;
  TokenType: TTokenType;
begin
  Token := TStringBuilder.Create;
  try
    Len := Length(SQL);
    I := 1;
    InString := False;

    while I <= Len do
    begin
      Ch := SQL[I];

      // Gestione stringhe tra apici
      if Ch = '''' then
      begin
        if InString then
        begin
          Token.Append(Ch);
          FTokens.Add(TToken.Create(Token.ToString, ttString));
          Token.Clear;
          InString := False;
        end
        else
        begin
          if Token.Length > 0 then
          begin
//            TokenType := IfThen(IsKeyword(Token.ToString), ttKeyword, ttIdentifier);
            if IsKeyword(Token.ToString) then
              TokenType := ttKeyword
            else
              TokenType := ttIdentifier;
            FTokens.Add(TToken.Create(Token.ToString, TokenType));
            Token.Clear;
          end;
          Token.Append(Ch);
          InString := True;
        end;
        Inc(I);
        Continue;
      end;

      if InString then
      begin
        Token.Append(Ch);
        // Gestione apici doppi
        if (Ch = '''') and (I < Len) and (SQL[I + 1] = '''') then
        begin
          Inc(I);
          Token.Append(SQL[I]);
        end;
      end
      else if CharInSet(Ch, ['(', ')', ',', ';']) then
      begin
        if Token.Length > 0 then
        begin
//          TokenType := IfThen(IsKeyword(Token.ToString), ttKeyword, ttIdentifier);
          if IsKeyword(Token.ToString) then
            TokenType := ttKeyword
          else
            TokenType := ttIdentifier;
          FTokens.Add(TToken.Create(Token.ToString, TokenType));
          Token.Clear;
        end;
        FTokens.Add(TToken.Create(Ch, ttSymbol));
      end
      else if Ch.IsWhiteSpace then
      begin
        if Token.Length > 0 then
        begin
//          TokenType := IfThen(IsKeyword(Token.ToString), ttKeyword, ttIdentifier);
          if IsKeyword(Token.ToString) then
            TokenType := ttKeyword
          else
            TokenType := ttIdentifier;
          FTokens.Add(TToken.Create(Token.ToString, TokenType));
          Token.Clear;
        end;
      end
      else
      begin
        Token.Append(Ch);
      end;

      Inc(I);
    end;

    if Token.Length > 0 then
    begin
      if InString then
        FTokens.Add(TToken.Create(Token.ToString, ttString))
      else
      begin
//        TokenType := IfThen(IsKeyword(Token.ToString), ttKeyword, ttIdentifier);
        if IsKeyword(Token.ToString) then
          TokenType := ttKeyword
        else
          TokenType := ttIdentifier;
        FTokens.Add(TToken.Create(Token.ToString, TokenType));
      end;
    end;
  finally
    Token.Free;
  end;
end;

function TSQLFormatter.IsKeyword(const Value: string): Boolean;
const
  Keywords: array[0..20] of string = (
    'SELECT', 'FROM', 'WHERE', 'JOIN', 'INNER', 'LEFT', 'RIGHT', 'FULL',
    'CROSS', 'OUTER', 'ON', 'GROUP', 'BY', 'ORDER', 'HAVING', 'UNION',
    'ALL', 'WITH', 'AS', 'AND', 'OR'
  );
var
  Keyword: string;
begin
  for Keyword in Keywords do
    if SameText(Value, Keyword) then
      Exit(True);
  Result := False;
end;

function TSQLFormatter.GetKeywordType(const Value: string): TKeywordType;
begin
  if SameText(Value, 'SELECT') then Exit(ktSelect);
  if SameText(Value, 'FROM') then Exit(ktFrom);
  if SameText(Value, 'WHERE') then Exit(ktWhere);
  if SameText(Value, 'GROUP BY') then Exit(ktGroupBy);
  if SameText(Value, 'ORDER BY') then Exit(ktOrderBy);
  if SameText(Value, 'HAVING') then Exit(ktHaving);
  if SameText(Value, 'UNION') or SameText(Value, 'UNION ALL') then Exit(ktUnion);
  if SameText(Value, 'WITH') then Exit(ktWith);
  if SameText(Value, 'ON') then Exit(ktOn);
  if ContainsText(Value, 'JOIN') then Exit(ktJoin);
  Result := ktNone;
end;

function TSQLFormatter.CombineMultiWordKeywords: TList<TToken>;
var
  I: Integer;
  Combined: string;
begin
  Result := TList<TToken>.Create;
  I := 0;

  while I < FTokens.Count do
  begin
    // GROUP BY, ORDER BY
    if (I + 1 < FTokens.Count) and
       SameText(FTokens[I + 1].Value, 'BY') and
       (SameText(FTokens[I].Value, 'GROUP') or SameText(FTokens[I].Value, 'ORDER')) then
    begin
      Combined := UpperCase(FTokens[I].Value) + ' BY';
      Result.Add(TToken.Create(Combined, ttKeyword));
      Inc(I, 2);
      Continue;
    end;

    // LEFT/RIGHT/FULL OUTER JOIN
    if (I + 2 < FTokens.Count) and
       SameText(FTokens[I + 1].Value, 'OUTER') and
       SameText(FTokens[I + 2].Value, 'JOIN') and
       (SameText(FTokens[I].Value, 'LEFT') or
        SameText(FTokens[I].Value, 'RIGHT') or
        SameText(FTokens[I].Value, 'FULL')) then
    begin
      Combined := UpperCase(FTokens[I].Value) + ' OUTER JOIN';
      Result.Add(TToken.Create(Combined, ttKeyword));
      Inc(I, 3);
      Continue;
    end;

    // INNER/LEFT/RIGHT/CROSS JOIN
    if (I + 1 < FTokens.Count) and
       SameText(FTokens[I + 1].Value, 'JOIN') and
       (SameText(FTokens[I].Value, 'INNER') or
        SameText(FTokens[I].Value, 'LEFT') or
        SameText(FTokens[I].Value, 'RIGHT') or
        SameText(FTokens[I].Value, 'CROSS')) then
    begin
      Combined := UpperCase(FTokens[I].Value) + ' JOIN';
      Result.Add(TToken.Create(Combined, ttKeyword));
      Inc(I, 2);
      Continue;
    end;

    // UNION ALL
    if (I + 1 < FTokens.Count) and
       SameText(FTokens[I].Value, 'UNION') and
       SameText(FTokens[I + 1].Value, 'ALL') then
    begin
      Result.Add(TToken.Create('UNION ALL', ttKeyword));
      Inc(I, 2);
      Continue;
    end;

    // Token singolo
    if FTokens[I].TokenType = ttKeyword then
      Result.Add(TToken.Create(UpperCase(FTokens[I].Value), ttKeyword))
    else
      Result.Add(FTokens[I]);

    Inc(I);
  end;
end;

procedure TSQLFormatter.Copy2ClipBoard(AValue: String);
begin
  Clipboard.Open;
  try
    Clipboard.Clear;
    Clipboard.AsText := AValue;
  finally
    Clipboard.Close;
  end;
end;

procedure TSQLFormatter.FormatTokens;
var
  CombinedTokens: TList<TToken>;
  I: Integer;
  KeywordType: TKeywordType;
begin
  CombinedTokens := CombineMultiWordKeywords;
  try
    FTokens.Clear;
    FTokens.AddRange(CombinedTokens);
  finally
    CombinedTokens.Free;
  end;

  I := 0;
  while I < FTokens.Count do
  begin
    if FTokens[I].TokenType = ttKeyword then
    begin
      KeywordType := GetKeywordType(FTokens[I].Value);
      ProcessKeyword(KeywordType, I, I);
    end
    else
      Inc(I);
  end;
end;

procedure TSQLFormatter.ProcessKeyword(KeywordType: TKeywordType;
  TokenIndex: Integer; var CurrentIndex: Integer);
begin
  case KeywordType of
    ktSelect: ProcessSelectClause(CurrentIndex);
    ktFrom: ProcessFromClause(CurrentIndex);
    ktWhere: ProcessWhereClause(CurrentIndex);
    ktJoin: ProcessJoinClause(FTokens[TokenIndex].Value, CurrentIndex);
    ktOn: ProcessOnClause(CurrentIndex);
    ktGroupBy, ktOrderBy: ProcessGroupByOrOrderBy(FTokens[TokenIndex].Value, CurrentIndex);
    ktHaving: ProcessWhereClause(CurrentIndex); // Simile a WHERE
  else
    WriteLine(FTokens[TokenIndex].Value);
    Inc(CurrentIndex);
  end;
end;

procedure TSQLFormatter.ProcessSelectClause(var Index: Integer);
var
  Columns: TStringList;
  CurrentCol: TStringBuilder;
  I: Integer;
  IsFirst: Boolean;
begin
  WriteLine('SELECT', 0);
  Inc(Index);

  Columns := TStringList.Create;
  CurrentCol := TStringBuilder.Create;
  try
    // Raccolta colonne fino a FROM o altra keyword
    while Index < FTokens.Count do
    begin
      if IsBreakKeyword(GetKeywordType(FTokens[Index].Value)) then
        Break;

      if (FTokens[Index].TokenType = ttSymbol) and (FTokens[Index].Value = ',') then
      begin
        if CurrentCol.Length > 0 then
        begin
          Columns.Add(Trim(CurrentCol.ToString));
          CurrentCol.Clear;
        end;
      end
      else
      begin
        if CurrentCol.Length > 0 then
          CurrentCol.Append(' ');
        CurrentCol.Append(FTokens[Index].Value);
      end;

      Inc(Index);
    end;

    if CurrentCol.Length > 0 then
      Columns.Add(Trim(CurrentCol.ToString));

    // Output colonne
    IsFirst := True;
    for I := 0 to Columns.Count - 1 do
    begin
      if IsFirst then
      begin
        FOutput.Append(GetIndent(0));
        FOutput.Append('  '); // Prima colonna indentata
        IsFirst := False;
      end
      else
      begin
        FOutput.AppendLine(',');
        FOutput.Append(GetIndent(0));
        FOutput.Append('  ');
      end;
      FOutput.Append(Columns[I]);
    end;

    if Columns.Count > 0 then
      FOutput.AppendLine;
  finally
    CurrentCol.Free;
    Columns.Free;
  end;
end;

procedure TSQLFormatter.ProcessFromClause(var Index: Integer);
var
  TableClause: string;
begin
  Inc(Index);
  TableClause := CollectUntilKeyword(Index, [ktWhere, ktJoin, ktGroupBy, ktOrderBy, ktHaving]);
  WriteLine('FROM ' + Trim(TableClause), 0);
end;

procedure TSQLFormatter.ProcessWhereClause(var Index: Integer);
var
  Conditions: TStringList;
  CurrentCondition: TStringBuilder;
  IsFirst: Boolean;
  I: Integer;
begin
  WriteLine(FTokens[Index].Value, 0); // WHERE o HAVING
  Inc(Index);

  Conditions := TStringList.Create;
  CurrentCondition := TStringBuilder.Create;
  try
    while Index < FTokens.Count do
    begin
      if IsBreakKeyword(GetKeywordType(FTokens[Index].Value)) then
        Break;

      if (FTokens[Index].TokenType = ttKeyword) and
         (SameText(FTokens[Index].Value, 'AND') or SameText(FTokens[Index].Value, 'OR')) then
      begin
        if CurrentCondition.Length > 0 then
        begin
          Conditions.Add(Trim(CurrentCondition.ToString));
          CurrentCondition.Clear;
        end;
        Conditions.Add(UpperCase(FTokens[Index].Value));
      end
      else
      begin
        if CurrentCondition.Length > 0 then
          CurrentCondition.Append(' ');
        CurrentCondition.Append(FTokens[Index].Value);
      end;

      Inc(Index);
    end;

    if CurrentCondition.Length > 0 then
      Conditions.Add(Trim(CurrentCondition.ToString));

    // Output condizioni
    IsFirst := True;
    for I := 0 to Conditions.Count - 1 do
    begin
      if SameText(Conditions[I], 'AND') or SameText(Conditions[I], 'OR') then
        WriteLine(Conditions[I], 1)
      else
        WriteLine(Conditions[I], 1);
    end;
  finally
    CurrentCondition.Free;
    Conditions.Free;
  end;
end;

procedure TSQLFormatter.ProcessJoinClause(const JoinKeyword: string; var Index: Integer);
var
  TableClause: string;
begin
  WriteLine(JoinKeyword, 0);
  Inc(Index);
  TableClause := CollectUntilKeyword(Index, [ktOn, ktJoin, ktWhere, ktGroupBy, ktOrderBy]);
  if Trim(TableClause) <> '' then
    WriteLine(Trim(TableClause), 1);
end;

procedure TSQLFormatter.ProcessOnClause(var Index: Integer);
var
  Conditions: TStringList;
  CurrentCondition: TStringBuilder;
  I: Integer;
begin
  WriteLine('ON', 1);
  Inc(Index);

  Conditions := TStringList.Create;
  CurrentCondition := TStringBuilder.Create;
  try
    while Index < FTokens.Count do
    begin
      if IsBreakKeyword(GetKeywordType(FTokens[Index].Value)) then
        Break;

      if (FTokens[Index].TokenType = ttKeyword) and
         (SameText(FTokens[Index].Value, 'AND') or SameText(FTokens[Index].Value, 'OR')) then
      begin
        if CurrentCondition.Length > 0 then
        begin
          Conditions.Add(Trim(CurrentCondition.ToString));
          CurrentCondition.Clear;
        end;
        Conditions.Add(UpperCase(FTokens[Index].Value));
      end
      else
      begin
        if CurrentCondition.Length > 0 then
          CurrentCondition.Append(' ');
        CurrentCondition.Append(FTokens[Index].Value);
      end;

      Inc(Index);
    end;

    if CurrentCondition.Length > 0 then
      Conditions.Add(Trim(CurrentCondition.ToString));

    for I := 0 to Conditions.Count - 1 do
      WriteLine(Conditions[I], 2);
  finally
    CurrentCondition.Free;
    Conditions.Free;
  end;
end;

procedure TSQLFormatter.ProcessGroupByOrOrderBy(const Keyword: string; var Index: Integer);
var
  ListClause: string;
begin
  WriteLine(Keyword, 0);
  Inc(Index);
  ListClause := CollectUntilKeyword(Index, [ktHaving, ktOrderBy, ktGroupBy]);
  if Trim(ListClause) <> '' then
    WriteLine(Trim(ListClause), 1);
end;

function TSQLFormatter.CollectUntilKeyword(var Index: Integer;
  const StopKeywords: array of TKeywordType): string;
var
  Buffer: TStringBuilder;
  KeywordType: TKeywordType;
  StopKw: TKeywordType;
  ShouldStop: Boolean;
begin
  Buffer := TStringBuilder.Create;
  try
    while Index < FTokens.Count do
    begin
      KeywordType := GetKeywordType(FTokens[Index].Value);

      ShouldStop := False;
      for StopKw in StopKeywords do
        if KeywordType = StopKw then
        begin
          ShouldStop := True;
          Break;
        end;

      if ShouldStop then
        Break;

      if FTokens[Index].TokenType = ttSymbol then
      begin
        if FTokens[Index].Value = ',' then
          Buffer.Append(',')
        else
          Buffer.Append(FTokens[Index].Value);
      end
      else
      begin
        if Buffer.Length > 0 then
          Buffer.Append(' ');
        Buffer.Append(FTokens[Index].Value);
      end;

      Inc(Index);
    end;

    Result := Trim(Buffer.ToString);
  finally
    Buffer.Free;
  end;
end;

procedure TSQLFormatter.WriteLine(const Line: string; IndentLevel: Integer);
begin
  if IndentLevel < 0 then
    IndentLevel := FCurrentIndent;

  FOutput.Append(GetIndent(IndentLevel));
  FOutput.AppendLine(TrimRight(Line));
end;

function TSQLFormatter.GetIndent(Level: Integer): string;
begin
  Result := StringOfChar(' ', Level * FIndentSize);
end;

function TSQLFormatter.IsBreakKeyword(KeywordType: TKeywordType): Boolean;
begin
  Result := KeywordType in [ktSelect, ktFrom, ktWhere, ktJoin, ktGroupBy,
                            ktOrderBy, ktHaving, ktUnion, ktWith];
end;

procedure TSQLFormatter.SkipWhitespace(var Index: Integer);
begin
  while (Index < FTokens.Count) and
        (FTokens[Index].TokenType = ttWhitespace) do
    Inc(Index);
end;

function PrettyPrintSQL(const SQL: string; ACopy2Clip: Boolean): string;
var
  Formatter: TSQLFormatter;
begin
  Formatter := TSQLFormatter.Create;
  try
    Result := Formatter.Format(SQL, ACopy2Clip);
  finally
    Formatter.Free;
  end;
end;

end.
