import Lilium from 0xf8d6e0586b0a20c7
import FungibleToken from 0xee82856bf20e2aa6

transaction {
    prepare(signer: AuthAccount) {
        if signer.borrow<&Lilium.Vault>(from: /storage/liliumVault) != nil {
            return
        }

        signer.save(
            <-Lilium.createEmptyVault(),
            to: /storage/liliumVault
        )

        signer.link<&Lilium.Vault{FungibleToken.Receiver}>(
            /public/liliumReceiver,
            target: /storage/liliumVault
        )

        signer.link<&Lilium.Vault{FungibleToken.Balance}>(
            /public/liliumBalance,
            target: /storage/liliumVault
        )
    }
}
