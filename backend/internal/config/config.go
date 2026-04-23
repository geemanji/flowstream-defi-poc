package config

import (
	"os"
)

type Config struct {
	Port        string
	DatabaseURL string
	RPCURL      string
	ContractAddr string
	StartBlock  uint64
}

func Load() *Config {
	return &Config{
		Port:         getEnv("PORT", "8080"),
		DatabaseURL:  getEnv("DATABASE_URL", "postgres://flowstream:flowstream@localhost:5432/flowstream?sslmode=disable"),
		RPCURL:       getEnv("RPC_URL", "http://localhost:8545"),
		ContractAddr: getEnv("CONTRACT_ADDRESS", "0x0000000000000000000000000000000000000000"),
		StartBlock:   0,
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
