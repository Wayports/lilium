import Lilium from 0xf8d6e0586b0a20c7
import FungibleToken from 0xee82856bf20e2aa6

transaction {
    prepare(signer: AuthAccount) {

        // Return early if the account already stores a ExampleToken Vault
        if signer.borrow<&Lilium.Vault>(from: /storage/liliumVault) != nil {
            return
        }

        signer.save(
            <-Lilium.createEmptyVault(),
            to: /storage/liliumVault
        )

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&Lilium.Vault{FungibleToken.Receiver}>(
            /public/liliumReceiver,
            target: /storage/liliumVault
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&Lilium.Vault{FungibleToken.Balance}>(
            /public/liliumBalance,
            target: /storage/liliumVault
        )
    }
}
