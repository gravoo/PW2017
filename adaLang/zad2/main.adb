--Bartlomiej Sadowski 204392
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Hashed_Maps;
with Track; 
use Ada.Containers;
use Ada.Text_IO;
use Track;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
begin
    Stop_Track_Pool := Build_Track_Pool;
    Put_Line("I am working, and I am not joking");
    Put_Line(Edge_ID'Image(Stop_Track_Pool.Element(100).Get_ID));
    Put_Line(Edge_ID'Image(Stop_Track_Pool.Element(200).Get_ID));
end Main;
