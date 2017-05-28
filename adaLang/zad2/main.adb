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
with Repair;
with Fault;
use Ada.Containers;
use Ada.Text_IO;
use Track;
use Steering;
use Track.Track_Container;
use Steering.Steering_Container;
use Steering.Edge_To_Node_Container;
use Train;
use Train.Train_Route_Container;
use Repair;

procedure Main is
    package SU renames Ada.Strings.Unbounded;
    Edges_To_Seteering_Map : Steering_Neighbours.Map; 
    Repair_Brigade : Repair_Thread;
    Fault_Generator : Fault.Fault_Thread;
    Train_Pool : Train_Container.Vector;
begin
    Track_Pool := Build_Track_Pool;
    Steering_Pool := Build_Steering_Pool;
    Set_Neigbour_For_Steering(0, (100,1)&(101,1)&(300,0));
    Set_Neigbour_For_Steering(1, (200,2)&(101,0)&(100,0));
    Set_Neigbour_For_Steering(2, (200,1)&(201,3));
    Set_Neigbour_For_Steering(3, (201,2)&(102,4)&(103,4));
    Set_Neigbour_For_Steering(4, (102,3)&(103,3));

    Train_Pool.Append(new Train_Thread);
    Train_Pool.Append(new Train_Thread);
    --Train_Pool(0).Start_Train;
    Train_Pool(0).Init_Train(0, 0, 100&200&201&102&103&201&200&101);
    Train_Pool(1).Init_Train(1, 4, 102&103);
    Train_Pool(0).Start_Train;
    Train_Pool(1).Start_Train;

    Repair_Brigade.Init_Repair_Thread(100, 0, Repair_Track_ID'First);
    Repair_Brigade.Request_Repair_Steering(5);
    Fault_Generator.Generate_Bug_On_Network;

    Put_Line("I am working, and I am not joking");
    Put_Line(Edge_ID'Image(Track_Pool.Element(100).Get_ID));
    Put_Line(Edge_ID'Image(Track_Pool.Element(200).Get_ID));
end Main;
