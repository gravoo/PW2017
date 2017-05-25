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

    Track : Track_Container.Vector;
begin
    Track.Append(New_Item => new Track_Thread, Count => 3);
    Put_Line("I am working, and I am not joking");
    Put_Line(Track_ID'Image(Track.Element(100).Get_ID));
end Main;
