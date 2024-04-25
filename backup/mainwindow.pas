unit mainwindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, LCLType, cthreads;

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

  //Funciones del formulario
  procedure Attack2Click(Sender: TObject);
  procedure Attack3Click(Sender: TObject);
  procedure Attack4Click(Sender: TObject);
  procedure FormCreate(Sender: TObject);
  procedure Attack1Click(Sender: TObject);


  //Funciones de batalla
  procedure BattleFlow(x: integer);
  procedure AttackSelf(chosen: integer);
  procedure DamageFormula(chosen: integer);

  private

  public

  end;

var
  Form1:  TForm1;
  PokeSelf: integer;
  PokeFoe: integer;
  LevelSelf: integer;
  LevelFoe: integer;
  AttackUsed: String;
  TypeAttacker: Integer;
  TypeAttack: Integer;
  TypeDefender: Integer;
  Matchup: Integer;
  SelfStats: array [1..5] of integer;
  SelfBuff: array[1..5] of Integer;
  FoeStats: array [1..5] of integer;
  FoeBuff: array [1..5] of integer;
  SelfMoves: array [1..4] of integer;
  FoeMoves: array [1..4] of integer;
  //

  Selfname_var: String;
  FoeName_var: String;

  //Combate
   MoveSelSelf: Integer;
   MoveSelFoe: Integer;
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
      FoeStats[1] := round((SQLQuery1.FieldByName('HP').AsInteger) * 2 * (LevelFoe / 50));
      FoeStats[2] := SQLQuery1.FieldByName('ATTACK').AsInteger;
      FoeStats[3] := SQLQuery1.FieldByName('DEFENSE').AsInteger;
      FoeStats[4] := SQLQuery1.FieldByName('SPECIAL').AsInteger;
      FoeStats[5] := SQLQuery1.FieldByName('SPEED').AsInteger;
      SQLQuery1.Close;

      FoeHP.Max := FoeStats[1];
      FoeHP.Position := FoeHP.Max;
  //Movimientos

      case (PokeSelf) of
        //PIKACHU
        1:
           begin
           SelfMoves[1] := 7;
           SelfMoves[2] := 2;
           SelfMoves[3] := 3;
           SelfMoves[4] := 11;
           end;
        //BULBASAUR
        3:
           begin
           SelfMoves[1] := 4;
           SelfMoves[2] := 3;
           SelfMoves[3] := 9;
           SelfMoves[4] := 2;
           end;
        //SQUIRTLE
        4:
           begin
           SelfMoves[1] := 6;
           SelfMoves[2] := 8;
           SelfMoves[3] := 3;
           SelfMoves[4] := 2;
           end;
        //CHARMANDER
        2:
           begin
           SelfMoves[1] := 5;
           SelfMoves[2] := 8;
           SelfMoves[3] := 9;
           SelfMoves[4] := 2;
           end;
        //MEOWTH
        5:
           begin
           SelfMoves[1] := 9;
           SelfMoves[2] := 6;
           SelfMoves[3] := 11;
           SelfMoves[4] := 2;
           end;
        //CHANSEY
        6:
           begin
           SelfMoves[1] := 10;
           SelfMoves[2] := 12;
           SelfMoves[3] := 7;
           SelfMoves[4] := 11;
           end;
      end;

      case (PokeFoe) of
        //PIKACHU
        1:
           begin
           FoeMoves[1] := 7;
           FoeMoves[2] := 2;
           FoeMoves[3] := 3;
           FoeMoves[4] := 11;
           end;
        //BULBASAUR
        3:
           begin
           FoeMoves[1] := 4;
           FoeMoves[2] := 3;
           FoeMoves[3] := 9;
           FoeMoves[4] := 2;
           end;
        //SQUIRTLE
        4:
           begin
           FoeMoves[1] := 6;
           FoeMoves[2] := 8;
           FoeMoves[3] := 3;
           FoeMoves[4] := 2;
           end;
        //CHARMANDER
        2:
           begin
           FoeMoves[1] := 5;
           FoeMoves[2] := 8;
           FoeMoves[3] := 9;
           FoeMoves[4] := 2;
           end;
        //MEOWTH
        5:
           begin
           FoeMoves[1] := 9;
           FoeMoves[2] := 6;
           FoeMoves[3] := 11;
           FoeMoves[4] := 2;
           end;
        //CHANSEY
        6:
           begin
           FoeMoves[1] := 10;
           FoeMoves[2] := 12;
           FoeMoves[3] := 7;
           FoeMoves[4] := 11;
           end;
      end;

      //Populate Moves

      SQLQuery1.SQL.Text := 'select NAME from MOVES where MOVE_NO = :MoveIndex';
      SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[1];
      SQLQuery1.Open;
      Attack1.Caption:= SQLQuery1.FieldByName('NAME').AsString;
      SQLQuery1.Close;

      SQLQuery1.SQL.Text := 'select NAME from MOVES where MOVE_NO = :MoveIndex';
      SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[2];
      SQLQuery1.Open;
      Attack2.Caption:= SQLQuery1.FieldByName('NAME').AsString;
      SQLQuery1.Close;

      SQLQuery1.SQL.Text := 'select NAME from MOVES where MOVE_NO = :MoveIndex';
      SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[3];
      SQLQuery1.Open;
      Attack3.Caption:= SQLQuery1.FieldByName('NAME').AsString;
      SQLQuery1.Close;

      SQLQuery1.SQL.Text := 'select NAME from MOVES where MOVE_NO = :MoveIndex';
      SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[4];
      SQLQuery1.Open;
      Attack4.Caption:= SQLQuery1.FieldByName('NAME').AsString;
      SQLQuery1.Close;

      Textbox.Caption:= Format('The TRAINER sent: %s', [FoeName_var]);
      SelfBuff[1] := 0;
    end;



    procedure Delay(dt: DWORD);
    var
      tc : DWORD;
    begin
      tc := GetTickCount64;
      while (GetTickCount64 < tc + dt) and (not Application.Terminated) do
        Application.ProcessMessages;
        end;


    procedure Tform1.DamageFormula(chosen: integer);
    var damage: integer = 0;
    begin
        SQLQuery1.SQL.Text := 'select POWER from MOVES where MOVE_NO = :MoveIndex';
        SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[chosen];
        SQLQuery1.Open;
        damage := SQLQuery1.FieldByName('POWER').AsInteger;
        SQLQuery1.Close;

        if (damage = 0) then
        begin
           case (SelfMoves[chosen]) of
           2:
              begin
                   delay(1000);
                   Textbox.Caption:= Format('%s ATTACK was lowered!', [FoeName_var]);
                   FoeStats[2] := round(FoeStats[2] - (FoeStats[2] * 0.33));

              end;
           3:
              begin
                   delay(1000);
                   Textbox.Caption:= Format('%s DEFENSE was lowered!', [FoeName_var]);
                   FoeStats[3] := round(FoeStats[3] - (FoeStats[3] * 0.33));
              end;
           12:
              begin

                   FoeStats[1] := round(FoeStats[1] + (FoeStats[3] * 0.5));
                   if (Foestats[1] > SelfHP.Max)
                   then
                         begin
                         FoeStats[1] := SelfHP.Max;
                         Textbox.Caption:= Format('%s HP maxed out!', [SelfName_var])

                         end
                   else
                        begin
                        Textbox.Caption:= Format('%s Recovered health!', [SelfName_var])
                        end



              end


           //Todo lo que reduce salud
           else
                    begin
                    SQLQuery1.SQL.Text := 'select TYPE from MOVES where MOVE_NO = :MoveIndex';
                    SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[chosen];
                    SQLQuery1.Open;
                    TypeAttack := SQLQuery1.FieldByName('TYPE').AsInteger;
                    SQLQuery1.Close;

                    SQLQuery1.SQL.Text := 'select TYPE from POKEMON where POKEMON_NO = :ChosenPoke';
                    SQLQuery1.ParamByName('ChosenPoke').AsInteger := Pokeself;
                    SQLQuery1.Open;
                    TypeAttacker := SQLQuery1.FieldByName('TYPE').AsInteger;
                    SQLQuery1.Close;


                    SQLQuery1.SQL.Text := 'select TYPE from POKEMON where POKEMON_NO = :ChosenPoke';
                    SQLQuery1.ParamByName('ChosenPoke').AsInteger := Pokefoe;
                    SQLQuery1.Open;
                    TypeDefender := SQLQuery1.FieldByName('TYPE').AsInteger;
                    SQLQuery1.Close;

                    if (TypeAttacker = TypeAttack)
                    then
                    damage := round(damage * 1.5);


                    SQLQuery1.SQL.Text := 'select T_MODIFIER from MATCHUPS where T_ATTACK = :ChosenMove and T_FOE =: ChosenFoe';
                    SQLQuery1.ParamByName('ChosenMove').AsInteger := Selfmoves[chosen];
                    SQLQuery1.ParamByName('ChosenFoe').AsInteger := TypeDefender;
                    SQLQuery1.Open;
                    if (SQLQuery1.FieldByName('T_MODIFIER').IsNull)
                    then
                    Matchup := 0
                    else
                    Matchup := SQLQuery1.FieldByName('T_MATCHUP').AsInteger;

                    SQLQuery1.Close;

                    if (Matchup = 1)
                    then

                    begin
                    damage := round(damage * 2);
                    Textbox.Caption:= ('It was super effective!')
                    end

                    else if (Matchup = 2)
                    then

                    begin
                    damage := round(damage * 0.5);
                    Textbox.Caption:= ('Its not very effective!');
                    end;


              end

           end;
         end;
        FoeHP.Position := FoeHP.Position - damage;
       end;



    procedure TForm1.AttackSelf(chosen: integer);
    begin
         Delay(1000);
         SQLQuery1.SQL.Text := 'select NAME from MOVES where MOVE_NO = :MoveIndex';
         SQLQuery1.ParamByName('MoveIndex').AsInteger := SelfMoves[chosen];
         SQLQuery1.Open;
         AttackUsed:= SQLQuery1.FieldByName('NAME').AsString;
         SQLQuery1.Close;
         Textbox.Caption:= Format('%s used %s!', [SelfName_var, AttackUsed]);
         Delay(1000);
         DamageFormula(chosen);

    end;

    procedure TForm1.BattleFlow(x: integer);

    begin

          Attack1.Enabled := False;
          Attack2.Enabled := False;
          Attack3.Enabled := False;
          Attack4.Enabled := False;
          AttackSelf(x);



    end;


    procedure TForm1.Attack1Click(Sender: TObject);

      begin
          Battleflow(1);
      end;

    procedure TForm1.Attack2Click(Sender: TObject);
      begin
         Battleflow(2);
      end;

    procedure TForm1.Attack3Click(Sender: TObject);
      begin
         Battleflow(3);
      end;

    procedure TForm1.Attack4Click(Sender: TObject);
      begin
         Battleflow(4);
      end;




end.

