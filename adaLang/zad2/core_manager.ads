with Steering; use Steering;
with Track; use Track;
with Train; use Train;
with Constants_And_Types; use Constants_And_Types;
with Ada.Containers.Vectors;  use Ada.Containers;
package Core_Manager is
    pragma Elaborate_Body;
    package Track_Container is new Vectors (Edge_ID, Track_Thread_Access);
    package Steering_Container is new Vectors (Node_ID, Steering_Thread_Access);
    package Edge_To_Node_Container is new Vectors (Node_ID, Edge_To_Node);
    use Edge_To_Node_Container;
    function Build_Steering_Pool return Steering_Container.Vector;
    function Build_Track_Pool return Track_Container.Vector;
    procedure Set_Neigbour_For_Steering(ID : Node_ID ; Edges_To_Node_Pool : Edge_To_Node_Container.Vector); 
    Steering_Pool : Steering_Container.Vector;
    Track_Pool : Track_Container.Vector;
end Core_Manager;
