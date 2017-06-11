with Ada.Containers.Vectors; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
package Station is
    use Local_Workers_Container;
    protected type Station_Thread(My_ID : Station_ID) is
        procedure Generate_Workers_For_Station;
        procedure Prepapre_Workers( Count_Of_Used_Workers : Containers.Count_Type );
        function Get_Workers( Num_Of_Worker : Containers.Count_Type) return Containers.Count_Type;
        procedure Set_My_Steering(ID : Node_ID);
    private
        My_Steering : Node_ID;
        My_Workers : Containers.Count_Type;
        My_Workers_To_Leave : Vector; 
    end Station_Thread;
    type Station_Thread_Access is access Station_Thread;
end Station;
