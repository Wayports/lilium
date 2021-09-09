package main

import (
	"context"
	"fmt"
	"io/ioutil"

	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/client"
	"github.com/onflow/flow-go-sdk/crypto"
	"google.golang.org/grpc"
)

func mintToken(recipientAddress string, transactionPath string) {
	// flowClient, err := client.New("localhost:3569", grpc.WithInsecure())
	flowClient, err := client.New("access.testnet.nodes.onflow.org:9000", grpc.WithInsecure())

	ctx := context.Background()

	var (
		creatorAddress    flow.Address
		creatorAccountKey *flow.AccountKey
		creatorSigner     crypto.Signer
	)

	sigAlgoName := "ECDSA_P256"

	creatorAddress = flow.HexToAddress("5e29a986bb1ed7ce") // Use f8d6e0586b0a20c7 for emulator and 5e29a986bb1ed7ce for testnet
	creatorAccount, err := flowClient.GetAccountAtLatestBlock(context.Background(),
		creatorAddress)
	creatorAccountKey = creatorAccount.Keys[0]

	// fmt.Printf("Creator Address: %v\n", creatorAccount);

	creatorSigAlgo := crypto.StringToSignatureAlgorithm(sigAlgoName)
	// creatorPrivateKey, err := crypto.DecodePrivateKeyHex(creatorSigAlgo, "0cb293c5b160cb30a7b0a4c62876a13942f2b6defbfc29e32602599c7a5318e4")
	creatorPrivateKey, err := crypto.DecodePrivateKeyHex(creatorSigAlgo, "bcb708b7a56e5dbb592341ed412245f8bf849361633cb67eecb6bca936253435")
	creatorSigner = crypto.NewInMemorySigner(creatorPrivateKey, creatorAccountKey.HashAlgo)

	tx := flow.NewTransaction()

	mintTransaction, err := ioutil.ReadFile(transactionPath)

	if err != nil {
		panic(err)
	}

	referenceBlock, _ := flowClient.GetLatestBlock(ctx, true)

	tx.SetScript(mintTransaction).
		SetGasLimit(1000).
		SetProposalKey(
			creatorAddress,
			creatorAccountKey.Index,
			creatorAccountKey.SequenceNumber,
		).
		SetReferenceBlockID(referenceBlock.ID).
		SetPayer(creatorAddress).
		AddAuthorizer(creatorAddress)

	err3 :=
		tx.AddArgument(cadence.Address(flow.HexToAddress(recipientAddress)))

	err4 :=
		tx.AddArgument(cadence.UFix64(30000000000))

	if err3 != nil {
		panic(err3)
	}

	if err4 != nil {
		panic(err4)
	}

	err1 := tx.SignEnvelope(creatorAddress, creatorAccountKey.Index, creatorSigner)

	if err1 != nil {
		panic("Something went wrong while signing the transaction")
	}

	err2 := flowClient.SendTransaction(ctx, *tx)

	if err2 != nil {
		panic(err2)
	}

	result, err := flowClient.GetTransactionResult(ctx, tx.ID())

	if err != nil {
		panic(err)
	}

	fmt.Printf("Transaction result: %v\n %v\n", tx.ID(), result.Status)
}
