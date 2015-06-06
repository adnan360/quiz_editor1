unit frmAboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LCLIntf;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    edtSourceWeb: TEdit;
    imgLogo: TImage;
    Label1: TLabel;
    lblSite: TLabel;
    lblProgramName: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure lblSiteClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  imgLogo.Picture.Icon.Assign(Application.Icon);
  lblProgramName.Caption:='Quiz Editor';
  Caption:='About Quiz Editor';
  edtSourceWeb.Text:='https://github.com/adnan360';
end;

procedure TfrmAbout.lblSiteClick(Sender: TObject);
begin
  OpenURL('http://lazplanet.blogspot.com');
end;

end.

