--Bartlomiej Sadowski 204392
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Hashed_Maps;
with Track; 
with Steering;
use Ada.Containers;
use Ada.Text_IO;
use Track;
use Steering;
use Track.Track_Container;
use Steering.Steering_Container;
use Steering.Edge_To_Node_Container;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    Edges_To_Seteering_Map : Steering_Neighbours.Map; 
    Test_Record : Edge_To_Node ;
begin
    Track_Pool := Build_Track_Pool;
    Steering_Pool := Build_Steering_Pool;
    Edges_To_Seteering_Map := Build_Neigbour_For_Steering((100,0)&(101,0)&(102,0));
    Steering_Pool(0).Set_Neighbour(Edges_To_Seteering_Map);
    Edges_To_Seteering_Map := Build_Neigbour_For_Steering((100,0)&(101,0)&(102,0));
    Steering_Pool(1).Set_Neighbour(Edges_To_Seteering_Map);


    Put_Line("I am working, and I am not joking");
    Put_Line(Edge_ID'Image(Track_Pool.Element(100).Get_ID));
    Put_Line(Edge_ID'Image(Track_Pool.Element(200).Get_ID));
end Main;
