 /*
 * Copyright (C) Wayports, Inc.
 *
 * SPDX-License-Identifier: (MIT)
 */

import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS
import PrivateReceiverForwarder from 0xPRIVATEFORWARDINGADDRESS

// This transaction creates a new private receiver in an account that 
// doesn't already have a private receiver or a public token receiver
// but does already have a Vault

transaction {

    prepare(acct: AuthAccount) {
        receiverCapability = signer.link<&Lilium.Vault{FungibleToken.Receiver}>(
            /private/liliumReceiver,
            target: /storage/liliumVault
        )

        let vault <- PrivateReceiverForwarder.createNewForwarder(recipient: receiverCapability)

        acct.save(<-vault, to: PrivateReceiverForwarder.PrivateReceiverStoragePath)

        signer.link<&{PrivateReceiverForwarder.Forwarder}>(
            PrivateReceiverForwarder.PrivateReceiverPublicPath,
            target: PrivateReceiverForwarder.PrivateReceiverStoragePath
        )
    }
}
