{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Juliomar Marchetti                              }
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

unit ACBrTEFDCappta;


interface

uses
  Classes, SysUtils, ACBrTEFDClass
  {$IfNDef NOGUI}
    {$If DEFINED(VisualCLX)}
      , QControls
    {$Else}
       {$If DEFINED(FMX)}
         , FMX.Controls
       {$Else}
         , Controls
       {$IfEnd}
    {$IfEnd}
  {$EndIf};

const
  CACBrTEFD_Cappta_ImprimeGerencialConcomitante = False ;
  CACBrTEFD_Cappta_PressioneEnter = 'PRESSIONE <ENTER>' ;
  CACBrTEFD_Cappta_TransacaoNaoEfetuada = 'Transa��o n�o efetuada.' ;
  CACBrTEFD_Cappta_TransacaoNaoEfetuadaReterCupom =
     'Transa��o n�o efetuada.'+sLineBreak+'Favor reter o Cupom' ;
  CACBrTEFD_Cappta_TransacaoEfetuadaReImprimir =
     'Transa��o TEF efetuada.'        + sLineBreak+
     'Favor reimprimir �ltimo Cupom.' + sLineBreak +
     '%s'                             + sLineBreak +
     '(Para Cielo utilizar os 6 �ltimos d�gitos.)';
  CACBrTEFD_Cappta_NaoInicializado = 'Cappta n�o inicializado' ;
  CACBrTEFD_Cappta_NaoConcluido = 'Requisi��o anterior n�o concluida' ;
  CACBrTEFD_Cappta_Erro1  = 'N�o autenticado/Alguma das informa��es fornecidas para autentica��o n�o � v�lida' ;
  CACBrTEFD_Cappta_Erro2  = 'CapptaGpPlus est� sendo inicializado' ;
  CACBrTEFD_Cappta_Erro3  = 'C�digo de terminal inv�lido' ;
  CACBrTEFD_Cappta_Erro6  = 'Erro na inicializa��o do TCP/IP' ;
  CACBrTEFD_Cappta_Erro7  = 'Erro interno no CapptaGpPlus' ;
  CACBrTEFD_Cappta_Erro8  = 'Erro na comunica��o entre a CappAPI e o CapptaGpPlus' ;
  CACBrTEFD_Cappta_Erro9  = 'Ocorre quando qualquer opera��o � realizada sem que se tenha finalizado o �ltimo pagamento';
  CACBrTEFD_Cappta_Erro10 = 'Uma reimpress�o ou cancelamento foi executada dentro de uma sess�o multi-cart�es';
  CACBrTEFD_Cappta_Erro11 = 'Dados inv�lidos passados pela automa��o.';
  CACBrTEFD_Cappta_Erro12 = 'Modo seguro n�o ativo (poss�vel falta de configura��o no servidor SiTef do arquivo .cha).';
  CACBrTEFD_Cappta_Erro13 = 'Caminho da DLL inv�lido (o caminho completo das bibliotecas est� muito grande).';
  CACBrTEFD_Cappta_Erro14 = 'Valor digitado no pinpad � inv�lido.';


  {$IFDEF LINUX}
    CACBrTEFD_Cappta_Lib = 'Cappta.Gp.Api.Com.so' ;
  {$ELSE}
    CACBrTEFD_Cappta_Lib = 'Cappta.Gp.Api.Com.dll' ;
  {$ENDIF}

{ TACBrTEFDCappta }
type
  TACBrTEFDCappta = class(TACBrTEFDClass)
  private
    xAutenticarPdv : function(
      cnpj : PAnsiChar;
      pdv : integer;
      chaveAutenticacao: PAnsiChar):integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xCancelarPagamento : function(
      senhaAdministrativa : PAnsiChar;
      numeroControle: PAnsiChar): integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    //xConfigurar : function (
      //Cappta.Gp.Api.Com.Model.IConfiguracoes configs) : integer;
    //{$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xConfirmarPagamentos : function : integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xDesfazerPagamentos : function : integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xEnviarParametro : function(
      parametro : PAnsiChar;
      acao : integer) : integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xIniciarMultiCartoes : function (
      quantidadePagamentos : integer) : integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    //xIterarOperacaoTef: function : Cappta.Gp.Api.Com.Model.IIteracaoTef;
    //{$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    //xPagamentoCrediario : function (
      //valor : double;
      //detalhes : Cappta.Gp.Api.Com.Model.IDetalhesCrediario ):integer;
    //{$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    //xPagamentoCredito : function(
      //valor: double;
      //detalhes: Cappta.Gp.Api.Com.Model.IDetalhesCredito ) : integer;
    //{$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xPagamentoDebito : function (
      valor: double) : integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    //xPagamentoTicketCarPessoaFisica : function(
      //valor : double;
      //detalhes : Cappta.Gp.Api.Com.Model.IDetalhesPagamentoTicketCarPessoaFisica ): integer;
    //{$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xReimprimirCupom : function(
      numeroControle: PAnsiChar;
      tipoVia : integer): integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    xReimprimirUltimoCupom: function(
      tipoVia: integer): integer;
    {$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;
    //xSolicitarInformacoesPinpad : function(
      //requisicaoPinpad : Cappta.Gp.Api.Com.Model.IRequisicaoInformacaoPinpad ): PAnsiChar;
    //{$IFDEF LINUX} cdecl {$ELSE} stdcall {$ENDIF} ;


    fPathDLL: string;

    procedure LoadDLLFunctions;
    procedure UnLoadDLLFunctions;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Inicializar ; override;
    procedure DesInicializar ; override;

    procedure AtivarGP ; override;
    procedure VerificaAtivo ; override;

    property PathDLL: string read fPathDLL write fPathDLL;

  published
  end;

implementation

uses
  {$IFDEF MSWINDOWS} Windows, {$ENDIF MSWINDOWS}
  ACBrUtil.FilesIO,
  ACBrUtil.Strings;

{ TACBrTEFDCappta }

procedure TACBrTEFDCappta.LoadDLLFunctions;
  procedure CapptaFunctionDetect( FuncName: AnsiString; var LibPointer: Pointer ) ;
   var
   sLibName: string;
   begin
     if not Assigned( LibPointer )  then
     begin
       // Verifica se exite o caminho das DLLs
       sLibName := '';
       if Length(PathDLL) > 0 then
          sLibName := PathWithDelim(PathDLL);

       // Concatena o caminho se exitir mais o nome da DLL.
       sLibName := sLibName + CACBrTEFD_Cappta_Lib;

       if not FunctionDetect( sLibName, FuncName, LibPointer) then
       begin
          LibPointer := NIL ;
          raise EACBrTEFDErro.Create( ACBrStr( 'Erro ao carregar a fun��o:'+FuncName+
                                           ' de: '+CACBrTEFD_Cappta_Lib ) ) ;
       end ;
     end ;
   end ;
begin
  CapptaFunctionDetect('AutenticarPdv',@xAutenticarPdv);
  CapptaFunctionDetect('CancelarPagamento', @xCancelarPagamento );
  //CapptaFunctionDetect('Configurar', @xConfigurar);
  CapptaFunctionDetect('ConfirmarPagamentos', @xConfirmarPagamentos);
  CapptaFunctionDetect('DesfazerPagamentos', @xDesfazerPagamentos);
  CapptaFunctionDetect('EnviarParametro', @xEnviarParametro );
  CapptaFunctionDetect('IniciarMultiCartoes', @xIniciarMultiCartoes);
  //CapptaFunctionDetect('IterarOperacaoTef', @xIterarOperacaoTef);
  //CapptaFunctionDetect('PagamentoCrediario', @xPagamentoCrediario);
  //CapptaFunctionDetect('PagamentoCredito', @xPagamentoCredito);
  CapptaFunctionDetect('PagamentoDebito', @xPagamentoDebito);
  //CapptaFunctionDetect('PagamentoTicketCarPessoaFisica', @xPagamentoTicketCarPessoaFisica);
  CapptaFunctionDetect('ReimprimirCupom', @xReimprimirCupom);
  CapptaFunctionDetect('ReimprimirUltimoCupom', @xReimprimirUltimoCupom);
  //CapptaFunctionDetect('SolicitarInformacoesPinpad', @xSolicitarInformacoesPinpad);

end;

procedure TACBrTEFDCappta.UnLoadDLLFunctions;
 var
    sLibName: String;
 begin
   sLibName := '';

   if Length(PathDLL) > 0 then
      sLibName := PathWithDelim(PathDLL);

   UnLoadLibrary( sLibName + CACBrTEFD_Cappta_Lib );

   xAutenticarPdv := nil;
   xCancelarPagamento := nil;
   //xConfigurar : = nil;
   xConfirmarPagamentos := nil;
   xDesfazerPagamentos := nil;
   xEnviarParametro := nil;
   xIniciarMultiCartoes := nil;
   //xIterarOperacaoTef:= nil;
   //xPagamentoCrediario := nil;
   //xPagamentoCredito := nil;
   xPagamentoDebito := nil;
   //xPagamentoTicketCarPessoaFisica := nil;
   xReimprimirCupom := nil;
   xReimprimirUltimoCupom:= nil;
   //xSolicitarInformacoesPinpad := nil;

end;

constructor TACBrTEFDCappta.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ArqReq    := '' ;
  ArqResp   := '' ;
  ArqSTS    := '' ;
  ArqTemp   := '' ;
  GPExeName := '' ;
  fpTipo    := gpCappta;
  Name      := 'Cappta' ;

  if Assigned( fpResp ) then
     fpResp.Free ;

  fpResp := TACBrTEFDResp.Create;
  fpResp.TipoGP := Tipo;
end;

destructor TACBrTEFDCappta.Destroy;
begin
  inherited Destroy;
end;

procedure TACBrTEFDCappta.Inicializar;
 Var
//   Sts : Integer ;
//   ParamAdic : AnsiString ;
   Erro : String;
 begin
   if Inicializado then exit ;


   LoadDLLFunctions;


   //GravaLog( '*** ConfiguraIntSiTefInterativoEx. EnderecoIP: '   +fEnderecoIP+
   //                                          ' CodigoLoja: '     +fCodigoLoja+
   //                                          ' NumeroTerminal: ' +fNumeroTerminal+
   //                                          ' Resultado: 0'     +
   //                                          ' ParametrosAdicionais: '+ParamAdic ) ;

   //Sts := xConfiguraIntSiTefInterativoEx( PAnsiChar(fEnderecoIP),
   //                                       PAnsiChar(fCodigoLoja),
   //                                       PAnsiChar(fNumeroTerminal),
   //                                       0,
   //                                       PAnsiChar(ParamAdic) );
   //Erro := '' ;
   //Case Sts of
   //  1 :	Erro := CACBrTEFD_CliSiTef_Erro1;
   //  2 : Erro := CACBrTEFD_CliSiTef_Erro2;
   //  3 : Erro := CACBrTEFD_CliSiTef_Erro3;
   //  6 : Erro := CACBrTEFD_CliSiTef_Erro6;
   //  7 : Erro := CACBrTEFD_CliSiTef_Erro7;
   //  8 : Erro := CACBrTEFD_CliSiTef_Erro8;
   // 10 : Erro := CACBrTEFD_CliSiTef_Erro10;
   // 11 : Erro := CACBrTEFD_CliSiTef_Erro11;
   // 12 : Erro := CACBrTEFD_CliSiTef_Erro12;
   // 13 : Erro := CACBrTEFD_CliSiTef_Erro13;
   //end;

   if Erro <> '' then
      raise EACBrTEFDErro.Create( ACBrStr( Erro ) ) ;

   GravaLog( Name +' Inicializado Cappta' );

   VerificarTransacoesPendentesClass(True);
   fpInicializado := True;
end;

procedure TACBrTEFDCappta.DesInicializar;
begin
  UnLoadDLLFunctions ;

  inherited DesInicializar;
end;

procedure TACBrTEFDCappta.AtivarGP;
begin
  raise EACBrTEFDErro.Create( ACBrStr( 'Cappta n�o pode ser ativado localmente' )) ;
end;

procedure TACBrTEFDCappta.VerificaAtivo;
begin
  {Nada a Fazer}
end;

end.

