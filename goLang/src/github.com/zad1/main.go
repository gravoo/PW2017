package main

import "fmt"
import "time"
import "container/ring"

type Train struct{
    maxVelocity int
    maxCapacity int
    track *ring.Ring
}

func(t* Train)  travelTrough(d time.Duration){
	for {
        t.track = t.track.Next()
        steering := t.track.Value.(steeringChanelId).nextSteeringId
        fmt.Println("TrainA is going to steering:", steering)
        connectMsg := &trackAssign{
            steering : steering,
            resp : make( chan string) }
        fmt.Println("Sending msg to steering")
        t.track.Value.(steeringChanelId).currentSteeringCh<- connectMsg
		time.Sleep(d)
        fmt.Println("Received value form steering:", <-connectMsg.resp)
	}
}

type Steering struct{
	timeToReconfig time.Duration
    inputChanel chan *trackAssign
    tracks map[string] chan string
}

func (s* Steering) assignTrainToTrack(steeringName string){
    for {
        fmt.Println(steeringName, " ",s.tracks)
        trainMsg := <-s.inputChanel
        fmt.Println("Received msg on steering", steeringName,"to steering", trainMsg.steering ," pushing to track", s.tracks[trainMsg.steering])
        s.tracks[trainMsg.steering] <- "ok"
		time.Sleep(2*time.Second)
        trainMsg.resp <- "ok"
    }
}

type Track struct{
    trackId int
    in chan string
}

func (tr* Track) track(){
	for{
		fmt.Println("Track is free, ok", <-tr.in)
		time.Sleep(2*time.Second)
	}
}

type trackAssign struct {
    steering string
    resp chan string
}

type steeringChanelId struct{
    nextSteeringId string
    currentSteeringCh chan *trackAssign
}

func main() {
    trackAChanel := make(chan string)
    trackA := Track{1, trackAChanel}
    steeringInputChannels := [2] chan *trackAssign{make(chan *trackAssign), make(chan *trackAssign)}
    steeringAtracks := map[string] chan string {"steeringB":trackAChanel}
    steeringBtracks := map[string] chan string {"steeringA":trackAChanel}

    steeringA := Steering{4*time.Second, steeringInputChannels[0], steeringAtracks}
    steeringB := Steering{4*time.Second, steeringInputChannels[1], steeringBtracks}

    trainATrack := ring.New(2)
    trainATrack.Value = steeringChanelId{"steeringB", steeringInputChannels[0]}
    trainATrack = trainATrack.Next()
    trainATrack.Value = steeringChanelId{"steeringA", steeringInputChannels[1]}
    trainATrack = trainATrack.Next()

    trainA:= Train{5, 5, trainATrack}

	go trainA.travelTrough(2000*time.Millisecond)
	go steeringA.assignTrainToTrack("steeringA")
	go steeringB.assignTrainToTrack("steeringB")
	go trackA.track()
	time.Sleep(20000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
