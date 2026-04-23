package db

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/lib/pq"

	"github.com/flowstream/backend/internal/models"
)

type PostgresDB struct {
	conn *sql.DB
}

func NewPostgresDB(databaseURL string) (*PostgresDB, error) {
	conn, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	conn.SetMaxOpenConns(25)
	conn.SetMaxIdleConns(5)
	conn.SetConnMaxLifetime(5 * time.Minute)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := conn.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return &PostgresDB{conn: conn}, nil
}

func (db *PostgresDB) Close() error {
	return db.conn.Close()
}

func (db *PostgresDB) Migrate(ctx context.Context) error {
	// In a real app, we would use a migration tool like golang-migrate
	// For this POC, we assume the schema is applied via schema.sql
	return nil
}
