import WRLEvent from 0xf8d6e0586b0a20c7

transaction(
    eventName: String,
    participants: [Address; 3],
    rewards: [UFix64; 3],
    baseReward: UFix64,
    storageTarget: StoragePath,
    validatorPath: PrivatePath,
    resultsPath: PrivatePath,
    publicPath: PublicPath,
) {
    prepare(signer: AuthAccount) {
        let adminRef = signer.borrow<&WRLEvent.Administrator>(from: /storage/admin)
            ?? panic("Could not borrow a reference to admin")

        let newEvent <- adminRef.createEvent(
            eventName: eventName,
            participants: participants,
            rewards: rewards,
            baseReward: baseReward
        )

        signer.save(<- newEvent, to: storageTarget)

        signer.link<&WRLEvent.Event{WRLEvent.Validable}>(
            validatorPath,
            target: storageTarget,
        )

        signer.link<&WRLEvent.Event{WRLEvent.ResultSetter}>(
            resultsPath,
            target: storageTarget,
        )

        signer.link<&WRLEvent.Event{WRLEvent.GetEventInfo}>(
            publicPath,
            target: storageTarget,
        )
    }
}
