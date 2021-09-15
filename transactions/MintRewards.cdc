import Lilium from 0xLILIUM
import WRLEvent from 0xWRLEVENT
import FungibleToken from 0xFUNGIBLE

transaction(eventName: String, stands: [Address; 3]) {
    let tokenAdmin: &Lilium.Administrator
    let eventsRef: &WRLEvent.Events

    prepare(signer: AuthAccount) {
        self.tokenAdmin = signer
            .borrow<&Lilium.Administrator>(from: /storage/liliumAdmin)
            ?? panic("Signer is not the token admin")

        self.eventsRef = signer.borrow<&WRLEvent.Events>(from: /storage/events)
            ?? panic("Signer is not the events admin")
    }

    execute {
        let currentEvent = self.eventsRef.getEvent(name: eventName);
        let baseReward = currentEvent.baseReward;

        var position = 0;
        for recipient in stands {
            if currentEvent.isParticipant(account: recipient) {
                let liliumAmount = currentEvent.rewards[position] + baseReward
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
