--Bartlomiej Sadowski 204392
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Integer_Text_IO;
with Repair_Manager;
with Fault_Coordinator;
with Core_Manager; use Core_Manager;
with Constants_And_Types; use Constants_And_Types.Train_Route_Container;
with Work_Manager; use Work_Manager;

procedure Main is
    --Time_Without_Flaws : Duration := 5.0;
    --Fault_Generator : Fault_Coordinator.Fault_Coordinator_Thread(
    --    Train_Pool.Length, Core_Manager.Steering_Pool.Length, Core_Manager.Track_Pool.Length);
    Work_Generator : Work_Thread_Generator;
begin
    Train_Pool := Build_Train_Pool(1);
    Train_Pool(0).Init_Train(0, 0, 100&200&201&102&103&201&200&101);
    Train_Pool(0).Start_Train;
    Work_Generator.Generate_Work_For_Random_Station(Needed_Workers => 1);
   -- delay Time_Without_Flaws;
   -- Fault_Generator.Generate_Bug_On_Network;
    Put_Line("I am working, and I am not joking");
end Main;
