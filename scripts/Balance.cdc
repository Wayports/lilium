import FungibleToken from 0xFUNGIBLE
import Lilium from 0xLILIUM

pub fun main(): UFix64 {
    let acct = getAccount()

    let vaultRef = acct.getCapability(/public/liliumBalance)
        .borrow<&Lilium.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
