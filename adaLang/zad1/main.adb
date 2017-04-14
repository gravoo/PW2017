with Ada.Text_IO;
with Ada.Strings.Unbounded;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    task type Train is 
        entry Inicialize(An_Name : in SU.Unbounded_String);
    end Train;

    task body Train is
        TrainName : SU.Unbounded_String;
    begin
        accept Inicialize(An_Name : SU.Unbounded_String) do 
            TrainName := An_Name;
            Ada.Text_IO.Put("Inicialize ");
            Ada.Text_IO.Put_Line(SU.To_String(TrainName));
        end Inicialize;
    end Train;
    TrainA: Train;
begin
    TrainA.Inicialize(SU.To_Unbounded_String("TrainA"));
end Main;
