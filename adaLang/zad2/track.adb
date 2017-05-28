with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Containers.Vectors;
use Ada.Containers;

package body Track is
    protected body Track_Thread is
    procedure Init_Stop_Track(ID : Edge_ID ;Track_Time_To_Wait : Duration) is 
    begin
        My_Type := Stop_Track;
        My_Time_To_Wait := Track_Time_To_Wait;
        My_ID := ID;
    end;
    procedure Init_Drive_Track(ID : Edge_ID ;Track_Max_Velocity : Natural; Track_Length : Natural) is
    begin
        My_Type := Drive_Track;
        My_Max_Velocity := Track_Max_Velocity;
        My_Length := Track_Length;
        My_ID := ID;
    end;
    procedure Init_Repair_Track(ID : Edge_ID) is
    begin
        My_ID := ID;
        My_Type := Repair_Track;
    end;
    function Get_Max_Velocity return Natural is
    begin
        return My_Max_Velocity;
    end;
    function Get_Length return Natural is
    begin
        return My_Length;
    end;
    function Get_Track_Type return Track_Type is
    begin
        return My_Type;
    end;
    function Get_Time_To_Wait return Duration is
    begin
        return My_Time_To_Wait;
    end;
    function Get_ID return Edge_ID is
    begin
        return My_ID;
    end;
    entry Wait_For_Availalbe
    when My_Availablity is
        begin 
            null;
        end;
    entry Request_Travel_Through
    when My_Availablity is
        begin
            Put_Line("Track_Thread id: " & Edge_ID'Image(My_ID) & " is taken");
            My_Availablity := False;
        end;
    entry Request_Release_Track 
    when not My_Availablity is
        begin
            Put_Line("Track_Thread id: " & Edge_ID'Image(My_ID) & " released");
            My_Availablity := True;
        end;
    end Track_Thread;
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
end Track;
