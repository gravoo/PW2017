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
    fmt.Println("Source goRoutine ", t.trainName,": traget ",connectMsg.targetSteering)
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
            responseFromTrack = <-connectMsg.resp
            msg.resp <- t.trainName + "has finished trace"

        case *stationToTrainMsg:
            fmt.Println("Source goRoutine ", t.trainName, ": received msg from station, time to wait", msg.timeToRest)
            connectMsg = t.assignTrainToSteering()
            time.Sleep(msg.timeToRest*time.Second)
            responseFromTrack = <-connectMsg.resp
            msg.resp <- t.trainName + "has finished waiting on station"
        }
        fmt.Println("Source goRoutine ", t.trainName, "has finished route")
	}
}

type Steering struct{
	timeToReconfig time.Duration
    inputChanel chan *steeringToTrainMsg
    tracks map[string] chan interface{}
    steeringName string
}

type steeringToTrackMsg struct {
    resp chan interface{}
}

func (s* Steering) assignTrainToTrack(){
    for {
        trainMsg := <-s.inputChanel
        go func (){
            fmt.Println("Source goRoutine ", s.steeringName, ": received msg from train with req travel to", trainMsg.targetSteering)
            connectMsg := &steeringToTrackMsg{resp:make (chan interface{})}
            fmt.Println("Source goRoutine ", s.steeringName, ": sending msg to track")
            s.tracks[trainMsg.targetSteering] <- connectMsg
            respFromTrack := <-connectMsg.resp
            fmt.Println("Source goRoutine ", s.steeringName, ": received msg from track time to reconfig", s.timeToReconfig)
            time.Sleep(s.timeToReconfig)
            trainMsg.resp <- respFromTrack
        }()
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
        timeToRest : st.timeToRest} }

func (st* Station) track(){
	for{
        msgFromSteering := <-st.steeringChan
        fmt.Println("Source goRoutine ", st.trackId, ": received msg from steering")
        connectMsg := st.buildStationToTrainMsg()
        msgFromSteering.(*steeringToTrackMsg).resp <- connectMsg
        fmt.Println("Source goRoutine ", st.trackId, ": received msg from train on finish", <-connectMsg.resp)
        close(connectMsg.resp)
	}
}

func(tr *Track) buildTrackToTrainMsg() *trackToTrainMsg{
    return &trackToTrainMsg{
        trackId : tr.trackId,
        resp : make( chan string ) ,
        maxAllowedVelocity:tr.maxAllowedVelocity,
        trackLength : tr.length}
}

func (tr* Track) track(){
	for{
        msgFromSteering := <-tr.steeringChan
        fmt.Println("Source goRoutine ", tr.trackId, ": received msg from steering")
        connectMsg := tr.buildTrackToTrainMsg()
        msgFromSteering.(*steeringToTrackMsg).resp <- connectMsg
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

func generateChannelsForSteerings(numOfSteering int) [] chan *steeringToTrainMsg{
    inputSteringChan := make([] chan *steeringToTrainMsg, numOfSteering)
    for i, _ := range inputSteringChan {
        inputSteringChan[i] = make(chan *steeringToTrainMsg)
    }
    return inputSteringChan
}

func generateChannelsForTrack(numOfTracks int) [] chan interface{}{
    tracks := make([] chan interface{}, numOfTracks)
    for i, _ := range tracks {
        tracks[i] = make(chan interface{}, 4)
    }
    return tracks
}

func main() {
    trackInputChannels := generateChannelsForTrack(8)
    steeringInputChannels := generateChannelsForSteerings(6)

    stationTrack0 := Station{0, trackInputChannels[0], 12*time.Second}
    stationTrack1 := Station{1, trackInputChannels[1], 12*time.Second}
    stationTrack2 := Station{2, trackInputChannels[2], 12*time.Second}
    stationTrack3 := Station{3, trackInputChannels[3], 12*time.Second}
    driveTrack10 := Track{10, trackInputChannels[4], 900, 90}
    driveTrack11 := Track{11, trackInputChannels[5], 90, 9}
    driveTrack12 := Track{12, trackInputChannels[6], 90, 9}
    driveTrack13 := Track{13, trackInputChannels[7], 90, 9}

    steeringAtracks := make(map[string] chan interface{})
    steeringAtracks["steeringC"] = stationTrack0.steeringChan
    steeringAtracks["steeringA"] = driveTrack11.steeringChan

    steeringBtracks := make(map[string] chan interface{})
    steeringBtracks["steeringC"] = trackInputChannels[1]
    steeringBtracks["steeringB"] = trackInputChannels[4]

    steeringCtracks := make(map[string] chan interface{})
    steeringCtracks["steeringA"] = trackInputChannels[0]
    steeringCtracks["steeringB"] = trackInputChannels[1]
    steeringCtracks["steeringD"] = trackInputChannels[4]

    steeringDtracks := make(map[string] chan interface{})
    steeringDtracks["steeringC"] = trackInputChannels[4]
    steeringDtracks["steeringE"] = trackInputChannels[2]
    steeringDtracks["steeringF"] = trackInputChannels[3]

    steeringEtracks := make(map[string] chan interface{})
    steeringEtracks["steeringD"] = trackInputChannels[2]
    steeringEtracks["steeringE"] = trackInputChannels[6]

    steeringFtracks := make(map[string] chan interface{})
    steeringFtracks["steeringD"] = trackInputChannels[3]
    steeringFtracks["steeringF"] = trackInputChannels[7]

    steeringA := Steering{4*time.Second, steeringInputChannels[0], steeringAtracks, "steeringA"}
    steeringB := Steering{4*time.Second, steeringInputChannels[1], steeringBtracks, "steeringB"}
    steeringC := Steering{4*time.Second, steeringInputChannels[2], steeringCtracks, "steeringC"}
    steeringD := Steering{4*time.Second, steeringInputChannels[3], steeringDtracks, "steeringD"}
    steeringE := Steering{4*time.Second, steeringInputChannels[4], steeringEtracks, "steeringE"}
    steeringF := Steering{4*time.Second, steeringInputChannels[5], steeringFtracks, "steeringF"}

    trainATrack := ring.New(8)
    trainATrack.Value = steeringChanelId{currentSteeringCh:steeringA.inputChanel, nextSteeringId:"steeringC"}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringD", steeringC.inputChanel}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringE", steeringD.inputChanel}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringE", steeringE.inputChanel}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringD", steeringE.inputChanel}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringC", steeringD.inputChanel}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringA", steeringC.inputChanel}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringA", steeringA.inputChanel}
    trainA:= Train{90, 5, trainATrack, "trainA"}

    trainBTrack := ring.New(8)
    trainBTrack.Value = steeringChanelId{"steeringD", steeringInputChannels[5]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringC", steeringInputChannels[3]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringB", steeringInputChannels[2]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringB", steeringInputChannels[1]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringC", steeringInputChannels[1]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringD", steeringInputChannels[2]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringF", steeringInputChannels[3]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringF", steeringInputChannels[5]}
    trainB := Train{45, 5, trainBTrack, "trainB"}


	go trainA.travelTrough()
	go trainB.travelTrough()
	go steeringA.assignTrainToTrack()
	go steeringB.assignTrainToTrack()
	go steeringC.assignTrainToTrack()
	go steeringD.assignTrainToTrack()
	go steeringE.assignTrainToTrack()
	go steeringF.assignTrainToTrack()
    go stationTrack0.track()
    go stationTrack1.track()
    go stationTrack2.track()
    go stationTrack3.track()
    go driveTrack10.track()
    go driveTrack11.track()
    go driveTrack12.track()
    go driveTrack13.track()
	time.Sleep(9000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
