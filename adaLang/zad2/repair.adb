package body Repair is
    task body Repair_Thread is
        My_ID : Train_ID;
        My_Steering : Node_ID;
        My_Repair_Track_ID : Repair_Track_ID;
    begin
        accept Init_Repair_Thread(ID : Train_ID; Steering_ID : Node_ID; Track : Repair_Track_ID) do
            My_ID := ID;
            My_Steering := Steering_ID;
            My_Repair_Track_ID := Track;
        end Init_Repair_Thread;
        accept Request_Repair_Steering(Broken_Steering_ID : Node_ID) do
            null;
        end Request_Repair_Steering;
     end Repair_Thread;
end Repair;
