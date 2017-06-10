with Ada.Text_IO; use Ada.Text_IO;

package body Work_Manager is
    task body Work_Thread_Generator is 
    begin
        accept Generate_Work_For_Random_Station do
            Put_Line("Test log");
        end;
    end Work_Thread_Generator;
end Work_Manager;
