package main

import "fmt"


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
        trainA := Train{1,2,[]Track{{1,2}, {1,2}, {1,2}, {1,2}},1}
        steeringA := Steering{[]int{1,2,3}}
        trainA.drive()
        steeringA.assignTrack(trainA)

}
