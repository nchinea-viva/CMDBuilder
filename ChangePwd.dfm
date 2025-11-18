object FChangePwd: TFChangePwd
  Left = 0
  Top = 0
  Caption = 'Change Password'
  ClientHeight = 231
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 46
    Height = 13
    Caption = 'Database'
  end
  object Label2: TLabel
    Left = 184
    Top = 24
    Width = 22
    Height = 13
    Caption = 'User'
  end
  object Label3: TLabel
    Left = 360
    Top = 24
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object cbDataBase: TComboBox
    Left = 16
    Top = 48
    Width = 145
    Height = 21
    TabOrder = 0
    OnChange = cbDataBaseChange
  end
  object cbUser: TComboBox
    Left = 184
    Top = 48
    Width = 145
    Height = 21
    TabOrder = 1
  end
  object ePwd: TEdit
    Left = 360
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 2
  end
  object btChange: TcxButton
    Left = 288
    Top = 85
    Width = 89
    Height = 25
    Caption = 'Change'
    TabOrder = 3
    OnClick = btChangeClick
  end
  object btClose: TcxButton
    Left = 392
    Top = 85
    Width = 89
    Height = 25
    Caption = 'Close'
    OptionsImage.Glyph.SourceDPI = 96
    OptionsImage.Glyph.Data = {
      89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
      6100000023744558745469746C650043616E63656C3B53746F703B457869743B
      426172733B526962626F6E3B4C9696B20000038849444154785E1D906B4C5367
      18C7FF3DBD40CB1A2E32B55C9D598B4CA675D8D13836652E9B0359B67D589665
      3259E644A52571644474CB4CB6ECC23770C4449DD38D2885005E4683AB69C616
      8DA12384264EC8AAAC0C9149A1175ACEE9E939CFDE9EE7E477F2CBFFB924E720
      E6E943CC3B8895D12B00A0FEE3D08167A75A5BBAEEB71D9D081E6B4DA549FBDD
      A3CEEFDD1F3658016818AA98A71FD1915E202DE980A19D741E3EF6E0F8A7FC7F
      673B6979E002C5BC43B4C2581EB8480BE7BA68E6441BEF3B72F03300990C8E1D
      5016554E7B55D6C1ED9543C6C2B5BB739FDF025988838424E4240F10A0D2EAA0
      D26540AD37203CFE17C2C187A3EDBFDE7CF3DAD4748403A06EA8A8E830AC5FB3
      3B7BAB1901B717AE23DFE1CEC5EBEC90A0E0EB71A3CFD981C0B017C6F252180B
      D6BD74BCFA856E003A0CBDFD966DF250532AD4FF038DB734D18557DF21CFB08F
      2E37B5D370ED5E72D7D52BEEF9654CE9F91C1FD392EB0C4D3A0E4BE7F6ECD909
      CFDEFAD381AF4ED0A3D35FD399E272BA3F3D478F971234FD2044BDCE930AF798
      CF2FAED0DF5373CACCFCA92F2970B29DDCAFD7F56B48945E918201C41738945A
      2D581C7461ADA3192AB50AD64F9A010272730CC8D4AA313BE44289D58CF85D3F
      2411504BB28D93845489145E041F9CC1863C09A11BD7E1EFEA86240339463DB2
      B3F59025C0DFD98DD0C83594E6886C360831F408523265D208BC0021B20A35A7
      82B8BC0429C2239A10D812417988007088B14C8A8421EA75A094044A8A48F200
      17E78587629220B370E69F2884EA3750F07E23245946868E43A64EA3B8695F23
      F8EA7A046763EC780AC9640AF155FEB1269AE0BD91AC8CFDF910108E26F15A5B
      33788D1E860CF6CDE7CF225D45FB3F02A0C7CE36076E5CBD84825C3562A20E4B
      097E0CAD051B5FFCA97C9BE4ABAEA05B2FDBE9E6BE0F880F8568FCDB0E1AA9AA
      646C579C654AEF564D15FDB96333FDBCC94A8E751B6A0140DF5168B9E42A7B86
      266AB6D2ED1A1BF559CAC853B58DFCB576F2D7D9D3AE64B777D96862D716EA2F
      2BA76F4CE62B008C1A00C2F9C57F9D8DA2C99212C5E72C85323699F320A77FD2
      72040021DF9885F56BF2204457706F9EC74C4CF2F744169A012430DBF21E00A8
      2B754F98BEC82EEEED7AF2291A306FA451EBD3346633938FF13BF341969D62BD
      CF738AAF6ED6EA4B006882CE77A14ABFD255D2799903606830E4EF28E274070C
      1C67D74255041044C25C9CE43B4149F8B16735F41B8038DB9300E07F6924ECFB
      01D589CC0000000049454E44AE426082}
    TabOrder = 4
    OnClick = btCloseClick
  end
  object Edit1: TEdit
    Left = 16
    Top = 129
    Width = 465
    Height = 21
    TabOrder = 5
  end
  object Edit2: TEdit
    Left = 16
    Top = 161
    Width = 465
    Height = 21
    TabOrder = 6
  end
  object Edit3: TEdit
    Left = 16
    Top = 193
    Width = 465
    Height = 21
    TabOrder = 7
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'IF EXISTS (SELECT * '
      '                 FROM INFORMATION_SCHEMA.TABLES '
      '                WHERE TABLE_SCHEMA = '#39'dbo'#39' '
      '                  AND TABLE_NAME = '#39'#Results'#39')'
      'begin'
      '  DROP TABLE #Results;'
      'end;'
      
        'CREATE TABLE #Results (SysId INT, DatabaseName NVARCHAR(128),  D' +
        'BVersion NVARCHAR(MAX));'#10
      'DECLARE @sql NVARCHAR(MAX);'#10
      'DECLARE @dbName NVARCHAR(128);'#10
      
        'DECLARE db_cursor CURSOR FOR '#10'SELECT name FROM sys.databases WHE' +
        'RE database_id > 4 AND state = 0;'
      #10'OPEN db_cursor;'#10
      'FETCH NEXT FROM db_cursor INTO @dbName;'
      #10'WHILE @@FETCH_STATUS = 0'
      #10'BEGIN'#10'    '
      
        'SET @sql = '#39'IF OBJECT_ID('#39#39#39' + @dbName + '#39'.dbo.CNF_DBInfo'#39#39') IS ' +
        'NOT NULL'#10'               '
      ' BEGIN'#10'                   '
      ' INSERT INTO #Results'#10'                    '
      
        'SELECT B.SystemId, '#39#39#39' + @dbName + '#39#39#39', A.ParamValue '#10'          ' +
        '         '
      
        ' FROM ['#39' + @dbName + '#39'].[dbo].[CNF_DBInfo] A, ['#39' + @dbName + '#39'].' +
        '[dbo].[CNF_System] B '#10'                    WHERE A.ParamName = '#39#39 +
        'SWVersion'#39#39#10'                END'#39';'
      
        '   '#10'    EXEC sp_executesql @sql;'#10'    FETCH NEXT FROM db_cursor I' +
        'NTO @dbName;'#10#10'END;'#10' '#10'CLOSE db_cursor;'#10'DEALLOCATE db_cursor;'#10'SELE' +
        'CT * FROM #Results order by 1 ;'#10'DROP TABLE #Results;'#10
      ''
      ''
      '')
    Left = 224
    Top = 74
  end
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Server=ITMI1L-DEVBOS11\MSSQLSERVER16'
      'OSAuthent=Yes'
      'Database=master'
      'DriverID=MSSQL')
    Connected = True
    LoginPrompt = False
    Left = 440
    Top = 10
  end
  object FDCommand: TFDCommand
    Connection = FDConnection1
    Left = 152
    Top = 80
  end
end
