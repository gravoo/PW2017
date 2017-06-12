package body Track_Builder is
    function Build_Track_Pool return Track_Container.Vector is
        Track_Pool : Track_Container.Vector;
    begin
        for I in Stop_Track_ID loop
            Track_Pool.Append(new Track_Thread);
            Track_Pool.Element(I).Init_Stop_Track(I, 2.0);
        end loop;
        for I in Drive_Track_ID loop
            Track_Pool.Append(new Track_Thread);
            Track_Pool.Element(I).Init_Drive_Track(ID => I, Track_Max_Velocity => 90, Track_Length => 90);
        end loop;
            Track_Pool.Append(new Track_Thread);
            Track_Pool.Element(Repair_Track_ID'First).Init_Repair_Track(ID => Repair_Track_ID'First);
        return Track_Pool;
    end;
begin
    Track_Pool := Build_Track_Pool;
end Track_Builder;
