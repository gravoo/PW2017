with Ada.Containers.Vectors;
use Ada.Containers;

package Steering is
    type Node_ID is range 0..100;
    protected type Steering_Thread is
        procedure Init_Steering(ID : Node_ID);
        procedure Set_Neighbour(ID : Node_ID);
        private
            My_ID : Node_ID;
            My_Neighbour : Node_ID;
    end Steering_Thread;
    type Steering_Thread_Access is access Steering_Thread;
    package Steering_Container is new Vectors (Node_ID, Steering_Thread_Access);
    function Build_Steering_Pool return Steering_Container.Vector;
    Steering_Pool : Steering_Container.Vector;
end Steering;
