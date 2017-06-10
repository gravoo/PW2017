package body Core_Manager is
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
    function Build_Track_Pool return Track_Container.Vector is
        Track_Pool : Track_Container.Vector;
    begin
        for I in Stop_Track_ID loop
            Track_Pool.Append(new Track_Thread);
            Track_Pool.Element(I).Init_Stop_Track(I, 5.0);
        end loop;
        for I in Drive_Track_ID loop
            Track_Pool.Append(new Track_Thread);
            Track_Pool.Element(I).Init_Drive_Track(ID => I, Track_Max_Velocity => 90, Track_Length => 900);
        end loop;
            Track_Pool.Append(new Track_Thread);
            Track_Pool.Element(Repair_Track_ID'First).Init_Repair_Track(ID => Repair_Track_ID'First);
        return Track_Pool;
    end;
    function Build_Train_Pool(Count_Of_Trains : Count_Type ) return Train_Container.Vector is
        Train_Pool : Train_Container.Vector;
    begin
        Train_Pool.Append(New_Item => new Train_Thread, Count => Count_Of_Trains );
        return Train_Pool;
    end;
    function Build_Station_Pool return Station_Container.Vector is
        Station_Pool : Station_Container.Vector;
    begin
        for I in Station_ID loop
            Station_Pool.Append( new Station_Thread(I) );
        end loop;
        return Station_Pool;
    end;
begin
    Track_Pool := Build_Track_Pool;
    Steering_Pool := Build_Steering_Pool;
    Station_Pool := Build_Station_Pool;
    Set_Neigbour_For_Steering(0, (100,1)&(101,1)&(300,0));
    Set_Neigbour_For_Steering(1, (200,2)&(101,0)&(100,0));
    Set_Neigbour_For_Steering(2, (200,1)&(201,3));
    Set_Neigbour_For_Steering(3, (201,2)&(102,4)&(103,4));
    Set_Neigbour_For_Steering(4, (102,3)&(103,3));
end Core_Manager;

