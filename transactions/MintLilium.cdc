// import Lilium from 0xf8d6e0586b0a20c7
// import FungibleToken from 0xee82856bf20e2aa6

import Lilium from 0x5e29a986bb1ed7ce
import FungibleToken from 0x9a0766d93b6608b7

transaction(recipient: Address, amount: UFix64) {
    let tokenAdmin: &Lilium.Administrator
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(signer: AuthAccount) {
        self.tokenAdmin = signer.borrow<&Lilium.Administrator>(from: /storage/liliumAdmin)
            ?? panic("Signer is not the token admin")

        self.tokenReceiver = getAccount(recipient)
            .getCapability(/public/liliumReceiver)
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Unable to borrow receiver reference")
    }

    execute {
        let minter <- self.tokenAdmin.createNewMinter(allowedAmount: amount)
        let mintedVault <- minter.mintTokens(amount: amount)

        self.tokenReceiver.deposit(from: <-mintedVault)

        destroy minter
    }
}
