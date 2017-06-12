with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers; use Ada.Containers;

package body Work_Manager is
    task body Work_Thread_Generator is 
        Count_Of_Needed_Workers : Containers.Count_Type;
        Count_Of_Workers : Containers.Count_Type := 0;
        Count_Of_Aquired_Workers : Containers.Count_Type := 0;
        Random_Station_ID : Station_ID;
    begin
        loop
        accept Generate_Work_For_Random_Station(Needed_Workers : Containers.Count_Type; ID : Station_ID) do
            Put_Line("Work_Manager_Thread: Received work for Station" & Station_ID'Image(ID));
            Count_Of_Needed_Workers := Needed_Workers;
            Count_Of_Workers := Needed_Workers;
            Random_Station_ID := ID;
        end Generate_Work_For_Random_Station;
            Put_Line("Work_Manager_Thread: preparing workers ");
            for stations of Station_Pool loop
               Count_Of_Aquired_Workers := stations.Get_Workers(Count_Of_Needed_Workers);
               Put_Line("Worker_Manager_Thread count of aquired " & Containers.Count_Type'Image(Count_Of_Aquired_Workers));
               stations.Prepapre_Workers(Count_Of_Aquired_Workers, Station_Pool(Random_Station_ID).Get_Steering_ID);
               Count_Of_Needed_Workers := Count_Of_Needed_Workers - Count_Of_Aquired_Workers;
               Put_Line("Worker_Manager_Thread still needed" & Containers.Count_Type'Image(Count_Of_Needed_Workers));
               exit when Count_Of_Needed_Workers <= 0;
            end loop;
            while not Station_Pool(Random_Station_ID).Ready_To_Get_Job_Done(Count_Of_Workers) loop
                delay 2.0;
            end loop;
           Station_Pool(Random_Station_ID).Finish_Job;
           Put_Line("Work_Manager_Thread: Job is done");
        end loop;
    end Work_Thread_Generator;
end Work_Manager;
