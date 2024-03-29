with Constants_And_Types; use Constants_And_Types;
with Station_Builder; use Station_Builder;
package Work_Manager is
    task type Work_Thread_Generator is
        entry Generate_Work_For_Random_Station(Needed_Workers : Containers.Count_Type; ID : Station_ID);
    end Work_Thread_Generator;
end Work_Manager;
