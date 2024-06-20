unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ListBox, FMX.Controls.Presentation, FMX.Edit;

type
  THeaderFooterForm = class(TForm)
    Header: TToolBar;
    HeaderLabel: TLabel;
    ItemLabel: TLabel;
    Item: TEdit;
    ShoppingList: TListBox;
    ShoppingListLabel: TLabel;
    AddItemButton: TSpeedButton;
    RemoveItemButton: TSpeedButton;
    ClearListButton: TSpeedButton;
    CopyListButton: TSpeedButton;
    SortItemsCheckbox: TCheckBox;
    StyleBook1: TStyleBook;
    StyleBook2: TStyleBook;
    procedure AddItemButtonClick(Sender: TObject);
    procedure RemoveItemButtonClick(Sender: TObject);
    procedure ClearListButtonClick(Sender: TObject);
    procedure CopyListButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SortItemsCheckboxChange(Sender: TObject);
    procedure ItemKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    const AppFolder: string = 'shoppinglist';
    const IniFileName: string = 'shoppinglist.ini';
    const DataSection: string = 'Data';
    const SortedKey: string = 'Sorted';
    const ShoppingListSection: string = 'ShoppingList';
    const CountKey: string = 'Count';
    const ItemKey: string = 'Item';
  private
    { Private declarations }
    FAppFolder: string;
    FList: TStringList; {Stores items as entered/added by the user}
    procedure AddItemToList(AItem: string; AAddToList: boolean = True);
    procedure LoadSettings;
    procedure SaveSettings;
    function GetConfigFileName: string; inline;
  public
    { Public declarations }
  end;

var
  HeaderFooterForm: THeaderFooterForm;

implementation

{$R *.fmx}
uses FMX.Platform, System.IniFiles, System.IOUtils;

procedure THeaderFooterForm.AddItemButtonClick(Sender: TObject);
begin
  if FList.IndexOf(Item.Text) = -1 then
    AddItemToList(Item.Text);
  Item.Text := '';
end;

procedure THeaderFooterForm.ClearListButtonClick(Sender: TObject);
begin
  FList.Clear;
  ShoppingList.Clear;
end;

procedure THeaderFooterForm.RemoveItemButtonClick(Sender: TObject);
begin
  var Index := ShoppingList.Selected.Index;
  var ItemToDelete := ShoppingList.Items[Index];
  FList.Delete(FList.IndexOf(ItemToDelete));
  ShoppingList.Items.Delete(Index);
end;

procedure THeaderFooterForm.CopyListButtonClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(
    IFMXClipboardService, Svc) then
    Svc.SetClipboard(ShoppingList.Items.CommaText)
end;

{Item is added to both the unsorted list and listbox}
procedure THeaderFooterForm.AddItemToList(AItem: string;
                                          AAddToList: boolean);
begin
  if AAddToList then
    FList.Add(AItem);

  var Item: TlistBoxItem := TlistBoxItem.Create(self);
  Item.Parent := ShoppingList;
  Item.Text := AItem;
end;

{Event handler to handle user clicking on Sort Items checkbox -

when the user clicks on the checkbox, Sorted is set to True and this will
trigger a procedure/function to sort the items in the listbox displayed
to the user.

when the checkbox is unchecked, Sorted is set to False and in this instance
we just want to reload the "unsorted" list of item into the listbox}

procedure THeaderFooterForm.SortItemsCheckboxChange(Sender: TObject);
begin
  ShoppingList.Sorted := SortItemsCheckbox.IsChecked;
  if not ShoppingList.Sorted then
  begin
    ShoppingList.Clear;
    for var Item in FList do
      AddItemToList(Item, False);
  end;
end;

{when the form is created, create our unsorted list of shopping items
and then load settings from previous session. Note that the .ini file
will be stored under the (user) documents folder vs folder where the
application is located. When applications located under program files or
similar, these folders are typically R/O.}
procedure THeaderFooterForm.FormCreate(Sender: TObject);
begin
  FList := TStringList.Create;
  FAppFolder := TPath.Combine(TPath.GetDocumentsPath, AppFolder);
  if not DirectoryExists(FAppFolder) then
    ForceDirectories(FAppFolder);
  LoadSettings;
end;

{when the application is closed, save settings from this session and
then free any memory ...}
procedure THeaderFooterForm.FormDestroy(Sender: TObject);
begin
  SaveSettings;
  FList.Free;
end;

{Just to make sure the all functions operate on the same configuration file}
function THeaderFooterForm.GetConfigFileName: string;
begin
  Result := TPath.Combine(FAppFolder, IniFileName);
end;

procedure THeaderFooterForm.ItemKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    AddItemButtonClick(sender);
end;

{Load settings from previous session - (i) whether the list was sorted
and (ii) items in the shopping list}
procedure THeaderFooterForm.LoadSettings;
begin
  var Config: TiniFile := TIniFile.Create(GetConfigFileName);
  var SortItems := Config.ReadBool(DataSection, SortedKey, False);
  var Count := Config.ReadInteger(ShoppingListSection, CountKey, 0);
  for var I := 0 to Count-1 do
  begin
    var Item := Config.ReadString(ShoppingListSection, ItemKey + I.ToString, '');
    if Item <> '' then
      AddItemToList(Item);
  end;
  Config.Free;

  SortItemsCheckbox.IsChecked := SortItems;
end;

{Save settings from this session - (i) whether the list was sorted
and (ii) items in the shopping list}
procedure THeaderFooterForm.SaveSettings;
begin
  var Config: TiniFile := TIniFile.Create(GetConfigFileName);
  Config.WriteBool(DataSection, SortedKey, SortItemsCheckbox.IsChecked);
  Config.WriteInteger(ShoppingListSection, CountKey, FList.Count);
  for var I := 0 to FList.Count-1 do
    Config.WriteString(ShoppingListSection, ItemKey + I.ToString, FList[I]);
  Config.Free;
end;

end.

{
Version 0.1
- basic application with add item, delete item and copy to clipboard

Version 0.11
- add .ini file for loading and saving settings and shopping list
- add option to show items in shopping list in alphabetical order
- add stylybook to main form; improved application appearance
}
