with Ada.Containers.Vectors; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;

package Track is
    protected type Track_Thread is
        procedure Init_Stop_Track(ID : Edge_ID ; Track_Time_To_Wait : Duration);
        procedure Init_Drive_Track(ID : Edge_ID ;Track_Max_Velocity : Natural; Track_Length : Natural);
        procedure Init_Repair_Track(ID : Edge_ID);
        function Get_Max_Velocity return Natural;
        function Get_Length return Natural;
        function Get_Track_Type return Track_Type;
        function Get_Time_To_Wait return Duration;
        function Get_ID return Edge_ID;
        entry Wait_For_Availalbe;
        entry Request_Travel_Through;
        entry Request_Release_Track;
        private
            My_Type : Track_Type;
            My_Time_To_Wait : Duration;
            My_Max_Velocity : Natural;
            My_Length : Natural;
            My_Availablity : Boolean := True;
            My_ID : Edge_ID;
    end Track_Thread;
    type Track_Thread_Access is access Track_Thread;
end Track;
