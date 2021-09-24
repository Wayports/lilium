import WRLEvent from 0xf8d6e0586b0a20c7

transaction(eventPath: StoragePath) {
    prepare(signer: AuthAccount) {
        let eventRef = signer.borrow<&WRLEvent.Event>(from: eventPath)
            ?? panic("Could not borrow a reference to event")

        eventRef.end()
    }
}
