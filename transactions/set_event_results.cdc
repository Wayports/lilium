import WRLEvent from 0xf8d6e0586b0a20c7

transaction(results: {Address:UInt64}) {
    prepare(signer: AuthAccount) {
        let botRef = signer.borrow<&WRLEvent.Oracle>(from: /storage/resultSetter)
            ?? panic("Could not borrow a reference to bot")

        botRef.setResults(results: results)
    }
}
