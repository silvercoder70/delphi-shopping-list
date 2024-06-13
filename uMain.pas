unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit;

type
  THeaderFooterForm = class(TForm)
    Header: TToolBar;
    Footer: TToolBar;
    HeaderLabel: TLabel;
    ItemLabel: TLabel;
    Item: TEdit;
    ShoppingList: TListBox;
    ShoppingListLabel: TLabel;
    AddItemButton: TSpeedButton;
    RemoveItemButton: TSpeedButton;
    ClearListButton: TSpeedButton;
    CopyListButton: TSpeedButton;
    procedure AddItemButtonClick(Sender: TObject);
    procedure RemoveItemButtonClick(Sender: TObject);
    procedure ClearListButtonClick(Sender: TObject);
    procedure CopyListButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HeaderFooterForm: THeaderFooterForm;

implementation

{$R *.fmx}
uses FMX.Platform;

procedure THeaderFooterForm.AddItemButtonClick(Sender: TObject);
begin
  if ShoppingList.Items.IndexOf(Item.Text) = -1 then
    ShoppingList.Items.Add(Item.Text);
  Item.Text := '';
end;

procedure THeaderFooterForm.ClearListButtonClick(Sender: TObject);
begin
  ShoppingList.Items.Clear;
end;

procedure THeaderFooterForm.RemoveItemButtonClick(Sender: TObject);
begin
  ShoppingList.Items.Delete(ShoppingList.Selected.Index);
end;

procedure THeaderFooterForm.CopyListButtonClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(
    IFMXClipboardService, Svc) then
    Svc.SetClipboard(ShoppingList.Items.CommaText)
end;

end.


