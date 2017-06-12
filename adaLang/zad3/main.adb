--Bartlomiej Sadowski 204392
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Vectors; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types.Train_Route_Container;
with Work_Manager; use Work_Manager;
with Train_Builder; use Train_Builder;

procedure Main is
    Work_Generator : Work_Thread_Generator;
begin
    Work_Generator.Generate_Work_For_Random_Station(Needed_Workers => 1);
    Put_Line("I am working, and I am not joking");
end Main;
