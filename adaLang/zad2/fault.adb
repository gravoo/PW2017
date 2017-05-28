--with Ada.Numerics.discrete_Random;
with Ada.Text_IO;
with Ada.Numerics.discrete_Random;
use Ada.Text_IO;
package body Fault is
    task body Fault_Thread is
         GG : Rand_Int.Generator;
         Number : Positive;
    begin
        accept Generate_Bug_On_Network do
            loop 
                Rand_Int.Reset(GG);
                Number := Rand_Int.Random(GG);
                Put_Line("Random number is: " & Positive'Image(Number));
                delay 10.0;
            end loop;
        end Generate_Bug_On_Network;
    end Fault_Thread;
end Fault;
