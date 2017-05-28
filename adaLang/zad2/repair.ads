with Steering;
use Steering;
with Track; 
use Track; 
with Train; 
use Train; 
package Repair is
    task type Repair_Thread is
        entry Init_Repair_Thread(ID : Train_ID; Steering_ID : Node_ID; Track : Repair_Track_ID);
        entry Request_Repair_Steering(Broken_Steering_ID : Node_ID);
    end Repair_Thread;
end Repair;
