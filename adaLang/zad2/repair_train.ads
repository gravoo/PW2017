with Ada.Containers.Doubly_Linked_Lists; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
package Repair_Train is
    task type Repair_Train_Thread is
        entry Request_Repair_Broken_Node(Broken_Node : Node_ID);
    end Repair_Train_Thread;
end Repair_Train;
