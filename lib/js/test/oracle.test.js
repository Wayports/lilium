import path from "path";
import {
  setResults,
  depositResultSetterCap,
  isResultSetterAccountSetup,
  createResultSetterCapReceiver
} from "../src/helpers/oracle";
import { createEvent, endEvent } from "../src/helpers/events";
import {
  init,
  mintFlow,
  emulator,
  shallPass,
  shallRevert,
  shallResolve,
  executeScript,
  getAccountAddress,
  deployContractByName
} from "flow-js-testing";

describe("Oracle", () => {
  beforeEach(async () => {
    const port = 8080;
    const basePath = path.resolve(__dirname, "../../../");
    await init(basePath, { port });

    await emulator.start(port);

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

  it("Should set up oracle account to receive result setter capability", async () => {
    const oracle = await getAccountAddress("Oracle1");

    await shallPass(createResultSetterCapReceiver(oracle));

    const isAccountSetup = await isResultSetterAccountSetup(oracle);

    expect(isAccountSetup).toBeTruthy();
  });

  it("Shouldn't allow update the results if event is not finished", async () => {});

  it("Should update the event results", async () => {
    // Setup
    const admin = await getAccountAddress("Admin");
    const oracle = await getAccountAddress("Oracle");
    const participant1 = await getAccountAddress("Participant1");
    const participant3 = await getAccountAddress("Participant2");
    const participant2 = await getAccountAddress("Participant3");
    const results = {
      [participant1]: 100000,
      [participant2]: 200000,
      [participant3]: 300000
    };
    await createEvent();
    await endEvent("/storage/wrl_s1_e1");
    await createResultSetterCapReceiver(oracle);
    await depositResultSetterCap(oracle);

    await shallPass(setResults({ oracleAddress: oracle, results }));
  });
});
