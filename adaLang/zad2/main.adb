--Bartlomiej Sadowski 204392
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Integer_Text_IO;
with Steering; use Steering.Edge_To_Node_Container; use Steering;
with Track; 
with Train; use Train;
with Repair;
with Fault;

procedure Main is
    Fault_Generator : Fault.Fault_Thread;
begin
    Steering_Pool := Steering.Build_Steering_Pool;
    Track.Track_Pool := Track.Build_Track_Pool;
    Set_Neigbour_For_Steering(0, (100,1)&(101,1)&(300,0));
    Set_Neigbour_For_Steering(1, (200,2)&(101,0)&(100,0));
    Set_Neigbour_For_Steering(2, (200,1)&(201,3));
    Set_Neigbour_For_Steering(3, (201,2)&(102,4)&(103,4));
    Set_Neigbour_For_Steering(4, (102,3)&(103,3));

    Train_Pool(0).Start_Train;
    Train_Pool(1).Start_Train;

    Fault_Generator.Generate_Bug_On_Network;

    Put_Line("I am working, and I am not joking");
end Main;
