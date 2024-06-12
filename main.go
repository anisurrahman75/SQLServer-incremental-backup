package main

import (
	"fmt"
	"time"
)

func main() {
	// Parse the given time string
	givenTime := "2024-06-11T18:05:00+06:00"
	parsedTime, err := time.Parse(time.RFC3339, givenTime)
	if err != nil {
		fmt.Println("Error parsing time:", err)
		return
	}

	// Get the UTC time by using the In method with UTC as the argument
	utcTime := parsedTime.In(time.UTC)

	// Print the UTC time in RFC3339 format
	fmt.Println("UTC time:", utcTime.Format(time.RFC3339))
}
