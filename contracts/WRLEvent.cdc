import Lilium from 0xLILIUM

pub contract WRLEvent {
    pub resource interface Validable {
        pub fun validate()

        pub fun addPenalty(participant: Address, time: UInt64)
    }

    pub resource interface ResultSetter {
        pub fun setResults(stands: {Address:UInt64});
    }

    pub resource Event: Validable, ResultSetter {
      pub let name: String
      pub let baseReward: UFix64
      pub let rewards: [UFix64; 3]
      pub let participants: [Address; 3]

      pub var finished: Bool
      pub var validations: Int
      pub var  resultsUpdated: Bool
      pub var finalStands: {Address:UInt64}
      pub var penalties: {Address:UInt64}

      init(
          name: String,
          participants: [Address; 3],
          rewards: [UFix64; 3],
          baseReward: UFix64,
      ) {
        self.name = name
        self.participants = participants
        self.rewards = rewards
        self.baseReward = baseReward
        self.finished = false
        self.resultsUpdated = false
        self.validations = 0
        self.finalStands = {};
        self.penalties = {};
      }

      pub fun isParticipant(account: Address): Bool {
          for address in self.participants {
              if account == address {
                  return true;
              }
          }

          return false;
      }

      pub fun setResults(stands: {Address:UInt64}) {
          pre {
            self.finished: "Race is not finished"
            !self.resultsUpdated: "Results were alredy updated"
          }

          self.finalStands = stands;
          self.resultsUpdated = true;
      }

      pub fun addPenalty(participant: Address, time: UInt64) {
          pre {
            self.finalStands.containsKey(participant): "The address was not registered in the event" // The address must be among the address of the final stands
            !self.penalties.containsKey(participant): "The participant already received a penalty in this event" // Only one penalty per event
          }

          let participantTime = self.finalStands[participant]!

          self.finalStands[participant] = participantTime + time
          self.penalties.insert(key: participant, time)
      }

      pub fun validate() {
          pre {
            self.resultsUpdated: "Results were not updated"
          }

          self.validations = self.validations + 1
      }

      pub fun end() {
          pre {
              !self.finished: "Race is already finished"
          }

          self.finished = true
      }

      pub fun sortByTime(): [Address] {
          pre {
            self.resultsUpdated: "Results were not updated"
          }

          let rewardOrder: [Address] = []

          var i = 0
          for participant in self.finalStands.keys {
            let currentParticipantTime = self.finalStands[participant]!

            var j = 0
            while(j < rewardOrder.length) {
                let participantTime = self.finalStands[rewardOrder[j]]!
                log(participantTime)

                if currentParticipantTime < participantTime {
                    break
                }

                j = j + 1
            }

            rewardOrder.insert(at: j, participant)
          }

          return rewardOrder;
      }
    }

    pub fun createSteward(): @Steward {
        return <- create Steward()
    }

    pub fun createBot(): @Bot {
        return <- create Bot()
    }

    pub resource interface ValidatorReceiver {
        pub fun receiveValidator(cap: Capability<&WRLEvent.Event{WRLEvent.Validable}>)
    }

    pub resource Steward: ValidatorReceiver {
        pub var validateEventCapability: Capability<&WRLEvent.Event{WRLEvent.Validable}>?

        init() {
            self.validateEventCapability = nil;
        }

        pub fun receiveValidator(cap: Capability<&WRLEvent.Event{WRLEvent.Validable}>) {
            pre {
                cap.borrow() != nil: "Invalid Validator capability";
            }

            self.validateEventCapability = cap;
        }

        pub fun validateEvent() {
            pre {
                self.validateEventCapability != nil: "No validator capability"
            }

            let validatorRef = self.validateEventCapability!.borrow()!

            validatorRef.validate();
        }

        pub fun addPenalty(participant: Address, time: UInt64) {
            pre {
                self.validateEventCapability != nil: "No validator capability"
            }

            let validatorRef = self.validateEventCapability!.borrow()!

            validatorRef.addPenalty(participant: participant, time: time);
        }
    }

    pub resource interface ResultSetterReceiver {
        pub fun receiveResultSetter(cap: Capability<&WRLEvent.Event{WRLEvent.ResultSetter}>)
    }

    pub resource Bot: ResultSetterReceiver {
        pub var resultSetter: Capability<&WRLEvent.Event{WRLEvent.ResultSetter}>?

        init() {
            self.resultSetter = nil
        }

        pub fun receiveResultSetter(cap: Capability<&WRLEvent.Event{WRLEvent.ResultSetter}>) {
            pre {
                cap.borrow() != nil: "Invalid Validator capability";
            }

            self.resultSetter = cap;
        }


        pub fun setResults(results: {Address: UInt64}) {
            pre {
                self.resultSetter != nil: "No capability"
            }

            let resultSetterRef = self.resultSetter!.borrow()!

            resultSetterRef.setResults(stands: results);
        }
    }

    pub resource Administrator {
        pub fun createEvent(
            eventName: String,
            participants: [Address; 3],
            rewards: [UFix64; 3],
            baseReward: UFix64
        ): @Event {
            return <- create Event(
                name: eventName,
                participants: participants,
                rewards: rewards,
                baseReward: baseReward
            )
        }
    }

    init() {
        let adminAccount = self.account;

        let admin <- create Administrator();

        adminAccount.save(<-admin, to: /storage/admin);
    }
}
