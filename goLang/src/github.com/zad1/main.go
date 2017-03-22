package main

import "fmt"
import "time"

func train(trainCh, steeringCh chan int, d time.Duration, val int){
	for {
		time.Sleep(d)
		trainCh <- val
		fmt.Println(<-steeringCh)
	}
}
type Steering struct{
	timeToReconfig time.Duration
}

func (s* Steering) assignTrainToTrack(trainCh, steeringCh, trackCh chan int, steeringName string){
	for x:= range trainCh {
		switch x{
		case 1:
			fmt.Println("train", x, "is going to route", x, "in steering", steeringName)
				steeringCh<-10
				trackCh<-10
				time.Sleep(s.timeToReconfig)
		case 2:
			fmt.Println("train", x, "is going to route", x, "in steering", steeringName)
				steeringCh<-20
				trackCh<-20
				time.Sleep(s.timeToReconfig)
		}

	}
}

func track(trackCh chan int){
	for{
		fmt.Println("Track is free, ok", <-trackCh)
		time.Sleep(5000*time.Millisecond)
	}
}

func main() {
	trainCh := make(chan int)
	steeringCh := make(chan int)
	trackCh := make(chan int)
    steering := Steering{4*time.Second}
	go train(trainCh, steeringCh, 2000*time.Millisecond, 1)
	go train(trainCh, steeringCh, 4000*time.Millisecond, 2)
	go steering.assignTrainToTrack(trainCh, steeringCh, trackCh, "steeringA")
	go track(trackCh)
	time.Sleep(20000*time.Millisecond)

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
