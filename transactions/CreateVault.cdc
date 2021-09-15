import Lilium from 0xLILIUM
import FungibleToken from 0xFUNGIBLE

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
