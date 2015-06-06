unit frm1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ComCtrls, LCLType, ExtCtrls;

const
  SOFT_NAME = 'Quiz Editor';

type

  { TForm1 }

  TForm1 = class(TForm)
    btnAddQuestion: TBitBtn;
    btnDeleteQuestion: TBitBtn;
    btnMoveUpQues: TBitBtn;
    btnMoveDownQues: TBitBtn;
    btnAddAns: TBitBtn;
    btnDeleteAns: TBitBtn;
    btnEditAns: TBitBtn;
    cboCorrectAns: TComboBox;
    edtQuestion: TEdit;
    GroupBox1: TGroupBox;
    grpQuestionDetails: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblAbout: TLabel;
    lstAnswers: TListBox;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    ToolBar2: TToolBar;
    ToolbarIcons: TImageList;
    lstQuestions: TListBox;
    ToolBar1: TToolBar;
    ToolSaveAs: TToolButton;
    ToolRun: TToolButton;
    ToolNew: TToolButton;
    ToolButton1: TToolButton;
    ToolOpen: TToolButton;
    ToolSave: TToolButton;
    procedure btnAddAnsClick(Sender: TObject);
    procedure btnAddQuestionClick(Sender: TObject);
    procedure btnDeleteAnsClick(Sender: TObject);
    procedure btnDeleteQuestionClick(Sender: TObject);
    procedure btnEditAnsClick(Sender: TObject);
    procedure btnMoveDownQuesClick(Sender: TObject);
    procedure btnMoveUpQuesClick(Sender: TObject);
    procedure cboCorrectAnsChange(Sender: TObject);
    procedure edtQuestionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblAboutClick(Sender: TObject);
    procedure lstQuestionsClick(Sender: TObject);
    procedure ToolNewClick(Sender: TObject);
    procedure ToolOpenClick(Sender: TObject);
    procedure ToolRunClick(Sender: TObject);
    procedure ToolSaveAsClick(Sender: TObject);
    procedure ToolSaveClick(Sender: TObject);
  private
    procedure OpenQuizFile(QuizFile: string);
    procedure PrepareQuestionPanel(QIndex: Integer);
    procedure RefreshQuestionList;
    { private declarations }
  public
    { public declarations }
  end;

  { Quiz Object }
  TAnswers = array of string;

  { TQuestion }

  TQuestion = object
    Question:string;
    Answers:TAnswers;
    CorrectAnswer:Integer;
    procedure ParseAndAddAnswers(str: String);
    procedure AddAnswer(ans: string);
    procedure DeleteAnswer(index: Integer);
    function GetCorrectAnswer: string;
  end;

  {TQuestions}
  TQuestionsArray = array of TQuestion;
  TQuestions = object
    questionsarray: TQuestionsArray;
    Count: Integer;
    procedure DeleteQuestion(index:Integer);
    procedure AddQuestion(AQuestion: TQuestion);
    procedure ParseAndAddQuestion(str: String);
    procedure ClearQuestions();
  private
    function Check(var ErrorStr: string): Boolean;
    procedure OrderQuestion(fromIndex: Integer; toIndex: Integer);
  end;

  { TQuizData }

  TQuizData = object
    //Questions: TQuestionsArray;
    Questions: TQuestions;
    QuizFilename: string;
    //procedure ParseAndAddQuestion(str: String);
    procedure SaveToFile(AFilename: string='');
  end;


var
  Form1: TForm1;

  MyQuizData: TQuizData;

implementation

uses
  frm2, frmAboutUnit;

{$R *.lfm}

function TQuestion.GetCorrectAnswer:string;
begin
  //ShowMessage(Answers[CorrectAnswer-1]);
  Result:=Answers[CorrectAnswer];
end;

// Returns true when no error found
// Otherwise returns the error
function TQuestions.Check(var ErrorStr:string):Boolean;
var
  i: Integer;
begin
  if Length(questionsarray) = 0 then begin

    Result:=False;
    ErrorStr:='The quiz file is empty.'#13#10
              +'Please add at least one question with a correct answer.';
    Exit;

  end else begin

    for i := 0 to Length(questionsarray)-1 do begin
      if (questionsarray[i].CorrectAnswer = MaxInt)
          or (questionsarray[i].CorrectAnswer > Length(questionsarray[i].Answers)-1) then begin
        Result:=False;
        ErrorStr:='One or more questions don''t have a correct answer set.'#13#10
                  +'Start checking from Question no. '+inttostr(i+1)+': "'
                  + questionsarray[i].Question + '"';
        Exit;
      end;
      //ShowMessage(IntToStr(questionsarray[i].CorrectAnswer) + '|' +
      //   IntToStr(High(Integer)) + '|' + inttostr(MaxInt));
    end;

  end;

  Result:=True;
end;

procedure TQuestions.OrderQuestion(fromIndex: Integer; toIndex: Integer);
var
  nilQuestions: TQuestionsArray;
  i, takeindex: Integer;
begin
  // We set the length of the nilQuestions before
  // loop because, the length would be the same.
  SetLength(nilQuestions, Length(questionsarray));

  for i := 0 to Length(questionsarray) - 1 do begin
    // We use alternate of fromIndex and toIndex
    // to write both items in switched index positions.
    // For every other index we do not switch index
    // so that they stay in place.
    if i = fromIndex then
      takeindex:=toIndex
    else if i = toIndex then
      takeindex:=fromIndex
    else
      takeindex:=i;

    // Finally, the magic.
    nilQuestions[takeindex] := questionsarray[i];
  end;

  // Now that our nilQuestions array is ready
  // we would just replace the array to our real array
  questionsarray := nilQuestions;
end;

procedure TQuizdata.SaveToFile(AFilename:string = '');
var
  Lines: TStringList;
  i, j:Integer;
  Line: string;
begin
  Lines := TStringList.Create;
  try

    for i := 0 to Questions.Count - 1 do begin
      Line := Questions.questionsarray[i].Question + ' = ';
      for j := 0 to Length(Questions.questionsarray[i].Answers) - 1 do begin
        Line := Line + '|';
        if j = Questions.questionsarray[i].CorrectAnswer then
            Line := Line + ' *';
        Line:=Line+Questions.questionsarray[i].Answers[j];
      end;
      Lines.Add(Line);
    end;

    Lines.Add('End of quiz = | | | |*');
    if AFilename = '' then
      Lines.SaveToFile(QuizFilename)
    else
      Lines.SaveToFile(AFilename);

  finally
    FreeAndNil(Lines);
  end;
end;

procedure TQuestion.AddAnswer(ans: string);
begin
  SetLength(Answers, Length(Answers) + 1);
  Answers[ Length(Answers) - 1 ] := ans;
end;

procedure TQuestion.DeleteAnswer(index: Integer);
var
  arr: TAnswers;
  i: Integer;
begin
  for i := 0 to Length(Answers) - 1 do begin
    // if we find the item to be deleted
    // we simply won't add it to the array
    if i <> index then begin
      SetLength(arr, Length(arr) + 1);
      arr[Length(arr) - 1] := Answers[i];
    end;
  end;

  Answers := arr;
end;

procedure TQuestion.ParseAndAddAnswers(str: String);
var
  parts: TStringList;
  i: Integer;
  ans: string;
begin
  parts:=TStringList.Create;
  try
      // remove the first pipe (|) because it will
      // lead us to all kinds of problems.
      // CorrectAnswer wouldn't be correctly set.
      str:=Trim(str);
      if Pos('|',str) = 1 then str:=RightStr(str,Length(str)-1);

      ExtractStrings(['|'], [], PChar(str), parts);
      for i := 0 to parts.Count - 1 do begin
          if Trim(parts[i]) <> '' then begin
              // set the correct answer
              if Pos('*', parts[i]) <> 0 then
                  CorrectAnswer:=i;
              // get answers and add them
              SetLength(Answers, Length(Answers) + 1);
              ans := parts[i];
              ans := trim( StringReplace(ans,'*','',[]) );
              Answers[Length(Answers) - 1] := ans;
          end;
      end;
  finally
      FreeAndNil(parts);
  end;
end;

procedure TQuestions.AddQuestion(AQuestion: TQuestion);
begin
  SetLength(questionsarray, Length(questionsarray) + 1);
  questionsarray[Length(questionsarray) - 1] := AQuestion;
  Count:=Count+1;
end;

procedure TQuestions.ParseAndAddQuestion(str: String);
var
  parts: TStringList;
  ques: TQuestion;
begin
  parts:=TStringList.Create;
  try
      ExtractStrings(['='], [], PChar(str), parts);
      if parts.Count > 1 then ques.Question:=trim(parts.Strings[0]);
      if parts.Count > 1 then begin
          ques.ParseAndAddAnswers(parts.Strings[1]);
          AddQuestion(ques);
      end;
  finally
      FreeAndNil(parts);
  end;
end;

procedure TQuestions.DeleteQuestion(index:Integer);
var
  NewQuestions: TQuestionsArray;
  i: Integer;
begin
  for i := 0 to Length(questionsarray)-1 do begin
      if i <> index then begin
          setlength(NewQuestions, length(NewQuestions) + 1);
          NewQuestions[Length(NewQuestions) - 1] := questionsarray[i];
      end;
  end;

  questionsarray := NewQuestions;
  Count:=Count-1;
end;

procedure TQuestions.ClearQuestions;
var
  nilQuestionsArray: TQuestionsArray;
begin
  questionsarray := nilQuestionsArray;
  Count:=0;
end;

{ TForm1 }

procedure TForm1.ToolNewClick(Sender: TObject);
begin
  MyQuizData.Questions.ClearQuestions;
  MyQuizData.QuizFilename:='';
  RefreshQuestionList;
  PrepareQuestionPanel(-1);

  Caption:=SOFT_NAME + ' - (Quiz File Not Saved Yet)';
end;

procedure TForm1.lstQuestionsClick(Sender: TObject);
begin
  PrepareQuestionPanel(lstQuestions.ItemIndex);
end;

procedure TForm1.PrepareQuestionPanel(QIndex:Integer);
var
  i: Integer;
begin
  //ShowMessage(MyQuizData.Questions[QIndex].Question +
  //    IntToStr(length(MyQuizData.Questions[QIndex].Answers)));

  // if the item exists in data
  if (QIndex < MyQuizData.Questions.Count) and (QIndex > -1) then begin

      grpQuestionDetails.Visible := True;

      edtQuestion.Text := MyQuizData.Questions.questionsarray[QIndex].Question;
      edtQuestion.SetFocus;

      lstAnswers.Clear;
      cboCorrectAns.Clear;
      for i := 0 to length(MyQuizData.Questions.questionsarray[QIndex].Answers) - 1 do begin
          lstAnswers.Items.Add(MyQuizData.Questions.questionsarray[QIndex].Answers[i]);

          cboCorrectAns.Items.Add(MyQuizData.Questions.questionsarray[QIndex].Answers[i]);
          //ShowMessage('uu '+IntToStr(MyQuizData.Questions.questionsarray[QIndex].CorrectAnswer));
      end;

      cboCorrectAns.ItemIndex := MyQuizData.Questions.questionsarray[QIndex].CorrectAnswer;
      //lblCorrectAns.Caption:=
      //      MyQuizData.Questions[QIndex].Answers[MyQuizData.Questions[QIndex].CorrectAnswer-1];



  end else begin
      edtQuestion.Text:='';
      lstAnswers.Clear;
      cboCorrectAns.Clear;
      grpQuestionDetails.Visible := False;
  end;
end;

procedure TForm1.btnAddQuestionClick(Sender: TObject);
var
  inp: string;
  ques: TQuestion;
begin
  inp := InputBox('Add Question', 'Please enter the question:', '');
  ques.Question:=inp;
  MyQuizData.Questions.AddQuestion(ques);

  RefreshQuestionList;

  // select last question
  lstQuestions.ItemIndex:=lstQuestions.Count-1;
  lstQuestionsClick(Sender);
end;

procedure TForm1.btnDeleteAnsClick(Sender: TObject);
begin
  MyQuizData.Questions.questionsarray[lstQuestions.ItemIndex].DeleteAnswer(lstAnswers.ItemIndex);
  PrepareQuestionPanel(lstQuestions.ItemIndex);
end;

procedure TForm1.btnAddAnsClick(Sender: TObject);
var
  ans: String;
begin
  ans:=InputBox('Add Answer', 'Please Write the Answer Choice:', '');

  if ans <> '' then begin
      //lstAnswers.Items.Add(ans);
      //cboCorrectAns.Items.Add(ans);
      MyQuizData.Questions.questionsarray[lstQuestions.ItemIndex].AddAnswer(ans);
      PrepareQuestionPanel(lstQuestions.ItemIndex);
  end;
end;

procedure TForm1.btnDeleteQuestionClick(Sender: TObject);
var
  index: Integer;
  Reply: Integer;
begin
  index := lstQuestions.ItemIndex;
  Reply := MessageDlg('Delete Question?',
      'Are you sure you want to delete the question'#10#13
      +'"'+ lstQuestions.Items[lstQuestions.ItemIndex]
      +'"?',
      mtConfirmation, [mbYes, mbNo],'');

  if Reply = IDYES then begin
      MyQuizData.Questions.DeleteQuestion(index);
      if index > 0 then lstQuestions.ItemIndex := index - 1;
      RefreshQuestionList;
      PrepareQuestionPanel(lstQuestions.ItemIndex);
  end;
end;

procedure TForm1.btnEditAnsClick(Sender: TObject);
var
  str: string;
begin
  str := InputBox('Edit Answer', 'Edit answer item:',
    lstAnswers.Items[lstAnswers.ItemIndex]);
  MyQuizData.Questions.questionsarray[lstQuestions.ItemIndex].Answers[lstAnswers.ItemIndex]
    := str;
  PrepareQuestionPanel(lstQuestions.ItemIndex);
end;

procedure TForm1.btnMoveDownQuesClick(Sender: TObject);
var
  index:Integer;
begin
  // first we store the selected index on a variable
  index:=lstQuestions.ItemIndex;

  // if it is not the first item selected
  // we do the magic
  if index < lstQuestions.Count - 1 then begin
      MyQuizData.Questions.OrderQuestion(index,index+1);
      lstQuestions.ItemIndex:=index+1;
      RefreshQuestionList;
  end;

end;

procedure TForm1.btnMoveUpQuesClick(Sender: TObject);
var
  index:Integer;
begin
  // first we store the selected index on a variable
  index:=lstQuestions.ItemIndex;

  // if it is not the first item selected
  // we do the magic
  if index > 0 then begin
      MyQuizData.Questions.OrderQuestion(index,index-1);
      lstQuestions.ItemIndex:=index-1;
      RefreshQuestionList;
  end;

end;

procedure TForm1.cboCorrectAnsChange(Sender: TObject);
begin
  // set the correct answer index for the
  // selected question
  MyQuizData.Questions.questionsarray[lstQuestions.ItemIndex].CorrectAnswer:=
    cboCorrectAns.ItemIndex;
end;

procedure TForm1.edtQuestionChange(Sender: TObject);
begin
  if lstQuestions.Items[lstQuestions.ItemIndex] <> edtQuestion.Text then begin
    MyQuizData.Questions.questionsarray[lstQuestions.ItemIndex].Question:=edtQuestion.Text;
    lstQuestions.Items[lstQuestions.ItemIndex]:=edtQuestion.Text;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //
  ToolNewClick(Sender);
end;

procedure TForm1.lblAboutClick(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

procedure TForm1.RefreshQuestionList();
var
  i: Integer;
  index: Integer;
begin
    index := lstQuestions.ItemIndex;
    lstQuestions.Clear;

    //if MyQuizData.Questions.Count > 0 then begin
        for i := 0 to MyQuizData.Questions.Count - 1 do begin
            lstQuestions.Items.Add(MyQuizData.Questions.questionsarray[i].Question);
        end;
    //end;

    if index < lstQuestions.Items.Count then
        lstQuestions.ItemIndex := index;
end;

procedure TForm1.ToolOpenClick(Sender: TObject);
begin
  // open quiz
  with OpenDialog1 do begin
    Execute;
    if FileExistsUTF8(FileName) then begin
      OpenQuizFile(FileName);
    end;
  end;
end;

procedure TForm1.ToolRunClick(Sender: TObject);
var
  str: string;
begin
  if MyQuizData.Questions.Check(str) then begin
      // solution from
      // http://forum.lazarus.freepascal.org/index.php/topic,18442.msg104284.html#msg104284
      Form2 := TForm2.Create(nil);
      Form2.ShowModal;
      Form2.Release;
  end else begin
      ShowMessage('Error: '+str);
  end;
end;

procedure TForm1.ToolSaveAsClick(Sender: TObject);
begin
  if SaveDialog1.Execute then begin
    MyQuizData.SaveToFile(SaveDialog1.FileName);
    MyQuizData.QuizFilename:=SaveDialog1.FileName;

    Caption:=SOFT_NAME + ' - ' + MyQuizData.QuizFilename;
  end;
end;

procedure TForm1.ToolSaveClick(Sender: TObject);
begin
  if MyQuizData.QuizFilename = '' then begin

    {if SaveDialog1.Execute then begin
      MyQuizData.SaveToFile(SaveDialog1.FileName);
      MyQuizData.QuizFilename:=SaveDialog1.FileName;

      Caption:=SOFT_NAME + ' - ' + MyQuizData.QuizFilename;
    end;}
    ToolSaveAsClick(Sender);

  end else begin

    // save the quiz data to the file that we opened
    MyQuizData.SaveToFile();

  end;
end;

procedure TForm1.OpenQuizFile(QuizFile:string);
var
  QuizList: TStringList;
  i: Integer;
begin
  QuizList := TStringList.Create;
  try
    MyQuizData.QuizFilename:=QuizFile;
    Caption := SOFT_NAME + ' - ' + MyQuizData.QuizFilename;

    MyQuizData.Questions.ClearQuestions;
    QuizList.LoadFromFile(QuizFile);

    for i := 0 to QuizList.Count - 1 do begin
      // if the line is not theend of file
      if pos('End of quiz =', QuizList.Strings[i]) = 0 then begin
        MyQuizData.Questions.ParseAndAddQuestion(QuizList.Strings[i]);
      end;
    end;

    RefreshQuestionList;
    PrepareQuestionPanel(-1);

  finally
    FreeAndNil(QuizList);
  end;
end;

end.

