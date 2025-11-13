object FIniConfig: TFIniConfig
  Left = 0
  Top = 0
  Caption = 'App BOS Service Ini Config'
  ClientHeight = 288
  ClientWidth = 726
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pFondo: TPanel
    Left = 0
    Top = 0
    Width = 726
    Height = 288
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 0
    object Label4: TLabel
      Left = 319
      Top = 10
      Width = 68
      Height = 13
      Caption = 'Active Server '
    end
    object ListView1: TListView
      Left = 317
      Top = 38
      Width = 404
      Height = 205
      Columns = <
        item
          Caption = 'System ID'
          Width = 64
        end
        item
          Caption = 'DataBase'
          Width = 230
        end
        item
          Caption = 'Version'
          Width = 75
        end>
      DoubleBuffered = True
      RowSelect = True
      ParentDoubleBuffered = False
      TabOrder = 0
      ViewStyle = vsReport
      OnSelectItem = ListView1SelectItem
    end
    object GroupBox2: TGroupBox
      Left = 6
      Top = 123
      Width = 304
      Height = 121
      Caption = 'New Configuration'
      Color = 12112051
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentColor = False
      ParentFont = False
      TabOrder = 1
      object Label5: TLabel
        Left = 8
        Top = 25
        Width = 32
        Height = 13
        Caption = 'Server'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 8
        Top = 57
        Width = 49
        Height = 13
        Caption = 'System ID'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label7: TLabel
        Left = 8
        Top = 89
        Width = 46
        Height = 13
        Caption = 'DataBase'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object eNewDB: TEdit
        Left = 72
        Top = 86
        Width = 225
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
      object eNewServer: TEdit
        Left = 72
        Top = 22
        Width = 225
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
      end
      object eNewSysID: TEdit
        Left = 72
        Top = 54
        Width = 73
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 2
      end
    end
    object BtnReload: TcxButton
      Left = 695
      Top = 5
      Width = 26
      Height = 26
      OptionsImage.Glyph.SourceDPI = 96
      OptionsImage.Glyph.Data = {
        89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
        610000002B744558745469746C650053657475703B437573746F6D697A3B4465
        7369676E3B53657474696E673B50726F70657274381FB5210000033849444154
        785E7D937D4C535718C69F7B7B4AE52355971095599D2B3A0264A6219A85AA03
        679832C3A21665A2F891CD124704D9206340746B46623019C6A82C565315043F
        96383F83124D86D3B9580BCC39C0E98A6C4080B60B850BB7F79E7BBC6D5AFE5A
        78935FCE93933CEF7DCFCDF3629AE25478154D484F57D5872FA3B2F6D29429C8
        17DF380ACA6BCEB3325B23DB576DDF116E14812BAEB6E3F38A93200060FBD2C2
        590ACAE2CABF6BBCAA50DAEF1919A8A18C59766C30833106FBF93B96DC5D158F
        E3E72CA800C7199F3C6CC93E62FBF43F6BF971C647C65D98987A65775E46C696
        9CF4ADC6C4C44EC6F0D192450930BC190F4561D9C9C9A91DF99B32F2ADDBD7BE
        976A7AFF27004412259048834040F2F8C72690B4643E9216CFE7BD3E3F348487
        2228282C58CB2F5E34175461B8FBB30B7DAF7ABD002049D2D4CFD1E4EEFA3A25
        39E55D5769610E2F49140A63E0390E924C43CF5025C40045D5B7F5CAD3F6472B
        DA1F5D730290B8A0796751ED368D56BB9968C8BAAAD23C4E1B45F0C7B3976868
        BA054234D8BE351B06430286863DA83BFEA332210AADA22034FFD97EAF890020
        4437C3B1273F4B1DDD0042087CFE71D41D6B46FF3FEECD248A7027CFE2C2A183
        56F01A82BD9F6DE4BD5E5FD6E973B7B2DC7FB92E11009C1C0884DEE71F9F84A4
        5050CA10131B0DDD0C5DB4362A4AD5B1102519E38208AA500C794621CB0104BD
        3C00F9E5F3AEA2AF0ED4B5EEAF3CC10607BD989C10B1735B0E92524D67826C5C
        BF1263C2243CBE51D86C2760B737B4F5B9BB4B010422E1D1A5993F5EBEA7E47B
        F9EFBE21F6C0D9C3DA1E77B1DFBBFB588F7B80B53FEB652D6D9DEC5AAB93ADB3
        942886B7D33201C4A8F0040053417C82B12C739549234C8AA1AF8D8CF830365B
        1FCC008646BC9839531F0AD5F2654BB9DE172FF603CEBC7796AE57A672C02816
        44C7EA70F3F62F68BD7D1F94D3B2A2BD9F700149467D7D239BA58F41DA3213A7
        D7C781CA745ED023530991244A1DBFDDD870E468C3AF0E47F3F5A71DF7B32684
        D1078303C370BBFF85E0F73DEC74B6655F6EBA78F5D40F0E57FF2BD71600A242
        2942B53AA718E1258909136B4ACF2D367F58C8CC6BACCC98F2410980B8E07DF8
        D4AA706F25AD997695A355DE0812D63CFEA75E03CFF56ADF743CC88500000000
        49454E44AE426082}
      TabOrder = 2
      OnClick = BtnReloadClick
    end
    object eActiveServer: TEdit
      Left = 399
      Top = 7
      Width = 290
      Height = 21
      TabOrder = 3
    end
    object gbConfig: TGroupBox
      Left = 5
      Top = 2
      Width = 305
      Height = 121
      Margins.Left = 6
      Caption = 'Current Configuration'
      Color = 8421631
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentColor = False
      ParentFont = False
      TabOrder = 4
      object Label1: TLabel
        Left = 8
        Top = 25
        Width = 32
        Height = 13
        Caption = 'Server'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 8
        Top = 57
        Width = 49
        Height = 13
        Caption = 'System ID'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 8
        Top = 89
        Width = 46
        Height = 13
        Caption = 'DataBase'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object eDB: TEdit
        Left = 72
        Top = 86
        Width = 225
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
      object eServer: TEdit
        Left = 72
        Top = 22
        Width = 225
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 1
      end
      object eSysID: TEdit
        Left = 72
        Top = 54
        Width = 73
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 2
      end
    end
    object Panel1: TPanel
      Left = 2
      Top = 245
      Width = 722
      Height = 41
      Align = alBottom
      BevelInner = bvLowered
      TabOrder = 5
      object btnSaveConfig: TcxButton
        Left = 8
        Top = 8
        Width = 166
        Height = 25
        Caption = 'Save INI Config'
        OptionsImage.Glyph.SourceDPI = 96
        OptionsImage.Glyph.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          610000000B744558745469746C6500536176653BF9E8F9090000004849444154
          785EDDD0C10900200885E1D66C1BAFCDD2146FB15E10782A4A940E25FC1E3FC4
          4432D45825577A9A00E39C0100CB747EBD200ED8BB0C3472971950F021401C4F
          140542756780187A6CE7455E0000000049454E44AE426082}
        TabOrder = 0
        OnClick = btnSaveConfigClick
      end
      object btClose: TcxButton
        Left = 553
        Top = 8
        Width = 166
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
        TabOrder = 1
        OnClick = btCloseClick
      end
    end
  end
end
