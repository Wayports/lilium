import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS

transaction(addressAmountMap: {Address: UFix64}) {

    // The Vault resource that holds the tokens that are being transferred
    let vaultRef: &Lilium.Vault

    prepare(signer: AuthAccount) {

        // Get a reference to the signer's stored vault
        self.vaultRef = signer.borrow<&Lilium.Vault>(from: /storage/liliumVault)
			?? panic("Could not borrow reference to the owner's Vault!")
    }

    execute {

        for address in addressAmountMap.keys {

            // Withdraw tokens from the signer's stored vault
            let sentVault <- self.vaultRef.withdraw(amount: addressAmountMap[address]!)

            // Get the recipient's public account object
            let recipient = getAccount(address)

            // Get a reference to the recipient's Receiver
            let receiverRef = recipient.getCapability(/public/liliumReceiver)
                .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the recipient's Vault")

            // Deposit the withdrawn tokens in the recipient's receiver
            receiverRef.deposit(from: <-sentVault)

        }
    }
}
