import WRLEvent from 0xf8d6e0586b0a20c7

transaction(stewardAddress: Address, validatorPath: PrivatePath) {
    prepare(signer: AuthAccount) {
        let validatorCapability = signer.getCapability
            <&WRLEvent.Event{WRLEvent.Validable}>
            (validatorPath)

        let stewardAccount = getAccount(stewardAddress)

        let capabilityReceiver = stewardAccount.getCapability
            <&WRLEvent.Steward{WRLEvent.ValidatorReceiver}>
            (/public/steward)
            .borrow() ?? panic("Could not borrow steward cap")

        capabilityReceiver.receiveValidator(cap: validatorCapability)
    }
}
