import WRLEvent from 0xf8d6e0586b0a20c7

transaction() {
    prepare(signer: AuthAccount) {
        let stewardRef = signer.borrow<&WRLEvent.Steward>(from: /storage/steward)
            ?? panic("Could not borrow a reference to the Steward")

        stewardRef.validateEvent()
    }
}
