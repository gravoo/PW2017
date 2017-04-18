with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
use Ada.Containers;
use Ada.Text_IO;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    type Train_ID is range 1..4;
    type Track_ID is range 1..20;
    type Steering_ID is range 1..2;


    protected type StopTrack(ID : Track_ID) is 
        entry Wait_For_Clear;
        entry Assign_Train(ID : Train_ID);
        entry Release_Track(ID : Train_ID);
    private
        Clear: Boolean := True;
    end StopTrack;
    type Track_Access is access StopTrack;
    package Track_Vector is new Vectors(Track_ID, Track_Access);
    package SteeringToTracks_Vector is new Vectors(Steering_ID, Track_Access);


    task type Steering(ID : Steering_ID) is 
        entry Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
        Track_InUse : out Track_Access);
        entry Init(Init_MyNeighbours : in SteeringToTracks_Vector.Vector);
    end Steering;

    type Steering_Access is access Steering;
    package Steering_Vector is new Vectors(Steering_ID, Steering_Access);
    Steerings_Vector : Steering_Vector.Vector;

    task type Train(ID : Train_ID; My_Steering: Steering_ID; Next_Steering: Steering_ID) is
        entry Init(Init_Route : in Steering_Vector.Vector);
    end Train;
    type Train_Access is access Train;

    package Train_Vector is new Vectors(Train_ID, Train_Access);
    Tracks_Vector : Track_Vector.Vector;
    SteeringToTracks_VectorMap: SteeringToTracks_Vector.Vector;

    task body Train is
        My_Route : Steering_Vector.Vector;
        My_Track : Track_Access;
    begin
        accept Init(Init_Route : in Steering_Vector.Vector) do
            My_Route := Init_Route;
        end Init;
        My_Route(My_Steering).Request_TravelThroug(ID, Next_Steering, My_Track);
        Put_Line("Train: "& Train_ID'Image (ID) & " on track");
        delay 1.0;
        My_Track.Release_Track(ID);
    end Train;

    task body Steering is
        My_Neighbours : SteeringToTracks_Vector.Vector;
    begin
        accept Init(Init_MyNeighbours : in SteeringToTracks_Vector.Vector) do
            My_Neighbours := Init_MyNeighbours;
        end Init;
        loop
            accept Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
                   Track_InUse : out Track_Access)  do 
                    My_Neighbours(Next_Steering).Assign_Train(TrainID);
                    Track_InUse := My_Neighbours(Next_Steering); 
            end Request_TravelThroug;
        end loop;
    end Steering;

    protected body StopTrack is
        entry Wait_For_Clear
        when Clear is
        begin
            null;
        end;
        entry Assign_Train(ID : Train_ID)
        when Clear is
        begin
            Put_Line("StopTrack task; train: "& Train_ID'Image (ID) & " on track");
            Clear := False;
        end;
        entry Release_Track(ID : Train_ID)
        when not Clear is
        begin
            Clear := True;
            Put_Line("StopTrack task; Train: "& Train_ID'Image (ID) & " released track");
        end;
    end StopTrack;
    Trains : Train_Vector.Vector;

begin
    Tracks_Vector.Append(new StopTrack(1));
    Tracks_Vector.Append(new StopTrack(2));
    SteeringToTracks_VectorMap.Append(Tracks_Vector(1));
    SteeringToTracks_VectorMap.Append(Tracks_Vector(2));
    Steerings_Vector.Append(new Steering(1));
    Steerings_Vector.Append(new Steering(2));
    Steerings_Vector(1).Init(SteeringToTracks_VectorMap);
    Trains.Append(new Train(1,1,2));
    Trains(1).Init(Steerings_Vector);
end Main;
