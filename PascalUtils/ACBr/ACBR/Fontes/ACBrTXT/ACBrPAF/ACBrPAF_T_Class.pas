{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Isaque Pinheiro                                 }
{                                                                              }
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

unit ACBrPAF_T_Class;

interface

uses SysUtils, Classes, DateUtils, ACBrTXTClass,
     ACBrPAF_T;

type
  /// TPAF_T -

  { TPAF_T }

  TPAF_T = class(TACBrTXTClass)
  private
    FRegistroT1: TRegistroT1;       /// FRegistroT1
    FRegistroT2: TRegistroT2List;   /// Lista de FRegistroT2
    FRegistroT9: TRegistroT9;       /// FRegistroT9

    procedure CriaRegistros;
    procedure LiberaRegistros;
  public
    constructor Create; /// Create
    destructor Destroy; override; /// Destroy
    procedure LimpaRegistros;

    procedure WriteRegistroT1;
    procedure WriteRegistroT2;
    procedure WriteRegistroT9;

    property RegistroT1: TRegistroT1 read FRegistroT1 write FRegistroT1;
    property RegistroT2: TRegistroT2List read FRegistroT2 write FRegistroT2;
    property RegistroT9: TRegistroT9 read FRegistroT9 write FRegistroT9;
  end;

implementation

uses ACBrTXTUtils;

{ TPAF_T }

constructor TPAF_T.Create;
begin
  inherited;
  CriaRegistros;
end;

procedure TPAF_T.CriaRegistros;
begin
  FRegistroT1 := TRegistroT1.Create;
  FRegistroT2 := TRegistroT2List.Create;
  FRegistroT9 := TRegistroT9.Create;

  FRegistroT9.TOT_REG := 0;
end;

destructor TPAF_T.Destroy;
begin
  LiberaRegistros;
  inherited;
end;

procedure TPAF_T.LiberaRegistros;
begin
  FRegistroT1.Free;
  FRegistroT2.Free;
  FRegistroT9.Free;
end;

procedure TPAF_T.LimpaRegistros;
begin
  /// Limpa os Registros
  LiberaRegistros;
  /// Recriar os Registros Limpos
  CriaRegistros;
end;

procedure TPAF_T.WriteRegistroT1;
begin
   if Assigned(FRegistroT1) then
   begin
      with FRegistroT1 do
      begin
        Check(funChecaCNPJ(CNPJ), '(T1) ESTABELECIMENTO: O CNPJ "%s" digitado � inv�lido!', [CNPJ]);
        Check(funChecaIE(IE, UF), '(T1) ESTABELECIMENTO: A Inscri��o Estadual "%s" digitada � inv�lida!', [IE]);
        ///
        Add(LFill('T1') +
            LFill(CNPJ, 14) +
            RFill(IE, 14) +
            RFill(IM, 14) +
            RFill(RAZAOSOCIAL, 50));
      end;
   end;
end;

function OrdenarT2(const ACampo1, ACampo2: Pointer): Integer;
var
  Campo1, Campo2: String;
begin
  Campo1 := FormatDateTime('YYYYMMDD', TRegistroT2(ACampo1).DT_MOV) +
            TRegistroT2(ACampo1).TP_DOCTO +
            TRegistroT2(ACampo1).SERIE +
            TRegistroT2(ACampo1).NUM_ECF;
  Campo2 := FormatDateTime('YYYYMMDD', TRegistroT2(ACampo2).DT_MOV) +
            TRegistroT2(ACampo2).TP_DOCTO +
            TRegistroT2(ACampo2).SERIE +
            TRegistroT2(ACampo2).NUM_ECF;

  Result := AnsiCompareText(Campo1, Campo2);
end;

procedure TPAF_T.WriteRegistroT2;
var
intFor: integer;
begin
  if Assigned(FRegistroT2) then
  begin
    FRegistroT2.Sort(@OrdenarT2);

    for intFor := 0 to FRegistroT2.Count - 1 do
    begin
      with FRegistroT2.Items[intFor] do
      begin
        Add(LFill('T2') +
            LFill(FRegistroT1.CNPJ, 14) +
            LFill(DT_MOV, 'yyyymmdd') +
            RFill(TP_DOCTO, 10, ifThen(RegistroValido, ' ', '?')) +
            RFill(SERIE, 2) +
            LFill(NUM_BILH_I, 6) +
            LFill(NUM_BILH_F, 6) +
            RFill(NUM_ECF, 20) +
            LFill(CRZ, 6) +
            RFill(CFOP, 4) +
            LFill(VL_CONT, 13, 2) +
            LFill(VL_BASECALC, 13, 2) +
            LFill(ALIQ, 4) +
            LFill(VL_IMPOSTO, 13, 2) +
            LFill(VL_ISENTAS, 13, 2) +
            LFill(VL_OUTRAS, 13, 2));
      end;
      ///
      FRegistroT9.TOT_REG := FRegistroT9.TOT_REG + 1;
    end;
  end;
end;

procedure TPAF_T.WriteRegistroT9;
begin
   if Assigned(FRegistroT9) then
   begin
     with FRegistroT9 do
     begin
       Add(LFill('T9') +
           LFill(FRegistroT1.CNPJ, 14) +
           RFill(FRegistroT1.IE, 14) +
           LFill(TOT_REG, 6, 0));
     end;
   end;
end;

end.
