object frmConfigWizard: TfrmConfigWizard
  Left = 0
  Top = 0
  Caption = 'Wizard Configurazione Build'
  ClientHeight = 500
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    700
    500)
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 684
    Height = 444
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object PageControl: TPageControl
      Left = 0
      Top = 0
      Width = 684
      Height = 444
      ActivePage = tabGeneral
      Align = alClient
      TabOrder = 0
      OnChange = PageControlChange
      object tabGeneral: TTabSheet
        Caption = '1. Informazioni Generali'
        object lblName: TLabel
          Left = 16
          Top = 16
          Width = 31
          Height = 13
          Caption = 'Nome:'
        end
        object lblDescription: TLabel
          Left = 16
          Top = 64
          Width = 58
          Height = 13
          Caption = 'Descrizione:'
        end
        object lblShortcut: TLabel
          Left = 16
          Top = 160
          Width = 56
          Height = 13
          Caption = 'Scorciatoia:'
        end
        object lblCategory: TLabel
          Left = 16
          Top = 208
          Width = 51
          Height = 13
          Caption = 'Categoria:'
        end
        object lblIcon: TLabel
          Left = 16
          Top = 256
          Width = 31
          Height = 13
          Caption = 'Icona:'
        end
        object edtName: TEdit
          Left = 16
          Top = 32
          Width = 300
          Height = 21
          TabOrder = 0
          OnChange = edtNameChange
        end
        object memoDescription: TMemo
          Left = 16
          Top = 80
          Width = 400
          Height = 65
          TabOrder = 1
        end
        object edtShortcut: TEdit
          Left = 16
          Top = 176
          Width = 50
          Height = 21
          MaxLength = 1
          TabOrder = 2
        end
        object cbCategory: TComboBox
          Left = 16
          Top = 224
          Width = 150
          Height = 21
          Style = csDropDownList
          TabOrder = 3
        end
        object cbIcon: TComboBox
          Left = 16
          Top = 272
          Width = 150
          Height = 21
          Style = csDropDownList
          TabOrder = 4
        end
        object chkEnabled: TCheckBox
          Left = 16
          Top = 320
          Width = 97
          Height = 17
          Caption = 'Abilitata'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
      end
      object tabProjects: TTabSheet
        Caption = '2. Progetti'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lblProjects: TLabel
          Left = 16
          Top = 16
          Width = 42
          Height = 13
          Caption = 'Progetti:'
        end
        object lvProjects: TListView
          Left = 16
          Top = 32
          Width = 500
          Height = 250
          Columns = <>
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = lvProjectsDblClick
        end
        object pnlProjectButtons: TPanel
          Left = 530
          Top = 32
          Width = 120
          Height = 250
          BevelOuter = bvNone
          TabOrder = 1
          object btnAddProject: TButton
            Left = 8
            Top = 8
            Width = 100
            Height = 25
            Caption = 'Aggiungi'
            TabOrder = 0
            OnClick = btnAddProjectClick
          end
          object btnEditProject: TButton
            Left = 8
            Top = 40
            Width = 100
            Height = 25
            Caption = 'Modifica'
            TabOrder = 1
            OnClick = btnEditProjectClick
          end
          object btnRemoveProject: TButton
            Left = 8
            Top = 72
            Width = 100
            Height = 25
            Caption = 'Rimuovi'
            TabOrder = 2
            OnClick = btnRemoveProjectClick
          end
          object btnMoveUp: TButton
            Left = 8
            Top = 120
            Width = 100
            Height = 25
            Caption = 'Sposta Su'
            TabOrder = 3
            OnClick = btnMoveUpClick
          end
          object btnMoveDown: TButton
            Left = 8
            Top = 152
            Width = 100
            Height = 25
            Caption = 'Sposta Gi'#249
            TabOrder = 4
            OnClick = btnMoveDownClick
          end
        end
        object pnlProjectEdit: TPanel
          Left = 16
          Top = 300
          Width = 634
          Height = 100
          BevelOuter = bvLowered
          TabOrder = 2
          Visible = False
          object lblProjectPath: TLabel
            Left = 8
            Top = 8
            Width = 91
            Height = 13
            Caption = 'Percorso Progetto:'
          end
          object lblTargets: TLabel
            Left = 8
            Top = 56
            Width = 41
            Height = 13
            Caption = 'Targets:'
          end
          object lblProjectDescription: TLabel
            Left = 200
            Top = 56
            Width = 58
            Height = 13
            Caption = 'Descrizione:'
          end
          object edtProjectPath: TEdit
            Left = 8
            Top = 24
            Width = 400
            Height = 21
            TabOrder = 0
          end
          object btnBrowseProject: TButton
            Left = 416
            Top = 24
            Width = 75
            Height = 21
            Caption = 'Sfoglia...'
            TabOrder = 1
            OnClick = btnBrowseProjectClick
          end
          object cbTargets: TComboBox
            Left = 8
            Top = 72
            Width = 150
            Height = 21
            TabOrder = 2
            Items.Strings = (
              'Build'
              'Clean;Build'
              'Make'
              'Rebuild')
          end
          object edtProjectDescription: TEdit
            Left = 200
            Top = 72
            Width = 200
            Height = 21
            TabOrder = 3
          end
          object btnSaveProject: TButton
            Left = 500
            Top = 24
            Width = 60
            Height = 25
            Caption = 'Salva'
            TabOrder = 4
            OnClick = btnSaveProjectClick
          end
          object btnCancelProject: TButton
            Left = 500
            Top = 56
            Width = 60
            Height = 25
            Caption = 'Annulla'
            TabOrder = 5
            OnClick = btnCancelProjectClick
          end
        end
      end
      object tabOptions: TTabSheet
        Caption = '3. Opzioni'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lblConfiguration: TLabel
          Left = 16
          Top = 16
          Width = 76
          Height = 13
          Caption = 'Configurazione:'
        end
        object cbConfiguration: TComboBox
          Left = 16
          Top = 32
          Width = 150
          Height = 21
          Style = csDropDownList
          TabOrder = 0
        end
        object chkVerbose: TCheckBox
          Left = 16
          Top = 80
          Width = 97
          Height = 17
          Caption = 'Verbose Output'
          TabOrder = 1
        end
        object chkCleanFirst: TCheckBox
          Left = 16
          Top = 112
          Width = 97
          Height = 17
          Caption = 'Clean First'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object chkShowOutput: TCheckBox
          Left = 16
          Top = 144
          Width = 137
          Height = 17
          Caption = 'Show Compiler Output'
          TabOrder = 3
        end
      end
    end
  end
  object pnlButtons: TPanel
    Left = 8
    Top = 460
    Width = 684
    Height = 32
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 440
      Top = 4
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      Enabled = False
      ModalResult = 1
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 528
      Top = 4
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Annulla'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnNext: TButton
      Left = 352
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Avanti >'
      TabOrder = 2
      OnClick = btnNextClick
    end
    object btnPrevious: TButton
      Left = 264
      Top = 4
      Width = 75
      Height = 25
      Caption = '< Indietro'
      Enabled = False
      TabOrder = 3
      OnClick = btnPreviousClick
    end
  end
  object OpenDialog: TOpenDialog
    Left = 640
    Top = 16
  end
end
