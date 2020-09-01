//image image.png
(*
Dialog um Buttons ergänzen.
*)
//lineal
program Project1;

uses
  App,      // TApplication
  Objects,  // Fensterbereich (TRect)
  Drivers,  // Hotkey
  Views,    // Ereigniss (cmQuit)
  Menus,    // Statuszeile
  Dialogs;  // Dialoge

const
  cmAbout = 1001;     // About anzeigen
  cmPara = 1003;      // Parameter
  cmMenuEnlish = 1005;
  cmMenuGerman = 1006;

type

  { TMyApp }

  TMyApp = object(TApplication)
    procedure InitStatusLine; virtual;                 // Statuszeile
    procedure InitMenuBar; virtual;                    // Menü
    procedure HandleEvent(var Event: TEvent); virtual; // Eventhandler

    procedure MyParameter;
    // neue Funktion für einen Dialog.
  private
    menuGer, menuEng: PMenu;
    StatusGer, StatusEng: PStatusDef;
  end;

  procedure TMyApp.InitStatusLine;
  var
    Rect: TRect;              // Rechteck für die Statuszeilen Position.

  begin
    GetExtent(Rect);
    Rect.A.Y := Rect.B.Y - 1;

    StatusGer := NewStatusDef(0, $FFFF,
    NewStatusKey('~Alt+X~ Programm beenden', kbAltX, cmQuit,
    NewStatusKey('~F10~ Menue', kbF10, cmMenu,
    NewStatusKey('~F1~ Hilfe', kbF1, cmHelp, nil))), nil);

    StatusEng := NewStatusDef(0, $FFFF,
    NewStatusKey('~Alt+X~ Exit', kbAltX, cmQuit,
    NewStatusKey('~F10~ Menu', kbF10, cmMenu,
    NewStatusKey('~F1~ Help', kbF1, cmHelp, nil))), nil);

    StatusLine := New(PStatusLine, Init(Rect, StatusGer));
  end;

  procedure TMyApp.InitMenuBar;
  var
    Rect: TRect;                       // Rechteck für die Menüzeilen-Position.

  begin

    menuGer := NewMenu(
      NewSubMenu('~D~atei', hcNoContext, NewMenu(
        NewItem('S~c~hliessen', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
        NewLine(
        NewItem('~B~eenden', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil)))),
      NewSubMenu('~O~ptionen', hcNoContext, NewMenu(
        NewItem('~P~arameter...', '', kbF2, cmPara, hcNoContext,
        NewLine(
        NewItem('~D~eutsch', 'Alt-D', kbAltD, cmMenuGerman, hcNoContext,
        NewItem('~E~nglisch', 'Alt-E', kbAltE, cmMenuEnlish, hcNoContext, nil))))),
      NewSubMenu('~H~ilfe', hcNoContext, NewMenu(
        NewItem('~A~bout...', '', kbNoKey, cmAbout, hcNoContext, nil)), nil))));

    menuEng := NewMenu(
      NewSubMenu('~F~ile', hcNoContext, NewMenu(
        NewItem('~P~arameters...', '', kbF2, cmPara, hcNoContext,
        NewLine(
        NewItem('~C~lose', 'Alt-F3', kbAltF3, cmClose, hcNoContext,
        NewLine(
        NewItem('E~x~it', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil)))))),
      NewSubMenu('~O~ptions', hcNoContext, NewMenu(
        NewItem('German', 'Alt-D', kbAltD, cmMenuGerman, hcNoContext,
        NewItem('English', 'Alt-E', kbAltE, cmMenuEnlish, hcNoContext, nil))),
      NewSubMenu('~H~elp', hcNoContext, NewMenu(
        NewItem('~A~bout...', '', kbNoKey, cmAbout, hcNoContext, nil)), nil))));

    GetExtent(Rect);
    Rect.B.Y := Rect.A.Y + 1;
    MenuBar := New(PMenuBar, Init(Rect, menuGer));
  end;

  procedure TMyApp.HandleEvent(var Event: TEvent);
  begin
    inherited HandleEvent(Event);

    if Event.What = evCommand then begin
      case Event.Command of
        cmAbout: begin
        end;
        cmMenuEnlish: begin
          MenuBar^.Menu := menuEng;
          MenuBar^.Draw;
          StatusLine^.Defs := StatusEng;
          StatusLine^.Draw;
          ReDraw;
        end;
        cmMenuGerman: begin
          MenuBar^.Menu := menuGer;
          MenuBar^.Draw;
          StatusLine^.Defs := StatusGer;
          StatusLine^.Draw;
          ReDraw;
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

(*
Den Dialog mit Buttons ergänzen.
Mit <b>Insert</b> fügt man die Komponenten hinzug, in diesem Fall sind es die Buttons.
Mit bfDefault legt man den Default-Button fest, dieser wird mit <b>[Enter]</b> aktiviert.
bfNormal ist ein gewöhnlicher Button.
Der Dialog wird nun Modal geöffnet, somit können <b>keine</b> weiteren Dialoge geöffnet werden.
dummy hat den Wert, des Button der gedrückt wurde, dies entspricht dem <b>cmxxx</b> Wert.
Die Höhe der Buttons muss immer <b>2</b> sein, ansonsten gibt es eine fehlerhafte Darstellung.
*)
  //code+
  procedure TMyApp.MyParameter;
  var
    Dia: PDialog;
    Rect: TRect;
    dummy: word;
  begin
    Rect.Assign(0, 0, 35, 15);                    // Grösse des Dialogs.
    Rect.Move(23, 3);                             // Position des Dialogs.
    Dia := New(PDialog, Init(Rect, 'Parameter')); // Dialog erzeugen.
    with Dia^ do begin

      // Ok-Button
      Rect.Assign(7, 12, 17, 14);
      Insert(new(PButton, Init(Rect, '~O~K', cmOK, bfDefault)));

      // Schliessen-Button
      Rect.Assign(19, 12, 32, 14);
      Insert(new(PButton, Init(Rect, '~A~bbruch', cmCancel, bfNormal)));
    end;
    dummy := Desktop^.ExecView(Dia);   // Dialog Modal öffnen.
    Dispose(Dia, Done);                // Dialog und Speicher frei geben.
  end;
  //code-

var
  MyApp: TMyApp;

begin
  MyApp.Init;   // Inizialisieren
  MyApp.Run;    // Abarbeiten
  MyApp.Done;   // Freigeben
end.
