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
		targetSteering: t.track.Value.(CurrentAndTargetSteering).nextSteeringId,
		resp:           make(chan interface{})}
}

func (t *Train) assignTrainToSteering() *SteeringToTrainMsg {
	connectMsg := t.buildSteeringToTrainMsg()
	fmt.Println("Source goRoutine ", t.trainName, ": traget ", connectMsg.targetSteering)
	t.track.Value.(CurrentAndTargetSteering).currentSteeringCh <- connectMsg
	t.track = t.track.Next()
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

type SteeringToTrackMsg struct {
	resp chan interface{}
}

func (s *Steering) assignTrainToTrack() {
	for {
		trainMsg := <-s.inputChanel
		go func() {
			fmt.Println("Source goRoutine ", s.steeringName, ": received msg from train with req travel to", trainMsg.targetSteering)
			connectMsg := &SteeringToTrackMsg{resp: make(chan interface{})}
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
		msgFromSteering.(*SteeringToTrackMsg).resp <- connectMsg
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
		msgFromSteering.(*SteeringToTrackMsg).resp <- connectMsg
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

type CurrentAndTargetSteering struct {
	nextSteeringId    string
	currentSteeringCh chan *SteeringToTrainMsg
}

func generateStopTracks(numOfStopTracks int) []*StopTrack {
	tracks := make([]*StopTrack, numOfStopTracks)
	for i, _ := range tracks {
		tracks[i] = &StopTrack{i, make(chan interface{}, 4), 12 * time.Second}
	}
	return tracks
}

func generateDriveTracks(numOfDriveTracks int) []*DriveTrack {
	tracks := make([]*DriveTrack, numOfDriveTracks)
	for i, _ := range tracks {
		tracks[i] = &DriveTrack{i + 100, make(chan interface{}, 4), 900, 90}
	}
	return tracks
}

type sourceTargetSteeringPair struct {
	sourceSteering string
	targetSteering string
}

func assignRouteToSteering(steeringRoute map[string]chan interface{}, steeringName string) *Steering {
	return &Steering{4 * time.Second, make(chan *SteeringToTrainMsg), steeringRoute, steeringName}
}

func generateTrackForTrain(trackTab []sourceTargetSteeringPair, steerings map[string]*Steering) *ring.Ring {
	tracks := ring.New(len(trackTab))
	for _, value := range trackTab {
		tracks.Value = CurrentAndTargetSteering{
			currentSteeringCh: steerings[value.sourceSteering].inputChanel, nextSteeringId: steerings[value.targetSteering].steeringName}
		tracks = tracks.Next()
	}
	return tracks
}

func main() {
	const numOfSteerings = 14
	const numOfTracks = 20
	const numOfStopTracks = 14
	const numOfDriveTracks = 6
	stopTracks := generateStopTracks(numOfStopTracks)
	driveTracks := generateDriveTracks(numOfDriveTracks)
	steerings := make(map[string]*Steering)
	steerings["steeringA"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringA": stopTracks[0].steeringChan, "steeringC": stopTracks[1].steeringChan}, "steeringA")
	steerings["steeringB"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringB": stopTracks[3].steeringChan, "steeringC": stopTracks[2].steeringChan}, "steeringB")
	steerings["steeringC"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringA": stopTracks[1].steeringChan, "steeringB": stopTracks[2].steeringChan, "steeringD": driveTracks[0].steeringChan}, "steeringC")
	steerings["steeringD"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringE": stopTracks[4].steeringChan, "steeringC": driveTracks[0].steeringChan}, "steeringD")
	steerings["steeringE"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringD": stopTracks[5].steeringChan, "steeringF": driveTracks[1].steeringChan}, "steeringE")
	steerings["steeringF"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringE": driveTracks[1].steeringChan, "steeringG": driveTracks[2].steeringChan}, "steeringF")
	steerings["steeringG"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringF": driveTracks[2].steeringChan, "steeringH": stopTracks[6].steeringChan}, "steeringG")
	steerings["steeringH"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringG": stopTracks[7].steeringChan, "steeringI": driveTracks[3].steeringChan}, "steeringH")
	steerings["steeringI"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringH": driveTracks[3].steeringChan, "steeringJ": driveTracks[4].steeringChan}, "steeringI")
	steerings["steeringJ"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringI": driveTracks[4].steeringChan, "steeringK": stopTracks[8].steeringChan}, "steeringJ")
	steerings["steeringK"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringL": driveTracks[5].steeringChan, "steeringJ": stopTracks[9].steeringChan}, "steeringK")
	steerings["steeringL"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringK": driveTracks[5].steeringChan, "steeringM": stopTracks[10].steeringChan, "steeringN": stopTracks[11].steeringChan}, "steeringL")
	steerings["steeringM"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringL": stopTracks[10].steeringChan, "steeringM": stopTracks[11].steeringChan}, "steeringM")
	steerings["steeringN"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringL": stopTracks[12].steeringChan, "steeringN": stopTracks[13].steeringChan}, "steeringN")

	tracksA := generateTrackForTrain([]sourceTargetSteeringPair{
		{"steeringA", "steeringC"}, {"steeringC", "steeringD"}, {"steeringD", "steeringE"},
		{"steeringE", "steeringD"}, {"steeringD", "steeringC"}, {"steeringC", "steeringA"},
		{"steeringA", "steeringA"}}, steerings)
	trainA := Train{90, 5, tracksA, "trainA"}

	tracksB := generateTrackForTrain([]sourceTargetSteeringPair{
		{"steeringB", "steeringC"}, {"steeringC", "steeringD"}, {"steeringD", "steeringE"},
		{"steeringE", "steeringD"}, {"steeringD", "steeringC"}, {"steeringC", "steeringB"},
		{"steeringB", "steeringB"}}, steerings)
	trainB := Train{90, 5, tracksB, "trainB"}
	for _, val := range stopTracks {
		go val.track()
	}
	for _, val := range driveTracks {
		go val.track()
	}
	for _, val := range steerings {
		go val.assignTrainToTrack()
	}

	go trainA.travelTrough()
	go trainB.travelTrough()

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
