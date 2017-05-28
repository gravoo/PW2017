with Ada.Containers.Vectors;
with Ada.Containers.Hashed_Maps;
with Track;
use Track;
use Ada.Containers;

package Steering is
    type Node_ID is range 0..100;
    function ID_Hashed (ID : Edge_ID) return Hash_Type;
    package Steering_Neighbours is new Ada.Containers.Hashed_Maps
        (Key_Type => Edge_ID,
         Element_Type => Node_ID, 
         Hash => ID_Hashed,
         Equivalent_Keys => "=");
    type Edge_To_Node is record
         ID : Edge_ID;
         Node : Node_ID;
    end record;

    protected type Steering_Thread is
        function Get_ID return Node_ID;
        procedure Init_Steering(ID : Node_ID; Time_To_Reconfigure: Duration);
        procedure Set_Neighbour(Neighbours : Steering_Neighbours.Map);
        entry Request_Reoncfigure_Steering(Time_To_Reconfigure : out Duration);
        entry Request_Release_Steering(ID : out Node_ID; Edge : in Edge_ID);
        private
            My_ID : Node_ID;
            My_Neighbours : Steering_Neighbours.Map;
            My_Time_To_Reconfigure : Duration;
            My_Availablity : Boolean := True;
    end Steering_Thread;
    type Steering_Thread_Access is access Steering_Thread;
    package Steering_Container is new Vectors (Node_ID, Steering_Thread_Access);
    package Edge_To_Node_Container is new Vectors (Node_ID, Edge_To_Node);
    function Build_Steering_Pool return Steering_Container.Vector;
    function Build_Neigbour_For_Steering(Edges_To_Node_Pool : Edge_To_Node_Container.Vector) 
        return Steering_Neighbours.Map;

    Steering_Pool : Steering_Container.Vector;
end Steering;
