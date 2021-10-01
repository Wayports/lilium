import path from "path";
import { createEventTransaction } from "../src/transaction-templates/event.template";
import { createEvent, getEvent, endEvent } from "../src/helpers/events";
import {
  init,
  emulator,
  shallPass,
  shallResolve,
  mintFlow,
  getAccountAddress,
  deployContractByName
} from "flow-js-testing";

jest.setTimeout(10000);

describe("WRL Events", () => {
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

  it("Should create a new event", async () => {
    await shallPass(createEvent());
  });

  it("Should change the event state to ended", async () => {
    await shallPass(createEvent());
    await shallPass(endEvent("/storage/wrl_s1_e1"));

    const event = await shallResolve(getEvent("/public/wrl_s1_e1"));

    expect(event.finished).toBeTruthy();
  });
});
