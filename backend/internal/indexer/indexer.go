package indexer

import (
	"context"
	"log"
	"time"

	"github.com/flowstream/backend/internal/db"
)

type Indexer struct {
	db           *db.PostgresDB
	rpcURL       string
	contractAddr string
}

func New(db *db.PostgresDB, rpcURL, contractAddr string) *Indexer {
	return &Indexer{
		db:           db,
		rpcURL:       rpcURL,
		contractAddr: contractAddr,
	}
}

func (i *Indexer) Start(ctx context.Context) error {
	log.Printf("starting indexer for contract %s", i.contractAddr)

	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			if err := i.poll(ctx); err != nil {
				log.Printf("poll error: %v", err)
			}
		}
	}
}

func (i *Indexer) poll(ctx context.Context) error {
	// Implementation for eth_getLogs and DB updates
	return nil
}
