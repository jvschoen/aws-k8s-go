package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type TelemetryData struct {
	DeviceId string `json:"device_id"`
	Timestamp string `json:"timestamp"`
	Metric string `json:"metric"`
	Value String `json:"value"`
}

func handleTelemetry(w http.ResponseWriter, r *http.Request) {
	var data TelemetryData
	err := json.NewDecoder(r.Body).Decode(&data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// TODO: implement routing data to delta
	fm.Fprint(w, "Received telemetry data: %+v", data)

}

func main() {
	http.HandleFunc("/telemetry", handleTelemetry)
	log.Fatal(http.ListenAndServe(":8080", nil))
}