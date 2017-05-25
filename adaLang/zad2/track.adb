with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Containers.Vectors;
use Ada.Containers;

package body Track is
    protected body Track_Thread is
    procedure Init_Stop_Track(ID : Track_ID ;Track_Time_To_Wait : Natural) is 
    begin
        My_Type := Stop_Track;
        My_Time_To_Wait := Track_Time_To_Wait;
        My_ID := ID;
    end;
    procedure Init_Drive_Track(ID : Track_ID ;Track_Max_Velocity : Natural; Track_Length : Natural) is
    begin
        My_Type := Drive_Track;
        My_Max_Velocity := Track_Max_Velocity;
        My_Length := Track_Length;
        My_ID := ID;
    end;
    procedure Get_Max_Velocity_And_Length(Length : out Natural; Max_Velocity : out Natural) is
    begin
        Length := My_Length;
        Max_Velocity := My_Max_Velocity;
    end;
    function Get_Track_Type return Track_Type is
    begin
        return My_Type;
    end;
    function Get_Time_To_Wait return Natural is
    begin
        return My_Time_To_Wait;
    end;
    function Get_ID return Track_ID is
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
            Put_Line("Track_Thread id:" & Track_ID'Image(My_ID) & " is taken");
            My_Availablity := False;
        end;
    entry Request_Release_Track 
    when not My_Availablity is
        begin
            Put_Line("Track_Thread id:" & Track_ID'Image(My_ID) & "released");
            My_Availablity := True;
        end;
    end Track_Thread;
    function Build_Track_Pool(Count_Stop_Track : Count_Type; Count_Drive_Track : Count_Type)
        return Track_Container.Vector is
        Track : Track_Container.Vector;
    begin
        Track.Append(New_Item => new Track_Thread, Count => Count_Stop_Track);
        Track.Append(New_Item => new Track_Thread, Count => Count_Drive_Track);
    end;
end Track;
