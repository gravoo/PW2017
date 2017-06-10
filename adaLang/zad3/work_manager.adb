with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers; use Ada.Containers;

package body Work_Manager is
    task body Work_Thread_Generator is 
        Count_Of_Needed_Workers : Containers.Count_Type := 100;
        Count_Of_Available_Workers : Containers.Count_Type := 0;
    begin
        accept Generate_Work_For_Random_Station(Needed_Workers : Containers.Count_Type) do
            Count_Of_Needed_Workers := Needed_Workers;
        end Generate_Work_For_Random_Station;
            while Count_Of_Needed_Workers > 0 loop
               Count_Of_Available_Workers := Station_Pool(0).Get_Workers(Count_Of_Needed_Workers);
               Count_Of_Needed_Workers := Count_Of_Needed_Workers - Count_Of_Available_Workers;
            end loop;
    end Work_Thread_Generator;
end Work_Manager;
