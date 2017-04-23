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
    type Steering_ID is range 0..100;
    type Track_Type is (Stop_Track, Drive_Track);
    function ID_Hashed (Id : Steering_ID) return Hash_Type is
    begin
       return Hash_Type'Val (Steering_ID'Pos (Id));
    end ID_Hashed;

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
    package SteeringTrack_Map is new Ada.Containers.Hashed_Maps
        (Element_Type => Track_Access,
         Key_Type => Steering_ID,
         Hash => ID_Hashed,
         Equivalent_Keys => "=");

    task type SteeringThread(ID : Steering_ID) is 
        entry Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
        Track_InUse : out Track_Access);
        entry Init(Init_MyNeighbours : in SteeringTrack_Map.Map);
    end SteeringThread;

    type Steering_Access is access SteeringThread;
    package Steering_Vector is new Vectors(Steering_ID, Steering_Access);
    Steerings : Steering_Vector.Vector;
    Train1Route : Steering_Vector.Vector;
    Train2Route : Steering_Vector.Vector;
    Train3Route : Steering_Vector.Vector;
    Train4Route : Steering_Vector.Vector;

    task type TrainThread(ID : Train_ID; Velocity : Integer) is
        entry Init(Init_Route : in Steering_Vector.Vector);
    end TrainThread;
    type Train_Access is access TrainThread;

    package Train_Vector is new Vectors(Train_ID, Train_Access);
    StopTracks : Track_Vector.Vector;
    DriveTracks : Track_Vector.Vector;
    Steering0TrackMap : SteeringTrack_Map.Map;
    Steering1TrackMap : SteeringTrack_Map.Map;
    Steering2TrackMap : SteeringTrack_Map.Map;
    Steering3TrackMap : SteeringTrack_Map.Map;
    Steering4TrackMap : SteeringTrack_Map.Map;
    Steering5TrackMap : SteeringTrack_Map.Map;
    Steering6TrackMap : SteeringTrack_Map.Map;
    Steering7TrackMap : SteeringTrack_Map.Map;
    Steering8TrackMap : SteeringTrack_Map.Map;
    Steering9TrackMap : SteeringTrack_Map.Map;
    Steering10TrackMap : SteeringTrack_Map.Map;
    Steering11TrackMap : SteeringTrack_Map.Map;
    Steering12TrackMap : SteeringTrack_Map.Map;
    Steering13TrackMap : SteeringTrack_Map.Map;
    Steering14TrackMap : SteeringTrack_Map.Map;
    Steering15TrackMap : SteeringTrack_Map.Map;
    Steering16TrackMap : SteeringTrack_Map.Map;
    Steering17TrackMap : SteeringTrack_Map.Map;
    Steering18TrackMap : SteeringTrack_Map.Map;
    Steering19TrackMap : SteeringTrack_Map.Map;

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
                        My_Track.Wait_OnStation(Wait_Time);
                        delay Duration(Wait_Time);
                    when Drive_Track =>
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
        My_Neighbours : SteeringTrack_Map.Map;
    begin
        accept Init(Init_MyNeighbours : in SteeringTrack_Map.Map) do
            My_Neighbours := Init_MyNeighbours;
        end Init;
        loop
            accept Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
                   Track_InUse : out Track_Access)  do 
                    Put_Line("steering id: " & Steering_ID'Image(ID) & " Target steering: " & Steering_ID'Image(Next_Steering));
                    My_Neighbours(Next_Steering).Wait_For_Clear;
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


    Steerings.Append(new SteeringThread(0));
    Steerings.Append(new SteeringThread(1));
    Steerings.Append(new SteeringThread(2));
    Steerings.Append(new SteeringThread(3));
    Steerings.Append(new SteeringThread(4));
    Steerings.Append(new SteeringThread(5));
    Steerings.Append(new SteeringThread(6));
    Steerings.Append(new SteeringThread(7));
    Steerings.Append(new SteeringThread(8));
    Steerings.Append(new SteeringThread(9));
    Steerings.Append(new SteeringThread(10));
    Steerings.Append(new SteeringThread(11));
    Steerings.Append(new SteeringThread(12));
    Steerings.Append(new SteeringThread(13));
    Steerings.Append(new SteeringThread(14));
    Steerings.Append(new SteeringThread(15));
    Steerings.Append(new SteeringThread(16));
    Steerings.Append(new SteeringThread(17));
    Steerings.Append(new SteeringThread(18));
    Steerings.Append(new SteeringThread(19));

    Steering0TrackMap.Insert(0, StopTracks(0));
    Steering0TrackMap.Insert(2, StopTracks(1));

    Steering1TrackMap.Insert(1, StopTracks(3));
    Steering1TrackMap.Insert(2, StopTracks(2));

    Steering2TrackMap.Insert(0, StopTracks(1));
    Steering2TrackMap.Insert(1, StopTracks(2));
    Steering2TrackMap.Insert(3, DriveTracks(0));

    Steering3TrackMap.Insert(2, DriveTracks(0));
    Steering3TrackMap.Insert(4, StopTracks(4));

    Steering4TrackMap.Insert(3, StopTracks(5));
    Steering4TrackMap.Insert(5, DriveTracks(1));
    Steering4TrackMap.Insert(17, DriveTracks(6));

    Steering5TrackMap.Insert(6, StopTracks(6));
    Steering5TrackMap.Insert(4, DriveTracks(8));

    Steering6TrackMap.Insert(5, StopTracks(7));
    Steering6TrackMap.Insert(7, DriveTracks(2));
    Steering6TrackMap.Insert(12, DriveTracks(4));

    Steering7TrackMap.Insert(6, DriveTracks(7));
    Steering7TrackMap.Insert(8, StopTracks(8));

    Steering8TrackMap.Insert(7, StopTracks(9));
    Steering8TrackMap.Insert(9, DriveTracks(3));
    
    Steering9TrackMap.Insert(8, DriveTracks(3));
    Steering9TrackMap.Insert(10, StopTracks(10));
    Steering9TrackMap.Insert(11, StopTracks(11));
    
    Steering10TrackMap.Insert(9, StopTracks(10));
    Steering10TrackMap.Insert(10, StopTracks(12));
    
    Steering11TrackMap.Insert(9, StopTracks(11));
    Steering11TrackMap.Insert(11, StopTracks(13));
    
    Steering12TrackMap.Insert(6, DriveTracks(4));
    Steering12TrackMap.Insert(13, StopTracks(14));
    
    Steering13TrackMap.Insert(12, StopTracks(15));
    Steering13TrackMap.Insert(14, DriveTracks(5));
    
    Steering14TrackMap.Insert(13, DriveTracks(5));
    Steering14TrackMap.Insert(15, StopTracks(16));
    Steering14TrackMap.Insert(16, StopTracks(17));
    
    Steering15TrackMap.Insert(14, StopTracks(16));
    Steering15TrackMap.Insert(15, StopTracks(18));
    
    Steering16TrackMap.Insert(14, StopTracks(17));
    Steering16TrackMap.Insert(16, StopTracks(19));
    
    Steering17TrackMap.Insert(4, DriveTracks(6));
    Steering17TrackMap.Insert(18, StopTracks(20));
    Steering17TrackMap.Insert(19, StopTracks(21));
    
    Steering18TrackMap.Insert(17, StopTracks(20));
    Steering18TrackMap.Insert(18, StopTracks(22));
    
    Steering19TrackMap.Insert(17, StopTracks(21));
    Steering19TrackMap.Insert(19, StopTracks(22));

    Steerings(0).Init(Steering0TrackMap);
    Steerings(1).Init(Steering1TrackMap);
    Steerings(2).Init(Steering2TrackMap);
    Steerings(3).Init(Steering3TrackMap);
    Steerings(4).Init(Steering4TrackMap);
    Steerings(5).Init(Steering5TrackMap);
    Steerings(6).Init(Steering6TrackMap);
    Steerings(7).Init(Steering7TrackMap);
    Steerings(8).Init(Steering8TrackMap);
    Steerings(9).Init(Steering9TrackMap);
    Steerings(10).Init(Steering10TrackMap);
    Steerings(11).Init(Steering11TrackMap);
    Steerings(12).Init(Steering12TrackMap);
    Steerings(13).Init(Steering13TrackMap);
    Steerings(14).Init(Steering14TrackMap);
    Steerings(15).Init(Steering15TrackMap);
    Steerings(16).Init(Steering16TrackMap);
    Steerings(17).Init(Steering17TrackMap);
    Steerings(18).Init(Steering18TrackMap);
    Steerings(19).Init(Steering19TrackMap);

    Train1Route.Append(Steerings(0));
    Train1Route.Append(Steerings(2));
    Train1Route.Append(Steerings(3));
    Train1Route.Append(Steerings(4));
    Train1Route.Append(Steerings(5));
    Train1Route.Append(Steerings(6));
    Train1Route.Append(Steerings(7));
    Train1Route.Append(Steerings(8));
    Train1Route.Append(Steerings(9));
    Train1Route.Append(Steerings(10));
    Train1Route.Append(Steerings(10));
    Train1Route.Append(Steerings(9));
    Train1Route.Append(Steerings(8));
    Train1Route.Append(Steerings(7));
    Train1Route.Append(Steerings(6));
    Train1Route.Append(Steerings(5));
    Train1Route.Append(Steerings(4));
    Train1Route.Append(Steerings(3));
    Train1Route.Append(Steerings(2));
    Train1Route.Append(Steerings(0));
    
    Train2Route.Append(Steerings(11));
    Train2Route.Append(Steerings(9));
    Train2Route.Append(Steerings(8));
    Train2Route.Append(Steerings(7));
    Train2Route.Append(Steerings(6));
    Train2Route.Append(Steerings(5));
    Train2Route.Append(Steerings(4));
    Train2Route.Append(Steerings(3));
    Train2Route.Append(Steerings(2));
    Train2Route.Append(Steerings(1));
    Train2Route.Append(Steerings(1));
    Train2Route.Append(Steerings(2));
    Train2Route.Append(Steerings(3));
    Train2Route.Append(Steerings(4));
    Train2Route.Append(Steerings(5));
    Train2Route.Append(Steerings(6));
    Train2Route.Append(Steerings(7));
    Train2Route.Append(Steerings(8));
    Train2Route.Append(Steerings(9));
    Train2Route.Append(Steerings(11));
    
    Train3Route.Append(Steerings(15));
    Train3Route.Append(Steerings(14));
    Train3Route.Append(Steerings(13));
    Train3Route.Append(Steerings(12));
    Train3Route.Append(Steerings(6));
    Train3Route.Append(Steerings(5));
    Train3Route.Append(Steerings(4));
    Train3Route.Append(Steerings(17));
    Train3Route.Append(Steerings(18));
    Train3Route.Append(Steerings(18));
    Train3Route.Append(Steerings(17));
    Train3Route.Append(Steerings(4));
    Train3Route.Append(Steerings(5));
    Train3Route.Append(Steerings(6));
    Train3Route.Append(Steerings(12));
    Train3Route.Append(Steerings(13));
    Train3Route.Append(Steerings(14));
    Train3Route.Append(Steerings(15));

    Train4Route.Append(Steerings(19));
    Train4Route.Append(Steerings(17));
    Train4Route.Append(Steerings(4));
    Train4Route.Append(Steerings(5));
    Train4Route.Append(Steerings(6));
    Train4Route.Append(Steerings(12));
    Train4Route.Append(Steerings(13));
    Train4Route.Append(Steerings(14));
    Train4Route.Append(Steerings(16));
    Train4Route.Append(Steerings(16));
    Train4Route.Append(Steerings(14));
    Train4Route.Append(Steerings(13));
    Train4Route.Append(Steerings(12));
    Train4Route.Append(Steerings(6));
    Train4Route.Append(Steerings(5));
    Train4Route.Append(Steerings(4));
    Train4Route.Append(Steerings(17));
    Train4Route.Append(Steerings(19));

    Trains.Append(new TrainThread(ID => 1, Velocity=>1));
    Trains.Append(new TrainThread(ID => 2, Velocity=>1));
    Trains.Append(new TrainThread(ID => 3, Velocity=>1));
    Trains.Append(new TrainThread(ID => 4, Velocity=>1));

    --Trains(1).Init(Train1Route);
    --Trains(2).Init(Train2Route);
    Trains(3).Init(Train3Route);
    Trains(4).Init(Train4Route);
end Main;
