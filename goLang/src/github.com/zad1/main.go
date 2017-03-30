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
        resp :  make(chan interface{}) }
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
        switch msg := responseFromTrack.(type){
        case *trackToTrainMsg:
            fmt.Println("Source goRoutine ", t.trainName, ": received msg from track", msg.trackId)
            velocity := func() int {
                if msg.maxAllowedVelocity < t.maxVelocity {
                    return msg.maxAllowedVelocity
                } else {
                    return t.maxVelocity
                }
            }
            timeToTravel := msg.trackLength/velocity()
            time.Sleep(time.Duration(timeToTravel)*time.Second)
            fmt.Println("Source goRoutine ",t.trainName,": has finidhed route after", timeToTravel)
            connectMsg = t.assignTrainToSteering()
            msg.resp <- t.trainName + "has finished trace"
        case *stationToTrainMsg:
            fmt.Println("Source goRoutine ", t.trainName, ": received msg from station", msg.trackId)
            connectMsg = t.assignTrainToSteering()
            time.Sleep(msg.timeToRest)
            msg.resp <- t.trainName + "has finished waiting on station"
        }
        responseFromTrack = <-connectMsg.resp
        fmt.Println("Source goRoutine ", t.trainName, "has finished route")
	}
}

type Steering struct{
	timeToReconfig time.Duration
    inputChanel chan *steeringToTrainMsg
    tracks map[string] chan interface{}
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
        //fmt.Println("Source goRoutine ", s.steeringName, ": received msg from track", trackResp.trackId, " time to reconfig")
		time.Sleep(s.timeToReconfig)
        trainMsg.resp <-trackResp
    }
}

type Track struct{
    trackId int
    steeringChan chan interface{}
    length int
    maxAllowedVelocity int
}

type Station struct{
    trackId int
    steeringChan chan interface{}
    timeToRest time.Duration
}

func(st *Station) buildStationToTrainMsg() *stationToTrainMsg{
    return &stationToTrainMsg{
        trackId : st.trackId,
        resp : make(chan string),
        timeToRest : st.timeToRest}
}

func (st* Station) track(){
	for{
        <-st.steeringChan
        fmt.Println("Source goRoutine ", st.trackId, ": received msg from steering")
        connectMsg := st.buildStationToTrainMsg()
        st.steeringChan <- connectMsg
        fmt.Println("Source goRoutine ", st.trackId, ": received msg from train on finish", <-connectMsg.resp)
        close(connectMsg.resp)
	}
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
    resp chan interface{}
}

type stationToTrainMsg struct{
    trackId int
    resp chan string
    timeToRest time.Duration
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
    //trackAChanel := make(chan *trackToTrainMsg)
    //trackBChanel := make(chan *trackToTrainMsg)

    stationAChanel := make(chan interface{})
    stationBChanel := make(chan interface{})

    //trackA := Track{1, trackAChanel, 180, 90}
    //trackB := Track{2, trackBChanel, 180, 90}
    stationA := Station{1, stationAChanel, 120}
    stationB := Station{1, stationBChanel, 120}

    steeringInputChannels := [3] chan *steeringToTrainMsg{make(chan *steeringToTrainMsg), make(chan *steeringToTrainMsg), make(chan *steeringToTrainMsg)}

    dupa := make( map[string] chan interface{})
    dupa["dupa"] = make(chan interface{})

    steeringAtracks := make(map[string] chan interface{})
    steeringAtracks["steeringB"] = stationAChanel
    steeringBtracks := make(map[string] chan interface{})
    steeringBtracks["steeringA"] = stationAChanel
    steeringBtracks["steeringC"] = stationBChanel
    steeringCtracks := make(map[string] chan interface{})
    steeringAtracks["steeringB"] = stationBChanel

    steeringA := Steering{4*time.Second, steeringInputChannels[0], steeringAtracks, "steeringA"}
    steeringB := Steering{4*time.Second, steeringInputChannels[1], steeringBtracks, "steeringB"}
    steeringC := Steering{4*time.Second, steeringInputChannels[2], steeringCtracks, "steeringC"}

    trainATrack := ring.New(2)
    trainATrack.Value = steeringChanelId{"steeringB", steeringInputChannels[0]}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringA", steeringInputChannels[1]}
    trainATrack = trainATrack.Next()
    trainA:= Train{90, 5, trainATrack, "trainA"}

    trainBTrack := ring.New(2)
    trainBTrack.Value = steeringChanelId{"steeringB", steeringInputChannels[2]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringC", steeringInputChannels[1]}
    trainBTrack = trainBTrack.Next()
    trainB:= Train{45, 5, trainBTrack, "trainB"}

	go trainA.travelTrough()
	go trainB.travelTrough()
	go steeringA.assignTrainToTrack()
	go steeringB.assignTrainToTrack()
	go steeringC.assignTrainToTrack()
    go stationA.track()
    go stationB.track()
	//go trackA.track()
	//go trackB.track()
	time.Sleep(9000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
