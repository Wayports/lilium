 /*
 * Copyright (C) Wayports, Inc.
 *
 * SPDX-License-Identifier: (MIT)
 */

// This script reads the balance field of an account's FlowToken Balance
import FungibleToken from 0xFUNGIBLETOKENADDRESS
import Lilium from 0xTOKENADDRESS

pub fun main(account: Address): UFix64 {
    let acct = getAccount(account)
    let vaultRef = acct.getCapability(/public/liliumBalance)
        .borrow<&Lilium.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
