package main

import "fmt"
import "time"
import "github.com/twmb/algoimpl/go/graph" 

type Train struct {
        velocity int
        capacity int
        route []Track
        currentTrack int
}
func (train *Train) drive() {
	fmt.Println("I am going throu tarck", train.currentTrack, "with speed", train.route[train.currentTrack].maxVelocity)
}

type StationaryTrack struct {
        restTime int
}

type Track struct {
        maxVelocity int
        length int
}

type Steering struct {
        tracks []int

}

func (steering *Steering) assignTrack(train Train) {
	fmt.Println("Assigned", train.currentTrack + 1, "To train")
}

func main() {
	trainGraph := graph.New(graph.Undirected)
	nodes := make(map[string]graph.Node, 0)
	nodes["steeringA"] = trainGraph.MakeNode()
	nodes["steeringB"] = trainGraph.MakeNode()
	nodes["steeringC"] = trainGraph.MakeNode()
	nodes["steeringD"] = trainGraph.MakeNode()
	trainGraph.MakeEdge(nodes["steeringA"], nodes["stationC"])
	trainGraph.MakeEdge(nodes["steeringB"], nodes["stationC"])
	trainGraph.MakeEdge(nodes["steeringC"], nodes["stationD"])
        trainA := Train{1,2,[]Track{{1,2}, {1,2}, {1,2}, {1,2}},1}
        steeringA := Steering{[]int{1,2,3}}
        go trainA.drive()
        steeringA.assignTrack(trainA)
	time.Sleep(10000)

}
