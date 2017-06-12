package body Station_Builder is
    function Build_Station_Pool return Station_Container.Vector is
        Station_Pool : Station_Container.Vector;
    begin
        for I in Station_ID loop
            Station_Pool.Append(new Station_Thread(I));
            Station_Pool(Station_Pool.Last_Index).Generate_Workers_For_Station;
        end loop;
        return Station_Pool;
    end;
begin
    Station_Pool := Build_Station_Pool;
    Station_Pool(0).Set_My_Steering(0);
    Station_Pool(1).Set_My_Steering(1);
    Station_Pool(2).Set_My_Steering(3);
    Station_Pool(3).Set_My_Steering(4);
    Station_Pool(4).Set_My_Steering(5);
    Station_Pool(5).Set_My_Steering(6);
    Station_Pool(6).Set_My_Steering(8);
    Station_Pool(7).Set_My_Steering(9);
    Station_Pool(8).Set_My_Steering(11);
    Station_Pool(9).Set_My_Steering(12);
    Station_Pool(10).Set_My_Steering(14);
    Station_Pool(11).Set_My_Steering(15);
end Station_Builder;
