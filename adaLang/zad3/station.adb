package body Station is
    protected body Station_Thread is
        procedure Generate_Workers_For_Station is
        begin
            My_Workers.Append(New_Item => My_ID, Count => 100);
        end;
        procedure Prepapre_Workers(Count_Of_Used_Workers : Containers.Count_Type) is
        begin
            My_Workers.Delete(Index => 0, Count => Count_Of_Used_Workers);
            My_Workers_To_Leave.Append(New_Item => My_ID, Count => Count_Of_Used_Workers);
        end;
        function Get_Workers( Num_Of_Worker : Containers.Count_Type) return Containers.Count_Type is
            Available_Workers : Containers.Count_Type := Containers.Count_Type'Min(My_Workers.Length, Num_Of_Worker);
        begin
            return Num_Of_Worker - Available_Workers;
        end;
    end Station_Thread;
end Station;
