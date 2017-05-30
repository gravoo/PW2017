with Ada.Text_IO; use Ada.Text_IO;
with Steering; use Steering;
with Track; use Track; 
with Repair_Train;
package body Repair is
    protected body Repair_Thread is
        procedure Init_Repair_Thread( ID : Train_ID; Steering_ID : Node_ID; Track : Repair_Track_ID ) is
        begin
            My_ID := ID;
            My_Steering := Steering_ID;
            My_Repair_Track_ID := Track;
        end;
        procedure Request_Repair_Steering(Broken_Steering_ID : Node_ID) is
            My_Repair_Brigade : Repair_Train.Repair_Train_Thread;
        begin
            Put_Line("Repair_Thread receive repair order from node" & Node_ID'Image(Broken_Steering_ID));
            My_Broken_Steering := Broken_Steering_ID;
            My_Type_Of_Fix := 1;
            case My_Type_Of_Fix is
               when 0 => Put_Line("Init procedure for fixing Train");
               when 1 => Put_Line("Init procedure for fixing Steering");
                         For_All_Network_Set_Fix_Mode(My_Broken_Steering);
                         My_Repair_Brigade.Request_Repair_Broken_Node(My_Broken_Steering);
                         For_All_Network_Unset_Fix_Mode(My_Broken_Steering);
               when 2 => Put_Line("Init procedure for fixing Track");
            end case;
        end;
        entry Request_Repair_Completed
        when My_Fix_Order is
        begin
            My_Fix_Order := False;
        end;
     end Repair_Thread;
    procedure For_All_Network_Set_Fix_Mode(Broken_Steering_ID : Node_ID) is
    begin
        for Steering of Steering_Pool loop
            if Steering /= Steering_Pool(Broken_Steering_ID) then
                Steering.Request_Set_Fix_Mode;
            end if;
        end loop;
    end;
    procedure For_All_Network_Unset_Fix_Mode(Broken_Steering_ID : Node_ID) is
    begin
        for Steering of Steering_Pool loop
            if Steering /= Steering_Pool(Broken_Steering_ID) then
            Steering.Request_Unset_Fix_Mode;
            end if;
        end loop;
    end;
 begin
    Repair_Brigade.Init_Repair_Thread(100, Node_ID'First, Repair_Track_ID'First);
end Repair;
