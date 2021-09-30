export const depositValidatorCapTransaction = validatorPath => `
import WRLEvent from "./contracts/WRLEvent.cdc"

transaction(stewardAddress: Address) {
    prepare(signer: AuthAccount) {
        let validatorPath = ${validatorPath}

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
`;
