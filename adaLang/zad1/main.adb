with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
with Ada.Containers.Ordered_Maps;
use Ada.Containers;
use Ada.Text_IO;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    type Train_ID is range 1..4;
    type Track_ID is range 0..23;
    type Steering_ID is range 1..20;
    type Track_Type is (Stop_Track, Drive_Track);
    function "<" (a, b : Steering_ID) return Boolean is
    begin
        if a < b then 
            return True;
        else
            return False;
        end if;
    end "<";

    protected type TrackThread(ID : Track_ID; My_TrackType : Track_Type; Wait_Time : Integer; Track_Max_Velocity : Integer; 
        Track_Length : Integer) is 
        entry Wait_For_Clear;
        entry Assign_Train(TrainID : Train_ID);
        entry Check_TrackType(TrackType : out Track_Type);
        entry Release_Track(TrainID : Train_ID);
        entry Wait_OnStation(Wait_OnTrackTime : out Integer);
        entry Drive_Trough(Length : out Integer; MaxVelocity : out Integer);
    private
        Clear: Boolean := True;
    end TrackThread;

    type Track_Access is access TrackThread;
    package Track_Vector is new Vectors(Track_ID, Track_Access);
    package SteeringToTracks_Vector is new Vectors(Steering_ID, Track_Access);
    package Steering_Map is new Ada.Containers.Ordered_Maps
        (Element_Type => Track_Access,
         Key_Type => Steering_ID);
    SteeringMap : Steering_Map.Map;


    task type SteeringThread(ID : Steering_ID) is 
        entry Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
        Track_InUse : out Track_Access);
        entry Init(Init_MyNeighbours : in SteeringToTracks_Vector.Vector);
    end SteeringThread;

    type Steering_Access is access SteeringThread;
    package Steering_Vector is new Vectors(Steering_ID, Steering_Access);
    Steerings : Steering_Vector.Vector;
    Train1Route : Steering_Vector.Vector;
    Train2Route : Steering_Vector.Vector;

    task type TrainThread(ID : Train_ID; Velocity : Integer) is
        entry Init(Init_Route : in Steering_Vector.Vector);
    end TrainThread;
    type Train_Access is access TrainThread;

    package Train_Vector is new Vectors(Train_ID, Train_Access);
    StopTracks : Track_Vector.Vector;
    DriveTracks : Track_Vector.Vector;
    Steering1Neighbours: SteeringToTracks_Vector.Vector;
    Steering2Neighbours: SteeringToTracks_Vector.Vector;
    Steering3Neighbours: SteeringToTracks_Vector.Vector;
    Steering4Neighbours: SteeringToTracks_Vector.Vector;

    task body TrainThread is
        My_Route : Steering_Vector.Vector;
        My_Track : Track_Access;
        My_TrackType : Track_Type;
        My_Steering: Steering_ID;
        Next_Steering: Steering_ID;
        Track_To_Release : Track_Access;
        Wait_Time : Integer;
        Track_MaxVelocity : Integer;
        Track_Length : Integer;
    begin
        accept Init(Init_Route : in Steering_Vector.Vector) do
            My_Route := Init_Route;
        end Init;
        loop
        Put_Line("TrainThread");
        Next_Steering := My_Route(My_Route.First_Index).ID;
        Put_Line(Steering_ID'Image(My_Route(My_Route.First_Index).ID) & " " & Steering_ID'Image(Next_Steering));
        My_Route(My_Route.First_Index).Request_TravelThroug(ID, Next_Steering, My_Track);
            for I in Steering_ID range My_Route.First_Index .. My_Route.Last_Index - 1 loop
                Put_Line("TrainThread: "& Train_ID'Image (ID) & " on track");
                My_Track.Check_TrackType(My_TrackType);
                case My_TrackType is
                    when Stop_Track =>
                        Put_Line("I am stop track");
                        My_Track.Wait_OnStation(Wait_Time);
                        delay Duration(Wait_Time);
                    when Drive_Track =>
                        Put_Line("I am drive track");
                        My_Track.Drive_Trough(Track_Length, Track_MaxVelocity);
                        delay Duration(Track_Length/Track_MaxVelocity);
                end case;
                Track_To_Release := My_Track;
                Next_Steering := My_Route(I+1).ID;
                Put_Line(Steering_ID'Image(Next_Steering));
                My_Route(I).Request_TravelThroug(ID, Next_Steering, My_Track);
                Track_To_Release.Release_Track(ID);
            end loop;
        My_Track.Release_Track(ID);
        end loop;
    end TrainThread;

    task body SteeringThread is
        My_Neighbours : SteeringToTracks_Vector.Vector;
    begin
        accept Init(Init_MyNeighbours : in SteeringToTracks_Vector.Vector) do
            My_Neighbours := Init_MyNeighbours;
        end Init;
        loop
            accept Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
                   Track_InUse : out Track_Access)  do 
                    Put_Line("steering id: " & Steering_ID'Image(ID) & " Target steering: " & Steering_ID'Image(Next_Steering));
                    My_Neighbours(Next_Steering).Assign_Train(TrainID);
                    Track_InUse := My_Neighbours(Next_Steering); 
            end Request_TravelThroug;
        end loop;
    end SteeringThread;

    protected body TrackThread is
        entry Wait_For_Clear
        when Clear is
        begin
            null;
        end;
        entry Assign_Train(TrainID : Train_ID)
        when Clear is
        begin
            Put_Line("TrackThread task; train: "& Train_ID'Image (TrainID) & " on track: " & Track_ID'Image(ID)
                & " " & Track_Type'Image(My_TrackType));
            Clear := False;
        end;
        entry Release_Track(TrainID : Train_ID)
        when not Clear is
        begin
            Clear := True;
            Put_Line("TrackThread task; Train: "& Train_ID'Image (TrainID) &
                " released track " & Track_Type'Image(My_TrackType) & " " & Track_ID'Image(ID));
        end;
        entry Check_TrackType(TrackType : out Track_Type)
        when not Clear is
        begin
            TrackType := My_TrackType;
        end;
        entry Wait_OnStation(Wait_OnTrackTime : out Integer)
        when not Clear is
        begin
             Wait_OnTrackTime := Wait_Time;  
        end;
        entry Drive_Trough(Length : out Integer; MaxVelocity : out Integer)
        when not Clear is
        begin
            Length := Track_Length;
            MaxVelocity := Track_Max_Velocity;
        end;
    end TrackThread;
    Trains : Train_Vector.Vector;

begin
    StopTracks.Append(new TrackThread(0, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(1, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(2, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(3, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(4, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(5, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(6, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(7, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(8, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(9, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(10, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(11, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(12, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(13, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(14, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(15, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(16, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(17, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(18, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(19, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(20, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(21, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(22, Stop_Track, 5, 0, 0));
    StopTracks.Append(new TrackThread(23, Stop_Track, 5, 0, 0));
    DriveTracks.Append(new TrackThread(0, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(1, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(2, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(3, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(4, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(5, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(6, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(7, Drive_Track, 0, 10, 20));
    DriveTracks.Append(new TrackThread(8, Drive_Track, 0, 10, 20));

    Steering1Neighbours.Append(StopTracks(0));
    Steering1Neighbours.Append(StopTracks(1));

    Steering2Neighbours.Append(StopTracks(1));
    Steering2Neighbours.Append(null);
    Steering2Neighbours.Append(DriveTracks(0));

    Steering3Neighbours.Append(null);
    Steering3Neighbours.Append(DriveTracks(0));
    Steering3Neighbours.Append(null);
    Steering3Neighbours.Append(StopTracks(2));

    Steering4Neighbours.Append(null);
    Steering4Neighbours.Append(null);
    Steering4Neighbours.Append(StopTracks(2));
    Steering4Neighbours.Append(StopTracks(3));

    Steerings.Append(new SteeringThread(1));
    Steerings.Append(new SteeringThread(2));
    Steerings.Append(new SteeringThread(3));
    Steerings.Append(new SteeringThread(4));

    Steerings(1).Init(Steering1Neighbours);
    Steerings(2).Init(Steering2Neighbours);
    Steerings(3).Init(Steering3Neighbours);
    Steerings(4).Init(Steering4Neighbours);

    Train1Route.Append(Steerings(1));
    Train1Route.Append(Steerings(2));
    Train1Route.Append(Steerings(3));
    Train1Route.Append(Steerings(4));
    Train1Route.Append(Steerings(4));
    Train1Route.Append(Steerings(3));
    Train1Route.Append(Steerings(2));
    Train1Route.Append(Steerings(1));
    Trains.Append(new TrainThread(ID => 1, Velocity=>1));

    Train2Route.Append(Steerings(4));
    Train2Route.Append(Steerings(3));
    Train2Route.Append(Steerings(2));
    Train2Route.Append(Steerings(1));
    Train2Route.Append(Steerings(1));
    Train2Route.Append(Steerings(2));
    Train2Route.Append(Steerings(3));
    Train2Route.Append(Steerings(4));
    Trains.Append(new TrainThread(ID => 2, Velocity=>1));

    Trains(1).Init(Train1Route);
    Trains(2).Init(Train2Route);
end Main;
