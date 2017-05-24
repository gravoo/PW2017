--Bartlomiej Sadowski 204392
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Hashed_Maps;
use Ada.Containers;
use Ada.Text_IO;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    type Train_ID is range 1..4;
    type Track_ID is range 0..100;
    type Steering_ID is range 0..10;
    type Edge_ID is range 0..10;
    type Track_Type is (Stop_Track, Drive_Track);
    subtype Stop_Track_ID is Track_ID range 0..3;
    subtype Drive_Track_ID is Track_ID range 0..3;

    function ID_Hashed (Id : Steering_ID) return Hash_Type is
    begin
       return Hash_Type'Val (Steering_ID'Pos (Id));
    end ID_Hashed;

    protected type TrackThread is 
        procedure InitDriveTrack(
            My_ID : in Track_ID;
            Track_Velocity : Natural; 
            Track_Length : Natural);
        procedure InitStopTrack(
            My_ID : Track_ID;
            Track_Time_To_Wait : Natural);
        entry Wait_For_Clear;
        entry Request_TravelTrough(TrainID : Train_ID);
        entry Check_TrackType(TrackType : out Track_Type);
        entry Release_Track(TrainID : Train_ID);
        entry Wait_OnStation(Wait_OnTrackTime : out Integer);
        entry Drive_Trough(Length : out Integer; MaxVelocity : out Integer);
    private
        Clear: Boolean := True;
        ID : Track_ID := 0;
        My_Track_Type : Track_Type := Stop_Track;
        My_Track_Length : Natural := 20;
        My_Track_Max_Velocity : Natural := 10; 
        My_Track_Time_To_Wait : Natural := 10;
    end TrackThread;

    type Track_Access is access all TrackThread;
    package Track_Vector is new Vectors(Track_ID, Track_Access);
    package SteeringToTracks_Vector is new Vectors(Steering_ID, Track_Access);
    package SteeringTrack_Map is new Ada.Containers.Hashed_Maps
        (Element_Type => Track_Access,
         Key_Type => Steering_ID,
         Hash => ID_Hashed,
         Equivalent_Keys => "=");

    task type SteeringThread is 
        entry Request_AssignTrack(TrainID : in Train_ID; Next_Steering : in Steering_ID;
        Track_InUse : out Track_Access);
        entry Init( My_ID : in Steering_ID);
        entry Request_ReconfigSteering;
    end SteeringThread;

    type Stop_Track_Type is array (Stop_Track_ID) of TrackThread;
    type Drive_Track_Type is array (Drive_Track_ID) of TrackThread;
    type Steering_Type is array (Steering_ID) of SteeringThread;
    type Steering_Access is access SteeringThread;
    type Route_Array_Type is array (positive range <>) of Edge_ID;
    type Route_Array_Access is access Route_Array_Type;
    Stop_Track_Pool : Stop_Track_Type;
    Drive_Track_Pool : Drive_Track_Type;
    Steering_Pool : Steering_Type;

    package Steering_Vector is new Vectors(Steering_ID, Steering_Access);
    Steerings : Steering_Vector.Vector;
    Train1Route : Steering_Vector.Vector;
    Train2Route : Steering_Vector.Vector;
    Train3Route : Steering_Vector.Vector;
    Train4Route : Steering_Vector.Vector;

    task type TrainThread is
        entry Init(My_ID : Train_ID; Route_Array : Route_Array_Access);
    end TrainThread;
    type Train_Access is access TrainThread;
    type Train_Type_Pool is array (Train_ID) of TrainThread;
    Train_Pool : Train_Type_Pool;

    package Train_Vector is new Vectors(Train_ID, Train_Access);
    StopTracks : Track_Vector.Vector;
    DriveTracks : Track_Vector.Vector;

    task body TrainThread is
        My_Track : Track_Access;
        My_TrackType : Track_Type;
        Next_Steering: Steering_ID;
        Track_To_Release : Track_Access;
        Wait_Time : Integer;
        Track_MaxVelocity : Integer;
        Track_Length : Integer;
        ID : Train_ID;
        Velocity : Integer;
        My_Steering : Steering_ID;
        My_Route : Route_Array_Access;
    begin
        accept Init(My_ID : Train_ID; Route_Array : Route_Array_Access) do
            ID:= My_ID;
            My_Route := Route_Array;
        end Init;
    end TrainThread;

    task body SteeringThread is
        My_Neighbours : SteeringTrack_Map.Map;
        ID : Steering_ID;
    begin
        accept Init(My_ID : in Steering_ID) do
            ID := My_ID;
        end Init;
        loop
            select
            accept Request_AssignTrack(TrainID : in Train_ID; Next_Steering : in Steering_ID;
                   Track_InUse : out Track_Access)  do 
                   Put_Line("steering id: " & Steering_ID'Image(ID) & " Target steering: " & Steering_ID'Image(Next_Steering));
                   Track_InUse := My_Neighbours(Next_Steering); 
            end Request_AssignTrack;
            or
            accept Request_ReconfigSteering do
                    delay 5.0;
            end Request_ReconfigSteering;
        end select;
        end loop;
    end SteeringThread;

    protected body TrackThread is
        procedure InitDriveTrack(
            My_ID : in Track_ID;
            Track_Velocity : Natural; 
            Track_Length : Natural) is
        begin 
            ID := My_ID;
            My_Track_Type := Drive_Track;
            My_Track_Length := Track_Length;
            My_Track_Max_Velocity := Track_Velocity;
        end InitDriveTrack;
        procedure InitStopTrack(
            My_ID : Track_ID;
            Track_Time_To_Wait : Natural) is
        begin
            ID := My_ID;
            My_Track_Time_To_Wait := Track_Time_To_Wait;
        end InitStopTrack;
        entry Wait_For_Clear
        when Clear is
        begin
            null;
        end;
        entry Request_TravelTrough(TrainID : Train_ID)
        when Clear is
        begin
            Put_Line("Track Thread task; train: "& Train_ID'Image (TrainID) & " on track: " & Track_ID'Image(ID)
                & " " & Track_Type'Image(My_Track_Type));
            Clear := False;
        end;
        entry Release_Track(TrainID : Train_ID)
        when not Clear is
        begin
            Clear := True;
            Put_Line("Track Thread task; Train: "& Train_ID'Image (TrainID) &
                " released track " & Track_Type'Image(My_Track_Type) & " " & Track_ID'Image(ID));
        end;
        entry Check_TrackType(TrackType : out Track_Type)
        when not Clear is
        begin
            TrackType := My_Track_Type;
        end;
        entry Wait_OnStation(Wait_OnTrackTime : out Integer)
        when not Clear is
        begin
             Wait_OnTrackTime := My_Track_Time_To_Wait;  
        end;
        entry Drive_Trough(Length : out Integer; MaxVelocity : out Integer)
        when not Clear is
        begin
            Length := My_Track_Length;
            MaxVelocity := My_Track_Max_Velocity;
        end;
    end TrackThread;
    Trains : Train_Vector.Vector;

    type Edge is record
        NeighbourSteering : Steering_ID;
        Weight : Natural := 10;
    end record;
    type Edges_Type is array (Edge_ID) of Edge;
    Edges_Pool : Edges_Type;

    procedure Inicialize_Stop_Track(Track_Pool_Array : in out Stop_Track_Type) is
    begin
        for Index in Track_Pool_Array'Range loop
            Track_Pool_Array(Index).InitStopTrack(Index, 10);
        end loop;
    end Inicialize_Stop_Track;
    procedure Inicialize_Drive_Track(Track_Pool_Array : in out Drive_Track_Type) is
    begin
        for Index in Track_Pool_Array'Range loop
            Track_Pool_Array(Index).InitDriveTrack(Index, 10, 10);
        end loop;
    end Inicialize_Drive_Track;
    procedure Inicialize_Steerings(Steering_Pool_Array : in out Steering_Type) is
    begin
        for Index in Steering_Pool_Array'Range loop
            Steering_Pool_Array(Index).Init(Index);
        end loop;
    end Inicialize_Steerings;
    
    Route_Access : Route_Array_Access := new Route_Array_Type(1..3);
begin
    --Route_Access :=Route_Array_Type(1,2,3);
    --Route_Access := new Route_Array_Type(1..3):=(1,2,3);
    Inicialize_Stop_Track(Stop_Track_Pool);
    Inicialize_Drive_Track(Drive_Track_Pool);
    Inicialize_Steerings(Steering_Pool);
    --Train_Pool(0).Init(1, Route_Access);
    Edges_Pool(0).NeighbourSteering := 0;
    Edges_Pool(0).Weight := 10;


end Main;
