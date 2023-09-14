unit NFseController1;

interface

uses
  Horse;

procedure RegisterRoutes;

function ToJSON: TJSONObject;
s
implementation

function TNFse.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('campo1', FCampo1);
  Result.AddPair('campo2', FCampo2);
  // Adicione outros campos aqui
end;

procedure RegisterRoutes;
begin
  THorse.Get('/nfse1', 
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      // Lógica para manipular a NFse1
      Res.Send('NFse1 Controller');
    end
  );
end;

initialization
  RegisterRoutes;

  

end.
