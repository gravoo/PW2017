with Station; use Station;
with Ada.Containers.Vectors;  use Ada.Containers;
with Constants_And_Types; use Constants_And_Types;
package Station_Builder is
    pragma Elaborate_Body;
    package Station_Container is new Vectors (Station_ID, Station_Thread_Access);
    function Build_Station_Pool return Station_Container.Vector;
    Station_Pool : Station_Container.Vector;
end Station_Builder;
