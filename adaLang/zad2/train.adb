with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Containers.Vectors;
use Ada.Containers;
with Track;
use Track;
with Steering;
use Steering;

package body Train is
    task body Train_Thread is
        My_ID : Train_ID;
        My_Route : Train_Route_Container.Vector;
        My_Steering : Node_ID;
        My_Time : Duration;
    begin 
        accept Init_Train(ID : Train_ID; Steering_ID : Node_ID; Train_Route : Train_Route_Container.Vector) do 
            My_ID := ID;
            My_Steering := Steering_ID;
            My_Route := Train_Route;
        end Init_Train;
        accept Start_Train do
        Put_Line("Train_Thread id:" & Train_ID'Image(My_ID) & " started route");
            for Track of My_Route loop
                Steering_Pool(My_Steering).Wait_For_Availalbe;
                Steering_Pool(My_Steering).Request_Reoncfigure_Steering(My_Time);
                Steering_Pool(My_Steering).Request_Release_Steering(My_Steering, Track);
                Track_Pool(Track).Wait_For_Availalbe;
                Track_Pool(Track).Request_Travel_Through;
                Track_Pool(Track).Request_Release_Track;
            end loop;
        end Start_Train;
    end Train_Thread;
end Train;
