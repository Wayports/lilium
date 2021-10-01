import WRLEvent from "../contracts/WRLEvent.cdc"

pub fun main(address: Address): Bool {
  return getAccount(address).getCapability
    <&WRLEvent.Oracle{WRLEvent.ResultSetterReceiver}>
    (/public/resultSetter)
    .check()
}
