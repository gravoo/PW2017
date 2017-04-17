with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
use Ada.Containers;

procedure Main is
    package Integer_Vectors is new Vectors(Natural, Integer);
    package SU renames Ada.Strings.Unbounded;

    task type Train is 
        entry Inicialize(An_Name : in SU.Unbounded_String; An_SteeringIndexes : Integer_Vectors.Vector);
    end Train;

    task type Steering is 
        entry Inicialize(An_Name : in SU.Unbounded_String);
        entry AssignTrainToTrack(An_TrackId : in Integer; An_TrainName : in SU.Unbounded_String);
    end Steering;

    task type StopTrack is 
        entry AssignTrain;
    end StopTrack;

    Steerings: array (0..0) of  Steering;
    Trains: array (0..0) of  Train;
    StopTracks: array (0..0) of StopTrack;
    SteeringIndexesForTrain0 : Integer_Vectors.Vector;

    task body Train is
        TrainName : SU.Unbounded_String;
        SteeringIndexes: Integer_Vectors.Vector;
    begin
        accept Inicialize(An_Name : SU.Unbounded_String; An_SteeringIndexes : Integer_Vectors.Vector) do 
            TrainName := An_Name;
            SteeringIndexes := An_SteeringIndexes;
            Ada.Text_IO.Put("Inicialize ");
            Ada.Text_IO.Put_Line(SU.To_String(TrainName));
            Ada.Text_IO.Put("Target steeing:");
			Ada.Integer_Text_IO.Put(SteeringIndexes.First_Element);
            Ada.Text_IO.Put_Line("");
            Steerings(SteeringIndexes.First_Element).AssignTrainToTrack(SteeringIndexes.First_Element, TrainName);
        end Inicialize;
    end Train;

    task body Steering is
        SteeringName : SU.Unbounded_String;
    begin
        accept Inicialize(An_Name : SU.Unbounded_String) do 
            SteeringName := An_Name;
            Ada.Text_IO.Put("Inicialize ");
            Ada.Text_IO.Put_Line(SU.To_String(SteeringName));
        end Inicialize;
        accept AssignTrainToTrack(An_TrackId : in Integer; An_TrainName : in SU.Unbounded_String) do 
            Ada.Text_IO.Put("Train request ");
            Ada.Text_IO.Put(SU.To_String(An_TrainName));
			Ada.Integer_Text_IO.Put(An_TrackId);
            Ada.Text_IO.Put(" assign to track ");
            Ada.Text_IO.Put_Line(SU.To_String(An_TrainName));
            Ada.Text_IO.Put_Line("");
            StopTracks(An_TrackId).AssignTrain;
        end AssignTrainToTrack;
    end Steering;

    task body StopTrack is
    begin
        accept AssignTrain do
            Ada.Text_IO.Put_Line("Hello from stop track");
        end AssignTrain;
    end StopTrack;
begin
    SteeringIndexesForTrain0.Append(0);
    SteeringIndexesForTrain0.Append(1);
    Steerings(0).Inicialize(SU.To_Unbounded_String("SteeringA"));
    Trains(0).Inicialize(SU.To_Unbounded_String("TrainA"), SteeringIndexesForTrain0);
end Main;
