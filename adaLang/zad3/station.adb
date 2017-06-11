with path_finder;
package body Station is
    protected body Station_Thread is
        procedure Generate_Workers_For_Station is
        begin
            My_Workers := Containers.Count_Type( Worker_ID'Last );
        end;
        procedure Prepapre_Workers(Count_Of_Used_Workers : Containers.Count_Type; Node_With_Work_ID : Node_ID) is
            Path : Stack_Container.List;
        begin
            My_Workers := My_Workers - Count_Of_Used_Workers;
            Path := path_finder.Get_Path_To_Node(My_Steering, Node_With_Work_ID);
            My_Workers_To_Leave.Append((My_Steering, Path), Count => Count_Of_Used_Workers);
        end;
        procedure Set_My_Steering(ID : Node_ID) is
        begin
            My_Steering := ID;
        end;
        function Get_Workers( Num_Of_Worker : Containers.Count_Type) return Containers.Count_Type is
            Available_Workers : Containers.Count_Type := Containers.Count_Type'Min(My_Workers, Num_Of_Worker);
        begin
            return Num_Of_Worker - Available_Workers;
        end;
        procedure Get_Pasangers(Passengers : out Vector; Capacity : Containers.Count_Type; Next_Node : Node_ID) is
        begin
            for worker of My_Workers_To_Leave loop 
                if Next_Node = worker.Route.First_Element then
                    worker.Route.Delete_First;
                    Passengers.Append(worker);
                end if;
                exit when Passengers.Length >= Capacity;
            end loop;
        end;
    end Station_Thread;
end Station;
