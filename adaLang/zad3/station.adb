with Ada.Text_IO; use Ada.Text_IO;
with path_finder;
package body Station is
    protected body Station_Thread is
        procedure Generate_Workers_For_Station is
        begin
            My_Workers := Containers.Count_Type( Worker_ID'Last );
        end;
        procedure Prepapre_Workers(Count_Of_Used_Workers : Containers.Count_Type; Node_With_Work_ID : Node_ID) is
            Path : Stack_Container.List;
            Reverse_Path : Stack_Container.List;
        begin
            My_Workers := My_Workers - Count_Of_Used_Workers;
            Path := path_finder.Get_Path_To_Node(My_Steering, Node_With_Work_ID);
            Reverse_Path := Path;
            Reverse_Path.Reverse_Elements;
            My_Workers_To_Leave.Append((My_Steering, Path, Reverse_Path), Count => Count_Of_Used_Workers);
        end;
        procedure Set_My_Steering(ID : Node_ID) is
        begin
            My_Steering := ID;
        end;
        function Get_Workers( Num_Of_Worker : Containers.Count_Type) return Containers.Count_Type is
            Available_Workers : Containers.Count_Type := Containers.Count_Type'Min(My_Workers, Num_Of_Worker);
        begin
            return Available_Workers;
        end;
        procedure Check_Passangers_Route(Passengers : out Vector; Next_Node : Node_ID) is
            Passengers_Tmp : Vector := Passengers;
        begin
            for worker in Passengers.First_Index .. Passengers.Last_Index loop 
                if Next_Node /= Passengers(worker).Route.First_Element then
                    My_Workers_To_Leave.Append(Passengers(worker));
                    Passengers_Tmp.Delete_First;
                else
                    Passengers(worker).Route.Delete_First;
                    Passengers_Tmp.Append(Passengers(worker));
                end if;
            end loop;
            Passengers := Passengers_Tmp;
        end;
        procedure Drop_Passengers(Passengers : out Vector) is
            Passengers_Tmp : Vector := Passengers;
        begin
            for worker in Passengers.First_Index .. Passengers.Last_Index loop 
                if Passengers(worker).Route.Is_Empty then
                    My_Peasant.Append(Passengers(worker));
                    My_Workers := My_Workers + 1;
                else
                    Passengers_Tmp.Append(Passengers(worker));
                end if;
            end loop;
            Passengers := Passengers_Tmp;
        end;
        procedure Get_Passangers(Passengers : out Vector; Capacity : Containers.Count_Type; Next_Node : Node_ID) is
            My_Workers_To_Leave_Tmp : Vector := My_Workers_To_Leave; 
        begin
            for worker in My_Workers_To_Leave.First_Index .. My_Workers_To_Leave.Last_Index loop
                if Next_Node = My_Workers_To_Leave(worker).Route.First_Element then
                    My_Workers_To_Leave(worker).Route.Delete_First;
                    Passengers.Append(My_Workers_To_Leave(worker));
                else
                    My_Workers_To_Leave_Tmp.Append(My_Workers_To_Leave(worker));
                end if;
                exit when Passengers.Length >= Capacity;
            end loop;
            My_Workers_To_Leave := My_Workers_To_Leave_Tmp;
        end;
        function Ready_To_Get_Job_Done(Count_Of_Workers : Containers.Count_Type) return Boolean is
        begin
            if Count_Of_Workers <= My_Peasant.Length then
                Put_Line("Station_Thread: station is ready for geting job done");
                return True;
            end if;
            Put_Line("Station_Thread: station is still not ready");
            return False;
        end;
        procedure Finish_Job is
        begin
            Put_Line("Station_Thread:" & Station_ID'Image(My_ID));
            for workers of My_Peasant loop
                workers.Route := workers.Reverse_Route;
            end loop;
            My_Workers_To_Leave.Append(My_Peasant);
        end;
        function Get_Steering_ID return Node_ID is
        begin
            return My_Steering;
        end;
    end Station_Thread;
end Station;
