with Ada.Containers.Doubly_Linked_Lists; use Ada.Containers;
with Constants; use Constants;
package Path_Finder is
    type Visited_Array is array (Node_ID) of Boolean;
    package Stack_Container is new Doubly_Linked_Lists(Node_ID);
    function DFS(Current_Node, Target_Node : Node_ID) return Boolean;
    function Get_Path_To_Node(Current_Node, Target_Node : Node_ID) return Stack_Container.List;
    Stack : Stack_Container.List;
    Visited : Visited_Array := (others => False);
end Path_Finder;