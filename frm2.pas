unit frm2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type

  { TForm2 }

  TForm2 = class(TForm)
    btnShowCorrectAns: TBitBtn;
    DividerBevel1: TDividerBevel;
    grpQuiz: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label8: TLabel;
    lblIsCorrect: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblQuestion: TLabel;
    Label7: TLabel;
    lblTotalQues: TLabel;
    lblCurrentQues: TLabel;
    lblCorrectAns: TLabel;
    lblLastAns: TLabel;
    panAnswers: TPanel;
    procedure btnShowCorrectAnsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure AnswerClick(Sender: TObject);
    procedure ShowQuestion(QIndex: Integer);
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;
  CurrentQuestionIndex: integer;
  CorrectAnswers: Integer;

implementation

uses
  frm1;

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormCreate(Sender: TObject);
begin

end;

procedure TForm2.btnShowCorrectAnsClick(Sender: TObject);
var
  x: Integer;
  comp: TControl;
begin
    for x := (panAnswers.ControlCount - 1) downto 0 do begin
        comp := panAnswers.controls[x];
        if (comp.Visible) and (comp.tag = (MyQuizData.Questions.questionsarray[CurrentQuestionIndex].CorrectAnswer)) then begin
          (comp as TButton).Font.Style := [fsBold, fsItalic];
        end;
    end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  lblTotalQues.Caption := inttostr(MyQuizData.Questions.Count);
  lblCurrentQues.Caption:='1';
  lblCorrectAns.Caption:='0';
  ShowQuestion(0);
end;

procedure TForm2.AnswerClick(Sender: TObject);
var
  lastans: Integer;
begin
  lastans := (Sender as TButton).Tag;

  //Caption := (IntToStr(CurrentQuestionIndex)+'|'
  //           + IntToStr(MyQuizData.Questions.Count - 1));

  if CurrentQuestionIndex <= MyQuizData.Questions.Count-1 then begin

    lblLastAns.Caption := MyQuizData.Questions
                          .questionsarray[CurrentQuestionIndex]
                          .Answers[lastans];

    if lastans = (MyQuizData.Questions
                   .questionsarray[CurrentQuestionIndex]
                   .CorrectAnswer) then begin
         lblIsCorrect.Caption:='Yes';
         CorrectAnswers:=CorrectAnswers+1;
         lblCorrectAns.Caption := IntToStr(CorrectAnswers);
    end else begin
         lblIsCorrect.Caption:='No. '#13#10
           +'Correct Answer: '
           +MyQuizData.Questions.questionsarray[CurrentQuestionIndex].GetCorrectAnswer;
    end;


    if CurrentQuestionIndex < MyQuizData.Questions.Count - 1 then
         ShowQuestion(CurrentQuestionIndex + 1)
    else begin
         ShowMessage('Quiz ended.'#13#10'There are no more questions.');
         grpQuiz.Visible:=False;
         btnShowCorrectAns.Enabled:=False;
    end;

  end;


end;

procedure TForm2.ShowQuestion(QIndex: Integer);
var
  i: Integer;
  btn:TButton;
  x: integer; comp: TControl;
begin
  //ShowMessage('show qu'+IntToStr(QIndex));

  if QIndex <= MyQuizData.Questions.Count-1 then begin

    lblQuestion.Caption := MyQuizData.Questions.questionsarray[QIndex].Question;

    for x := (panAnswers.ControlCount - 1) downto 0 do begin
      comp := panAnswers.controls[x];
      comp.Visible:=False; //comp.Free;
    end;

    for i := 0 to length(MyQuizData.Questions.questionsarray[QIndex].Answers)-1 do begin
      btn := TButton.Create(nil);
      btn.Caption := MyQuizData.Questions.questionsarray[QIndex].Answers[i];
      btn.Tag:=i;
      btn.Width := 250;
      btn.Top := i * btn.Height;
      btn.Parent := panAnswers;
      btn.OnClick := @AnswerClick;
    end;


    lblCurrentQues.Caption := inttostr(QIndex+1);
    CurrentQuestionIndex := QIndex;

  end else begin
    ShowMessage('Error: No question with this index : '+IntToStr(QIndex));
  end;
end;

end.

