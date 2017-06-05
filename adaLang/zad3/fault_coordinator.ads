with Ada.Numerics.discrete_Random;
with Constants_And_Types; use Constants_And_Types;
package Fault_Coordinator is
    subtype Rand_Range is Natural;
    package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
    task type Fault_Coordinator_Thread(
        Count_Of_Trains, Count_Of_Steering, Count_Of_Tracks : Containers.Count_Type) is
        entry Generate_Bug_On_Network;
    end Fault_Coordinator_Thread;
    function Get_Broken_Steering_ID(Number : Positive) return Node_ID;
end Fault_Coordinator;
