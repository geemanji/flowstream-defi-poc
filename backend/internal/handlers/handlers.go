package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/flowstream/backend/internal/db"
	"github.com/flowstream/backend/internal/indexer"
)

type Handlers struct {
	db  *db.PostgresDB
	idx *indexer.Indexer
}

func New(db *db.PostgresDB, idx *indexer.Indexer) *Handlers {
	return &Handlers{db: db, idx: idx}
}

func (h *Handlers) RegisterRoutes(mux *http.ServeMux) {
	mux.HandleFunc("GET /api/health", h.Health)
	mux.HandleFunc("GET /api/streams", h.ListStreams)
	mux.HandleFunc("GET /api/stats", h.GetStats)
}

func (h *Handlers) Health(w http.ResponseWriter, r *http.Request) {
	json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func (h *Handlers) ListStreams(w http.ResponseWriter, r *http.Request) {
	// Implementation for listing streams from DB
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode([]interface{}{})
}

func (h *Handlers) GetStats(w http.ResponseWriter, r *http.Request) {
	// Implementation for aggregate stats
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"total_streams": 0,
		"active_streams": 0,
	})
}
