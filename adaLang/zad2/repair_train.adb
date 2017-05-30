with Ada.Text_IO; use Ada.Text_IO;
with path_finder; use path_finder;
package body Repair_Train is
    task body Repair_Train_Thread  is
        My_First_Steering : Node_ID := Node_ID'First;
        My_Track : Stack_Container.List;
    begin
        accept Request_Repair_Broken_Node(Broken_Node : Node_ID)  do
            Put_Line("Received repair order for node" & Node_ID'Image(Broken_Node));
            My_Track := Get_Path_To_Node(My_First_Steering, Broken_Node);
        end Request_Repair_Broken_Node;
    end;
end Repair_Train;
    
