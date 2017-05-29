with Ada.Text_IO; use Ada.Text_IO;
with Fault;
package body Repair is
    task body Repair_Thread is
        My_ID : Train_ID;
        My_Steering : Node_ID;
        My_Repair_Track_ID : Repair_Track_ID;
        My_Broken_Steering : Node_ID;
        My_Type_Of_Fix : Fault.Count_Of_Types; 
    begin
        accept Init_Repair_Thread(
            ID : Train_ID; Steering_ID : Node_ID; Track : Repair_Track_ID ) do
            My_ID := ID;
            My_Steering := Steering_ID;
            My_Repair_Track_ID := Track;
        end Init_Repair_Thread;
        loop
            accept Request_Repair_Steering(Broken_Steering_ID : Node_ID) do
                Put_Line("Repair_Thread receive repair order from node" & Node_ID'Image(Broken_Steering_ID));
                My_Broken_Steering := Broken_Steering_ID;
                My_Type_Of_Fix := 1;
            end Request_Repair_Steering;
                case My_Type_Of_Fix is
                   when 0 => Put_Line("Init procedure for fixing Train");
                   when 1 => Put_Line("Init procedure for fixing Steering");
                             For_All_Network_Set_Fix_Mode;
                             For_All_Network_Unset_Fix_Mode;
                             Steering.Steering_Pool(My_Broken_Steering).Fix_Steering;
                   when 2 => Put_Line("Init procedure for fixing Track");
                end case;
        end loop;
     end Repair_Thread;
    procedure For_All_Network_Set_Fix_Mode is
    begin
        for Steering of Steering_Pool loop
            Steering.Wait_For_Availalbe;
            Steering.Request_Set_Fix_Mode;
        end loop;
    end;
    procedure For_All_Network_Unset_Fix_Mode is
    begin
        for Steering of Steering_Pool loop
            Steering.Wait_For_Availalbe;
            Steering.Request_Unset_Fix_Mode;
        end loop;
    end;
 begin
    Repair_Brigade.Init_Repair_Thread(100, Steering.Node_ID'First, Track.Repair_Track_ID'First);
end Repair;
