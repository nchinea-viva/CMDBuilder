unit SQLPrettyPrint;

interface

function PrettyPrintSQL(const SQL: string): string;

implementation

uses
  System.SysUtils, System.Classes, System.StrUtils;

const
  BreakKeywords: array[0..14] of string = (
    'SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'HAVING',
    'INNER JOIN', 'LEFT JOIN', 'LEFT OUTER JOIN', 'RIGHT JOIN', 'FULL JOIN',
    'JOIN', 'OUTER APPLY', 'CROSS APPLY', 'CROSS JOIN'
  );

function NormalizeSpaces(const S: string): string;
begin
  Result := Trim(StringReplace(S, #13#10, ' ', [rfReplaceAll]));
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
end;

function PrettyPrintSQL(const SQL: string): string;
var
  Tmp: string;
  Line: string;
  I: Integer;
  SL: TStringList;
  K: string;
begin
  Tmp := SQL;
  Tmp := NormalizeSpaces(Tmp);
  Tmp := StringReplace(Tmp, ',', ',#BRK#', [rfReplaceAll]); // spezza colonne SELECT

  // Inserisce line break prima delle keywords
  for K in BreakKeywords do
    Tmp := StringReplace(Tmp, K, '#BRK#' + K, [rfReplaceAll, rfIgnoreCase]);

  // Rimuove duplicazioni BRK
  while Pos('#BRK##BRK#', Tmp) > 0 do
    Tmp := StringReplace(Tmp, '#BRK##BRK#', '#BRK#', [rfReplaceAll]);

  SL := TStringList.Create;
  try
    SL.Text := StringReplace(Tmp, '#BRK#', sLineBreak, [rfReplaceAll]);

    // pulizia righe
    for I := SL.Count - 1 downto 0 do
    begin
      Line := Trim(SL[I]);
      if Line = '' then
        SL.Delete(I)
      else
        SL[I] := Line;
    end;

    // indentazione semplice
    for I := 0 to SL.Count - 1 do
    begin
      if StartsText('SELECT', SL[I]) then SL[I] := SL[I]
      else if StartsText('FROM', SL[I]) then SL[I] := SL[I]
      else if StartsText('WHERE', SL[I]) then SL[I] := SL[I]
      else if StartsText('ORDER BY', SL[I]) then SL[I] := SL[I]
      else if StartsText('GROUP BY', SL[I]) then SL[I] := SL[I]
      else if ContainsText(SL[I], 'JOIN') then SL[I] := SL[I]
      else
        SL[I] := '  ' + SL[I]; // indent normale
    end;

    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

end.
(*
interface

uses
  System.SysUtils, System.Classes, System.StrUtils, System.Generics.Collections;

function PrettyPrintSQL(const SQL: string): string;

implementation

type
  TSQLTokenType = (ttWord, ttSymbol, ttWhitespace, ttString, ttNumber);

const
  // Keywords che devono forzare un break di riga prima (stile A)
  BreakKeywords: array[0..18] of string = (
    'SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'HAVING', 'JOIN',
    'INNER JOIN', 'LEFT JOIN', 'LEFT OUTER JOIN', 'RIGHT JOIN',
    'FULL JOIN', 'CROSS JOIN', 'OUTER APPLY', 'CROSS APPLY',
    'ON', 'UNION', 'UNION ALL', 'WITH'
  );

  // Keywords che richiedono un indentazione per i loro "children"
  IndentAfter: array[0..4] of string = ('SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY');

function TrimAndCollapseSpaces(const S: string): string;
var
  i: Integer;
  sb: TStringBuilder;
  lastSpace: Boolean;
begin
  sb := TStringBuilder.Create;
  try
    lastSpace := False;
    for i := 1 to Length(S) do
    begin
      if CharInSet(S[i], [#9, #10, #13, ' ']) then
      begin
        if not lastSpace then
        begin
          sb.Append(' ');
          lastSpace := True;
        end;
      end
      else
      begin
        sb.Append(S[i]);
        lastSpace := False;
      end;
    end;
    Result := Trim(sb.ToString);
  finally
    sb.Free;
  end;
end;

function IsAlphaNum(AChar: Char): Boolean;
begin
  Result := CharInSet(AChar, ['0'..'9', 'A'..'Z', 'a'..'z', '_', '@', '.']);
end;

// Tokenizza lo SQL rispettando stringhe tra '' e parentesi
function TokenizeSQL(const SQL: string): TArray<string>;
var
  i, L: Integer;
  sb: TStringBuilder;
  ch: Char;
  inString: Boolean;
  arr: TList<string>;
begin
  arr := TList<string>.Create;
  sb := TStringBuilder.Create;
  try
    L := Length(SQL);
    inString := False;
    i := 1;
    while i <= L do
    begin
      ch := SQL[i];
      if inString then
      begin
        sb.Append(ch);
        if (ch = '''') and (i < L) and (SQL[i+1] = '''') then
        begin
          // escaped quote '', consume next '
          sb.Append(SQL[i+1]);
          Inc(i);
        end
        else if ch = '''' then
        begin
          // end string
          arr.Add(sb.ToString);
          sb.Clear;
          inString := False;
        end;
      end
      else
      begin
        if ch = '''' then
        begin
          // start string
          if sb.Length > 0 then
          begin
            arr.Add(sb.ToString);
            sb.Clear;
          end;
          inString := True;
          sb.Append(ch);
        end
        else if CharInSet(ch, ['(', ')', ',', ';']) then
        begin
          if sb.Length > 0 then
          begin
            arr.Add(sb.ToString);
            sb.Clear;
          end;
          arr.Add(ch);
        end
        else if CharInSet(ch, [' ', #9, #13, #10]) then
        begin
          if sb.Length > 0 then
          begin
            arr.Add(sb.ToString);
            sb.Clear;
          end;
          // skip whitespace tokens (we'll manage spacing)
        end
        else
        begin
          sb.Append(ch);
        end;
      end;
      Inc(i);
    end;

    if sb.Length > 0 then
      arr.Add(sb.ToString);

    Result := arr.ToArray;
  finally
    sb.Free;
    arr.Free;
  end;
end;

function UpperIfKeyword(const Token: string): string;
begin
  // Manteniamo `with(nolock)` e nomi con case originali per le identità quando opportuno.
  // Tuttavia per le keywords le faremo uppercase.
  Result := Token;
  if Result = '' then Exit;

  // Consider multi-word keywords (GROUP BY, ORDER BY, LEFT OUTER JOIN etc.)
  // Questo sarà gestito nel formatter principale. Qui solo uppercase singole tokens se coincidono.
  if SameText(Result, 'select') or SameText(Result, 'from') or SameText(Result, 'where') or
     SameText(Result, 'group') or SameText(Result, 'order') or SameText(Result, 'having') or
     SameText(Result, 'join') or SameText(Result, 'inner') or SameText(Result, 'left') or
     SameText(Result, 'right') or SameText(Result, 'full') or SameText(Result, 'cross') or
     SameText(Result, 'on') or SameText(Result, 'union') or SameText(Result, 'with') or
     SameText(Result, 'apply') then
    Result := UpperCase(Result);
end;

function CombinePossibleMultiWordKeywords(const Tokens: TArray<string>): TArray<string>;
var
  i: Integer;
  outList: TList<string>;
  t: string;
begin
  outList := TList<string>.Create;
  try
    i := 0;
    while i < Length(Tokens) do
    begin
      t := Tokens[i];
      // check for GROUP BY or ORDER BY
      if (i + 1 < Length(Tokens)) and SameText(Tokens[i+1], 'by') and
         (SameText(t, 'group') or SameText(t, 'order')) then
      begin
        outList.Add(UpperCase(t) + ' BY');
        Inc(i, 2);
        Continue;
      end;

      // check for LEFT OUTER JOIN / LEFT JOIN / RIGHT JOIN / INNER JOIN / CROSS JOIN
      if (i + 2 < Length(Tokens)) and SameText(Tokens[i+1], 'outer') and SameText(Tokens[i+2], 'join') and
         (SameText(t, 'left') or SameText(t, 'right') or SameText(t, 'full')) then
      begin
        outList.Add(UpperCase(t) + ' OUTER JOIN');
        Inc(i, 3);
        Continue;
      end;

      if (i + 1 < Length(Tokens)) and SameText(Tokens[i+1], 'join') and
         (SameText(t, 'left') or SameText(t, 'right') or SameText(t, 'inner') or SameText(t, 'cross')) then
      begin
        outList.Add(UpperCase(t) + ' JOIN');
        Inc(i, 2);
        Continue;
      end;

      // UNION ALL
      if (i + 1 < Length(Tokens)) and SameText(t, 'union') and SameText(Tokens[i+1], 'all') then
      begin
        outList.Add('UNION ALL');
        Inc(i, 2);
        Continue;
      end;

      // default: uppercase common keywords
      outList.Add(UpperIfKeyword(t));
      Inc(i);
    end;

    Result := outList.ToArray;
  finally
    outList.Free;
  end;
end;

function IsBreakKeyword(const Token: string): Boolean;
var
  k: string;
begin
  for k in BreakKeywords do
    if SameText(Token, k) then
      Exit(True);
  Result := False;
end;

function IsIndentAfter(const Token: string): Boolean;
var
  k: string;
begin
  for k in IndentAfter do
    if SameText(Token, k) then
      Exit(True);
  Result := False;
end;

// helper: returns true if token is a comma
function IsComma(const Token: string): Boolean;
begin
  Result := Token = ',';
end;

// helper detect function-like token e.g. COUNT( oppure OVER(
function IsFunctionToken(const Token: string): Boolean;
begin
  // if token ends with '(' we had split '(' separately; our tokenizer places '(' as separate token
  Result := False; // not used here
end;

// Main formatter
function PrettyPrintSQL(const SQL: string): string;
var
  norm: string;
  rawTokens: TArray<string>;
  tokens: TArray<string>;
  i: Integer;
  outLines: TStringList;
  currentLine: string;
  indentLevel: Integer;
  indent: string;
  lastKeyword: string;
  inSelectList: Boolean;
  selectPrefix: string;
  colBuffer: TStringList;
  tok: string;
  nextTok: string;
  pendingBreak: Boolean;

  procedure FlushCurrentLine;
  begin
    if Trim(currentLine) <> '' then
    begin
      outLines.Add(currentLine);
      currentLine := '';
    end;
  end;

  procedure AddLine(const S: string);
  begin
    outLines.Add(S);
  end;

  function IndentStr(Level: Integer): string;
  begin
    Result := StringOfChar(' ', Level * 2); // 2 spaces per indent level (stile A)
  end;

begin
  Result := '';
  norm := TrimAndCollapseSpaces(SQL);

  if norm = '' then Exit;

  // Tokenize
  rawTokens := TokenizeSQL(norm);
  tokens := CombinePossibleMultiWordKeywords(rawTokens);

  outLines := TStringList.Create;
  colBuffer := TStringList.Create;
  try
    indentLevel := 0;
    currentLine := '';
    lastKeyword := '';
    inSelectList := False;
    pendingBreak := False;

    i := 0;
    while i < Length(tokens) do
    begin
      tok := tokens[i];
      nextTok := '';
      if i + 1 < Length(tokens) then nextTok := tokens[i+1];

      // Normalize casing for keywords (we already uppercased some common ones in CombinePossibleMultiWordKeywords)
      if IsBreakKeyword(tok) then
      begin
        // Special-case SELECT
        if SameText(tok, 'SELECT') then
        begin
          FlushCurrentLine;
          currentLine := 'SELECT';
          inSelectList := True;
          // collect select columns until FROM (or other break keyword)
          Inc(i);
          // gather columns respecting commas
          colBuffer.Clear;
          while i < Length(tokens) do
          begin
            tok := tokens[i];
            // stop when next major break
            if IsBreakKeyword(tok) and (not SameText(tok, ',')) then
              Break;

            // comma handling
            if IsComma(tok) then
            begin
              // end current column token
              if colBuffer.Count > 0 then
              begin
                // assemble column
                currentLine := currentLine + ' ' + Trim(colBuffer.Text).Replace(sLineBreak, ' ');
                // move currentLine to out (first column appended to SELECT line)
                // For style A we want first column on same line? In DOPO first column is on same line as SELECT, subsequent on next lines
                if outLines.Count = 0 then
                begin
                  // this was the first SELECT line; keep currentLine as SELECT <col> and then for next columns add new lines
                  AddLine(currentLine);
                end;
                // prepare for subsequent columns
                if colBuffer.Count > 0 then
                begin
                  // subsequent columns -> put each on a new line with indentation '  '
                  // but we will handle below in a simpler way: add each column as its own line
                end;
                // Add column line
                // For first column we already added above; try to ensure proper behavior:
                // We'll add the column as its own line with indentation
                // But to match DOPO: first column on same line as SELECT, others on new lines.
                // Detect if outLines already contains the initial SELECT line; if it does and the last added line starts with 'SELECT' then the first column is already on that line.
                // Simpler: reformat by storing each column to a list and then emission after loop.
              end;
              // reset
              colBuffer.Clear;
              Inc(i);
              Continue;
            end
            else if IsBreakKeyword(tok) then
            begin
              // break out: don't consume this token yet
              Break;
            end
            else
            begin
              // append token part to current column buffer
              colBuffer.Add(tok + ' ');
              Inc(i);
              Continue;
            end;
          end;

          // After gathering all columns (colBuffer may have last column)
          // We'll rebuild SELECT block cleanly:
          // Re-parse from where we started collecting to i-1 to create column list
          // Simpler approach: re-tokenize select-list portion by scanning tokens between the original SELECT and before next BreakKeyword
          // Implement simpler: walk backwards from current position to find previous 'SELECT' index and collect tokens between indexes.
          // To avoid excessive complexity, fallback: create a small pass collecting tokens from the original tokens array.
          // We'll implement a clearer collection above by re-scanning:

          // Re-scan to build column list
          // find start index (we are already at index i where token is break or end), so find j the token index after 'SELECT' occurrence
          var j, startIdx: Integer;
          startIdx := 0;
          // find the last 'SELECT' in outLines? Simpler: scan tokens backward to find previous 'SELECT' token index.
          j := i - 1;
          while j >= 0 do
          begin
            if SameText(tokens[j], 'SELECT') then
            begin
              startIdx := j + 1;
              Break;
            end;
            Dec(j);
          end;

          // Collect columns between startIdx .. i-1
          var colTokens: TList<string>;
          colTokens := TList<string>.Create;
          try
            var k: Integer;
            var tempBuf: TStringBuilder;
            tempBuf := TStringBuilder.Create;
            try
              for k := startIdx to i - 1 do
              begin
                if tokens[k] = ',' then
                begin
                  colTokens.Add(Trim(tempBuf.ToString));
                  tempBuf.Clear;
                end
                else
                begin
                  if tempBuf.Length > 0 then
                    tempBuf.Append(' ');
                  tempBuf.Append(tokens[k]);
                end;
              end;
              if tempBuf.Length > 0 then
                colTokens.Add(Trim(tempBuf.ToString));
            finally
              tempBuf.Free;
            end;

            // Emit SELECT and columns per style A:
            // First column stays on same line as SELECT (if exists), others on new lines with two spaces indent.
            if colTokens.Count > 0 then
            begin
              // emit SELECT line with first column
              currentLine := 'SELECT ' + colTokens[0];
              AddLine(currentLine);
              // subsequent columns
              for k := 1 to colTokens.Count - 1 do
              begin
                AddLine('  ' + colTokens[k]);
              end;
            end
            else
            begin
              // fallback
              AddLine('SELECT');
            end;
          finally
            colTokens.Free;
          end;

          // leave i as is (already points to next break keyword like FROM)
          Continue;
        end
        else
        begin
          // General break keyword: push currentLine and start new line with keyword
          FlushCurrentLine;
          currentLine := tok;
          // Special-case FROM -> we'll put its table on same line or next depending on tokens; usually put FROM <table> on same line in style A
          if SameText(tok, 'FROM') then
          begin
            // consume following tokens until next break keyword, put them on same line(s)
            Inc(i);
            // collect from tokens[i] until next break keyword
            var buf := TStringBuilder.Create;
            try
              while i < Length(tokens) do
              begin
                if IsBreakKeyword(tokens[i]) then Break;
                if tokens[i] = ',' then
                  buf.Append(',')
                else
                begin
                  if buf.Length > 0 then buf.Append(' ');
                  buf.Append(tokens[i]);
                end;
                Inc(i);
              end;
              // put FROM line
              AddLine('FROM ' + Trim(buf.ToString));
            finally
              buf.Free;
            end;
            Continue;
          end
          else if SameText(tok, 'WHERE') then
          begin
            // we'll put WHERE on its own line and then indent conditions
            AddLine('WHERE');
            Inc(i);
            // consume tokens until next break keyword
            var condBuf := TStringBuilder.Create;
            var condTokens: TList<string>;
            condTokens := TList<string>.Create;
            try
              while i < Length(tokens) do
              begin
                if IsBreakKeyword(tokens[i]) then Break;
                condTokens.Add(tokens[i]);
                Inc(i);
              end;
              // build condition lines splitting by AND/OR
              var tt: Integer := 0;
              var condLine: TStringBuilder := TStringBuilder.Create;
              try
                while tt < condTokens.Count do
                begin
                  var ct := condTokens[tt];
                  if SameText(ct, 'and') or SameText(ct, 'or') or SameText(ct, 'AND') or SameText(ct, 'OR') then
                  begin
                    // finish previous line
                    if condLine.Length > 0 then
                    begin
                      AddLine('  ' + condLine.ToString);
                      condLine.Clear;
                    end;
                    // add AND / OR at start of new line
                    AddLine('  ' + UpperCase(ct) );
                  end
                  else
                  begin
                    if condLine.Length > 0 then
                      condLine.Append(' ');
                    condLine.Append(ct);
                  end;
                  Inc(tt);
                end;
                if condLine.Length > 0 then
                  AddLine('  ' + condLine.ToString);
              finally
                condLine.Free;
              end;
            finally
              condTokens.Free;
              condBuf.Free;
            end;
            Continue;
          end
          else if SameText(tok, 'ORDER BY') or SameText(tok, 'GROUP BY') then
          begin
            // collect everything until next break; put ORDER / GROUP on own line then "  BY list"
            AddLine(tok);
            Inc(i);
            var listBuf := TStringBuilder.Create;
            try
              while i < Length(tokens) do
              begin
                if IsBreakKeyword(tokens[i]) then Break;
                if tokens[i] = ',' then
                  listBuf.Append(',')
                else
                begin
                  if listBuf.Length > 0 then listBuf.Append(' ');
                  listBuf.Append(tokens[i]);
                end;
                Inc(i);
              end;
              // put the by-list on the next line with two spaces indent
              AddLine('  ' + Trim(listBuf.ToString));
            finally
              listBuf.Free;
            end;
            Continue;
          end
          else if SameText(tok, 'ON') then
          begin
            // ON conditions: put newline and indent
            AddLine('  ON');
            Inc(i);
            var onBuf := TStringBuilder.Create;
            var onTokens: TList<string>;
            onTokens := TList<string>.Create;
            try
              while i < Length(tokens) do
              begin
                // stop at next JOIN/WHERE/ORDER BY/GROUP BY etc.
                if IsBreakKeyword(tokens[i]) then Break;
                onTokens.Add(tokens[i]);
                Inc(i);
              end;
              // assemble ON line(s). Split by AND/OR similar to WHERE
              var p := 0;
              var lineB := TStringBuilder.Create;
              try
                while p < onTokens.Count do
                begin
                  var ot := onTokens[p];
                  if SameText(ot, 'and') or SameText(ot, 'or') then
                  begin
                    if lineB.Length > 0 then
                    begin
                      AddLine('    ' + lineB.ToString);
                      lineB.Clear;
                    end;
                    AddLine('    ' + UpperCase(ot));
                  end
                  else
                  begin
                    if lineB.Length > 0 then
                      lineB.Append(' ');
                    lineB.Append(ot);
                  end;
                  Inc(p);
                end;
                if lineB.Length > 0 then
                  AddLine('    ' + lineB.ToString);
              finally
                lineB.Free;
              end;
            finally
              onTokens.Free;
              onBuf.Free;
            end;
            Continue;
          end
          else
          begin
            // generic break keyword: just output keyword on its own line
            AddLine(tok);
            Inc(i);
            Continue;
          end;
        end;
      end
      else
      begin
        // non-break token: could be JOIN table, JOIN keyword handled above, so here we parse typical constructs
        // Detect JOIN patterns: if token contains JOIN as part of token (e.g. 'LEFT JOIN' we handled earlier)
        if SameText(tok, 'LEFT JOIN') or SameText(tok, 'LEFT OUTER JOIN') or
           SameText(tok, 'INNER JOIN') or SameText(tok, 'RIGHT JOIN') or
           SameText(tok, 'FULL JOIN') or SameText(tok, 'CROSS JOIN') or
           SameText(tok, 'JOIN') or SameText(tok, 'LEFT JOIN') then
        begin
          // Emit JOIN on its own line
          AddLine(tok);
          Inc(i);
          // consume following tokens until ON (keep the join target on same line)
          var joinBuf := TStringBuilder.Create;
          try
            while i < Length(tokens) do
            begin
              if SameText(tokens[i], 'ON') then Break;
              if joinBuf.Length > 0 then joinBuf.Append(' ');
              joinBuf.Append(tokens[i]);
              Inc(i);
            end;
            // append join table line
            if joinBuf.Length > 0 then
              AddLine('  ' + joinBuf.ToString);
          finally
            joinBuf.Free;
          end;
          // next token might be ON, let main loop handle it
          Continue;
        end
        else
        begin
          // If we reach here, we have stray tokens (e.g. table names not preceded by FROM because some were handled differently)
          if Trim(tok) <> '' then
          begin
            // append to current line or produce a line
            if currentLine = '' then
              currentLine := tok
            else
              currentLine := currentLine + ' ' + tok;
          end;
          Inc(i);
        end;
      end;
    end; // while tokens

    // flush leftovers
    FlushCurrentLine;

    // Post-process: uppercase main keywords and fix spacing around commas and operators
    for i := 0 to outLines.Count - 1 do
    begin
      var s := outLines[i];
      // replace multiple spaces with single where appropriate
      s := TrimAndCollapseSpaces(s);
      // Ensure keywords like SELECT, FROM, WHERE are uppercase if present at line start
      for var k in BreakKeywords do
      begin
        if StartsText(LowerCase(k), LowerCase(s)) then
        begin
          // replace only the initial occurrence preserving remainder
          var rest := Trim(Copy(s, Length(k) + 1, MaxInt));
          s := k;
          if rest <> '' then
            s := s + ' ' + rest;
          Break;
        end;
      end;
      // fix commas: make sure commas stay attached to previous token (but style A wants commas at end of column lines? original DOPO had commas at end of lines)
      // We'll keep commas attached to previous token by removing space before comma and keeping comma
      s := StringReplace(s, ' ,', ',', [rfReplaceAll]);
      outLines[i] := s;
    end;

    // Rebuild final result
    Result := outLines.Text;

    // Final cleanup: ensure each line ends properly, remove trailing spaces
    var finalLines := TStringList.Create;
    try
      finalLines.Text := Result;
      for i := 0 to finalLines.Count - 1 do
        finalLines[i] := TrimRight(finalLines[i]);
      Result := finalLines.Text;
    finally
      finalLines.Free;
    end;

    // Replace some patterns to match style of sample: put AS alignment style minimal
    // Also ensure COUNT(1)OVER() becomes COUNT(1) OVER() spacing
    Result := StringReplace(Result, ')OVER(', ') OVER(', [rfReplaceAll, rfIgnoreCase]);

  finally
    outLines.Free;
    colBuffer.Free;
  end;
end;

end.



(*
interface

function PrettyPrintSQL(const SQL: string): string;

implementation

uses
  System.SysUtils, System.Classes, System.StrUtils;

const
  BreakKeywords: array[0..14] of string = (
    'SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'HAVING',
    'INNER JOIN', 'LEFT JOIN', 'LEFT OUTER JOIN', 'RIGHT JOIN', 'FULL JOIN',
    'JOIN', 'OUTER APPLY', 'CROSS APPLY', 'CROSS JOIN'
  );

function NormalizeSpaces(const S: string): string;
begin
  Result := Trim(StringReplace(S, #13#10, ' ', [rfReplaceAll]));
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
end;

function PrettyPrintSQL(const SQL: string): string;
var
  Tmp: string;
  Line: string;
  I: Integer;
  SL: TStringList;
  K: string;
begin
  Tmp := SQL;
  Tmp := NormalizeSpaces(Tmp);
  Tmp := StringReplace(Tmp, ',', ',#BRK#', [rfReplaceAll]); // spezza colonne SELECT

  // Inserisce line break prima delle keywords
  for K in BreakKeywords do
    Tmp := StringReplace(Tmp, K, '#BRK#' + K, [rfReplaceAll, rfIgnoreCase]);

  // Rimuove duplicazioni BRK
  while Pos('#BRK##BRK#', Tmp) > 0 do
    Tmp := StringReplace(Tmp, '#BRK##BRK#', '#BRK#', [rfReplaceAll]);

  SL := TStringList.Create;
  try
    SL.Text := StringReplace(Tmp, '#BRK#', sLineBreak, [rfReplaceAll]);

    // pulizia righe
    for I := SL.Count - 1 downto 0 do
    begin
      Line := Trim(SL[I]);
      if Line = '' then
        SL.Delete(I)
      else
        SL[I] := Line;
    end;

    // indentazione semplice
    for I := 0 to SL.Count - 1 do
    begin
      if StartsText('SELECT', SL[I]) then SL[I] := SL[I]
      else if StartsText('FROM', SL[I]) then SL[I] := SL[I]
      else if StartsText('WHERE', SL[I]) then SL[I] := SL[I]
      else if StartsText('ORDER BY', SL[I]) then SL[I] := SL[I]
      else if StartsText('GROUP BY', SL[I]) then SL[I] := SL[I]
      else if ContainsText(SL[I], 'JOIN') then SL[I] := SL[I]
      else
        SL[I] := '  ' + SL[I]; // indent normale
    end;

    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

end.


(*
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
    JoinKeywords := TArray<string>.Create('JOIN', 'INNER', 'LEFT', 'RIGHT', 'FULL', 'CROSS', 'OUTER');
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
        begin
          //Output.Append(sLineBreak + Indent);
        end;
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
    'UNION', 'INTERSECT', 'EXCEPT', 'INTO', 'VALUES', 'SET'
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
*)
