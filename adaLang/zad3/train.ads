with Ada.Containers.Vectors; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;

package Train is
    task type Train_Thread is
        entry Init_Train(ID : Train_ID; Steering_ID : Node_ID; Train_Route : Train_Route_Container.Vector);
        entry Start_Train;
    end Train_Thread;
    type Train_Thread_Access is access Train_Thread;
end Train;
