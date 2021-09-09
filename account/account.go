package main

import (
	"context"
	"fmt"
	"github.com/onflow/cadence"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/client"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/templates"
	"google.golang.org/grpc"
	"io/ioutil"
)

func main() {
	// createWaycoinVault()
	mintToken()
	// createAccount()
}

func createWaycoinVault() {
	flowClient, err := client.New("localhost:3569", grpc.WithInsecure())
	ctx := context.Background()

	var (
		userAddress    flow.Address
		userAccountKey *flow.AccountKey
		userSigner     crypto.Signer
	)

	sigAlgoName := "ECDSA_P256"

	userAddress = flow.HexToAddress("01cf0e2f2f715450")

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

	createVaultTransaction, err := ioutil.ReadFile("../coin/cadance/contracts/CreateVault.cdc")

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

func mintToken() {
	// flowClient, err := client.New("localhost:3569", grpc.WithInsecure())
	flowClient, err := client.New("access.devnet.nodes.onflow.org:9000", grpc.WithInsecure())
	ctx := context.Background()

	var (
		creatorAddress    flow.Address
		creatorAccountKey *flow.AccountKey
		creatorSigner     crypto.Signer
	)

	sigAlgoName := "ECDSA_P256"

	creatorAddress = flow.HexToAddress("a9e5922489486101")
	creatorAccount, err := flowClient.GetAccountAtLatestBlock(context.Background(),
		creatorAddress)
	creatorAccountKey = creatorAccount.Keys[0]

	creatorSigAlgo := crypto.StringToSignatureAlgorithm(sigAlgoName)
	creatorPrivateKey, err := crypto.DecodePrivateKeyHex(creatorSigAlgo, "68ee617d9bf67a4677af80aaca5a090fcda80ff2f4dbc340e0e36201fa1f1d8c")
	creatorSigner = crypto.NewInMemorySigner(creatorPrivateKey, creatorAccountKey.HashAlgo)

	// creatorAccount := flowClient.GetAccount(ctx, creatorAddress)

	tx := flow.NewTransaction()

	mintTransaction, err := ioutil.ReadFile("../coin/cadance/contracts/MintToken.cdc")

	if err != nil {
		panic(err)
	}

	referenceBlock, _ := flowClient.GetLatestBlock(ctx, true)

	tx.SetScript(mintTransaction).
		SetGasLimit(100).
		SetProposalKey(
			creatorAddress,
			creatorAccountKey.Index,
			creatorAccountKey.SequenceNumber,
		).
		SetReferenceBlockID(referenceBlock.ID).
		SetPayer(creatorAddress).
		AddAuthorizer(creatorAddress)

	err3 :=
		tx.AddArgument(cadence.Address(flow.HexToAddress("225fa82e8a76c178")))

	if err3 != nil {
		panic(err3)
	}

	err1 := tx.SignEnvelope(creatorAddress, creatorAccountKey.Index, creatorSigner)

	if err1 != nil {
		panic("Something went wrong while signing the transaction")
	}

	err2 := flowClient.SendTransaction(ctx, *tx)

	if err2 != nil {
		panic(err2)
	}
}

func createAccount() {
	var (
		creatorAddress flow.Address
		// creatorPrivKey    flow.Address
		creatorAccountKey *flow.AccountKey
		creatorSigner     crypto.Signer
	)
	sigAlgoName := "ECDSA_P256"
	// hashAlgoName := "SHA3_256"

	flowClient, err := client.New("localhost:3569", grpc.WithInsecure())

	if err != nil {
		fmt.Printf("Failed to establish connection with Access API %v", err)
	}

	// creatorPrivKey := flow.HexToAddress("899a2c70cd1928399aec1d1ad130687a110edfd6066471df1c066561e2c6b535")
	creatorAddress = flow.HexToAddress("f8d6e0586b0a20c7")

	creatorAccount, err := flowClient.GetAccountAtLatestBlock(context.Background(), creatorAddress)

	if err != nil {
		panic("Something went wrong while retrieving the latest block")
	}

	creatorAccountKey = creatorAccount.Keys[0]

	seed := []byte("dolphin ears space cowboy octopus rodeo potato cannon pineapple")

	privateKey, err := crypto.GeneratePrivateKey(crypto.ECDSA_P256, seed)

	publicKey := privateKey.PublicKey()

	fmt.Printf("PUBLIC KEY: %v", publicKey)
	fmt.Printf("\nPRIVATE KEY: %v", privateKey)

	accountKey := flow.NewAccountKey().
		SetPublicKey(publicKey).
		SetHashAlgo(crypto.SHA3_256).
		SetWeight(flow.AccountKeyWeightThreshold)

	fmt.Printf("\nAccount key: %v", accountKey)

	tx := templates.CreateAccount([]*flow.AccountKey{accountKey}, nil, creatorAddress)

	creatorSigAlgo := crypto.StringToSignatureAlgorithm(sigAlgoName)
	creatorPrivateKey, err := crypto.DecodePrivateKeyHex(creatorSigAlgo, "5da7f1564956e928a40b4fbc1739e67b0d5d4e2dad0ab43eaa0198369b6ed0a1")
	creatorSigner = crypto.NewInMemorySigner(creatorPrivateKey, creatorAccountKey.HashAlgo)

	tx.SetPayer(creatorAddress)
	tx.SetProposalKey(
		creatorAddress,
		creatorAccountKey.Index,
		creatorAccountKey.SequenceNumber,
	)

	latestBlock, err := flowClient.GetLatestBlockHeader(context.Background(), true)

	if err != nil {
		panic("Failed to fetch the latest block")
	}

	tx.SetReferenceBlockID(latestBlock.ID)

	err = tx.SignEnvelope(creatorAddress, creatorAccountKey.Index, creatorSigner)

	if err != nil {
		panic("Failed to sign the transaction")
	}

	err = flowClient.SendTransaction(context.Background(), *tx)

	if err != nil {
		panic("Failed to send the transaction")
	}
}
