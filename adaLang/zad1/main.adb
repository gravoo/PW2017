with Ada.Text_IO;

procedure Main is
    task type Steering is
        entry AssignTrainToTrack;
    end Steering;
    task type Train is 
        entry AssignTrain (An_Steering : in Steering);
    end Train;

    task body Steering is
        SteeringName : String := "SteeringA";
    begin 
        loop
            accept AssignTrainToTrack do
                Ada.Text_IO.Put_Line("received msg from train with req travel to");
            end AssignTrainToTrack;
        end loop;
    end Steering;

    task body Train is
        TrainName : String := "TrainA";
    begin
        loop
            select 
            accept AssignTrain(An_Steering : in Steering) do
                Ada.Text_IO.Put_Line("traget");
                An_Steering.AssignTrainToTrack;
            end AssignTrain;
            end select;
        end loop;
    end Train;
    SteeringA, SteeringB: Steering;
    TrainA, TrainB: Train;
begin
    TrainA.AssignTrain(SteeringA);
end Main;
