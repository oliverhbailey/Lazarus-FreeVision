//image image.png
(*
Hier wird ein About-Dialog erstellt, das sieht man gut für was man Label gebrauchen kann.
*)
//lineal
program Project1;

uses
  SysUtils, // Für Dateioperationen
  App,      // TApplication
  Objects,  // Fensterbereich (TRect)
  Drivers,  // Hotkey
  Views,    // Ereigniss (cmQuit)
  Menus,    // Statuszeile
  MsgBox,   // Messageboxen
  Dialogs;  // Dialoge

(*
Die Datei, in welcher sich die Daten für den Dialog befinden.
*)
//code+
const
  DialogDatei = 'parameter.cfg';
  //code-

  cmAbout = 1001;     // About anzeigen
  cmList = 1002;      // Datei Liste
  cmPara = 1003;      // Parameter

type
  TParameterData = record
    Druck,
    Schrift: longword;
    Hinweis: string[50];
  end;

(*
Eine neue Funktion <b>About</b> ist hinzugekommen.
*)
  //code+
type
  TMyApp = object(TApplication)
    ParameterData: TParameterData;                     // Parameter für Dialog.
    fParameterData: file of TParameterData;            // File-Hander füe das speichern/laden der Daten des Dialoges.

    constructor Init;                                  // Neuer Constructor

    procedure InitStatusLine; virtual;                 // Statuszeile
    procedure InitMenuBar; virtual;                    // Menü
    procedure HandleEvent(var Event: TEvent); virtual; // Eventhandler
    procedure OutOfMemory; virtual;                    // Wird aufgerufen, wen Speicher überläuft.

    procedure MyParameter;                             // neue Funktion für einen Dialog.
    procedure About;                                   // About Dialog.
  end;
  //code-

  constructor TMyApp.Init;
  begin
    inherited Init;
    // Prüfen ob Datei vorhanden.
    if FileExists(DialogDatei) then begin
      // Daten von Platte laden.
      AssignFile(fParameterData, DialogDatei);
      Reset(fParameterData);
      Read(fParameterData, ParameterData);
      CloseFile(fParameterData);
      // ansonsten Default-Werte nehmen.
    end else begin
      with ParameterData do begin
        Druck := %0101;
        Schrift := 2;
        Hinweis := 'Hello world !';
      end;
    end;
  end;

  procedure TMyApp.InitStatusLine;
  var
    Rect: TRect;              // Rechteck für die Statuszeilen Position.

    P0: PStatusDef;           // Pointer ganzer Eintrag.
    P1, P2, P3: PStatusItem;  // Poniter auf die einzelnen Hot-Key.
  begin
    GetExtent(Rect);
    Rect.A.Y := Rect.B.Y - 1;

    P3 := NewStatusKey('~F1~ Hilfe', kbF1, cmHelp, nil);
    P2 := NewStatusKey('~F10~ Menu', kbF10, cmMenu, P3);
    P1 := NewStatusKey('~Alt+X~ Programm beenden', kbAltX, cmQuit, P2);
    P0 := NewStatusDef(0, $FFFF, P1, nil);

    StatusLine := New(PStatusLine, Init(Rect, P0));
  end;

  procedure TMyApp.InitMenuBar;
  var
    Rect: TRect;                       // Rechteck für die Menüzeilen-Position.

    M: PMenu;                          // Ganzes Menü
    SM0, SM1, SM2,                     // Submenu
    M0_0, M0_2, M0_3, M0_4, M0_5,
    M1_0, M2_0: PMenuItem;             // Einfache Menüpunkte

  begin
    GetExtent(Rect);
    Rect.B.Y := Rect.A.Y + 1;

    M2_0 := NewItem('~A~bout...', '', kbNoKey, cmAbout, hcNoContext, nil);
    SM2 := NewSubMenu('~H~ilfe', hcNoContext, NewMenu(M2_0), nil);

    M1_0 := NewItem('~P~arameter...', '', kbF2, cmPara, hcNoContext, nil);
    SM1 := NewSubMenu('~O~ption', hcNoContext, NewMenu(M1_0), SM2);

    M0_5 := NewItem('~B~eenden', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil);
    M0_4 := NewLine(M0_5);
    M0_3 := NewItem('S~c~hliessen', 'Alt-F3', kbAltF3, cmClose, hcNoContext, M0_4);
    M0_2 := NewLine(M0_3);
    M0_0 := NewItem('~L~iste', 'F2', kbF2, cmList, hcNoContext, M0_2);
    SM0 := NewSubMenu('~D~atei', hcNoContext, NewMenu(M0_0), SM1);

    M := NewMenu(SM0);

    MenuBar := New(PMenuBar, Init(Rect, M));
  end;

(*
Hier wird das About augerufen, wen im Menü About gewält wird.
*)
  //code+
  procedure TMyApp.HandleEvent(var Event: TEvent);
  begin
    inherited HandleEvent(Event);

    if Event.What = evCommand then begin
      case Event.Command of
        cmAbout: begin
          About;   // About Dialog aufrufen
        end;
        cmList: begin
        end;
        cmPara: begin
          MyParameter;
        end;
        else begin
          Exit;
        end;
      end;
    end;
    ClearEvent(Event);
  end;
  //code-

  procedure TMyApp.OutOfMemory;
  begin
    MessageBox('Zu wenig Arbeitsspeicher !', nil, mfError + mfOkButton);
  end;

  procedure TMyApp.MyParameter;
  var
    Dia: PDialog;
    Rect: TRect;
    dummy: word;
    Ptr: PView;
  begin
    Rect.Assign(0, 0, 35, 15);
    Rect.Move(23, 3);
    Dia := New(PDialog, Init(Rect, 'Parameter'));
    with Dia^ do begin

      // CheckBoxen
      Rect.Assign(2, 3, 18, 7);
      Ptr := New(PCheckBoxes, Init(Rect,
        NewSItem('~D~atei',
        NewSItem('~Z~eile',
        NewSItem('D~a~tum',
        NewSItem('~Z~eit',
        nil))))));
      Insert(Ptr);
      // Label für CheckGroup.
      Rect.Assign(2, 2, 10, 3);
      Insert(New(PLabel, Init(Rect, 'Dr~u~cken', Ptr)));

      // RadioButton
      Rect.Assign(21, 3, 33, 6);
      Ptr := New(PRadioButtons, Init(Rect,
        NewSItem('~G~ross',
        NewSItem('~M~ittel',
        NewSItem('~K~lein',
        nil)))));
      Insert(Ptr);
      // Label für RadioGroup.
      Rect.Assign(20, 2, 31, 3);
      Insert(New(PLabel, Init(Rect, '~S~chrift', Ptr)));

      // Edit Zeile
      Rect.Assign(3, 10, 32, 11);
      Ptr := New(PInputLine, Init(Rect, 50));
      Insert(Ptr);
      // Label für Edit Zeile
      Rect.Assign(2, 9, 10, 10);
      Insert(New(PLabel, Init(Rect, '~H~inweis', Ptr)));

      // Ok-Button
      Rect.Assign(7, 12, 17, 14);
      Insert(new(PButton, Init(Rect, '~O~K', cmOK, bfDefault)));

      // Schliessen-Button
      Rect.Assign(19, 12, 32, 14);
      Insert(new(PButton, Init(Rect, '~A~bbruch', cmCancel, bfNormal)));
    end;
    if ValidView(Dia) <> nil then begin // Prüfen ob genügend Speicher.
      Dia^.SetData(ParameterData);      // Dialog mit den Werten laden.
      dummy := Desktop^.ExecView(Dia);  // Dialog ausführen.
      if dummy = cmOK then begin        // Wen Dialog mit Ok beenden, dann Daten vom Dialog in Record laden.
        Dia^.GetData(ParameterData);

        // Daten auf Platte speichern.
        AssignFile(fParameterData, DialogDatei);
        Rewrite(fParameterData);
        Write(fParameterData, ParameterData);
        CloseFile(fParameterData);
      end;

      Dispose(Dia, Done);               // Dialog und Speicher frei geben.
    end;
  end;

(*
About Dialog erstellen.
Mit <b>TRext.Grow(...</b> kann man das Rect verkleinern und vergrössern.
Mit <b>#13</b> kann man eine Zeilenumbruch einfügen.
Mit <b>#3</b> wird der Text horizontal im Rect zentriert.
Mit <b>#2</b> wird der Text rechtbündig geschrieben.

Mit <b>PLabel</b> könnte man auch Text ausgeben, aber für festen Text eignet sich <b>PStaticText</b> besser.
*)
  //code+
  procedure TMyApp.About;
  var
    Dia: PDialog;
    Rect: TRect;
  begin
    Rect.Assign(0, 0, 42, 11);
    Rect.Move(1, 1);
    Dia := New(PDialog, Init(Rect, 'About'));
    with Dia^ do begin
      Options := Options or ofCentered; // Dialog zentrieren

      // StaticText einfügen.
      Rect.Assign(2, 2, 40, 8);
      Insert(New(PStaticText, Init(Rect,
        #13 +
        'Free Vison Tutorial 1.0' + #13 +
        '2017' + #13 +
        #3 + 'Zentriert' + #13 +
        #2 + 'Rechts')));
      Rect.Assign(16, 8, 26, 10);
      Insert(New(PButton, Init(Rect, '~O~K', cmOK, bfDefault)));
    end;
    if ValidView(Dia) <> nil then begin
      Desktop^.ExecView(Dia);           // Modal aufrufen, Funktionsergebniss wird nicht ausgewrtet.
      Dispose(Dia, Done);               // Dialog frei geben.
    end;
  end;
  //code-

var
  MyApp: TMyApp;

begin
  MyApp.Init;   // Inizialisieren
  MyApp.Run;    // Abarbeiten
  MyApp.Done;   // Freigeben
end.
