package utils

import "time"

type DriveTrackToTrainMsg struct {
	TrackId            int
	Resp               chan string
	MaxAllowedVelocity int
	TrackLength        int
}

type SteeringToTrainMsg struct {
	TargetSteering string
	Resp           chan interface{}
}

type StopTrackToTrainMsg struct {
	TrackId    int
	Resp       chan string
	TimeToRest time.Duration
}
type SteeringToTrackMsg struct {
	Resp chan interface{}
}
type TrackToTrainMsg struct {
	Resp chan interface{}
}

type TrainToTrackMsg struct {
	Resp chan interface{}
}
