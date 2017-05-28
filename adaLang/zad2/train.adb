with Ada.Containers.Vectors;
use Ada.Containers;
package body Train is
    task body Train_Thread is
        My_ID : Train_ID;
        My_Route : Train_Route_Container.Vector;
    begin 
        accept Init_Train(ID : Train_ID; Train_Route : Train_Route_Container.Vector) do 
            My_ID := ID;
            My_Route := Train_Route;
        end Init_Train;
    end Train_Thread;
end Train;
