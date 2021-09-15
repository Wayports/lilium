import WRLEvent from 0xWRLEVENT

transaction(
    eventName: String,
    participants: [Address; 3],
    rewards: [UFix64; 3],
    baseReward: UFix64
) {
    let eventsRef: &WRLEvent.Events;
    let newEvent: WRLEvent.Event; 
    
    prepare(signer: AuthAccount) {
        self.eventsRef = signer.borrow<&WRLEvent.Events>(from: /storage/events)
            ?? panic("Could not borrow a reference to the event")

        self.newEvent = WRLEvent.Event(eventName, participants, rewards, baseReward) 
    }

    execute {
        self.eventsRef.addEvent(event: self.newEvent)
    }
}
