with Ada.Text_IO; use Ada.Text_IO;
package body Steering is
    function ID_Hashed (ID : Edge_ID) return Hash_Type is
    begin
       return Hash_Type'Val (Edge_ID'Pos (ID));
    end ID_Hashed;

    protected body Steering_Thread is
        function Get_ID return Node_ID is
        begin
            return My_ID;
        end;
        function Get_Time_To_Reconfigure return Duration is
        begin 
            return My_Time_To_Reconfigure;
        end;
        function Get_Neigbours return Steering_Neighbours.Map is
        begin
            return My_Neighbours;
        end;
        function Get_First_Available_Track_For_Steering(Destination_Node : in Node_ID) return Edge_ID is
            A_Cursor  : Cursor := My_Neighbours.First;
        begin
            for Node in My_Neighbours.Iterate loop
                if Destination_Node = Element(Node) then
                    return Key(Node);
                end if;
            end loop;
            return Key(A_Cursor);
        end;
        procedure Init_Steering(ID : Node_ID; Time_To_Reconfigure: Duration) is
        begin
            My_ID := ID;
            My_Time_To_Reconfigure := Time_To_Reconfigure;
        end;
        procedure Set_Neighbour(Neighbours : Steering_Neighbours.Map) is
        begin
            My_Neighbours := Neighbours;
        end;
        entry Request_Reoncfigure_Steering
        when My_Availablity is
        begin 
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " is taken ");
            My_Availablity := False;
        end;
        entry Request_Release_Steering(ID : out Node_ID; Edge : in Edge_ID)
        when not My_Availablity is
        begin
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " released ");
            My_Availablity := True;
            ID := My_Neighbours(Edge);
        end;
        entry Wait_For_Fixed_Status
        when not My_Broken_State or not My_Fix_Mode is
        begin 
            null;
        end;
        entry Wait_For_Availalbe
        when My_Availablity is
        begin 
            null;
        end;
        entry Request_Rise_Alarm
        when not My_Broken_State is
        begin
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " broken");
            My_Broken_State := True;
        end;
        entry Request_Call_Of_Alarm 
        when My_Broken_State is
        begin
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " fixed");
            My_Broken_State := False;
        end;
        entry Request_Set_Fix_Mode
        when not My_Fix_Mode is
        begin
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " in fix mode");
            My_Fix_Mode := True;
        end;
        entry Request_Unset_Fix_Mode
        when My_Fix_Mode is
        begin
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " is free to go");
            My_Fix_Mode := False;
        end;
    end Steering_Thread;
end Steering;
