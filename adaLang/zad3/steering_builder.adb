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
            Steering_Pool.Element(I).Init_Steering(I, 10.0);
        end loop;
        return Steering_Pool;
    end;
begin
    Steering_Pool := Build_Steering_Pool;
    Set_Neigbour_For_Steering(0, (100,1)&(101,1)&(300,0));
    Set_Neigbour_For_Steering(1, (200,2)&(101,0)&(100,0));
    Set_Neigbour_For_Steering(2, (200,1)&(201,3));
    Set_Neigbour_For_Steering(3, (201,2)&(102,4)&(103,4));
    Set_Neigbour_For_Steering(4, (102,3)&(103,3));
end Steering_Builder;

