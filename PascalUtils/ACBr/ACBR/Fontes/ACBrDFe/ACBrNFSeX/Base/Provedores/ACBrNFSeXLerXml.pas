{******************************************************************************}
{ Projeto: Componentes ACBr                                                    }
{  Biblioteca multiplataforma de componentes Delphi para intera��o com equipa- }
{ mentos de Automa��o Comercial utilizados no Brasil                           }
{                                                                              }
{ Direitos Autorais Reservados (c) 2020 Daniel Simoes de Almeida               }
{                                                                              }
{ Colaboradores nesse arquivo: Italo Giurizzato Junior                         }
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

unit ACBrNFSeXLerXml;

interface

uses
  SysUtils, Classes,
  ACBrXmlBase, ACBrXmlReader,
  ACBrXmlDocument,
  ACBrNFSeXInterface, ACBrNFSeXClass, ACBrNFSeXConversao;

type
  { TNFSeRClass }

  TNFSeRClass = class(TACBrXmlReader)
  private
    FNFSe: TNFSe;
    FProvedor: TnfseProvedor;
    FtpXML: TtpXML;
    FAmbiente: TACBrTipoAmbiente;

  protected
    FpAOwner: IACBrNFSeXProvider;

    function NormatizarItemListaServico(const Codigo: string): string;
    function ItemListaServicoDescricao(const Codigo: string): string;
    function TipodeXMLLeitura(const aArquivo: string): TtpXML; virtual;
    function NormatizarXml(const aXml: string): string; virtual;
    function NormatizarAliquota(const Aliquota: Double): Double;
    function LerLinkURL: string;

    procedure VerificarSeConteudoEhLista(const aDiscriminacao: string);
    procedure LerListaJson(const aDiscriminacao: string);
    procedure LerListaTabulada(const aDiscriminacao: string);
  public
    constructor Create(AOwner: IACBrNFSeXProvider);

    function LerXml: Boolean; Override;
    procedure LerCampoLink;

    property NFSe: TNFSe             read FNFSe     write FNFSe;
    property Provedor: TnfseProvedor read FProvedor write FProvedor;
    property tpXML: TtpXML           read FtpXML    write FtpXML;
    property Ambiente: TACBrTipoAmbiente read FAmbiente write FAmbiente default taHomologacao;
  end;

implementation

uses
  StrUtils, StrUtilsEx,
  ACBrJSON,
  ACBrUtil.Strings, ACBrUtil.XMLHTML,
  ACBrDFeException;

{ TNFSeRClass }

constructor TNFSeRClass.Create(AOwner: IACBrNFSeXProvider);
begin
  FpAOwner := AOwner;
end;

function TNFSeRClass.ItemListaServicoDescricao(const Codigo: string): string;
var
  xCodigo: string;
begin
  xCodigo := OnlyNumber(Codigo);

  if FpAOwner.ConfigGeral.TabServicosExt then
    Result := ObterDescricaoServico(xCodigo)
  else
    Result := CodItemServToDesc(xCodigo);
end;

function TNFSeRClass.LerXml: Boolean;
begin
  Result := False;
  raise EACBrDFeException.Create(ClassName + '.LerXml, n�o implementado');
end;

function TNFSeRClass.NormatizarAliquota(const Aliquota: Double): Double;
begin
  if Aliquota < 1 then
    Result := Aliquota * 100
  else
    Result := Aliquota;
end;

function TNFSeRClass.NormatizarItemListaServico(const Codigo: string): string;
var
  Item: Integer;
  xCodigo: string;
begin
  xCodigo := Codigo;

  Item := StrToIntDef(OnlyNumber(xCodigo), 0);
  if Item < 100 then
    Item := Item * 100 + 1;

  xCodigo := FormatFloat('0000', Item);

  Result := Copy(xCodigo, 1, 2) + '.' + Copy(xCodigo, 3, 2);
end;

function TNFSeRClass.NormatizarXml(const aXml: string): string;
begin
{$IfDef FPC}
  Result := aXml;
{$Else}
  Result := ParseText(aXml, True, False);
  Result := FastStringReplace(Result, '&', '&amp;', [rfReplaceAll]);
{$EndIf}
end;

function TNFSeRClass.TipodeXMLLeitura(const aArquivo: string): TtpXML;
var
  aXML: string;
begin
  aXML := RemoverPrefixosDesnecessarios(aArquivo);

  if (Pos('/infnfse>', LowerCase(aXML)) > 0) then
    Result := txmlNFSe
  else
    Result := txmlRPS;
end;

procedure TNFSeRClass.VerificarSeConteudoEhLista(const aDiscriminacao: string);
var
  xDiscriminacao: string;
begin
  xDiscriminacao := NFSe.Servico.Discriminacao;
  FpAOwner.ConfigGeral.DetalharServico := False;

  if (Pos('[', xDiscriminacao) > 0) and (Pos(']', xDiscriminacao) > 0) and
     (Pos('{', xDiscriminacao) > 0) and (Pos('}', xDiscriminacao) > 0) then
  begin
    FpAOwner.ConfigGeral.DetalharServico := True;

    if Pos('":', xDiscriminacao) > 0 then
      LerListaJson(xDiscriminacao)
    else
      LerListaTabulada(xDiscriminacao);
  end;
end;

function TNFSeRClass.LerLinkURL: string;
var
  LinkNFSeParam: TLinkNFSeParam;
begin
  LinkNFSeParam := TLinkNFSeParam.Create;
  try
    LinkNFSeParam.Ambiente := Integer(FpAOwner.ConfigGeral.Ambiente);
    LinkNFSeParam.ProLinkURL := FpAOwner.ConfigWebServices.Producao.LinkURL;
    LinkNFSeParam.HomLinkURL := FpAOwner.ConfigWebServices.Homologacao.LinkURL;
    LinkNFSeParam.xMunicipio := FpAOwner.ConfigGeral.xMunicipio;

    Result := NFSe.LinkNFSe(LinkNFSeParam);
  finally
    LinkNFSeParam.Free;
  end;
end;

procedure TNFSeRClass.LerListaJson(const aDiscriminacao: string);
var
  xDiscriminacao: string;
  json, jsonItem: TACBrJsonObject;
  i: Integer;
begin
  xDiscriminacao := '{"a": ' + aDiscriminacao + '}';
  Json := TACBrJsonObject.Parse(xDiscriminacao);

  for i := 0 to json.AsJSONArray['a'].Count -1 do
  begin
    jsonItem := json.AsJSONArray['a'].ItemAsJSONObject[i];

    with NFSe.Servico.ItemServico.New do
    begin
      Descricao := jsonItem.AsString['Descricao'];
      ValorUnitario := jsonItem.AsCurrency['ValorUnitario'];
      Quantidade := jsonItem.AsCurrency['Quantidade'];
      ValorTotal := jsonItem.AsCurrency['ValorTotal'];
    end;
  end;
end;

procedure TNFSeRClass.LerListaTabulada(const aDiscriminacao: string);
var
  xDiscriminacao, xDescricao, xItemServico: string;
  fQuantidade, fValorUnitario, fValorServico, fValorBC, fAliquota: Double;
  i, j: Integer;

  function ExtraiValorCampo(aCampo: string; aCampoNumerico: Boolean): string;
  begin
    i := PosEx(aCampo, xDiscriminacao, j) + Length(aCampo) + 1;

    if i = Length(aCampo) + 1 then
      Result := ''
    else
    begin
      j := PosEx(']', xDiscriminacao, i);
      Result := Copy(xDiscriminacao, i, j-i);

      if aCampoNumerico then
        Result := StringReplace(Result, '.', ',', [rfReplaceAll])
    end;
  end;
begin
  xDiscriminacao := aDiscriminacao;
  J := 1;

  while true do
  begin
    xDescricao := ExtraiValorCampo('Descricao', False);

    if xDescricao = '' then
      Break;

    xItemServico := ExtraiValorCampo('ItemServico', False);
    fQuantidade := StrToFloatDef(ExtraiValorCampo('Quantidade', True), 0);
    fValorUnitario := StrToFloatDef(ExtraiValorCampo('ValorUnitario', True), 0);
    fValorServico := StrToFloatDef(ExtraiValorCampo('ValorServico', True), 0);
    fValorBC := StrToFloatDef(ExtraiValorCampo('ValorBaseCalculo', True), 0);
    fAliquota := StrToFloatDef(ExtraiValorCampo('Aliquota', True), 0);

    with NFSe.Servico.ItemServico.New do
    begin
      Descricao := xDescricao;
      ItemListaServico := xItemServico;
      Quantidade := fQuantidade;
      ValorUnitario := fValorUnitario;
      ValorTotal := fValorServico;
      ValorBCINSS := fValorBC;
      BaseCalculo := fValorBC;
      Aliquota := fAliquota;
    end;
  end;
end;

procedure TNFSeRClass.LerCampoLink;
var
  Link: string;
  i: Integer;

function ExtrairURL(PosIni: Integer; Texto: string): string;
var
  j: Integer;
  Url: string;
begin
  Url := '';
  j := PosIni;

  while (j < Length(Texto)) and (Texto[j] <> ' ') do
  begin
    Url := Url + Texto[j];
    Inc(j);
  end;

  Result := Url;
end;

begin
  if NFSe.Link = '' then
  begin
    Link := '';

    i := pos('http://', LowerCase(NFSe.OutrasInformacoes));

    if i > 0 then
      Link := ExtrairURL(i, NFSe.OutrasInformacoes)
    else
    begin
      i := pos('https://', LowerCase(NFSe.OutrasInformacoes));

      if i > 0 then
        Link := ExtrairURL(i, NFSe.OutrasInformacoes);
    end;

    if Link = '' then
      Link := LerLinkURL;

    NFSe.Link := Trim(Link);
  end;
end;

end.
