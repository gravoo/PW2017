with Ada.Containers.Vectors;
use Ada.Containers;

package Track is
    type Edges_ID is range 100..200;
    subtype Track_ID is Edges_ID range 100..200;
    type Track_Type is (Stop_Track, Drive_Track);
        protected type Track_Thread is
        procedure Init_Stop_Track(ID : Track_ID ; Track_Time_To_Wait : Natural);
        procedure Init_Drive_Track(ID : Track_ID ;Track_Max_Velocity : Natural; Track_Length : Natural);
        procedure Get_Max_Velocity_And_Length(Length : out Natural; Max_Velocity : out Natural);
        function Get_Track_Type return Track_Type;
        function Get_Time_To_Wait return Natural;
        function Get_ID return Track_ID;
        entry Wait_For_Availalbe;
        entry Request_Travel_Through;
        entry Request_Release_Track;
        private
            My_Type : Track_Type;
            My_Time_To_Wait : Natural;
            My_Max_Velocity : Natural;
            My_Length : Natural;
            My_Availablity : Boolean := True;
        My_ID : Track_ID := 100;
    end Track_Thread;
    type Track_Thread_Access is access Track_Thread;
    package Track_Container is new Vectors (Edges_ID, Track_Thread_Access);
    function Build_Track_Pool(Count_Stop_Track : Count_Type; Count_Drive_Track : Count_Type)
        return Track_Container.Vector;
end Track;
