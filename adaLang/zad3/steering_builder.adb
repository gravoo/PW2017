package body Steering_Builder is
    procedure Set_Neigbour_For_Steering(ID : Node_ID ; Edges_To_Node_Pool : Edge_To_Node_Container.Vector) is 
        Neigbours_Node : Steering_Neighbours.Map;
    begin
        for Edges of Edges_To_Node_Pool loop
            Neigbours_Node.Insert(Edges.ID, Edges.Node);
        end loop;
        Steering_Pool(ID).Set_Neighbour(Neigbours_Node);
    end;

    function Build_Steering_Pool return Steering_Container.Vector is 
        Steering_Pool : Steering_Container.Vector;
    begin
        for I in Node_ID loop
            Steering_Pool.Append(new Steering_Thread);
            Steering_Pool.Element(I).Init_Steering(I, 2.0);
        end loop;
        return Steering_Pool;
    end;
begin
    Steering_Pool := Build_Steering_Pool;
    Set_Neigbour_For_Steering(0, (100,0)&(200,1));
    Set_Neigbour_For_Steering(1, (200,0)&(201,2)&(101,1)&(102,1)&(207,10));
    Set_Neigbour_For_Steering(2, (201,1)&(203,4)&(202,3));
    Set_Neigbour_For_Steering(3, (103,3)&(202,2));
    Set_Neigbour_For_Steering(4, (107,4)&(106,4)&(203,2)&(205,7)&(204,5));
    Set_Neigbour_For_Steering(5, (204,4)&(104,5));
    Set_Neigbour_For_Steering(6, (105,6)&(206,7));
    Set_Neigbour_For_Steering(7, (206,6)&(205,4));
    Set_Neigbour_For_Steering(8, (108,8)&(208,10));
    Set_Neigbour_For_Steering(9, (112,9)&(209,10));
    Set_Neigbour_For_Steering(10, (207,1)&(209,9)&(208,8)&(210,11)&(211,12));
    Set_Neigbour_For_Steering(11, (111,11)&(210,10));
    Set_Neigbour_For_Steering(12, (211,10)&(109,12)&(110,12));
    Set_Neigbour_For_Steering(13, (213,12)&(214,14));
    Set_Neigbour_For_Steering(14, (214,13)&(114,14));
    Set_Neigbour_For_Steering(15, (212,12)&(113,15));

    Steering_Pool(0).Set_Steering_On_Station(0);
    Steering_Pool(1).Set_Steering_On_Station(1);
    Steering_Pool(3).Set_Steering_On_Station(2);
    Steering_Pool(4).Set_Steering_On_Station(3);
    Steering_Pool(5).Set_Steering_On_Station(4);
    Steering_Pool(6).Set_Steering_On_Station(5);
    Steering_Pool(8).Set_Steering_On_Station(6);
    Steering_Pool(9).Set_Steering_On_Station(7);
    Steering_Pool(11).Set_Steering_On_Station(8);
    Steering_Pool(12).Set_Steering_On_Station(9);
    Steering_Pool(14).Set_Steering_On_Station(10);
    Steering_Pool(15).Set_Steering_On_Station(11);
end Steering_Builder;

