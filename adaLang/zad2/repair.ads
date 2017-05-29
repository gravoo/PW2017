with Steering;
use Steering;
with Track; 
use Track; 
with Train; 
use Train; 
package Repair is
    procedure For_All_Network_Set_Fix_Mode;
    procedure For_All_Network_Unset_Fix_Mode;
    task type Repair_Thread is
        entry Init_Repair_Thread(ID : Train_ID; Steering_ID : Node_ID; Track : Repair_Track_ID);
        entry Request_Repair_Steering(Broken_Steering_ID : Node_ID);
    end Repair_Thread;
    Repair_Brigade : Repair_Thread;
end Repair;
