//Bartlomiej Sadowski 204392
package main

import (
	"fmt"
	"github.com/zad2/utils"
	"time"
)

type TrainThread struct {
	maxVelocity int
	maxCapacity int
	trainName   string
	trackEdges  []*steeringTuple
}

type AssignTrackToTrain struct {
	edge  *steeringTuple
	track chan interface{}
}
type ReconfigureSteering struct {
	Resp chan bool
}

func (train *TrainThread) buildTrainToSteeringMsg(indexOfEdge int) *AssignTrackToTrain {
	return &AssignTrackToTrain{
		edge:  train.trackEdges[indexOfEdge],
		track: make(chan interface{})}
}

func (train *TrainThread) startTrainThread() {
	for {
		for i, _ := range train.trackEdges {
			trainSteeringPipe := train.buildTrainToSteeringMsg(i)
			train.trackEdges[i].from.steeringInputChanel <- trainSteeringPipe
			trackToTravel := <-trainSteeringPipe.track
			fmt.Println("TrainThread received track to travel")
			steeringReconfig := &ReconfigureSteering{Resp: make(chan bool)}
			train.trackEdges[i].from.steeringReconfChanel <- steeringReconfig
			fmt.Println("TrainThread steering reconfiguration result", <-steeringReconfig.Resp)
			trackPipe := &utils.TrainToTrackMsg{Resp: make(chan interface{})}
			switch trackData := trackToTravel.(type) {
			case *DriveTrackThread:
				trackData.trackInputChanel <- trackPipe
				trackType := <-trackPipe.Resp
				fmt.Println("TrainThread receivec msg from DriveTrack, time to travel")
				time.Sleep(time.Duration(trackData.length/trackData.maxAllowedVelocity) * time.Second)
				trackType.(*utils.DriveTrackToTrainMsg).Resp <- "Release track"
			case *StopTrackThread:
				trackData.trackInputChanel <- trackPipe
				trackType := <-trackPipe.Resp
				fmt.Println("TrainThread receivec msg from StopTrack, time to wait")
				time.Sleep(trackData.timeToRest)
				trackType.(*utils.StopTrackToTrainMsg).Resp <- "Release track"
			}
		}
	}
}

type SteeringThread struct {
	timeToReconfig       time.Duration
	steeringInputChanel  chan *AssignTrackToTrain
	steeringName         string
	steeringEdges        map[*steeringTuple]interface{}
	steeringReconfChanel chan *ReconfigureSteering
}

func (s *SteeringThread) startSteeringThread() {
	for {
		select {
		case requestFromTrain := <-s.steeringInputChanel:
			fmt.Println("SteeringThread", s.steeringName, " received request for track")
			requestFromTrain.track <- s.steeringEdges[requestFromTrain.edge]
		case reconfigSteering := <-s.steeringReconfChanel:
			fmt.Println("SteeringThread", s.steeringName, " during reconfiguration")
			time.Sleep(s.timeToReconfig)
			reconfigSteering.Resp <- true
		}
	}
}

type DriveTrackThread struct {
	trackId            int
	trackInputChanel   chan interface{}
	length             int
	maxAllowedVelocity int
}

func (tr *DriveTrackThread) buildTrainMsg() *utils.DriveTrackToTrainMsg {
	return &utils.DriveTrackToTrainMsg{
		TrackId:            tr.trackId,
		Resp:               make(chan string),
		MaxAllowedVelocity: tr.maxAllowedVelocity,
		TrackLength:        tr.length}
}

func (tr *DriveTrackThread) startTrackThread() {
	for {
		trainPipe := <-tr.trackInputChanel
		fmt.Println("DriveTrackThread", tr.trackId, ":received msg from train")
		trackPipe := tr.buildTrainMsg()
		trainPipe.(*utils.TrainToTrackMsg).Resp <- trackPipe
		fmt.Println("DriveTrackThread", tr.trackId, ": received msg from train on finish", <-trackPipe.Resp)
		close(trackPipe.Resp)
	}
}

type StopTrackThread struct {
	trackId          int
	trackInputChanel chan interface{}
	timeToRest       time.Duration
}

func (tr *StopTrackThread) buildTrainMsg() *utils.StopTrackToTrainMsg {
	return &utils.StopTrackToTrainMsg{
		TrackId:    tr.trackId,
		Resp:       make(chan string),
		TimeToRest: tr.timeToRest}
}

func (tr *StopTrackThread) startTrackThread() {
	for {
		trainPipe := <-tr.trackInputChanel
		fmt.Println("StopTrackThread", tr.trackId, ":received msg from train")
		trackPipe := tr.buildTrainMsg()
		trainPipe.(*utils.TrainToTrackMsg).Resp <- trackPipe
		fmt.Println("StopTrackThread", tr.trackId, ": received msg from train on finish", <-trackPipe.Resp)
		close(trackPipe.Resp)
	}
}

type steeringTuple struct {
	from, to *SteeringThread
}

func main() {
	var nodes []*SteeringThread
	var edges = make([]*steeringTuple, 6)
	var trains []*TrainThread

	nodes = append(nodes, &SteeringThread{5 * time.Second, make(chan *AssignTrackToTrain), "steering1",
		make(map[*steeringTuple]interface{}), make(chan *ReconfigureSteering)})
	nodes = append(nodes, &SteeringThread{5 * time.Second, make(chan *AssignTrackToTrain), "steering2",
		make(map[*steeringTuple]interface{}), make(chan *ReconfigureSteering)})
	nodes = append(nodes, &SteeringThread{5 * time.Second, make(chan *AssignTrackToTrain), "steering3",
		make(map[*steeringTuple]interface{}), make(chan *ReconfigureSteering)})

	edges[0] = &steeringTuple{nodes[0], nodes[0]}
	edges[1] = &steeringTuple{nodes[0], nodes[1]}
	edges[2] = &steeringTuple{nodes[1], nodes[0]}
	edges[3] = &steeringTuple{nodes[1], nodes[2]}
	edges[4] = &steeringTuple{nodes[2], nodes[1]}
	edges[5] = &steeringTuple{nodes[2], nodes[2]}

	nodes[0].steeringEdges[edges[0]] = &StopTrackThread{10, make(chan interface{}), 15 * time.Second}
	nodes[0].steeringEdges[edges[1]] = &DriveTrackThread{101, make(chan interface{}), 900, 90}
	nodes[1].steeringEdges[edges[2]] = nodes[0].steeringEdges[edges[1]]
	nodes[1].steeringEdges[edges[3]] = &DriveTrackThread{102, make(chan interface{}), 900, 90}
	nodes[2].steeringEdges[edges[4]] = nodes[1].steeringEdges[edges[3]]
	nodes[2].steeringEdges[edges[5]] = &StopTrackThread{11, make(chan interface{}), 15 * time.Second}

	go nodes[0].steeringEdges[edges[0]].(*StopTrackThread).startTrackThread()
	go nodes[0].steeringEdges[edges[1]].(*DriveTrackThread).startTrackThread()
	go nodes[1].steeringEdges[edges[3]].(*DriveTrackThread).startTrackThread()
	go nodes[2].steeringEdges[edges[5]].(*StopTrackThread).startTrackThread()

	trains = append(trains, &TrainThread{1, 2, "train1", nil})
	trains[0].trackEdges = append(trains[0].trackEdges, edges[1])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[3])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[5])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[2])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[0])

	go nodes[0].startSteeringThread()
	go nodes[1].startSteeringThread()
	go nodes[2].startSteeringThread()

	go trains[0].startTrainThread()

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
