with Ada.Containers.Vectors; use Ada.Containers;
with Constants; use Constants;

package Train is
    package Train_Route_Container is new Vectors (Natural, Edge_ID);
    use Train_Route_Container;
    task type Train_Thread is
        entry Init_Train(ID : Train_ID; Steering_ID : Node_ID; Train_Route : Train_Route_Container.Vector);
        entry Start_Train;
    end Train_Thread;

    type Train_Thread_Access is access Train_Thread;
    package Train_Container is new Vectors (Train_ID, Train_Thread_Access);
    Train_Pool : Train_Container.Vector;
end Train;
