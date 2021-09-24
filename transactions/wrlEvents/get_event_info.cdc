import WRLEvent from 0xf8d6e0586b0a20c7

pub fun main(eventPath: PublicPath): WRLEvent.EventInfo {
    let eventRef = getAccount(0xf8d6e0586b0a20c7)
        .getCapability(eventPath)
        .borrow<&WRLEvent.Event{WRLEvent.GetEventInfo}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return eventRef.getEventInfo()
}
