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

func(t* Train)  travelTrough(){
	for {
        t.track = t.track.Next()
        nextSteeringName := t.track.Value.(steeringChanelId).nextSteeringId
        fmt.Println(t.trainName, "is going to: ", nextSteeringName)
        connectMsg := &steeringToTrainAssignMsg{
            targetSteering : nextSteeringName,
            resp :  make(chan *trackToTrainAssignMsg) }
        fmt.Println("Sending msg to steering")
        t.track.Value.(steeringChanelId).currentSteeringCh<-connectMsg
        responseFromTrain := <-connectMsg.resp
        velocity := func() int {
            if responseFromTrain.maxAllowedVelocity < t.maxVelocity {
                return responseFromTrain.maxAllowedVelocity
            } else {
                return t.maxVelocity
            }
        }
        fmt.Println("Received value form steering, assign track to train with speed:",velocity())
        timeToTravel := velocity()/responseFromTrain.trackLength
        fmt.Println("track is blocked for", timeToTravel, "h")
        time.Sleep(5*time.Second)
        responseFromTrain.resp <- t.trainName + "has finished trace"
        fmt.Println("we are done now")
	}
}

type Steering struct{
	timeToReconfig time.Duration
    inputChanel chan *steeringToTrainAssignMsg
    tracks map[string] chan *trackToTrainAssignMsg
}

func (s* Steering) assignTrainToTrack(steeringName string){
    for {
        trainMsg := <-s.inputChanel
        fmt.Println("Received msg on", steeringName, "to ", trainMsg.targetSteering ," pushing to track", s.tracks[trainMsg.targetSteering])
        connectMsg := &trackToTrainAssignMsg{}
        s.tracks[trainMsg.targetSteering] <- connectMsg
        trackResp := <-s.tracks[trainMsg.targetSteering]
        fmt.Println("Response from track", trackResp.trackId)
		time.Sleep(s.timeToReconfig)
        trainMsg.resp <-trackResp
    }
}

type Track struct{
    trackId int
    in chan *trackToTrainAssignMsg
    length int
    maxAllowedVelocity int
}

func (tr* Track) track(){
	for{
		fmt.Println("Received msg on trackId", tr.trackId," ",<-tr.in)
        connectMsg := &trackToTrainAssignMsg{
            trackId : tr.trackId,
            resp : make( chan string) ,
            maxAllowedVelocity:tr.maxAllowedVelocity,
            trackLength : tr.length}
        tr.in <- connectMsg
        fmt.Println(<-connectMsg.resp)
        close(connectMsg.resp)
	}
}

type steeringToTrainAssignMsg struct{
    targetSteering string
    resp chan *trackToTrainAssignMsg
}

type trackToTrainAssignMsg struct{
    trackId int
    resp chan string
    maxAllowedVelocity int
    trackLength int
}

type steeringChanelId struct{
    nextSteeringId string
    currentSteeringCh chan *steeringToTrainAssignMsg
}

func main() {
    trackAChanel := make(chan *trackToTrainAssignMsg)
    trackBChanel := make(chan *trackToTrainAssignMsg)

    trackA := Track{1, trackAChanel, 50, 90}
    trackB := Track{2, trackBChanel, 50, 90}

    steeringInputChannels := [3] chan *steeringToTrainAssignMsg{make(chan *steeringToTrainAssignMsg),
                                                                make(chan *steeringToTrainAssignMsg),
                                                                make(chan *steeringToTrainAssignMsg)}

    steeringAtracks := map[string] chan *trackToTrainAssignMsg {"steeringB":trackAChanel}
    steeringBtracks := map[string] chan *trackToTrainAssignMsg {"steeringA":trackAChanel, "steeringC":trackBChanel}
    steeringCtracks := map[string] chan *trackToTrainAssignMsg {"steeringB":trackBChanel}

    steeringA := Steering{4*time.Second, steeringInputChannels[0], steeringAtracks}
    steeringB := Steering{4*time.Second, steeringInputChannels[1], steeringBtracks}
    steeringC := Steering{4*time.Second, steeringInputChannels[2], steeringCtracks}

    trainATrack := ring.New(3)
    trainATrack.Value = steeringChanelId{"steeringB", steeringInputChannels[0]}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringC", steeringInputChannels[1]}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringB", steeringInputChannels[2]}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringA", steeringInputChannels[1]}
    trainATrack = trainATrack.Next()
    trainA:= Train{80, 5, trainATrack, "trainA"}

    trainBTrack := ring.New(3)
    trainBTrack.Value = steeringChanelId{"steeringB", steeringInputChannels[2]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringA", steeringInputChannels[1]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringB", steeringInputChannels[0]}
    trainBTrack = trainBTrack.Next()
    trainBTrack.Value = steeringChanelId{"steeringC", steeringInputChannels[1]}
    trainBTrack = trainBTrack.Next()
    trainB:= Train{80, 5, trainBTrack, "trainB"}

	go trainA.travelTrough()
	go trainB.travelTrough()
	go steeringA.assignTrainToTrack("steeringA")
	go steeringB.assignTrainToTrack("steeringB")
	go steeringC.assignTrainToTrack("steeringC")
	go trackA.track()
	go trackB.track()
	time.Sleep(20000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
