package main

import (
	"context"
	"fmt"
	"io/ioutil"

	"github.com/onflow/flow-go-sdk/client"
	"google.golang.org/grpc"
)

func getAccountBalance() {
	ctx := context.Background()
	flowClient, err := client.New("localhost:3569", grpc.WithInsecure())
	balanceScript, err := ioutil.ReadFile("../scripts/Balance.cdc")

	value, err := flowClient.ExecuteScriptAtLatestBlock(ctx, balanceScript, nil)

	if err != nil {
		panic(err)
	}

	fmt.Printf("Balance: %v\n", value)
}
