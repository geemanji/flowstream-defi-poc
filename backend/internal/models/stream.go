package models

import "time"

type Stream struct {
	ID            int64     `json:"id"` 
	StreamID      int64     `json:"stream_id"` 
	Sender        string    `json:"sender"` 
	Recipient     string    `json:"recipient"` 
	Token         string    `json:"token"` 
	Deposit       string    `json:"deposit"` 
	RatePerSecond string    `json:"rate_per_second"` 
	StartTime     int64     `json:"start_time"` 
	StopTime      int64     `json:"stop_time"` 
	Withdrawn     string    `json:"withdrawn"` 
	Active        bool      `json:"active"` 
	TxHash        string    `json:"tx_hash"` 
	BlockNumber   int64     `json:"block_number"` 
	CreatedAt     time.Time `json:"created_at"` 
	UpdatedAt     time.Time `json:"updated_at"` 
}
