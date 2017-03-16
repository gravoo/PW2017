package main

import (
        "testing"
        "fmt"
)

func TestTrain(t *testing.T) {
        s := Train{1,2,3}
        fmt.Println(" created train :) ", s.velocity)
        fmt.Println(" created train :) ", s)
}

