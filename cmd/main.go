package main

import (
	"fmt"
)

var (
	version   string
	buildDate string
)

func main() {
	fmt.Printf("Version: %s\nBuild Date: %s\n", version, buildDate)
	fmt.Println("Hello, Go Environment!")
}
