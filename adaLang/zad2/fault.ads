with Ada.Numerics.discrete_Random;
package Fault is
   subtype Rand_Range is Positive;
   package Rand_Int is new Ada.Numerics.Discrete_Random(Rand_Range);
    task type Fault_Thread is
        entry Generate_Bug_On_Network;
    end Fault_Thread;
end Fault;
