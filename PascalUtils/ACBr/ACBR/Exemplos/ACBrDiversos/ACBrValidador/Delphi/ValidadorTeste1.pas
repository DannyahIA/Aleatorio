{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{																			   }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do  Projeto ACBr    }
{ Componentes localizado em      http://www.sourceforge.net/projects/acbr      }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida - daniel@projetoacbr.com.br - www.projetoacbr.com.br}
{       Rua Coronel Aureliano de Camargo, 963 - Tatu� - SP - 18270-170         }
{******************************************************************************}

{$I ACBr.inc}

unit ValidadorTeste1;

interface

uses
  SysUtils,
 {$IFDEF Delphi6_UP} Types, Variants, VarConv, {$ELSE} Windows,{$ENDIF}
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ACBrBase, ACBrValidador;

type
  TfrValidador = class(TForm)
    ACBrValidador1: TACBrValidador;
    edDocto: TEdit;
    Label1: TLabel;
    cbTipoDocto: TComboBox;
    Label2: TLabel;
    mMsgErro: TMemo;
    Label3: TLabel;
    bValidar: TButton;
    Label4: TLabel;
    edComple: TEdit;
    Label5: TLabel;
    cbPermiteVazio: TCheckBox;
    cbAjustarTam: TCheckBox;
    bFormatar: TButton;
    cbException: TCheckBox;
    edIgnorar: TEdit;
    cbExibeDigCorreto: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ACBrValidador1MsgErro(Mensagem: String);
    procedure bValidarClick(Sender: TObject);
    procedure bFormatarClick(Sender: TObject);
    procedure cbPermiteVazioClick(Sender: TObject);
    procedure cbAjustarTamClick(Sender: TObject);
    procedure cbExceptionClick(Sender: TObject);
    procedure cbTipoDoctoChange(Sender: TObject);
    procedure edDoctoChange(Sender: TObject);
    procedure cbExibeDigCorretoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frValidador: TfrValidador;

implementation

uses
  TypInfo;

{$R *.dfm}

procedure TfrValidador.FormCreate(Sender: TObject);
var
  td: TACBrValTipoDocto;
begin
  edIgnorar.Text := ACBrValidador1.IgnorarChar ;
  cbPermiteVazio.Checked := ACBrValidador1.PermiteVazio ;
  cbException.Checked    := ACBrValidador1.RaiseExcept ;
  cbAjustarTam.Checked   := ACBrValidador1.AjustarTamanho ;

  cbTipoDocto.Items.Clear;
  for td := Low(TACBrValTipoDocto) to High(TACBrValTipoDocto) do
    cbTipoDocto.Items.Add(GetEnumName(TypeInfo(TACBrValTipoDocto), Integer(td)));
  cbTipoDocto.ItemIndex  := Integer(ACBrValidador1.TipoDocto) ;
end;

procedure TfrValidador.ACBrValidador1MsgErro(Mensagem: String);
begin
  mMsgErro.Text := ACBrValidador1.MsgErro ;
end;

procedure TfrValidador.bValidarClick(Sender: TObject);
begin
  bFormatarClick( Sender );
  
  ACBrValidador1.Documento   := edDocto.Text ;
  ACBrValidador1.Complemento := edComple.Text ;
  ACBrValidador1.IgnorarChar := edIgnorar.Text ;

  if ACBrValidador1.Validar then
     mMsgErro.Text := 'Documento OK'
  else
     mMsgErro.Text := ACBrValidador1.MsgErro ;

end;

procedure TfrValidador.bFormatarClick(Sender: TObject);
begin
  ACBrValidador1.Documento   := edDocto.Text ;
  ACBrValidador1.Complemento := edComple.Text ;

  edDocto.Text := ACBrValidador1.Formatar ;
end;

procedure TfrValidador.cbPermiteVazioClick(Sender: TObject);
begin
  ACBrValidador1.PermiteVazio := cbPermiteVazio.Checked ;
end;

procedure TfrValidador.cbAjustarTamClick(Sender: TObject);
begin
  ACBrValidador1.AjustarTamanho := cbAjustarTam.Checked ;
end;

procedure TfrValidador.cbExibeDigCorretoClick(Sender: TObject);
begin
  ACBrValidador1.ExibeDigitoCorreto := cbExibeDigCorreto.Checked ;
end;

procedure TfrValidador.cbExceptionClick(Sender: TObject);
begin
  ACBrValidador1.RaiseExcept := cbException.Checked ;
end;

procedure TfrValidador.cbTipoDoctoChange(Sender: TObject);
begin
  ACBrValidador1.TipoDocto := TACBrValTipoDocto( cbTipoDocto.ItemIndex ) ;
  if ACBrValidador1.TipoDocto <> docInscEst then
     edComple.Text := '' ;
end;

procedure TfrValidador.edDoctoChange(Sender: TObject);
begin
  mMsgErro.Lines.Clear ;
end;

end.
