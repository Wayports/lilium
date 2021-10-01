import path from "path";
import {
  validateEvent,
  depositValidatorCap,
  penalizeParticipant,
  isValidatorAccountSetup,
  createValidatorCapReceiver
} from "../src/helpers/steward";
import { createEvent, endEvent, getEvent } from "../src/helpers/events";
import { updateFinalStands } from "../src/helpers/oracle.js";
import {
  init,
  emulator,
  mintFlow,
  shallPass,
  shallRevert,
  shallResolve,
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
    await endEvent("/storage/wrl_s1_e1");
    await updateFinalStands();

    await shallPass(validateEvent(validator));
  });

  it("Should add a time penalty to a participant", async () => {
    // Setup
    const penalty = 1000;
    const participantFinalTime = 100000;
    const validator = await getAccountAddress("Validator1");
    const participant1 = await getAccountAddress("Participant1");
    await createEvent();
    await createValidatorCapReceiver(validator);
    await depositValidatorCap(validator);
    await endEvent("/storage/wrl_s1_e1");
    await updateFinalStands();

    // adds time penalty to participant final time
    await shallPass(
      penalizeParticipant({
        participantAddress: participant1,
        penalty,
        validator
      })
    );

    const event = await getEvent("/public/wrl_s1_e1");
    const participantPenalty = event.penalties[participant1];
    const timeAfterPenalty = event.finalStands[participant1];

    // should register the penalty in a dictionary
    expect(participantPenalty).toBe(penalty);
    // should add the penalty to participant final stands dictionary
    expect(timeAfterPenalty).toBe(penalty + participantFinalTime);
  });
});
