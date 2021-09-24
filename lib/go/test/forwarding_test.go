package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/onflow/cadence"
	jsoncdc "github.com/onflow/cadence/encoding/json"
	"github.com/onflow/flow-go-sdk"
	"github.com/onflow/flow-go-sdk/crypto"
	"github.com/onflow/flow-go-sdk/test"

	"github.com/onflow/flow-ft/lib/go/contracts"
	"github.com/onflow/flow-ft/lib/go/templates"
)

func TestPrivateForwarder(t *testing.T) {
	b := newBlockchain()

	accountKeys := test.AccountKeyGenerator()

	liliumAccountKey, liliumSigner := accountKeys.NewWithSigner()
	fungibleAddr, liliumAddr, _ :=
		DeployTokenContracts(b, t, []*flow.AccountKey{liliumAccountKey})

	forwardingCode := contracts.PrivateReceiverForwarder(fungibleAddr.String())
	cadenceCode := bytesToCadenceArray(forwardingCode)

	name, _ := cadence.NewString("PrivateReceiverForwarder")

	tx := flow.NewTransaction().
		SetScript(templates.GenerateDeployPrivateForwardingScript()).
		SetGasLimit(100).
		SetProposalKey(b.ServiceKey().Address, b.ServiceKey().Index, b.ServiceKey().SequenceNumber).
		SetPayer(b.ServiceKey().Address).
		AddAuthorizer(liliumAddr).
		AddRawArgument(jsoncdc.MustEncode(name)).
		AddRawArgument(jsoncdc.MustEncode(cadenceCode))

	_ = tx.AddArgument(cadence.Path{Domain: "storage", Identifier: "privateForwardingSender"})
	_ = tx.AddArgument(cadence.Path{Domain: "storage", Identifier: "privateForwardingStorage"})
	_ = tx.AddArgument(cadence.Path{Domain: "public", Identifier: "privateForwardingPublic"})

	signAndSubmit(
		t, b, tx,
		[]flow.Address{b.ServiceKey().Address, liliumAddr},
		[]crypto.Signer{b.ServiceKey().Signer(), liliumSigner},
		false,
	)

	joshAccountKey, joshSigner := accountKeys.NewWithSigner()
	joshAddress, _ := b.CreateAccount([]*flow.AccountKey{joshAccountKey}, nil)

	t.Run("Should be able to set up an account to accept private deposits", func(t *testing.T) {

		script := templates.GenerateSetupAccountPrivateForwarderScript(
			fungibleAddr,
			liliumAddr,
			liliumAddr,
			"Lilium",
		)

		tx := flow.NewTransaction().
			SetScript(script).
			SetGasLimit(100).
			SetProposalKey(
				b.ServiceKey().Address,
				b.ServiceKey().Index,
				b.ServiceKey().SequenceNumber,
			).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(joshAddress)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				joshAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				joshSigner,
			},
			false,
		)
	})

	t.Run("Should be able to transfer private tokens to an account", func(t *testing.T) {

		recipient1Address := cadence.Address(joshAddress)
		recipient1Amount := CadenceUFix64("300.0")

		pair := cadence.KeyValuePair{Key: recipient1Address, Value: recipient1Amount}
		recipientPairs := make([]cadence.KeyValuePair, 1)
		recipientPairs[0] = pair

		script := templates.GenerateTransferPrivateManyAccountsScript(fungibleAddr, liliumAddr, liliumAddr, "Lilium")
		tx = flow.NewTransaction().
			SetScript(script).
			SetGasLimit(100).
			SetProposalKey(
				b.ServiceKey().Address,
				b.ServiceKey().Index,
				b.ServiceKey().SequenceNumber,
			).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(liliumAddr)

		_ = tx.AddArgument(cadence.NewDictionary(recipientPairs))

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				liliumAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				liliumSigner,
			},
			false,
		)

		// Assert that the vaults' balances are correct
		script = templates.GenerateInspectVaultScript(fungibleAddr, liliumAddr, "Lilium")
		result, err := b.ExecuteScript(
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.Address(liliumAddr)),
			},
		)
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
		balance := result.Value
		assertEqual(t, CadenceUFix64("700.0"), balance)

		script = templates.GenerateInspectVaultScript(fungibleAddr, liliumAddr, "Lilium")
		result, err = b.ExecuteScript(
			script,
			[][]byte{
				jsoncdc.MustEncode(cadence.Address(joshAddress)),
			},
		)
		require.NoError(t, err)
		if !assert.True(t, result.Succeeded()) {
			t.Log(result.Error.Error())
		}
		balance = result.Value
		assertEqual(t, CadenceUFix64("300.0"), balance)

		script = templates.GenerateInspectSupplyScript(fungibleAddr, liliumAddr, "Lilium")
		supply := executeScriptAndCheck(t, b, script, nil)
		assertEqual(t, CadenceUFix64("1000.0"), supply)
	})

	t.Run("Should be able to create a new account with private forwarder", func(t *testing.T) {

		script := templates.GenerateCreateAccountPrivateForwarderScript(
			fungibleAddr,
			liliumAddr,
			liliumAddr,
			"Lilium",
		)
		tx = flow.NewTransaction().
			SetScript(script).
			SetGasLimit(100).
			SetProposalKey(
				b.ServiceKey().Address,
				b.ServiceKey().Index,
				b.ServiceKey().SequenceNumber,
			).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(liliumAddr)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				liliumAddr,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				liliumSigner,
			},
			false,
		)

	})

	t.Run("Should be able to do account setup a second time without change", func(t *testing.T) {

		script := templates.GenerateSetupAccountPrivateForwarderScript(
			fungibleAddr,
			liliumAddr,
			liliumAddr,
			"Lilium",
		)

		// send the same transaction one more time for the same address that's already set up
		tx := flow.NewTransaction().
			SetScript(script).
			SetGasLimit(100).
			SetProposalKey(
				b.ServiceKey().Address,
				b.ServiceKey().Index,
				b.ServiceKey().SequenceNumber,
			).
			SetPayer(b.ServiceKey().Address).
			AddAuthorizer(joshAddress)

		signAndSubmit(
			t, b, tx,
			[]flow.Address{
				b.ServiceKey().Address,
				joshAddress,
			},
			[]crypto.Signer{
				b.ServiceKey().Signer(),
				joshSigner,
			},
			false,
		)
	})
}
