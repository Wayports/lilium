package main

import (
	"context"
	"fmt"
	"io/ioutil"

	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/client"
	"github.com/onflow/flow-go-sdk/crypto"
	"google.golang.org/grpc"
)

func createLiliumVault(accountAddress string) {
	flowClient, err := client.New("localhost:3569", grpc.WithInsecure())
	ctx := context.Background()

	var (
		userAddress    flow.Address
		userAccountKey *flow.AccountKey
		userSigner     crypto.Signer
	)

	sigAlgoName := "ECDSA_P256"

	userAddress = flow.HexToAddress(accountAddress)

	fmt.Printf("User Address: %v\n", userAddress)

	creatorAccount, err := flowClient.GetAccountAtLatestBlock(context.Background(),
		userAddress)

	if err != nil {
		panic(err)
	}

	userAccountKey = creatorAccount.Keys[0]

	creatorSigAlgo := crypto.StringToSignatureAlgorithm(sigAlgoName)
	creatorPrivateKey, err := crypto.DecodePrivateKeyHex(creatorSigAlgo, "ab977a921d98d8dde09bc5bc968645a84d743ee74cd99b246551237dcb83c840")
	userSigner = crypto.NewInMemorySigner(creatorPrivateKey, userAccountKey.HashAlgo)

	tx := flow.NewTransaction()

	createVaultTransaction, err := ioutil.ReadFile("../transactions/CreateVault.cdc")

	if err != nil {
		panic(err)
	}

	referenceBlock, _ := flowClient.GetLatestBlock(ctx, true)

	tx.SetScript(createVaultTransaction).
		SetGasLimit(100).
		SetProposalKey(
			userAddress,
			userAccountKey.Index,
			userAccountKey.SequenceNumber,
		).
		SetReferenceBlockID(referenceBlock.ID).
		SetPayer(userAddress).
		AddAuthorizer(userAddress)

	err1 := tx.SignEnvelope(userAddress, userAccountKey.Index, userSigner)

	if err1 != nil {
		panic("Something went wrong while signing the transaction")
	}

	err2 := flowClient.SendTransaction(ctx, *tx)

	if err2 != nil {
		panic(err2)
	}
}