unit mainwindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)

  //Componentes visuales del formulario
  ///////////////////////////
  Attack1: TButton;
  Attack2: TButton;
  Attack3: TButton;
  Attack4: TButton;
  FoeHP: TProgressBar;
  FoeName: TLabel;
  SelfLevel: TLabel;
  FoeLevel: TLabel;
  SelfName: TLabel;
  SelfHP: TProgressBar;
  SelfPicture: TImage;
  FoePicture: TImage;
  Shape1: TShape;
  Textbox: TLabel;
  ////////////////////
  //Componentes de DB
  SQLQuery1: TSQLQuery;
  DataSource1: TDataSource;  //No se usa
  DBConnection: TSQLite3Connection;
  SQLTransaction1: TSQLTransaction;
  //Contenedor para stats

  //Funciones
  procedure FormCreate(Sender: TObject);


  private

  public

  end;

var
  Form1:  TForm1;
  PokeSelf: integer;
  PokeFoe: integer;
  LevelSelf: integer;
  LevelFoe: integer;
  Errenege: integer;
  Isunique: boolean = False;
  SelfStats: array [1..5] of Integer;
  FoeStats: array [1..5] of Integer;
  SelfMoves: array [1..4] of Integer = (0, 0 , 0, 0);
  FoeMoves: array [1..4] of Integer;
  //

  Selfname_var: String;
  FoeName_var: String;

  //Combate

   Damage: integer;
   IsParalyzed: boolean = False;
   IsBurnt: boolean = False;
   DefMod: integer;
   AttMod: integer;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.FormCreate(Sender: TObject);
begin

  Pokeself := StrToInt(InputBox('Select your pokemon number',
  'Your Pokemon number from 1 to 6', '1'));
  Pokefoe := StrToInt(InputBox('Select opponent pokemon number',
  'Enemy Pokemon number from 1 to 6', '1'));
  LevelSelf := StrToInt(InputBox('Select your pokemon level',
  'Level from 1 to 100', '25'));


  //Chapuza increible

  case(PokeSelf) of
  3 :  SelfPicture.Picture.LoadFromFile('back_bulbasaur.png');
  4 :  SelfPicture.Picture.LoadFromFile('back_squirtle.png');
  2 :  SelfPicture.Picture.LoadFromFile('back_charmander.png');
  1 :  SelfPicture.Picture.LoadFromFile('back_pikachu.png');
  5 :  SelfPicture.Picture.LoadFromFile('back_meowth.png');
  6 :  SelfPicture.Picture.LoadFromFile('back_chansey.png');
  else
    Application.Messagebox('Invalid value. Exiting program!', 'Error!', MB_OK);
    Application.Terminate;
  end;
   case(PokeFoe) of
  3 :  FoePicture.Picture.LoadFromFile('front_bulbasaur.png');
  4 :  FoePicture.Picture.LoadFromFile('front_squirtle.png');
  2 :  FoePicture.Picture.LoadFromFile('front_charmander.png');
  1 :  FoePicture.Picture.LoadFromFile('front_pikachu.png');
  5 :  FoePicture.Picture.LoadFromFile('front_meowth.png');
  6 :  FoePicture.Picture.LoadFromFile('front_chansey.png');
  else
    Application.Messagebox('Invalid value. Exiting program!', 'Error!', MB_OK);
    Application.Terminate;
  end;

  //Conexion con la DB
  if DBConnection.Connected then
  DBConnection.Close;
  DBConnection.Open;
  //Datos de la UI


  //Nombres
  SQLQuery1.SQL.Text := 'select NAME from POKEMON where POKEMON_NO = :SelectionSelf';
  SQLQuery1.ParamByName('SelectionSelf').AsInteger := PokeSelf;
  SQLQuery1.Open;
  Selfname_var := SQLQuery1.FieldByName('NAME').AsString;
  SelfName.Caption:= Selfname_var;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text := 'select NAME from POKEMON where POKEMON_NO = :SelectionFoe';
  SQLQuery1.ParamByName('SelectionFoe').AsInteger := PokeFoe;
  SQLQuery1.Open;
  FoeName_var := SQLQuery1.FieldByName('NAME').AsString;
  FoeName.Caption:= FoeName_var;
  SQLQuery1.Close;

  //Niveles

  SelfLevel.Caption := InttoStr(LevelSelf);
  LevelFoe := ((Random(6) + LevelSelf) - 3);
  FoeLevel.Caption := InttoStr(LevelFoe);

  //Stats


      SQLQuery1.SQL.Text := 'select HP, ATTACK, DEFENSE, SPECIAL, SPEED from POKEMON where POKEMON_NO = :SelectionSelf';
      SQLQuery1.ParamByName('SelectionSelf').AsInteger := PokeSelf;
      SQLQuery1.Open;
      SelfStats[1] := SQLQuery1.FieldByName('HP').AsInteger;
      SelfStats[2] := SQLQuery1.FieldByName('ATTACK').AsInteger;
      SelfStats[3] := SQLQuery1.FieldByName('DEFENSE').AsInteger;
      SelfStats[4] := SQLQuery1.FieldByName('SPECIAL').AsInteger;
      SelfStats[5] := SQLQuery1.FieldByName('SPEED').AsInteger;
      SQLQuery1.Close;

      SelfHP.Max := SelfStats[1];
      SelfHP.Position := SelfHP.Max;

      SQLQuery1.SQL.Text := 'select HP, ATTACK, DEFENSE, SPECIAL, SPEED from POKEMON where POKEMON_NO = :SelectionFoe';
      SQLQuery1.ParamByName('SelectionFoe').AsInteger := PokeSelf;
      SQLQuery1.Open;
      FoeStats[1] := SQLQuery1.FieldByName('HP').AsInteger;
      FoeStats[2] := SQLQuery1.FieldByName('ATTACK').AsInteger;
      FoeStats[3] := SQLQuery1.FieldByName('DEFENSE').AsInteger;
      FoeStats[4] := SQLQuery1.FieldByName('SPECIAL').AsInteger;
      FoeStats[5] := SQLQuery1.FieldByName('SPEED').AsInteger;
      SQLQuery1.Close;

      FoeHP.Max := FoeStats[1];
      FoeHP.Position := FoeHP.Max;
  //Movimientos

      case(PokeSelf) of


      //PIKACHU
      1: SelfMoves[1] := 7;
         SelfMoves[2] := 2;
         SelfMoves[3] := 3;
         SelfMoves[4] := 11;
      //BULBASAUR
      2: SelfMoves[1] := 4;
         SelfMoves[2] := 3;
         SelfMoves[3] := 9;
         SelfMoves[4] := 2;
      //SQUIRTLE
      3: SelfMoves[1] := 6;
         SelfMoves[2] := 8;
         SelfMoves[3] := 3;
         SelfMoves[4] := 2;
      //CHARMANDER
      4: SelfMoves[1] := 5;
         SelfMoves[2] := 8;
         SelfMoves[3] := 9;
         SelfMoves[4] := 2;
      //MEOWTH
      5: SelfMoves[1] := 9;
         SelfMoves[2] := 6;
         SelfMoves[3] := 11;
         SelfMoves[4] := 2;
      //CHANSEY
      6: SelfMoves[1] := 10;
         SelfMoves[2] := 12;
         SelfMoves[3] := 7;
         SelfMoves[4] := 11;
      end;


  end;





end.

