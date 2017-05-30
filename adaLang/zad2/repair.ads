with Constants; use Constants;
package Repair is
    procedure For_All_Network_Set_Fix_Mode(Broken_Steering_ID : Node_ID);
    procedure For_All_Network_Unset_Fix_Mode(Broken_Steering_ID : Node_ID);
    protected type Repair_Thread is
        procedure Init_Repair_Thread(ID : Train_ID; Steering_ID : Node_ID; Track : Repair_Track_ID);
        procedure Request_Repair_Steering(Broken_Steering_ID : Node_ID);
        entry Request_Repair_Completed;
    private
        My_Fix_Order : Boolean := False;
        My_ID : Train_ID;
        My_Steering : Node_ID;
        My_Repair_Track_ID : Repair_Track_ID;
        My_Broken_Steering : Node_ID;
        My_Type_Of_Fix : Count_Of_Types; 
    end Repair_Thread;
    Repair_Brigade : Repair_Thread;
end Repair;
