import path from "path";
import {
  init,
  emulator,
  shallPass,
  mintFlow,
  shallThrow,
  deployContract,
  sendTransaction,
  getAccountAddress,
  deployContractByName
} from "flow-js-testing";

jest.setTimeout(10000);

describe("WRL Events", () => {
  beforeEach(async () => {
    const port = 8080;
    const basePath = path.resolve(__dirname, "../../../");
    await init(basePath, { port });

    await emulator.start(port, true);

    const admin = await getAccountAddress("Admin");

    await mintFlow(admin, "1000.0");

    await deployContractByName({
      name: "WRLEvent",
      to: admin,
      args: []
    });

    return;
  });

  afterEach(async () => {
    return emulator.stop();
  });

  test()

  test("Create a new event", async () => {
    const admin = await getAccountAddress("Admin");
    const participant1 = await getAccountAddress("Participant1");
    const participant2 = await getAccountAddress("Participant2");
    const participant3 = await getAccountAddress("Participant3");

    const args = [
      "wrl_s1_e1",
      [participant1, participant2, participant3],
      ["3.0", "2.0", "1.0"],
      "1.0",
      "/storage/wrl_s1_e1",
      "/private/validator_s1_e1",
      "/private/results_s1_e1",
      "/public/wrl_s1_e1"
    ];

    await shallPass(sendTransaction("create_event", [admin], args));
  });
});
