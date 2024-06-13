program ShoppingList;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {HeaderFooterForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(THeaderFooterForm, HeaderFooterForm);
  Application.Run;
end.
