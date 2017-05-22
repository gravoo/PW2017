//Bartlomiej Sadowski 204392
package main

import (
	"fmt"
	"github.com/zad2/utils"
	"math/rand"
	"time"
)

type RepairBrigadeThread struct {
	repairBrigadeInput chan interface{}
	timeOfRepair       time.Duration
	tracks             []*steeringTuple
	steerings          []*SteeringThread
	startPosition      *steeringTuple
	trackEdges         []*steeringTuple
}

func (train *RepairBrigadeThread) buildTrainToSteeringMsg(indexOfEdge int) *AssignTrackToTrain {
	return &AssignTrackToTrain{
		edge:  train.trackEdges[indexOfEdge],
		track: make(chan interface{})}
}

func (train *RepairBrigadeThread) startRepairTrain(positionToFix *steeringTuple) {
	for {
		for i, _ := range train.trackEdges {
			trainSteeringPipe := train.buildTrainToSteeringMsg(i)
			train.trackEdges[i].from.steeringInputChanel <- trainSteeringPipe
			trackToTravel := <-trainSteeringPipe.track
			fmt.Println("RepairBrigade received track to travel")
			if positionToFix == train.trackEdges[i] {
				fmt.Println("Reached target to fix")
			}
			steeringReconfig := &ReconfigureSteering{Resp: make(chan bool)}
			train.trackEdges[i].from.steeringReconfChanel <- steeringReconfig
			fmt.Println("TrainThread steering reconfiguration result", <-steeringReconfig.Resp)
			trackPipe := &utils.TrainToTrackMsg{Resp: make(chan interface{})}
			switch trackData := trackToTravel.(type) {
			case *DriveTrackThread:
				trackData.trackInputChanel <- trackPipe
				trackType := <-trackPipe.Resp
				fmt.Println("RepairBrigade receivec msg from DriveTrack, time to travel")
				time.Sleep(time.Duration(trackData.length/trackData.maxAllowedVelocity) * time.Second)
				trackType.(*utils.DriveTrackToTrainMsg).Resp <- "Release track"
			case *StopTrackThread:
				trackData.trackInputChanel <- trackPipe
				trackType := <-trackPipe.Resp
				fmt.Println("RepairBrigade receivec msg from StopTrack, time to wait")
				time.Sleep(trackData.timeToRest)
				trackType.(*utils.StopTrackToTrainMsg).Resp <- "Release track"
			}
		}
	}
}

func fillWithWalues(nodes []*SteeringThread) map[*SteeringThread]int {
	nodeToDistance := make(map[*SteeringThread]int)
	for _, value := range nodes {
		nodeToDistance[value] = 1<<31 - 1
	}
	return nodeToDistance
}

func findPath(nodes map[*SteeringThread]*SteeringThread, target *SteeringThread) []*steeringTuple {
	var finalPath []*steeringTuple
	for father, son := range nodes {
		finalPath = append(finalPath, &steeringTuple{son, father, 0})
		if father.steeringName == target.steeringName {
			break
		}
	}
	return finalPath
}
func findMin(nodes map[*SteeringThread]int) *SteeringThread {
	min := 1<<31 - 1
	var minElement *SteeringThread
	for id, value := range nodes {
		if value <= min {
			min = value
			minElement = id
		}
	}
	return minElement
}

func (rb *RepairBrigadeThread) findShortestPath(source, target *SteeringThread) []*steeringTuple {
	nodeToDistance := fillWithWalues(rb.steerings)
	nodeToDistance[source] = 0
	result := make(map[*SteeringThread]*SteeringThread)
	pre := make(map[*SteeringThread]*SteeringThread)
	for i := 0; i < len(rb.steerings); i++ {
		minElem := findMin(nodeToDistance)
		for _, value := range minElem.neighborEdges {
			if nodeToDistance[value.to] > nodeToDistance[minElem]+value.weight {
				nodeToDistance[value.to] = nodeToDistance[minElem] + value.weight
				pre[value.to] = minElem
			}
			result[minElem] = minElem
			delete(nodeToDistance, minElem)
		}
	}
	finalResult := findPath(pre, target)
	for _, val := range finalResult {
		fmt.Println("Edge to get broken train:", val.from.steeringName,
			val.to.steeringName)
	}
	return finalResult
}

func (rb *RepairBrigadeThread) startRepairBrigadeThread() {
	repairOrder := <-rb.repairBrigadeInput
	switch repair := repairOrder.(type) {
	case *TrainBrokenOrder:
		fmt.Println(repair.currentEdge.from.steeringName)
		fmt.Println(repair.currentEdge.to.steeringName)
		rb.trackEdges = rb.findShortestPath(rb.startPosition.from, repair.currentEdge.from)
		go rb.startRepairTrain(repair.currentEdge)
	}
}

type TrainThread struct {
	maxVelocity int
	maxCapacity int
	trainName   string
	trackEdges  []*steeringTuple
	repairOrder chan interface{}
}

type AssignTrackToTrain struct {
	edge  *steeringTuple
	track chan interface{}
}
type ReconfigureSteering struct {
	Resp chan bool
}

type TrainBrokenOrder struct {
	currentEdge *steeringTuple
	Resp        chan interface{}
}

func (train *TrainThread) buildTrainToSteeringMsg(indexOfEdge int) *AssignTrackToTrain {
	return &AssignTrackToTrain{
		edge:  train.trackEdges[indexOfEdge],
		track: make(chan interface{})}
}

func (train *TrainThread) generateFault(indexOfEdge int) {
	randNum := rand.Float64()
	if randNum > 0.5 {
		fmt.Println("TrainThread", train.trainName, "is broken, send msg for help")
		RepairBrigadePipe := &TrainBrokenOrder{
			currentEdge: train.trackEdges[indexOfEdge],
			Resp:        make(chan interface{})}
		train.repairOrder <- RepairBrigadePipe
		fmt.Println(<-RepairBrigadePipe.Resp)
	}
	fmt.Println(randNum)
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
			train.generateFault(i)
		}
	}
}

type SteeringThread struct {
	timeToReconfig       time.Duration
	steeringInputChanel  chan *AssignTrackToTrain
	steeringName         string
	steeringEdges        map[*steeringTuple]interface{}
	steeringReconfChanel chan *ReconfigureSteering
	neighborEdges        []*steeringTuple
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
	weight   int
}

func main() {
	var nodes []*SteeringThread
	var edges = make([]*steeringTuple, 7)
	var trains []*TrainThread

	nodes = append(nodes, &SteeringThread{5 * time.Second, make(chan *AssignTrackToTrain), "steering1",
		make(map[*steeringTuple]interface{}), make(chan *ReconfigureSteering), nil})
	nodes = append(nodes, &SteeringThread{5 * time.Second, make(chan *AssignTrackToTrain), "steering2",
		make(map[*steeringTuple]interface{}), make(chan *ReconfigureSteering), nil})
	nodes = append(nodes, &SteeringThread{5 * time.Second, make(chan *AssignTrackToTrain), "steering3",
		make(map[*steeringTuple]interface{}), make(chan *ReconfigureSteering), nil})

	edges[0] = &steeringTuple{nodes[0], nodes[0], 10}
	edges[1] = &steeringTuple{nodes[0], nodes[1], 10}
	edges[6] = &steeringTuple{nodes[0], nodes[0], 10}
	nodes[0].neighborEdges = append(nodes[0].neighborEdges, edges[0])
	nodes[0].neighborEdges = append(nodes[0].neighborEdges, edges[1])
	nodes[0].steeringEdges[edges[0]] = &StopTrackThread{10, make(chan interface{}), 15 * time.Second}
	nodes[0].steeringEdges[edges[1]] = &DriveTrackThread{101, make(chan interface{}), 900, 90}
	nodes[0].steeringEdges[edges[6]] = &StopTrackThread{12, make(chan interface{}), 15 * time.Second}
	go nodes[0].steeringEdges[edges[0]].(*StopTrackThread).startTrackThread()
	go nodes[0].steeringEdges[edges[1]].(*DriveTrackThread).startTrackThread()
	go nodes[0].steeringEdges[edges[6]].(*StopTrackThread).startTrackThread()

	edges[2] = &steeringTuple{nodes[1], nodes[0], 10}
	edges[3] = &steeringTuple{nodes[1], nodes[2], 10}
	nodes[1].neighborEdges = append(nodes[1].neighborEdges, edges[2])
	nodes[1].neighborEdges = append(nodes[1].neighborEdges, edges[3])
	nodes[1].steeringEdges[edges[2]] = &DriveTrackThread{102, make(chan interface{}), 900, 90}
	nodes[1].steeringEdges[edges[3]] = &DriveTrackThread{103, make(chan interface{}), 900, 90}
	go nodes[1].steeringEdges[edges[2]].(*DriveTrackThread).startTrackThread()
	go nodes[1].steeringEdges[edges[3]].(*DriveTrackThread).startTrackThread()

	edges[4] = &steeringTuple{nodes[2], nodes[1], 10}
	edges[5] = &steeringTuple{nodes[2], nodes[2], 10}
	nodes[2].neighborEdges = append(nodes[2].neighborEdges, edges[4])
	nodes[2].neighborEdges = append(nodes[2].neighborEdges, edges[5])
	nodes[2].steeringEdges[edges[4]] = &DriveTrackThread{104, make(chan interface{}), 900, 90}
	nodes[2].steeringEdges[edges[5]] = &StopTrackThread{11, make(chan interface{}), 15 * time.Second}
	go nodes[2].steeringEdges[edges[4]].(*DriveTrackThread).startTrackThread()
	go nodes[2].steeringEdges[edges[5]].(*StopTrackThread).startTrackThread()

	repairChanel := make(chan interface{})
	repairBrigade := &RepairBrigadeThread{repairChanel, 40 * time.Second, edges, nodes, edges[0], nil}

	trains = append(trains, &TrainThread{1, 2, "train1", nil, repairChanel})
	trains[0].trackEdges = append(trains[0].trackEdges, edges[1])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[3])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[5])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[2])
	trains[0].trackEdges = append(trains[0].trackEdges, edges[0])

	go nodes[0].startSteeringThread()
	go nodes[1].startSteeringThread()
	go nodes[2].startSteeringThread()

	go trains[0].startTrainThread()
	go repairBrigade.startRepairBrigadeThread()

	var input string
	fmt.Scanln(&input)
	fmt.Println("done")

}
