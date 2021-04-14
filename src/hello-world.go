package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func helloWorld(w http.ResponseWriter, r *http.Request) {
	pod := os.Getenv("POD_NAME")
	fmt.Fprintf(w, "Hi, I hope you're well! This is pod %s", pod)
}

func main() {
	http.HandleFunc("/", helloWorld)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
