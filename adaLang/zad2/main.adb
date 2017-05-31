--Bartlomiej Sadowski 204392
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Integer_Text_IO;
with Train; use Train;
with Repair_Manager;
with Fault_Coordinator;
with Core_Manager; use Core_Manager;

procedure Main is
    Fault_Generator : Fault_Coordinator.Fault_Coordinator_Thread(
        Train_Pool.Length, Core_Manager.Steering_Pool.Length, Core_Manager.Track_Pool.Length);
begin

    Train_Pool(0).Start_Train;
    Train_Pool(1).Start_Train;

    Fault_Generator.Generate_Bug_On_Network;

    Put_Line("I am working, and I am not joking");
end Main;
