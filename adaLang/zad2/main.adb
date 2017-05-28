--Bartlomiej Sadowski 204392
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
with Ada.Integer_Text_IO;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Hashed_Maps;
with Track; 
with Steering;
with Train;
use Ada.Containers;
use Ada.Text_IO;
use Track;
use Steering;
use Track.Track_Container;
use Steering.Steering_Container;
use Steering.Edge_To_Node_Container;
use Train;
use Train.Train_Route_Container;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    Edges_To_Seteering_Map : Steering_Neighbours.Map; 
begin
    Track_Pool := Build_Track_Pool;
    Steering_Pool := Build_Steering_Pool;
    Set_Neigbour_For_Steering(0, (100,0)&(101,0)&(102,0));
    Set_Neigbour_For_Steering(1, (100,0)&(101,0)&(102,0));

    Train_Pool.Append(new Train_Thread);
    Train_Pool(0).Init_Train(0, 100&200&299&200&100);

    Put_Line("I am working, and I am not joking");
    Put_Line(Edge_ID'Image(Track_Pool.Element(100).Get_ID));
    Put_Line(Edge_ID'Image(Track_Pool.Element(200).Get_ID));
end Main;
