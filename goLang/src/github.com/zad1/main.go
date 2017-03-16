package main

import "fmt"

type Train struct {
        velocity int
        capacity int
        route int
}

type StationaryTrack struct {
        restTime int
}

type Track struct {
        maxVelocity int
        length int
}

func main() {
        s := Train{1,2,3}
	fmt.Println("Thats the new project bb", s.velocity)
}
