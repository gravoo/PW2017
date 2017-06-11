with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers; use Ada.Containers;

package body Work_Manager is
    task body Work_Thread_Generator is 
        Count_Of_Needed_Workers : Containers.Count_Type := 20;
        Count_Of_Available_Workers : Containers.Count_Type := 0;
        Random_Station_ID : Node_ID := 4;
    begin
        accept Generate_Work_For_Random_Station(Needed_Workers : Containers.Count_Type) do
            Count_Of_Needed_Workers := Needed_Workers;
        end Generate_Work_For_Random_Station;
            for stations of Station_Pool loop
               Count_Of_Available_Workers := stations.Get_Workers(Count_Of_Needed_Workers);
               stations.Prepapre_Workers(Count_Of_Needed_Workers, Random_Station_ID);
               Count_Of_Needed_Workers := Count_Of_Needed_Workers - Count_Of_Available_Workers;
               exit when Count_Of_Needed_Workers >= 0;
            end loop;
            while not Station_Pool(Station_ID(Random_Station_ID)).Ready_To_Get_Job_Done(Count_Of_Needed_Workers) loop
                delay 20.0;
            end loop;
           Station_Pool(Station_Pool.Last_Index).Finish_Job;
    end Work_Thread_Generator;
end Work_Manager;
