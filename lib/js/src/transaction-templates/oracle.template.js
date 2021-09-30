export const depositResultSetterTransaction = resultsPath => `
  import WRLEvent from "./contracts/WRLEvent.cdc"

  transaction(oracleAddress: Address) {
      prepare(signer: AuthAccount) {
          let resultsPath = ${resultsPath}

          let resultSetterCapability = signer.getCapability
              <&WRLEvent.Event{WRLEvent.ResultSetter}>
              (resultsPath)

          let oracleAccount = getAccount(oracleAddress)

          let capabilityReceiver = oracleAccount.getCapability
              <&WRLEvent.Oracle{WRLEvent.ResultSetterReceiver}>
              (/public/resultSetter)
              .borrow() ?? panic("Could not borrow steward cap")

          capabilityReceiver.receiveResultSetter(cap: resultSetterCapability)
      }
  }
`;
