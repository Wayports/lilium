import Lilium from 0xf8d6e0586b0a20c7
import WRLEvent from 0xf8d6e0586b0a20c7
import FungibleToken from 0xee82856bf20e2aa6

transaction(eventPath: StoragePath) {
    let tokenAdmin: &Lilium.Administrator
    let eventRef: &WRLEvent.Event
    let stands: [Address]
    let baseReward: UFix64

    prepare(signer: AuthAccount) {
        self.tokenAdmin = signer
            .borrow<&Lilium.Administrator>(from: /storage/liliumAdmin)
            ?? panic("Signer is not the token admin")

        self.eventRef = signer.borrow<&WRLEvent.Event>(from: eventPath)
            ?? panic("Signer is not the events admin")

        self.stands = self.eventRef.sortByTime()

        self.baseReward = self.eventRef.baseReward
    }

    execute {
        let baseReward = self.eventRef.baseReward;

        var position = 0;
        for recipient in self.stands {
            if self.eventRef.isParticipant(account: recipient) {
                let liliumAmount = self.eventRef.rewards[position] + baseReward
                let minter <- self.tokenAdmin.createNewMinter(allowedAmount: liliumAmount)

                let mintedVault <- minter.mintTokens(
                    amount: liliumAmount 
                );
                let receiver = getAccount(recipient)
                    .getCapability(/public/liliumReceiver)
                    .borrow<&{FungibleToken.Receiver}>()
                    ?? panic("Unable to borrow receiver reference")

                receiver.deposit(from: <- mintedVault);

                position = position + 1;

                destroy minter
            }
        }
    }
}
