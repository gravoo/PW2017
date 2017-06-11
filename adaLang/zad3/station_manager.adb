package body Station_Manager is
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
end Station_Manager;
