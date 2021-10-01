import WRLEvent from "../contracts/WRLEvent.cdc"

pub fun main(address: Address): Bool {
    // let capabilityReceiver = getAccount(address).getCapability
    //     <&WRLEvent.Steward{WRLEvent.ValidatorReceiver}>
    //     (/public/steward)
    //     .borrow() ?? panic("Could not borrow steward cap")

  return getAccount(address).getCapability
    <&WRLEvent.Steward{WRLEvent.ValidatorReceiver}>
    (/public/steward)
    .check()
}
