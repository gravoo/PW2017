with Ada.Text_IO; use Ada.Text_IO;
with Repair;
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
        entry Wait_For_Availalbe
        when My_Availablity and not My_Fix_Mode is
        begin 
            null;
        end;
        procedure Rise_Alarm is
        begin
            Put_Line("Steering_Thread id: " & Node_ID'Image(My_ID) & " broken");
            Repair.Repair_Brigade.Request_Repair_Steering(My_ID);
            Repair.Repair_Brigade.Request_Repair_Completed;
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
    function Build_Steering_Pool return Steering_Container.Vector is 
        Steering_Pool : Steering_Container.Vector;
    begin
        for I in Node_ID loop
            Steering_Pool.Append(new Steering_Thread);
            Steering_Pool.Element(I).Init_Steering(I, 10.0);
        end loop;
        return Steering_Pool;
    end;
    procedure Set_Neigbour_For_Steering(ID : Node_ID ; Edges_To_Node_Pool : Edge_To_Node_Container.Vector) is 
        Neigbours_Node : Steering_Neighbours.Map;
    begin
        for Edges of Edges_To_Node_Pool loop
            Neigbours_Node.Insert(Edges.ID, Edges.Node);
        end loop;
        Steering_Pool(ID).Set_Neighbour(Neigbours_Node);
    end;
end Steering;
