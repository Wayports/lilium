import WRLEvent from 0xf8d6e0586b0a20c7

transaction(botAddress: Address, resultsPath: PrivatePath) {
    prepare(signer: AuthAccount) {
        let resultSetterCapability = signer.getCapability
            <&WRLEvent.Event{WRLEvent.ResultSetter}>
            (resultsPath)

        let botAccount = getAccount(botAddress)

        let capabilityReceiver = botAccount.getCapability
            <&WRLEvent.Bot{WRLEvent.ResultSetterReceiver}>
            (/public/resultSetter)
            .borrow() ?? panic("Could not borrow steward cap")

        capabilityReceiver.receiveResultSetter(cap: resultSetterCapability)
    }
}
