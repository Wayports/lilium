 /*
 * Copyright (C) Wayports, Inc.
 *
 * SPDX-License-Identifier: (MIT)
 */

// This transaction is a template for a transaction that
// could be used by the admin account to burn tokens
// from their stored Vault
//
// The burning amount would be a parameter to the transaction

import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS

transaction(amount: UFix64) {

    // Vault resource that holds the tokens that are being burned
    let vault: @FungibleToken.Vault

    let admin: &Lilium.Administrator

    prepare(signer: AuthAccount) {

        // Withdraw 10 tokens from the admin vault in storage
        self.vault <- signer.borrow<&Lilium.Vault>(from: /storage/liliumVault)!
            .withdraw(amount: amount)

        // Create a reference to the admin admin resource in storage
        self.admin = signer.borrow<&Lilium.Administrator>(from: /storage/liliumAdmin)
            ?? panic("Could not borrow a reference to the admin resource")
    }

    execute {
        let burner <- self.admin.createNewBurner()

        burner.burnTokens(from: <-self.vault)

        destroy burner
    }
}
