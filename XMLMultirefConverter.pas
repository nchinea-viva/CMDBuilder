unit XMLMultirefConverter;

interface

uses
  System.SysUtils, System.Classes, Xml.XMLDoc, Xml.XMLIntf,
  System.StrUtils,
  System.Generics.Collections, Vcl.Clipbrd;

type
  TMultirefResolver = class
  private
    FReferences: TDictionary<string, IXMLNode>;
    FProcessedNodes: TList<IXMLNode>;
    FXmlResult: String;
    procedure CollectReferences(Node: IXMLNode);
    procedure ResolveReferences(Node: IXMLNode);
    function GetHrefId(const HrefValue: string): string;
    procedure CloneNodeContent(Source, Dest: IXMLNode);
    procedure RemoveMultiRefNodes(Node: IXMLNode);
  public
    constructor Create;
    destructor Destroy; override;
    function ConvertXML(const InputXML: string; ACopy2Clip: Boolean = False): string;
    Procedure Copy2ClipBoard;
  end;

function ResolveMultiref(const XMLString: string; ACopy2Clip: Boolean = False): string;
function PrettyPrintXML(const XMLString: string): string;

implementation

function ResolveMultiref(const XMLString: string; ACopy2Clip: Boolean = False): string;
var
  Resolver: TMultirefResolver;
begin
  Resolver := TMultirefResolver.Create;
  try
    try
      Result := Resolver.ConvertXML(XMLString, ACopy2Clip);
    except
      Result := XMLString;
    end;
  finally
    Resolver.Free;
  end;
end;

{ TMultirefResolver }

constructor TMultirefResolver.Create;
begin
  inherited;
  FReferences := TDictionary<string, IXMLNode>.Create;
  FProcessedNodes := TList<IXMLNode>.Create;
end;

destructor TMultirefResolver.Destroy;
begin
  FReferences.Free;
  FProcessedNodes.Free;
  inherited;
end;

function TMultirefResolver.ConvertXML(const InputXML: string; ACopy2Clip: Boolean = False): string;
var
  XMLDoc: IXMLDocument;
  OutputStream: TStringStream;
begin
  XMLDoc := TXMLDocument.Create(nil);
  try
    XMLDoc.LoadFromXML(InputXML);
    XMLDoc.Active := True;

    FReferences.Clear;
    FProcessedNodes.Clear;
    CollectReferences(XMLDoc.DocumentElement);

    ResolveReferences(XMLDoc.DocumentElement);

    RemoveMultiRefNodes(XMLDoc.DocumentElement);

    XMLDoc.SaveToXML(Result);

    Result := PrettyPrintXML(Result);
    if ACopy2Clip then
    begin
      FXmlResult := Result;
      Copy2ClipBoard;
    end;
  except
    on E: Exception do
      raise Exception.Create('Errore nella conversione XML: ' + E.Message);
  end;
end;

procedure TMultirefResolver.Copy2ClipBoard;
begin
  Clipboard.Open;
  try
    Clipboard.Clear;
    Clipboard.AsText := FXmlResult;
  finally
    Clipboard.Close;
  end;
end;

function PrettyPrintXML3(const XMLString: string): string;
var
  Input: string;
  Output: TStringBuilder;
  IndentLevel: Integer;
  Pos, TagStart, TagEnd, NextTagStart: Integer;
  Tag, Content, TagName: string;
  IsClosingTag, IsSelfClosing, IsDeclaration, HasOnlyTextContent: Boolean;
begin
  Input := Trim(XMLString);
  Output := TStringBuilder.Create;
  try
    IndentLevel := 0;
    Pos := 1;

    while Pos <= Length(Input) do
    begin
      // Trova il prossimo tag
      TagStart := System.StrUtils.PosEx('<', Input, Pos);

      if TagStart = 0 then
      begin
        // Nessun altro tag, aggiungi il resto
        Content := Trim(Copy(Input, Pos, Length(Input)));
        if Content <> '' then
          Output.Append(Content);
        Break;
      end;

      // Trova la fine del tag
      TagEnd := System.StrUtils.PosEx('>', Input, TagStart);
      if TagEnd = 0 then
        Break;

      // Estrai il tag completo
      Tag := Copy(Input, TagStart, TagEnd - TagStart + 1);

      // Determina il tipo di tag
      IsClosingTag := (Length(Tag) > 2) and (Tag[2] = '/');
      IsSelfClosing := (Length(Tag) > 2) and (Tag[Length(Tag) - 1] = '/');
      IsDeclaration := (Length(Tag) > 2) and (Tag[2] = '?');

      // Verifica se il tag ha solo contenuto testuale (no altri tag figli)
      HasOnlyTextContent := False;
      if not IsClosingTag and not IsSelfClosing and not IsDeclaration then
      begin
        NextTagStart := System.StrUtils.PosEx('<', Input, TagEnd + 1);
        if NextTagStart > 0 then
        begin
          Content := Copy(Input, TagEnd + 1, NextTagStart - TagEnd - 1);
          // Se il prossimo tag è il tag di chiusura corrispondente
          if (NextTagStart > TagEnd) and (Input[NextTagStart + 1] = '/') then
          begin
            HasOnlyTextContent := Trim(Content) <> '';
          end;
        end;
      end;

      // Gestisci indentazione per tag di chiusura
      if IsClosingTag and not HasOnlyTextContent then
      begin
        Dec(IndentLevel);
        if IndentLevel < 0 then
          IndentLevel := 0;
      end;

      // Aggiungi newline e indentazione
      if not HasOnlyTextContent then
      begin
        if (Output.Length > 0) or IsDeclaration then
        begin
          if not IsDeclaration or (Output.Length > 0) then
            Output.Append(sLineBreak);
          Output.Append(StringOfChar(' ', IndentLevel * 2));
        end;
      end;

      // Aggiungi il tag
      Output.Append(Tag);

      // Se ha solo contenuto testuale, aggiungi contenuto e tag di chiusura sulla stessa riga
      if HasOnlyTextContent then
      begin
        Content := Copy(Input, TagEnd + 1, NextTagStart - TagEnd - 1);
        Output.Append(Trim(Content));

        // Trova e aggiungi il tag di chiusura
        TagEnd := System.StrUtils.PosEx('>', Input, NextTagStart);
        if TagEnd > 0 then
        begin
          Tag := Copy(Input, NextTagStart, TagEnd - NextTagStart + 1);
          Output.Append(Tag);
          Pos := TagEnd + 1;
          Continue;
        end;
      end;

      // Aumenta indentazione per tag di apertura (non self-closing)
      if not IsClosingTag and not IsSelfClosing and not IsDeclaration and not HasOnlyTextContent then
        Inc(IndentLevel);

      // Muovi la posizione dopo il tag
      Pos := TagEnd + 1;
    end;

    Result := Output.ToString;
  finally
    Output.Free;
  end;
end;

function PrettyPrintXML(const XMLString: string): string;
var
  XMLDoc: IXMLDocument;
  Output: TStringBuilder;

  procedure ProcessNode(Node: IXMLNode; IndentLevel: Integer);
  var
    I: Integer;
    Indent: string;
    HasChildElements: Boolean;
    TextContent: string;
  begin
    if Node = nil then
      Exit;

    Indent := StringOfChar(' ', IndentLevel * 2);

    // Controlla se ha elementi figli (non solo testo)
    HasChildElements := False;
    for I := 0 to Node.ChildNodes.Count - 1 do
    begin
      if Node.ChildNodes[I].NodeType = ntElement then
      begin
        HasChildElements := True;
        Break;
      end;
    end;

    // Scrivi il tag di apertura
    Output.Append(Indent);
    Output.Append('<');
    Output.Append(Node.NodeName);

    // Aggiungi attributi
    for I := 0 to Node.AttributeNodes.Count - 1 do
    begin
      Output.Append(' ');
      Output.Append(Node.AttributeNodes[I].NodeName);
      Output.Append('="');
      Output.Append(Node.AttributeNodes[I].Text);
      Output.Append('"');
    end;

    // Se il nodo è vuoto o self-closing
    if (Node.ChildNodes.Count = 0) and (Node.IsTextElement = False) then
    begin
      Output.Append('/>');
      Output.Append(sLineBreak);
      Exit;
    end;

    Output.Append('>');

    // Se ha solo contenuto testuale (nessun elemento figlio)
    if not HasChildElements and Node.IsTextElement then
    begin
      TextContent := Trim(Node.Text);
      Output.Append(TextContent);
      Output.Append('</');
      Output.Append(Node.NodeName);
      Output.Append('>');
      Output.Append(sLineBreak);
    end
    else
    begin
      // Ha elementi figli, vai a capo
      Output.Append(sLineBreak);

      // Processa tutti i figli
      for I := 0 to Node.ChildNodes.Count - 1 do
      begin
        if Node.ChildNodes[I].NodeType = ntElement then
          ProcessNode(Node.ChildNodes[I], IndentLevel + 1);
      end;

      // Tag di chiusura con indentazione
      Output.Append(Indent);
      Output.Append('</');
      Output.Append(Node.NodeName);
      Output.Append('>');
      Output.Append(sLineBreak);
    end;
  end;

begin
  XMLDoc := TXMLDocument.Create(nil);
  Output := TStringBuilder.Create;
  try
    XMLDoc.LoadFromXML(XMLString);
    XMLDoc.Active := True;

    // Aggiungi dichiarazione XML
    Output.Append('<?xml version="1.0" encoding="UTF-8"?>');
    Output.Append(sLineBreak);

    // Processa il documento
    ProcessNode(XMLDoc.DocumentElement, 0);

    Result := Output.ToString;
  finally
    Output.Free;
  end;
end;

function PrettyPrintXML4(const XMLString: string): string;
var
  Input: string;
  Output: TStringBuilder;
  IndentLevel: Integer;
  Pos, TagStart, TagEnd: Integer;
  Tag, Content: string;
  IsClosingTag, IsSelfClosing, IsDeclaration: Boolean;
begin
  Input := Trim(XMLString);
  Output := TStringBuilder.Create;
  try
    IndentLevel := 0;
    Pos := 1;

    while Pos <= Length(Input) do
    begin
      // Trova il prossimo tag
      TagStart := PosEx('<', Input, Pos);

      if TagStart = 0 then
      begin
        // Nessun altro tag, aggiungi il resto
        Content := Trim(Copy(Input, Pos, Length(Input)));
        if Content <> '' then
          Output.Append(Content);
        Break;
      end;

      // Aggiungi eventuale contenuto di testo prima del tag
      if TagStart > Pos then
      begin
        Content := Trim(Copy(Input, Pos, TagStart - Pos));
        if Content <> '' then
          Output.Append(Content);
      end;

      // Trova la fine del tag
      TagEnd := PosEx('>', Input, TagStart);
      if TagEnd = 0 then
        Break;

      // Estrai il tag completo
      Tag := Copy(Input, TagStart, TagEnd - TagStart + 1);

      // Determina il tipo di tag
      IsClosingTag := (Length(Tag) > 2) and (Tag[2] = '/');
      IsSelfClosing := (Length(Tag) > 2) and (Tag[Length(Tag) - 1] = '/');
      IsDeclaration := (Length(Tag) > 2) and (Tag[2] = '?');

      // Gestisci indentazione
      if IsClosingTag then
      begin
        Dec(IndentLevel);
        if IndentLevel < 0 then
          IndentLevel := 0;
      end;
      Content := Trim(Content);
      // Aggiungi newline e indentazione (eccetto per la dichiarazione XML)
      if (Output.Length > 0) or IsDeclaration then
      begin
        if (not IsDeclaration or (Output.Length > 0)) and (Content<>'') then
          Output.Append(sLineBreak);
        Output.Append(StringOfChar(' ', IndentLevel * 2));
      end;
      Content := '';
      // Aggiungi il tag
      Output.Append(Tag);

      // Aumenta indentazione per tag di apertura (non self-closing)
      if not IsClosingTag and not IsSelfClosing and not IsDeclaration then
        Inc(IndentLevel);

      // Muovi la posizione dopo il tag
      Pos := TagEnd + 1;
    end;

    Result := Output.ToString;
  finally
    Output.Free;
  end;
end;


function PrettyPrintXML2(const XMLString: string): string;
var
  Input: string;
  Output: TStringBuilder;
  I, IndentLevel: Integer;
  InTag, InClosingTag, InAttribute: Boolean;
  C, NextC: Char;
  Indent: string;
begin
  Input := Trim(XMLString);
  Output := TStringBuilder.Create;
  try
    IndentLevel := 0;
    InTag := False;
    InClosingTag := False;
    InAttribute := False;

    I := 1;
    while I <= Length(Input) do
    begin
      C := Input[I];

      if I < Length(Input) then
        NextC := Input[I + 1]
      else
        NextC := #0;

      case C of
        '<':
          begin
            // Inizio tag
            InTag := True;

            // Se è un tag di chiusura
            if NextC = '/' then
            begin
              InClosingTag := True;
              Dec(IndentLevel);
              if IndentLevel < 0 then
                IndentLevel := 0;
            end;

            // Aggiungi indentazione
            if (Output.Length > 0) and not (NextC = '/') then
            begin
              Indent := #10 + StringOfChar(' ', IndentLevel * 2);
              Output.Append(Indent);
            end;

            Output.Append(C);
          end;

        '>':
          begin
            Output.Append(C);
            // Se non è un tag self-closing o commento o dichiarazione XML
            if not InClosingTag and
               (I > 1) and
               (Input[I - 1] <> '/') and
               (Input[I - 1] <> '?') and
               (I < Length(Input)) and
               (NextC <> '<') then
            begin
              // Controlla se il contenuto dopo > è solo testo
              // Se il prossimo carattere non è <, è contenuto di testo
              Inc(IndentLevel);
            end
            else if not InClosingTag and
                    (I > 1) and
                    (Input[I - 1] <> '/') and
                    (Input[I - 1] <> '?') then
            begin
              Inc(IndentLevel);
            end;

            InTag := False;
            InClosingTag := False;
          end;

        '"':
          begin
            Output.Append(C);
            if InTag then
              InAttribute := not InAttribute;
          end;

        ' ', #9, #10, #13:
          begin
            // Preserva spazi dentro attributi o contenuto di testo
            if InTag or InAttribute then
              Output.Append(C)
            else if (I > 1) and not (Input[I - 1] in ['>', '<']) then
              Output.Append(C);
          end;

        else
          Output.Append(C);
      end;

      Inc(I);
    end;

    Result := Output.ToString;
  finally
    Output.Free;
  end;
end;

procedure TMultirefResolver.CollectReferences(Node: IXMLNode);
var
  I: Integer;
  IdAttr: IXMLNode;
  RefId: string;
begin
  if Node = nil then
    Exit;

  // Cercare nodi multiRef con attributo id
  if SameText(Node.LocalName, 'multiRef') then
  begin
    IdAttr := Node.AttributeNodes.FindNode('id');
    if IdAttr <> nil then
    begin
      RefId := IdAttr.Text;
      if not FReferences.ContainsKey(RefId) then
        FReferences.Add(RefId, Node);
    end;
  end;

  // Ricorsione sui figli
  for I := 0 to Node.ChildNodes.Count - 1 do
    CollectReferences(Node.ChildNodes[I]);
end;

procedure TMultirefResolver.ResolveReferences(Node: IXMLNode);
var
  I: Integer;
  HrefAttr: IXMLNode;
  HrefId: string;
  RefNode: IXMLNode;
begin
  if Node = nil then
    Exit;

  // Evitare cicli infiniti
  if FProcessedNodes.Contains(Node) then
    Exit;
  FProcessedNodes.Add(Node);

  // Verificare se questo nodo ha un href
  HrefAttr := Node.AttributeNodes.FindNode('href');
  if HrefAttr <> nil then
  begin
    HrefId := GetHrefId(HrefAttr.Text);

    if FReferences.TryGetValue(HrefId, RefNode) then
    begin
      // Prima risolvere eventuali riferimenti nel nodo sorgente
      ResolveReferences(RefNode);

      // Copiare il contenuto del nodo referenziato
      CloneNodeContent(RefNode, Node);

      // Rimuovere l'attributo href
      Node.AttributeNodes.Delete('href');
    end;
  end;

  // Ricorsione sui figli
  for I := 0 to Node.ChildNodes.Count - 1 do
    ResolveReferences(Node.ChildNodes[I]);
end;

function TMultirefResolver.GetHrefId(const HrefValue: string): string;
begin
  Result := HrefValue;
  // Rimuovere il # iniziale se presente
  if (Length(Result) > 0) and (Result[1] = '#') then
    Result := Copy(Result, 2, Length(Result) - 1);
end;

procedure TMultirefResolver.CloneNodeContent(Source, Dest: IXMLNode);
var
  I: Integer;
  AttrNode: IXMLNode;
  ChildNode, NewChild: IXMLNode;
begin
  if Source = nil then
    Exit;

  // Copiare gli attributi (eccetto id, root, encodingStyle)
  for I := 0 to Source.AttributeNodes.Count - 1 do
  begin
    AttrNode := Source.AttributeNodes[I];
    if not (SameText(AttrNode.LocalName, 'id') or
            SameText(AttrNode.LocalName, 'root') or
            SameText(AttrNode.LocalName, 'encodingStyle')) then
    begin
      Dest.Attributes[AttrNode.NodeName] := AttrNode.NodeValue;
    end;
  end;

  // Rimuovere i figli esistenti di Dest (se ce ne sono)
  while Dest.ChildNodes.Count > 0 do
    Dest.ChildNodes.Delete(0);

  // Se il nodo source ha solo testo (nodo semplice)
  if (Source.ChildNodes.Count = 0) and (Source.IsTextElement) then
  begin
    Dest.NodeValue := Source.NodeValue;
  end
  else
  begin
    // Copiare i nodi figli
    for I := 0 to Source.ChildNodes.Count - 1 do
    begin
      ChildNode := Source.ChildNodes[I];

      if ChildNode.NodeType = ntElement then
      begin
        NewChild := Dest.AddChild(ChildNode.NodeName);
        CloneNodeContent(ChildNode, NewChild);
      end
      else if ChildNode.NodeType = ntText then
      begin
        Dest.NodeValue := ChildNode.NodeValue;
      end;
    end;
  end;
end;

procedure TMultirefResolver.RemoveMultiRefNodes(Node: IXMLNode);
var
  I: Integer;
  ChildNode: IXMLNode;
begin
  if Node = nil then
    Exit;

  I := 0;
  while I < Node.ChildNodes.Count do
  begin
    ChildNode := Node.ChildNodes[I];

    // Rimuovere i nodi multiRef
    if SameText(ChildNode.LocalName, 'multiRef') then
      Node.ChildNodes.Delete(I)
    else
    begin
      RemoveMultiRefNodes(ChildNode);
      Inc(I);
    end;
  end;
end;

end.
