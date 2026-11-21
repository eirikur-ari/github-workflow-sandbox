package main

import "fmt"

func main() {
	// stuff
	fmt.Println("5 + 3 =", add(5, 3))
}

func add(a, b int) int {
	return a + b
}
