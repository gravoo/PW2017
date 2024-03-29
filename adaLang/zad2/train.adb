with Ada.Text_IO; use Ada.Text_IO;
with Core_Manager; use Core_Manager;

package body Train is
    task body Train_Thread is
        My_ID : Train_ID;
        My_Route : Train_Route_Container.Vector;
        My_Steering : Node_ID;
    begin 
        accept Init_Train(ID : Train_ID; Steering_ID : Node_ID; Train_Route : Train_Route_Container.Vector) do 
            My_ID := ID;
            My_Steering := Steering_ID;
            My_Route := Train_Route;
        end Init_Train;
        accept Start_Train do
        Put_Line("Train_Thread id:" & Train_ID'Image(My_ID) & " started route");
        end Start_Train;
        loop
            for My_Track of My_Route loop
                Steering_Pool(My_Steering).Wait_For_Availalbe;
                Steering_Pool(My_Steering).Wait_For_Fixed_Status;
                Steering_Pool(My_Steering).Request_Reoncfigure_Steering;
                delay Steering_Pool(My_Steering).Get_Time_To_Reconfigure;
                Steering_Pool(My_Steering).Wait_For_Fixed_Status;
                Steering_Pool(My_Steering).Request_Release_Steering(My_Steering, My_Track);
                Track_Pool(My_Track).Wait_For_Availalbe;
                Track_Pool(My_Track).Request_Travel_Through;
                case Track_Pool(My_Track).Get_Track_Type is
                    when Stop_Track => 
                        delay Track_Pool(My_Track).Get_Time_To_Wait;
                    when Drive_Track =>
                        delay Duration(Track_Pool(My_Track).Get_Length/Track_Pool(My_Track).Get_Max_Velocity); 
                    when Repair_Track =>
                        null;
                end case;
                Track_Pool(My_Track).Request_Release_Track;
            end loop;
        end loop;
    end Train_Thread;
end Train;
