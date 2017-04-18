with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
use Ada.Containers;
use Ada.Text_IO;

procedure Main is
    package Integer_Vectors is new Vectors(Natural, Integer);
    package SU renames Ada.Strings.Unbounded;
    type Train_ID is range 1..4;
    type Track_ID is range 1..20;
    type Steering_ID is range 1..10;

    task type Train(ID : Train_ID; My_Steering: Steering_ID; Next_Steering: Steering_ID) is end Train;
    type Train_Access is access Train;

    protected type StopTrack is 
        entry Wait_For_Clear;
        entry Assign_Train(ID : Train_ID);
    private
        Clear: Boolean := True;
    end StopTrack;

    task type Steering is 
        entry Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
        My_TrackId : out Track_ID);
    end Steering;

    Steerings: array (Steering_ID) of Steering;
    StopTracks: array (Track_ID) of StopTrack;

    task body Train is
        My_TrackId : Track_ID;
    begin
        Steerings(My_Steering).Request_TravelThroug(ID, Next_Steering, My_TrackId);
        Put_Line("Train: "& Train_ID'Image (ID) & " on track:" & Track_ID'Image(My_TrackId));
        delay 10.0;
    end Train;

    task body Steering is
        SteeringName : SU.Unbounded_String;
    begin
        loop
            accept Request_TravelThroug(TrainID : in Train_ID; Next_Steering : in Steering_ID;
                My_TrackId : out Track_ID)
                do 
                StopTracks(1).Assign_Train(TrainID);
                My_TrackId := 1;
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
            Clear := False;
        end;
    end StopTrack;

    New_Train : Train_Access;

begin
    New_Train := new Train(1,1,2);
end Main;
