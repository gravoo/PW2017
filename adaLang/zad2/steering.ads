with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Maps; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;

package Steering is
    function ID_Hashed (ID : Edge_ID) return Hash_Type;
    package Steering_Neighbours is new Ada.Containers.Hashed_Maps
        (Key_Type => Edge_ID,
         Element_Type => Node_ID, 
         Hash => ID_Hashed,
         Equivalent_Keys => "=");
    use Steering_Neighbours;

    protected type Steering_Thread is
        function Get_ID return Node_ID;
        function Get_Time_To_Reconfigure return Duration;
        function Get_Neigbours return Steering_Neighbours.Map;
        function Get_First_Available_Track_For_Steering(Destination_Node : in Node_ID) return Edge_ID;
        procedure Init_Steering(ID : Node_ID; Time_To_Reconfigure: Duration);
        procedure Set_Neighbour(Neighbours : Steering_Neighbours.Map);
        entry Request_Rise_Alarm;
        entry Request_Call_Of_Alarm;
        entry Request_Reoncfigure_Steering;
        entry Request_Release_Steering(ID : out Node_ID; Edge : in Edge_ID);
        entry Wait_For_Availalbe;
        entry Request_Set_Fix_Mode;
        entry Request_Unset_Fix_Mode;
        entry Wait_For_Fixed_Status;
        private
            My_ID : Node_ID;
            My_Neighbours : Steering_Neighbours.Map;
            My_Time_To_Reconfigure : Duration;
            My_Availablity : Boolean := True;
            My_Fix_Mode : Boolean := False;
            My_Broken_State : Boolean := False;
    end Steering_Thread;
    type Steering_Thread_Access is access Steering_Thread;
end Steering;
