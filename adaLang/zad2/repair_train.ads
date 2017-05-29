with Steering;
package Repair_Train is
    task type Repair_Train_Thread is
        entry Request_Repair_Broken_Node(Broken_Node : Steering.Node_ID);
    end Repair_Train_Thread;
end Repair_Train;
