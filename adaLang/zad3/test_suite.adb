with Ada.Text_IO; use Ada.Text_IO;
with Path_Finder; use Path_Finder;
with Steering; use Steering.Edge_To_Node_Container; use Steering;
with Ada.Containers.Doubly_Linked_Lists; use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
procedure Test_Suite is
    Result : Stack_Container.List;
begin 
    Steering.Steering_Pool := Steering.Build_Steering_Pool;
    Set_Neigbour_For_Steering(0, (100,1)&(101,1)&(300,0));
    Set_Neigbour_For_Steering(1, (200,2)&(101,0)&(100,0));
    Set_Neigbour_For_Steering(2, (200,1)&(201,3));
    Set_Neigbour_For_Steering(3, (201,2)&(102,4)&(103,4));
    Set_Neigbour_For_Steering(4, (102,3)&(103,3));
    Result := Get_Path_To_Node(0, 4);
    for Node of Result loop
        Put(Node_ID'Image(Node) & " ");
    end loop;
    Result := Get_Path_To_Node(2, 4);
    for Node of Result loop
        Put(Node_ID'Image(Node) & " ");
    end loop;
end Test_Suite;




