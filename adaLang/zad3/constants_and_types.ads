with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers;
with Ada.Containers.Vectors;  use Ada.Containers;
package Constants_And_Types is
    type Node_ID is range 0..4;
    type Edge_ID is range 100..300;
    type Train_ID is range 0 .. 100;
    type Worker_ID is range 0 .. 10;
    type Station_ID is range 0 .. 1;
    type Track_Type is (Stop_Track, Drive_Track, Repair_Track);
    type Count_Of_Types is range 0..2;
    type Edge_To_Node is record
         ID : Edge_ID;
         Node : Node_ID;
    end record;
    subtype Stop_Track_ID is Edge_ID range 100..199;
    subtype Drive_Track_ID is Edge_ID range 200..299;
    subtype Repair_Track_ID is Edge_ID range 300..300;
    package Containers renames Ada.Containers;
    Count_Of_Steering : constant  Positive := 4;
    Count_Of_Train : constant Containers.Count_Type := 2;
    Count_Of_Stop_Track : constant Containers.Count_Type := 4;
    Count_Of_Drive_Track : constant Containers.Count_Type := 2;
    package Edge_To_Node_Container is new Vectors (Node_ID, Edge_To_Node);
    package Train_Route_Container is new Vectors (Natural, Edge_ID);
    package Stack_Container is new Doubly_Linked_Lists(Node_ID);
    type Worker is record
        ID : Node_ID;
        Route : Stack_Container.List;
        Reverse_Route : Stack_Container.List;
    end record;
    package Local_Workers_Container is new Vectors (Natural, Worker);
end Constants_And_Types;
