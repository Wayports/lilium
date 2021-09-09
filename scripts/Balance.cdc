import FungibleToken from 0xee82856bf20e2aa6
import Lilium from 0xf8d6e0586b0a20c7

pub fun main(): UFix64 {
    let acct = getAccount(0xf3fcd2c1a78f5eee)
    let vaultRef = acct.getCapability(/public/liliumBalance)
        .borrow<&Lilium.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    log("User Balance")
    log(vaultRef.balance)

    return vaultRef.balance
}
