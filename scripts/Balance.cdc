import FungibleToken from 0xFUNGIBLE
import Lilium from 0xLILIUM

pub fun main(account: Address): UFix64 {
    let vaultRef = getAccount(account)
        .getCapability(/public/liliumBalance)
        .borrow<&Lilium.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}

