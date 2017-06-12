with Ada.Containers.Vectors; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
with Train; use Train;
package Train_Builder is
    pragma Elaborate_Body;
    use Constants_And_Types.Train_Route_Container;
    package Train_Container is new Vectors (Train_ID, Train_Thread_Access);
    function Build_Train_Pool(Count_Of_Trains : Count_Type) return Train_Container.Vector;
    Train_Pool : Train_Container.Vector;
end Train_Builder;
