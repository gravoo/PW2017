with Constants_And_Types; use Constants_And_Types;
with Ada.Containers.Vectors;  use Ada.Containers;
with Track; use Track;

package Track_Builder is
    pragma Elaborate_Body;
    package Track_Container is new Vectors (Edge_ID, Track_Thread_Access);
    function Build_Track_Pool return Track_Container.Vector;
    Track_Pool : Track_Container.Vector;
end Track_Builder;
