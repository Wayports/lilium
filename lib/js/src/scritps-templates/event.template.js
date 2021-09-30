export const getEventScript = ({ publicPath, adminAddress }) => `
  import WRLEvent from "./contracts/WRLEvent.cdc"

  pub fun main(): WRLEvent.EventInfo {
      let eventRef = getAccount(${adminAddress})
          .getCapability(${publicPath})
          .borrow<&WRLEvent.Event{WRLEvent.GetEventInfo}>()
          ?? panic("Could not borrow Balance reference to the Vault")

      return eventRef.getEventInfo()
  }
`;
