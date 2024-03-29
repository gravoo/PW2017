with Ada.Text_IO; use Ada.Text_IO;

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
end Track;
