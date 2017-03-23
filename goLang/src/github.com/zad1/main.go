package main

import "fmt"
import "time"
import "container/ring"

type Train struct{
    maxVelocity int
    maxCapacity int
    currentPosition chan int
    track *ring.Ring
}

func(t* Train)  travelTrough(d time.Duration){
	for {
        t.track = t.track.Next()
        fmt.Println("Train is going to track", t.track.Value)
		time.Sleep(d)
		t.currentPosition <-t.track.Value.(int)
		fmt.Println("Received value form steeringA", <-t.currentPosition)
	}
}
type Steering struct{
	timeToReconfig time.Duration
    trains chan int
}

func (s* Steering) assignTrainToTrack(steeringName string){
	for x:= range s.trains {
		switch x{
		case 1:
			fmt.Println("train", x, "is going to route", x, "in steering", steeringName)
				s.trains<-1
				time.Sleep(s.timeToReconfig)
		case 2:
			fmt.Println("train", x, "is going to route", x, "in steering", steeringName)
				s.trains<-2
				time.Sleep(s.timeToReconfig)
		}

	}
}
type Track struct{
    trackId int
    in chan int
}

func (tr* Track) track(){
	for{
		fmt.Println("Track is free, ok", <-tr.in)
		time.Sleep(5000*time.Millisecond)
	}
}

func main() {
	trainCh := make(chan int)
	trackCh := make(chan int)
    trainATrack := ring.New(2)
    trainATrack.Value = 1
    trainATrack = trainATrack.Next()
    trainATrack.Value = 2
    steeringA := Steering{4*time.Second, trainCh}
    trainA:= Train{5, 5, trainCh, trainATrack}
    trackA := Track{1, trackCh}

	go trainA.travelTrough(2000*time.Millisecond)
	go steeringA.assignTrainToTrack("steeringA")
	go trackA.track()
	time.Sleep(20000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
