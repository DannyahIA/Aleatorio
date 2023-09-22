unit nfse_controller;

interface

uses
  Horse;

procedure RegisterRoutes;

procedure Route(Req: THorseRequest; Res: THorseResponse; Next: TProc);

function ToJSON: TJSONObject;

implementation

function TNFse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('campo1', FCampo1);
  Result.AddPair('campo2', FCampo2);
  // Adicione outros campos aqui
end;

procedure Route(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  // Lógica para manipular a NFse1
  Res.Send('NFse1 Controller');
end

procedure RegisterRoutes;
begin
  THorse.Get('/nfse1', );
end;

initialization
 
RegisterRoutes;

end.
