with Constants_And_Types; use Constants_And_Types;
with Ada.Containers.Vectors;  use Ada.Containers;
with Steering; use Steering;
with Station; use Station;

package Steering_Builder is
    pragma Elaborate_Body;
    use Edge_To_Node_Container;
    package Steering_Container is new Vectors (Node_ID, Steering_Thread_Access);
    function Build_Steering_Pool return Steering_Container.Vector;
    procedure Set_Neigbour_For_Steering(ID : Node_ID ; Edges_To_Node_Pool : Edge_To_Node_Container.Vector); 
    Steering_Pool : Steering_Container.Vector;
end Steering_Builder;
