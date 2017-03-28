package main

import "fmt"
import "time"
import "container/ring"

type Train struct{
    maxVelocity int
    maxCapacity int
    track *ring.Ring
    trainName string
}

func(t *Train) buildSteeringToTrainMsg() *steeringToTrainMsg {
    return &steeringToTrainMsg{
        targetSteering : t.track.Value.(steeringChanelId).nextSteeringId,
        resp :  make(chan *trackToTrainMsg) }
}


func(t* Train) assignTrainToSteering() *steeringToTrainMsg {
    t.track = t.track.Next()
    connectMsg := t.buildSteeringToTrainMsg()
    fmt.Println("Source goRoutine", t.trainName,": traget ",connectMsg.targetSteering)
    t.track.Value.(steeringChanelId).currentSteeringCh<-connectMsg
    return connectMsg
}

func(t* Train)  travelTrough(){
    connectMsg := t.assignTrainToSteering()
    responseFromTrack := <-connectMsg.resp
	for {
        fmt.Println("Source goRoutine ", t.trainName, ": received msg from track", responseFromTrack.trackId)
        velocity := func() int {
            if responseFromTrack.maxAllowedVelocity < t.maxVelocity {
                return responseFromTrack.maxAllowedVelocity
            } else {
                return t.maxVelocity
            }
        }
        timeToTravel := velocity()/responseFromTrack.trackLength
        time.Sleep(5*time.Second)
        connectMsg = t.assignTrainToSteering()
        responseFromTrack.resp <- t.trainName + "has finished trace"
        responseFromTrack = <-connectMsg.resp
        fmt.Println("Source goRoutine ",t.trainName,": has finidhed route after", timeToTravel)
	}
}

type Steering struct{
	timeToReconfig time.Duration
    inputChanel chan *steeringToTrainMsg
    tracks map[string] chan *trackToTrainMsg
    steeringName string
}

func (s* Steering) assignTrainToTrack(){
    for {
        trainMsg := <-s.inputChanel
        fmt.Println("Source goRoutine ", s.steeringName, ": received msg from train with req travel to", trainMsg.targetSteering)
        connectMsg := &trackToTrainMsg{}
        fmt.Println("Source goRoutine ", s.steeringName, ": sending msg to track")
        s.tracks[trainMsg.targetSteering] <- connectMsg
        trackResp := <-s.tracks[trainMsg.targetSteering]
        fmt.Println("Source goRoutine ", s.steeringName, ": received msg from track", trackResp.trackId, " time to reconfig")
		time.Sleep(s.timeToReconfig)
        trainMsg.resp <-trackResp
    }
}

type Track struct{
    trackId int
    steeringChan chan *trackToTrainMsg
    length int
    maxAllowedVelocity int
}

func(tr *Track) buildTrackToTrainMsg() *trackToTrainMsg{
    return &trackToTrainMsg{
        trackId : tr.trackId,
        resp : make( chan string) ,
        maxAllowedVelocity:tr.maxAllowedVelocity,
        trackLength : tr.length}
}

func (tr* Track) track(){
	for{
        <-tr.steeringChan
        fmt.Println("Source goRoutine ", tr.trackId, ": received msg from steering")
        connectMsg := tr.buildTrackToTrainMsg()
        tr.steeringChan <- connectMsg
        fmt.Println("Source goRoutine ", tr.trackId, ": received msg from train on finish", <-connectMsg.resp)
        close(connectMsg.resp)
	}
}

type steeringToTrainMsg struct{
    targetSteering string
    resp chan *trackToTrainMsg
}

type trackToTrainMsg struct{
    trackId int
    resp chan string
    maxAllowedVelocity int
    trackLength int
}

type steeringChanelId struct{
    nextSteeringId string
    currentSteeringCh chan *steeringToTrainMsg
}

func main() {
    trackAChanel := make(chan *trackToTrainMsg)
    trackBChanel := make(chan *trackToTrainMsg)

    trackA := Track{1, trackAChanel, 50, 90}
    trackB := Track{2, trackBChanel, 50, 90}

    steeringInputChannels := [3] chan *steeringToTrainMsg{make(chan *steeringToTrainMsg),
                                                                make(chan *steeringToTrainMsg),
                                                                make(chan *steeringToTrainMsg)}

    steeringAtracks := map[string] chan *trackToTrainMsg {"steeringB":trackAChanel}
    steeringBtracks := map[string] chan *trackToTrainMsg {"steeringA":trackAChanel, "steeringC":trackBChanel}
    steeringCtracks := map[string] chan *trackToTrainMsg {"steeringB":trackBChanel}

    steeringA := Steering{4*time.Second, steeringInputChannels[0], steeringAtracks, "steeringA"}
    steeringB := Steering{4*time.Second, steeringInputChannels[1], steeringBtracks, "steeringB"}
    steeringC := Steering{4*time.Second, steeringInputChannels[2], steeringCtracks, "steeringC"}

    trainATrack := ring.New(2)
    trainATrack.Value = steeringChanelId{"steeringB", steeringInputChannels[0]}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringA", steeringInputChannels[1]}
    trainATrack = trainATrack.Next()
    trainA:= Train{80, 5, trainATrack, "trainA"}

    trainBTrack := ring.New(2)
    trainBTrack.Value = steeringChanelId{"steeringB", steeringInputChannels[2]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringC", steeringInputChannels[1]}
    trainBTrack = trainBTrack.Next()
    trainB:= Train{40, 5, trainBTrack, "trainB"}

	go trainA.travelTrough()
	go trainB.travelTrough()
	go steeringA.assignTrainToTrack()
	go steeringB.assignTrainToTrack()
	go steeringC.assignTrainToTrack()
	go trackA.track()
	go trackB.track()
	time.Sleep(9000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
