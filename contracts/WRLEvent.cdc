import Lilium from 0xLILIUM

pub contract WRLEvent {
    pub struct Event {
      pub let name: String;
      pub let participants: [Address; 35];
      pub let rewards: [UFix64; 35];
      pub let baseReward: UFix64;
      pub let end: Bool;

      init(
          name: String,
          participants: [Address; 35],
          rewards: [UFix64; 35],
          baseReward: UFix64
      ) {
        self.name = name;
        self.participants = participants; 
        self.rewards = rewards
        self.baseReward = baseReward;
        self.end = false;
      }

      pub fun isParticipant(account: Address): Bool {
          for address in self.participants {
              if account == address {
                  return true;
              }
          }

          return false;
      }
    }

    pub resource Events {
        pub let events: {String: Event};

        init() {
            self.events = {};
        }

        pub fun addEvent(event: Event) {
            pre {
                self.events[event.name] == nil: "An event with the same name already exists"
            }

            self.events[event.name] = event;
        }

        pub fun getEvent(name: String): Event {
            return self.events[name] ?? panic("Event not found");
        }
    }

    init() {
        let adminAccount = self.account;
        let events <- create Events();

        adminAccount.save(<-events, to: /storage/events);
    }
}
