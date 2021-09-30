export const createEventTransaction = ({
  storageTarget,
  validatorPath,
  resultsPath,
  publicPath,
  participants,
  rewards
}) => `
  import WRLEvent from "./contracts/WRLEvent.cdc"

  transaction(eventName: String, baseReward: UFix64) {
      let adminRef: &WRLEvent.Administrator
      let signer: AuthAccount

      prepare(signer: AuthAccount) {
          self.signer = signer

          self.adminRef = signer.borrow<&WRLEvent.Administrator>(from: /storage/admin)
              ?? panic("Could not borrow a reference to admin")

      }

      execute {
          let participants: [Address; 3] = ${participants}

          let newEvent <- self.adminRef.createEvent(
              eventName: eventName,
              participants: participants,
              rewards: ${rewards},
              baseReward: baseReward
          )

          self.signer.save(<- newEvent, to: ${storageTarget})

          self.signer.link<&WRLEvent.Event{WRLEvent.Validable}>(
              ${validatorPath},
              target: ${storageTarget},
          )

          self.signer.link<&WRLEvent.Event{WRLEvent.ResultSetter}>(
              ${resultsPath},
              target: ${storageTarget},
          )

          self.signer.link<&WRLEvent.Event{WRLEvent.GetEventInfo}>(
              ${publicPath},
              target: ${storageTarget},
          )

      }
  }
`;

export const endEventTransaction = ({ storagePath }) => `
  import WRLEvent from "./contracts/WRLEvent.cdc"

  transaction() {
      prepare(signer: AuthAccount) {
          let eventRef = signer.borrow<&WRLEvent.Event>(from: ${storagePath})
              ?? panic("Could not borrow a reference to event")

          eventRef.end()
      }
  }
`;
