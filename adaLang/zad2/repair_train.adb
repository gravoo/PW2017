with Steering;
package body Repair_Train is
    task body Repair_Train_Thread  is
        My_First_Steering : Steering.Node_ID := Steering.Node_ID'First;
    begin
        accept Request_Repair_Broken_Node(Broken_Node : Steering.Node_ID)  do
            null;
        end Request_Repair_Broken_Node;
    end;
    type Visited_Array is array (Boolean) of Steering.Node_ID;
    Visited : Visited_Array := (others => False);
end Repair_Train;
    
