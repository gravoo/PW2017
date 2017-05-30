with Ada.Containers.Hashed_Maps; use Ada.Containers;
package body Repair_Train is
    task body Repair_Train_Thread  is
        My_First_Steering : Node_ID := Node_ID'First;
    begin
        accept Request_Repair_Broken_Node(Broken_Node : Node_ID)  do
            null;
        end Request_Repair_Broken_Node;
    end;
end Repair_Train;
    
