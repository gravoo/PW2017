with Ada.Text_IO; use Ada.Text_IO;
with Core_Manager; use Core_Manager;
package body Repair_Train is
    procedure Unset_Fix_Mode_For_Not_Used_Steerings(Used_Steerings : Stack_Container.List) is
        type Not_Used_Steerings_Type is array (Node_ID) of Boolean;
        Not_Used_Steerings : Not_Used_Steerings_Type := (others => True);
    begin
        for Steering of Used_Steerings loop
            Not_Used_Steerings(Steering) := False;
        end loop;
        for I in Node_ID'Range loop
            if Not_Used_Steerings(I) then
                Steering_Pool(I).Request_Unset_Fix_Mode;
            end if;
        end loop;
    end;
    procedure Move_Back_To_Base(Node : in Stack_Container.Cursor) is
        My_Track : Edge_ID;
        My_Steering : Node_ID;
        use Stack_Container;
    begin
        My_Track := Steering_Pool(Element(Node)).Get_First_Available_Track_For_Steering(Element(Node));
        Put_Line("Repair_Train going back to base");
        Steering_Pool(Element(Node)).Wait_For_Availalbe;
        Steering_Pool(Element(Node)).Request_Reoncfigure_Steering;
        Steering_Pool(Element(Node)).Request_Release_Steering(My_Steering, My_Track);
        Track_Pool(My_Track).Wait_For_Availalbe;
        Track_Pool(My_Track).Request_Travel_Through;
        Track_Pool(My_Track).Request_Release_Track;
    end;
    procedure Move_To_Broken_Node(Node : in Stack_Container.Cursor) is
        My_Track : Edge_ID;
        use Stack_Container;
    begin
        My_Track := Steering_Pool(Element(Node)).Get_First_Available_Track_For_Steering(Element(Node));
        Steering_Pool(Element(Node)).Wait_For_Availalbe;
        Steering_Pool(Element(Node)).Request_Unset_Fix_Mode;
        Track_Pool(My_Track).Wait_For_Availalbe;
        Track_Pool(My_Track).Request_Travel_Through;
        Track_Pool(My_Track).Request_Release_Track;
    end;
    task body Repair_Train_Thread  is
        My_First_Steering : Node_ID := Node_ID'First;
        My_Route : Stack_Container.List;
        My_Node_To_Fix : Node_ID;
        My_Repair_Time : Duration := 20.0;
        use Stack_Container;
    begin
        accept Request_Repair_Broken_Node(Broken_Node : Node_ID)  do
            Put_Line("Repair_Train_Thread received repair order" & Node_ID'Image(Broken_Node));
            My_Node_To_Fix := Broken_Node;
        end Request_Repair_Broken_Node;
            My_Route := Get_Path_To_Node(My_First_Steering, My_Node_To_Fix);
            Unset_Fix_Mode_For_Not_Used_Steerings(My_Route);
            My_Route.Iterate(Move_To_Broken_Node'Access);
            Put_Line("Reached broken node, fixing...");
            delay My_Repair_Time;
            Put_Line("Fixed");
            Steering_Pool(My_Node_To_Fix).Request_Call_Of_Alarm;
            My_Route.Reverse_Iterate(Move_Back_To_Base'Access);
    end;
end Repair_Train;
    
