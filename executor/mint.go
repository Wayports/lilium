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
	flowClient, err := client.New("access.testnet.nodes.onflow.org:9000", grpc.WithInsecure())

	ctx := context.Background()

	var (
		creatorAddress    flow.Address
		creatorAccountKey *flow.AccountKey
		creatorSigner     crypto.Signer
	)

	sigAlgoName := "ECDSA_P256"

	creatorAddress = flow.HexToAddress("")
	creatorAccount, err := flowClient.GetAccountAtLatestBlock(context.Background(),
		creatorAddress)
	creatorAccountKey = creatorAccount.Keys[0]

	creatorSigAlgo := crypto.StringToSignatureAlgorithm(sigAlgoName)
	creatorPrivateKey, err := crypto.DecodePrivateKeyHex(creatorSigAlgo, "")
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
