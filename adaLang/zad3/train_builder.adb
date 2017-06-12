package body Train_Builder is
    function Build_Train_Pool(Count_Of_Trains : Count_Type ) return Train_Container.Vector is
        Train_Pool : Train_Container.Vector;
    begin
        Train_Pool.Append(New_Item => new Train_Thread, Count => Count_Of_Trains );
        return Train_Pool;
    end;
begin
    Train_Pool := Build_Train_Pool(1);
    Train_Pool(0).Init_Train(0, 0, 100&200&201&202&103&202&201&200&100);
    Train_Pool(0).Start_Train;
end Train_Builder;
