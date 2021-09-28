import path from "path";
import {
  init,
  emulator,
  shallPass,
  sendTransaction,
  getAccountAddress
} from "js-testing-framework";

jest.setTimeout(10000);

describe("WRL Events", () => {
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../../");
    const port = 8080;
    await init(basePath, { port });
    return emulator.start(port);
  });

  afterEach(async () => {
    return emulator.stop();
  });

  test("Create event", async () => {
    const code = `
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
    `;

    const AdminAccount = await getAccountAddress("");
    const signers = [AdminAccount];
    const args = [];

    const txResult = await shallPass(
      sendTransaction({
        code,
        signers,
        args
      })
    );
  });
});
