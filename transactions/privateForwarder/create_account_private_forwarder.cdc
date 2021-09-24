 /*
 * Copyright (C) Wayports, Inc.
 *
 * SPDX-License-Identifier: (MIT)
 */

import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS
import PrivateReceiverForwarder from 0xPRIVATEFORWARDINGADDRESS

// This transaction is used to create a user's Flow account with a private forwarder

transaction {
    prepare(payer: AuthAccount) {
        let acct = AuthAccount(payer: payer)

        acct.save(<-Lilium.createEmptyVault(),
            to: /storage/liliumVault
        )

        // Create a private receiver
        let receiverCapability = acct.link<&{FungibleToken.Receiver}>(
            /private/liliumReceiver,
            target: /storage/liliumVault
        )!

        // Use the private receiver to create a private forwarder
        let forwarder <- PrivateReceiverForwarder.createNewForwarder(recipient: receiverCapability)

        acct.save(<-forwarder, to: PrivateReceiverForwarder.PrivateReceiverStoragePath)

        acct.link<&PrivateReceiverForwarder.Forwarder>(
            PrivateReceiverForwarder.PrivateReceiverPublicPath,
            target: PrivateReceiverForwarder.PrivateReceiverStoragePath
        )
    }
}
