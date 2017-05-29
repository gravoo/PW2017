with Ada.Numerics.discrete_Random;
with Ada.Containers;
with Steering;
package Fault is
    subtype Rand_Range is Natural;
    type Count_Of_Types is range 0..2;
    package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
    task type Fault_Thread(
        Count_Of_Trains, Count_Of_Steering, Count_Of_Tracks : Ada.Containers.Count_Type) is
        entry Generate_Bug_On_Network;
    end Fault_Thread;
    function Get_Broken_Steering_ID(Number : Positive) return Steering.Node_ID;
end Fault;
