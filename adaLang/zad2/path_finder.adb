with Steering;
package body path_finder is
function Get_Path_To_Node(Current_Node, Target_Node : Node_ID) return Stack_Container.List is
    Result : Boolean;
begin
    Visited := (others => False);
    Stack.Clear;
    Result := DFS(Current_Node, Target_Node);
    return Stack;
end;

function DFS(Current_Node, Target_Node : Node_ID) return Boolean is
begin
    Visited( Current_Node ) := True;
    Stack.Append( Current_Node );
    if Current_Node = Target_Node then
        return True;
    end if;
    for Node of Steering.Steering_Pool(Current_Node).Get_Neigbours loop
        if Visited( Node ) = False then
            if DFS(Node, Target_Node) = True then
                return True;
            end if;
        end if;
    end loop;
    Stack.Delete_Last;
    return False;
end;
end path_finder;
