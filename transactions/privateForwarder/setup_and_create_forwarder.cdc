
import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS
import PrivateReceiverForwarder from 0xPRIVATEFORWARDINGADDRESS

// This transaction adds a Vault, a private receiver forwarder
// a balance capability, and a public capability for the receiver

transaction {

    prepare(signer: AuthAccount) {
        if signer.getCapability<&PrivateReceiverForwarder.Forwarder>(PrivateReceiverForwarder.PrivateReceiverPublicPath).check() {
            // private forwarder was already set up
            return
        }

        if signer.borrow<&Lilium.Vault>(from: /storage/liliumVault) == nil {
            // Create a new Lilium Vault and put it in storage
            signer.save(
                <-Lilium.createEmptyVault(),
                to: /storage/liliumVault
            )
        }

        signer.link<&{FungibleToken.Receiver}>(
            /private/liliumReceiver,
            target: /storage/liliumVault
        )

        let receiverCapability = signer.getCapability<&{FungibleToken.Receiver}>(/private/liliumReceiver)

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&Lilium.Vault{FungibleToken.Balance}>(
            /public/liliumBalance,
            target: /storage/liliumVault
        )

        let forwarder <- PrivateReceiverForwarder.createNewForwarder(recipient: receiverCapability)

        signer.save(<-forwarder, to: PrivateReceiverForwarder.PrivateReceiverStoragePath)

        signer.link<&PrivateReceiverForwarder.Forwarder>(
            PrivateReceiverForwarder.PrivateReceiverPublicPath,
            target: PrivateReceiverForwarder.PrivateReceiverStoragePath
        )
    }
}
