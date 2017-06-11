with Ada.Containers.Vectors; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
package Station is
    use Local_Workers_Container;
    protected type Station_Thread(My_ID : Station_ID) is
        procedure Generate_Workers_For_Station;
        procedure Prepapre_Workers( Count_Of_Used_Workers : Containers.Count_Type; Node_With_Work_ID : Node_ID);
        function Get_Workers( Num_Of_Worker : Containers.Count_Type) return Containers.Count_Type;
        function Ready_To_Get_Job_Done(Count_Of_Workers : Containers.Count_Type) return Boolean;
        procedure Check_Passangers_Route(Passengers : out Vector; Next_Node : Node_ID);
        procedure Drop_Passengers(Passengers : out Vector);
        procedure Get_Passangers(Passengers : out Vector; Capacity : Containers.Count_Type; Next_Node : Node_ID);
        procedure Set_My_Steering(ID : Node_ID);
        procedure Finish_Job;
    private
        My_Steering : Node_ID;
        My_Workers : Containers.Count_Type;
        My_Workers_To_Leave : Vector; 
        My_Peasant : Vector; 
    end Station_Thread;
    type Station_Thread_Access is access Station_Thread;
end Station;
