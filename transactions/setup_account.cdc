 /*
 * Copyright (C) Wayports, Inc.
 *
 * SPDX-License-Identifier: (MIT)
 */

// This transaction is a template for a transaction
// to add a Vault resource to their account
// so that they can use the lilium

import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS

transaction {

    prepare(signer: AuthAccount) {

        // Return early if the account already stores a Lilium Vault
        if signer.borrow<&Lilium.Vault>(from: /storage/liliumVault) != nil {
            return
        }

        // Create a new Lilium Vault and put it in storage
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
