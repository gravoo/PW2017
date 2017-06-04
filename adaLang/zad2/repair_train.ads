with Ada.Containers.Doubly_Linked_Lists; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
with path_finder; use path_finder;
package Repair_Train is
    procedure Unset_Fix_Mode_For_Not_Used_Steerings(Used_Steerings : Stack_Container.List);
    procedure Move_To_Broken_Node(Node : in Stack_Container.Cursor);
    procedure Move_Back_To_Base(Node : in Stack_Container.Cursor);
    task type Repair_Train_Thread is
        entry Request_Repair_Broken_Node(Broken_Node : Node_ID);
    end Repair_Train_Thread;
end Repair_Train;
