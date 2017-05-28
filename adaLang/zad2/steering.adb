package body Steering is
    protected body Steering_Thread is
        procedure Init_Steering(ID : Node_ID) is
        begin
            My_ID := ID;
        end;
        procedure Set_Neighbour(ID : Node_ID) is
        begin
            My_Neighbour := ID;
        end;
    end Steering_Thread;
    function Build_Steering_Pool return Steering_Container.Vector is 
        Steering_Pool : Steering_Container.Vector;
    begin
        for I in Node_ID loop
            Steering_Pool.Append(new Steering_Thread);
            Steering_Pool.Element(I).Init_Steering(I);
        end loop;
        return Steering_Pool;
    end;
end Steering;
