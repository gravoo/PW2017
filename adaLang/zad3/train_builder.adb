package body Train_Builder is
    function Build_Train_Pool(Count_Of_Trains : Count_Type ) return Train_Container.Vector is
        Train_Pool : Train_Container.Vector;
    begin
        Train_Pool.Append(New_Item => new Train_Thread, Count => Count_Of_Trains );
        return Train_Pool;
    end;
begin
    Train_Pool := Build_Train_Pool(1);
end Train_Builder;
