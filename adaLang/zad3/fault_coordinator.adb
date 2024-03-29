--with Ada.Numerics.discrete_Random;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.discrete_Random;
with Steering;
with Repair_Manager;
with Steering_Builder; use Steering_Builder;
package body Fault_Coordinator is
    task body Fault_Coordinator_Thread is
         GG : Rand_Int.Generator;
         Rand_Number : Natural;
         Time_For_New_Fault : Duration := 10.0;
         Fault_For_Type : Count_Of_Types;
         Broken_Steering : Node_ID;
    begin
        accept Generate_Bug_On_Network do
                Put_Line("Random Fault generator started");
        end Generate_Bug_On_Network;
            loop 
                delay Time_For_New_Fault;
                Rand_Int.Reset(GG);
                Rand_Number := Rand_Int.Random(GG);
                Fault_For_Type  := Count_Of_Types(Rand_Number mod Natural(Count_Of_Types'Last + 1));
                Fault_For_Type := 1;
                case Fault_For_Type is
                   when 0 => Put_Line("Fault generated for Train");
                   when 1 => Broken_Steering := Get_Broken_Steering_ID(Rand_Number);
                             Put_Line("Fault generated for Steering" & Node_ID'Image(Broken_Steering));
                             Steering_Pool(Broken_Steering).Request_Rise_Alarm;
                             Repair_Manager.Repair_Headquarter.Request_Repair_Steering(Broken_Steering);
                   when 2 => Put_Line("Fault generated for Track");
                end case;
            end loop;
    end Fault_Coordinator_Thread;
    function Get_Broken_Steering_ID(Number : Positive) return Node_ID is
        Broken_Steering : Node_ID := Node_ID'First;
    begin
        return Node_ID(Number mod Count_Of_Steering) + Broken_Steering;
    end;
end Fault_Coordinator;
