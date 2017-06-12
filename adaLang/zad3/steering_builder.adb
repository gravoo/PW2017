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
    Steering_Pool(0).Set_Steering_On_Station(0);
    Set_Neigbour_For_Steering(1, (200,0)&(201,2));
    Set_Neigbour_For_Steering(2, (201,1)&(101,2));
    Steering_Pool(2).Set_Steering_On_Station(1);
end Steering_Builder;

