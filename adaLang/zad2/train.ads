with Ada.Containers.Vectors;
with Track;
use Track;
use Ada.Containers;

package Train is
    type Train_ID is range 0 .. 100;
    package Train_Route_Container is new Vectors (Natural, Edge_ID);
    task type Train_Thread is
        entry Init_Train(ID : Train_ID; Train_Route : Train_Route_Container.Vector);
    end Train_Thread;

    type Train_Thread_Access is access Train_Thread;
    package Train_Container is new Vectors (Train_ID, Train_Thread_Access);
    Train_Pool : Train_Container.Vector;
end Train;
