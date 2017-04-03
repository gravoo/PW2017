package main

import "fmt"
import "time"
import "container/ring"

type Train struct {
	maxVelocity int
	maxCapacity int
	track       *ring.Ring
	trainName   string
}

func (t *Train) buildSteeringToTrainMsg() *SteeringToTrainMsg {
	return &SteeringToTrainMsg{
		targetSteering: t.track.Value.(steeringChanelId).nextSteeringId,
		resp:           make(chan interface{})}
}

func (t *Train) assignTrainToSteering() *SteeringToTrainMsg {
	t.track = t.track.Next()
	connectMsg := t.buildSteeringToTrainMsg()
	fmt.Println("Source goRoutine ", t.trainName, ": traget ", connectMsg.targetSteering)
	t.track.Value.(steeringChanelId).currentSteeringCh <- connectMsg
	return connectMsg
}

func (t *Train) driveTroughTrack(msg *DriveTrackToTrainMsg) int {
	velocity := func() int {
		if msg.maxAllowedVelocity < t.maxVelocity {
			return msg.maxAllowedVelocity
		} else {
			return t.maxVelocity
		}
	}
	timeToTravel := msg.trackLength / velocity()
	time.Sleep(time.Duration(timeToTravel) * time.Second)
	return timeToTravel
}

func (t *Train) waitOnStopTrack(msg *StopTrackToTrainMsg) {
	time.Sleep(msg.timeToRest * time.Second)
}

func (t *Train) releaseStopTrack(msg *StopTrackToTrainMsg) {
	msg.resp <- t.trainName
}

func (t *Train) releaseDriveTrack(msg *DriveTrackToTrainMsg) {
	msg.resp <- t.trainName
}

func (train *Train) travelTrough() {
	trainSteeringPipe := train.assignTrainToSteering()
	trackToAttach := <-trainSteeringPipe.resp
	for {
		switch assignedTrack := trackToAttach.(type) {
		case *DriveTrackToTrainMsg:
			fmt.Println("Source goRoutine ", train.trainName, ": received msg from track", assignedTrack.trackId)
			timeToTravel := train.driveTroughTrack(assignedTrack)
			fmt.Println("Source goRoutine ", train.trainName, ": has finidhed route after", timeToTravel)
			trainSteeringPipe = train.assignTrainToSteering()
			train.releaseDriveTrack(assignedTrack)
			trackToAttach = <-trainSteeringPipe.resp
		case *StopTrackToTrainMsg:
			fmt.Println("Source goRoutine ", train.trainName, ": received msg from station, time to wait", assignedTrack.timeToRest)
			trainSteeringPipe = train.assignTrainToSteering()
			train.waitOnStopTrack(assignedTrack)
			trackToAttach = <-trainSteeringPipe.resp
			train.releaseStopTrack(assignedTrack)
		}
		fmt.Println("Source goRoutine ", train.trainName, "has finished route")
	}
}

type Steering struct {
	timeToReconfig time.Duration
	inputChanel    chan *SteeringToTrainMsg
	tracks         map[string]chan interface{}
	steeringName   string
}

type steeringToTrackMsg struct {
	resp chan interface{}
}

func (s *Steering) assignTrainToTrack() {
	for {
		trainMsg := <-s.inputChanel
		go func() {
			fmt.Println("Source goRoutine ", s.steeringName, ": received msg from train with req travel to", trainMsg.targetSteering)
			connectMsg := &steeringToTrackMsg{resp: make(chan interface{})}
			fmt.Println("Source goRoutine ", s.steeringName, ": sending msg to track")
			s.tracks[trainMsg.targetSteering] <- connectMsg
			respFromTrack := <-connectMsg.resp
			fmt.Println("Source goRoutine ", s.steeringName, ": received msg from track time to reconfig", s.timeToReconfig)
			time.Sleep(s.timeToReconfig)
			trainMsg.resp <- respFromTrack
		}()
	}
}

type DriveTrack struct {
	trackId            int
	steeringChan       chan interface{}
	length             int
	maxAllowedVelocity int
}

type StopTrack struct {
	trackId      int
	steeringChan chan interface{}
	timeToRest   time.Duration
}

func (st *StopTrack) buildTrainMsg() *StopTrackToTrainMsg {
	return &StopTrackToTrainMsg{
		trackId:    st.trackId,
		resp:       make(chan string),
		timeToRest: st.timeToRest}
}

func (st *StopTrack) track() {
	for {
		msgFromSteering := <-st.steeringChan
		fmt.Println("Source goRoutine ", st.trackId, ": received msg from steering")
		connectMsg := st.buildTrainMsg()
		msgFromSteering.(*steeringToTrackMsg).resp <- connectMsg
		fmt.Println("Source goRoutine ", st.trackId, ": received msg from train on finish", <-connectMsg.resp)
		close(connectMsg.resp)
	}
}

func (tr *DriveTrack) buildTrainMsg() *DriveTrackToTrainMsg {
	return &DriveTrackToTrainMsg{
		trackId:            tr.trackId,
		resp:               make(chan string),
		maxAllowedVelocity: tr.maxAllowedVelocity,
		trackLength:        tr.length}
}

func (tr *DriveTrack) track() {
	for {
		msgFromSteering := <-tr.steeringChan
		fmt.Println("Source goRoutine ", tr.trackId, ": received msg from steering")
		connectMsg := tr.buildTrainMsg()
		msgFromSteering.(*steeringToTrackMsg).resp <- connectMsg
		fmt.Println("Source goRoutine ", tr.trackId, ": received msg from train on finish", <-connectMsg.resp)
		close(connectMsg.resp)
	}
}

type SteeringToTrainMsg struct {
	targetSteering string
	resp           chan interface{}
}

type StopTrackToTrainMsg struct {
	trackId    int
	resp       chan string
	timeToRest time.Duration
}
type DriveTrackToTrainMsg struct {
	trackId            int
	resp               chan string
	maxAllowedVelocity int
	trackLength        int
}

type steeringChanelId struct {
	nextSteeringId    string
	currentSteeringCh chan *SteeringToTrainMsg
}

func generateChannelsForSteerings(numOfSteering int) []chan *SteeringToTrainMsg {
	inputSteringChan := make([]chan *SteeringToTrainMsg, numOfSteering)
	for i, _ := range inputSteringChan {
		inputSteringChan[i] = make(chan *SteeringToTrainMsg)
	}
	return inputSteringChan
}

func generateChannelsForTrack(numOfTracks int) []chan interface{} {
	tracks := make([]chan interface{}, numOfTracks)
	for i, _ := range tracks {
		tracks[i] = make(chan interface{}, 4)
	}
	return tracks
}

func main() {

}
