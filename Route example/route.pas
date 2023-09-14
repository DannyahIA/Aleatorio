uses
  Horse,
  NFseController1, // Adicione as units dos controllers aqui
  NFseController2,
  NFseController3;

begin
  THorse.Use(
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      // Middlewares globais podem ser adicionados aqui
      Next;
    end
  );

  // Rota para receber o JSON via POST
  THorse.Post('/receberjson',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      JSONData: TJSONObject;
      NFse1, NFse2, NFse3: TNFse; // Suponha que você tenha uma classe TNFse para representar a NFse
      ResultJSON: TJSONObject;
    begin
      // Faça o parse do JSON recebido
      JSONData := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;

      try
        // Crie objetos NFse com base nos dados do JSON
        NFse1 := CreateNFseFromJSON(JSONData); // Implemente essa função
        NFse2 := CreateNFseFromJSON(JSONData); // Implemente essa função
        NFse3 := CreateNFseFromJSON(JSONData); // Implemente essa função

        // Envie os objetos NFse para o serviço ABCr (implemente essa lógica)

        // Crie um JSON de resposta com os resultados
        ResultJSON := TJSONObject.Create;
        ResultJSON.AddPair('nfse1', NFse1.ToJSON); // Implemente o método ToJSON na classe TNFse
        ResultJSON.AddPair('nfse2', NFse2.ToJSON);
        ResultJSON.AddPair('nfse3', NFse3.ToJSON);

        // Envie o JSON de resposta para o cliente
        Res.Send(ResultJSON.ToString);
      finally
        JSONData.Free;
        ResultJSON.Free;
      end;
    end
  );

  // Registre as rotas de cada controller
  RegisterRoutes1;
  RegisterRoutes2;
  RegisterRoutes3;

  THorse.Listen(9000);
end.