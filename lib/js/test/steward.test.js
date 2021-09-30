import path from "path";
import {
  createValidatorCapReceiver,
  validateEvent,
  isValidatorAccountSetup,
  depositValidatorCap
} from "../src/helpers/steward";
import { createEvent } from "../src/helpers/events";
import {
  createResultSetterCapReceiver,
  depositResultSetterCap
} from "../src/helpers/oracle.js";
import {
  init,
  emulator,
  shallPass,
  shallRevert,
  shallResolve,
  mintFlow,
  executeScript,
  getAccountAddress,
  deployContractByName
} from "flow-js-testing";

describe("Stewards", () => {
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

  it("Should set up the validator account to receive validator capability", async () => {
    const validator = await getAccountAddress("Validator1");

    await shallPass(createValidatorCapReceiver(validator));

    const isAccountSetup = await shallResolve(
      isValidatorAccountSetup(validator)
    );

    expect(isAccountSetup).toBeTruthy();
  });

  it("Should't allow event validation before results are updated", async () => {
    // Setup
    const validator = await getAccountAddress("Validator1");
    await createEvent();
    await createValidatorCapReceiver(validator);
    await depositValidatorCap(validator);

    // should not allow the validator to validate the events before the results
    await shallRevert(validateEvent(validator));
  });

  it("Should allow event validation after results are updated", async () => {
    // Setup
    const validator = await getAccountAddress("Validator1");
    await createEvent();
    await createValidatorCapReceiver(validator);
    await depositValidatorCap(validator);
  });

  it("Should add a time penalty to a participant", async () => {});
});
