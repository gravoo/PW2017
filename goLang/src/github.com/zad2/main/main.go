//Bartlomiej Sadowski 204392
package main

import (
	"container/ring"
	"fmt"
	"github.com/zad2/utils"
	"time"
)

type Train struct {
	maxVelocity int
	maxCapacity int
	track       *ring.Ring
	trainName   string
}

func (t *Train) buildSteeringToTrainMsg() *utils.SteeringToTrainMsg {
	return &utils.SteeringToTrainMsg{
		TargetSteering: t.track.Value.(CurrentAndTargetSteering).nextSteeringId,
		Resp:           make(chan interface{})}
}

func (t *Train) assignTrainToSteering() *utils.SteeringToTrainMsg {
	connectMsg := t.buildSteeringToTrainMsg()
	fmt.Println("Source goRoutine ", t.trainName, ": destination ", connectMsg.TargetSteering)
	t.track.Value.(CurrentAndTargetSteering).currentSteeringCh <- connectMsg
	t.track = t.track.Next()
	return connectMsg
}

func (t *Train) driveTroughTrack(msg *utils.DriveTrackToTrainMsg) int {
	velocity := func() int {
		if msg.MaxAllowedVelocity < t.maxVelocity {
			return msg.MaxAllowedVelocity
		} else {
			return t.maxVelocity
		}
	}
	timeToTravel := msg.TrackLength / velocity()
	time.Sleep(time.Duration(timeToTravel) * time.Second)
	return timeToTravel
}

func (t *Train) waitOnStopTrack(msg *utils.StopTrackToTrainMsg) {
	time.Sleep(msg.TimeToRest * time.Second)
}

func (t *Train) releaseStopTrack(msg *utils.StopTrackToTrainMsg) {
	msg.Resp <- t.trainName
}

func (t *Train) releaseDriveTrack(msg *utils.DriveTrackToTrainMsg) {
	msg.Resp <- t.trainName
}

func (train *Train) travelTrough() {
	trainSteeringPipe := train.assignTrainToSteering()
	trackToAttach := <-trainSteeringPipe.Resp
	for {
		switch assignedTrack := trackToAttach.(type) {
		case *utils.DriveTrackToTrainMsg:
			fmt.Println("Source goRoutine ", train.trainName, ": received msg from track", assignedTrack.TrackId)
			timeToTravel := train.driveTroughTrack(assignedTrack)
			fmt.Println("Source goRoutine ", train.trainName, ": has finished route after", timeToTravel)
			trainSteeringPipe = train.assignTrainToSteering()
			train.releaseDriveTrack(assignedTrack)
			trackToAttach = <-trainSteeringPipe.Resp
		case *utils.StopTrackToTrainMsg:
			fmt.Println("Source goRoutine ", train.trainName, ": received msg from station, time to wait", assignedTrack.TimeToRest)
			trainSteeringPipe = train.assignTrainToSteering()
			train.waitOnStopTrack(assignedTrack)
			trackToAttach = <-trainSteeringPipe.Resp
			train.releaseStopTrack(assignedTrack)
		}
		fmt.Println("Source goRoutine ", train.trainName, "has finished route")
	}
}

type Steering struct {
	timeToReconfig time.Duration
	inputChanel    chan *utils.SteeringToTrainMsg
	tracks         map[string]chan interface{}
	steeringName   string
}

func (s *Steering) assignTrainToTrack() {
	for {
		trainMsg := <-s.inputChanel
		go func() {
			fmt.Println("Source goRoutine ", s.steeringName, ": received msg from train with req travel to", trainMsg.TargetSteering)
			connectMsg := &utils.SteeringToTrackMsg{Resp: make(chan interface{})}
			fmt.Println("Source goRoutine ", s.steeringName, ": sending msg to track")
			s.tracks[trainMsg.TargetSteering] <- connectMsg
			respFromTrack := <-connectMsg.Resp
			fmt.Println("Source goRoutine ", s.steeringName, ": received msg from track time to reconfiguration", s.timeToReconfig)
			time.Sleep(s.timeToReconfig)
			trainMsg.Resp <- respFromTrack
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

func (st *StopTrack) buildTrainMsg() *utils.StopTrackToTrainMsg {
	return &utils.StopTrackToTrainMsg{
		TrackId:    st.trackId,
		Resp:       make(chan string),
		TimeToRest: st.timeToRest}
}

func (st *StopTrack) track() {
	for {
		msgFromSteering := <-st.steeringChan
		fmt.Println("Source goRoutine ", st.trackId, ": received msg from steering")
		connectMsg := st.buildTrainMsg()
		msgFromSteering.(*utils.SteeringToTrackMsg).Resp <- connectMsg
		fmt.Println("Source goRoutine ", st.trackId, ": received msg from train on finish", <-connectMsg.Resp)
		close(connectMsg.Resp)
	}
}

func (tr *DriveTrack) buildTrainMsg() *utils.DriveTrackToTrainMsg {
	return &utils.DriveTrackToTrainMsg{
		TrackId:            tr.trackId,
		Resp:               make(chan string),
		MaxAllowedVelocity: tr.maxAllowedVelocity,
		TrackLength:        tr.length}
}

func (tr *DriveTrack) track() {
	for {
		msgFromSteering := <-tr.steeringChan
		fmt.Println("Source goRoutine ", tr.trackId, ": received msg from steering")
		connectMsg := tr.buildTrainMsg()
		msgFromSteering.(*utils.SteeringToTrackMsg).Resp <- connectMsg
		fmt.Println("Source goRoutine ", tr.trackId, ": received msg from train on finish", <-connectMsg.Resp)
		close(connectMsg.Resp)
	}
}

type CurrentAndTargetSteering struct {
	nextSteeringId    string
	currentSteeringCh chan *utils.SteeringToTrainMsg
}

func generateStopTracks(numOfStopTracks int) []*StopTrack {
	tracks := make([]*StopTrack, numOfStopTracks)
	for i, _ := range tracks {
		tracks[i] = &StopTrack{i, make(chan interface{}, 4), 10 * time.Second}
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

func assignRouteToSteering(steeringRoute map[string]chan interface{}, steeringName string) *Steering {
	return &Steering{5 * time.Second, make(chan *utils.SteeringToTrainMsg), steeringRoute, steeringName}
}

func generateTrackForTrain(trackTab []string, steerings map[string]*Steering) *ring.Ring {
	tracks := ring.New(len(trackTab))
	firstSteering := trackTab[0]
	for _, value := range trackTab {
		tracks.Value = CurrentAndTargetSteering{
			currentSteeringCh: steerings["steering"+firstSteering].inputChanel, nextSteeringId: steerings["steering"+value].steeringName}
		firstSteering = value
		tracks = tracks.Next()
	}
	return tracks
}

func main() {
	const numOfSteerings = 22
	const numOfTracks = 30
	const numOfStopTracks = 24
	const numOfDriveTracks = 9
	stopTracks := generateStopTracks(numOfStopTracks)
	driveTracks := generateDriveTracks(numOfDriveTracks)
	steerings := make(map[string]*Steering)
	steerings["steeringA"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringA": stopTracks[0].steeringChan,
		"steeringC": stopTracks[1].steeringChan}, "steeringA")
	steerings["steeringB"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringB": stopTracks[3].steeringChan,
		"steeringC": stopTracks[2].steeringChan}, "steeringB")
	steerings["steeringC"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringA": stopTracks[1].steeringChan,
		"steeringB": stopTracks[2].steeringChan,
		"steeringD": driveTracks[0].steeringChan}, "steeringC")
	steerings["steeringD"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringE": stopTracks[4].steeringChan,
		"steeringC": driveTracks[0].steeringChan}, "steeringD")
	steerings["steeringE"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringD": stopTracks[5].steeringChan,
		"steeringG": driveTracks[1].steeringChan,
		"steeringU": driveTracks[6].steeringChan}, "steeringE")
	steerings["steeringG"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringE": driveTracks[8].steeringChan,
		"steeringH": stopTracks[6].steeringChan}, "steeringG")
	steerings["steeringH"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringG": stopTracks[7].steeringChan,
		"steeringJ": driveTracks[2].steeringChan,
		"steeringO": driveTracks[4].steeringChan}, "steeringH")
	steerings["steeringJ"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringH": driveTracks[7].steeringChan,
		"steeringK": stopTracks[8].steeringChan,
		"steeringO": driveTracks[6].steeringChan}, "steeringJ")
	steerings["steeringK"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringL": driveTracks[3].steeringChan,
		"steeringJ": stopTracks[9].steeringChan}, "steeringK")
	steerings["steeringL"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringK": driveTracks[3].steeringChan,
		"steeringM": stopTracks[10].steeringChan,
		"steeringN": stopTracks[11].steeringChan}, "steeringL")
	steerings["steeringM"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringL": stopTracks[10].steeringChan,
		"steeringM": stopTracks[12].steeringChan}, "steeringM")
	steerings["steeringN"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringL": stopTracks[11].steeringChan,
		"steeringN": stopTracks[13].steeringChan}, "steeringN")
	steerings["steeringO"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringJ": driveTracks[6].steeringChan,
		"steeringP": stopTracks[14].steeringChan}, "steeringO")
	steerings["steeringP"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringO": stopTracks[15].steeringChan,
		"steeringR": driveTracks[7].steeringChan}, "steeringP")
	steerings["steeringR"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringS": stopTracks[16].steeringChan,
		"steeringT": stopTracks[17].steeringChan,
		"steeringP": driveTracks[5].steeringChan}, "steeringR")
	steerings["steeringS"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringR": stopTracks[16].steeringChan,
		"steeringS": stopTracks[18].steeringChan}, "steeringS")
	steerings["steeringT"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringR": stopTracks[17].steeringChan,
		"steeringT": stopTracks[19].steeringChan}, "steeringT")
	steerings["steeringU"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringW": stopTracks[20].steeringChan,
		"steeringX": stopTracks[21].steeringChan,
		"steeringE": driveTracks[6].steeringChan}, "steeringU")
	steerings["steeringW"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringU": stopTracks[20].steeringChan,
		"steeringW": stopTracks[22].steeringChan}, "steeringW")
	steerings["steeringX"] = assignRouteToSteering(map[string]chan interface{}{
		"steeringU": stopTracks[21].steeringChan,
		"steeringX": stopTracks[23].steeringChan}, "steeringX")

	routes := make(map[string]*ring.Ring)
	routes["trainAroute"] = generateTrackForTrain([]string{
		"A", "C", "D", "E", "G", "H", "J", "K", "L", "M",
		"M", "L", "K", "J", "H", "G", "E", "D", "C", "A"}, steerings)
	routes["trainBroute"] = generateTrackForTrain([]string{
		"N", "L", "K", "J", "H", "G", "E", "D", "C", "B",
		"B", "C", "D", "E", "G", "H", "J", "K", "L", "N"}, steerings)
	routes["trainCroute"] = generateTrackForTrain([]string{
		"S", "R", "P", "O", "J", "H", "G",
		"H", "J", "O", "P", "R", "S"}, steerings)
	routes["trainDroute"] = generateTrackForTrain([]string{
		"X", "U", "E", "G", "H",
		"G", "E", "U", "W"}, steerings)

	trains := make(map[string]*Train)
	trains["trainA"] = &Train{90, 5, routes["trainAroute"], "trainA"}
	trains["trainB"] = &Train{90, 5, routes["trainBroute"], "trainB"}
	trains["trainC"] = &Train{90, 5, routes["trainCroute"], "trainC"}
	trains["trainD"] = &Train{90, 5, routes["trainDroute"], "trainD"}

	for _, val := range stopTracks {
		go val.track()
	}
	for _, val := range driveTracks {
		go val.track()
	}
	for _, val := range steerings {
		go val.assignTrainToTrack()
	}

	for _, val := range trains {
		go val.travelTrough()
	}

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
