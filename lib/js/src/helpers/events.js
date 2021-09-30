import {
  executeScript,
  sendTransaction,
  getAccountAddress
} from "flow-js-testing";
import {
  createEventTransaction,
  endEventTransaction
} from "../transaction-templates/event.template";
import { getEventScript } from "../scritps-templates/event.template";

export const createEvent = async () => {
  const admin = await getAccountAddress("Admin");
  const participant1 = await getAccountAddress("Participant1");
  const participant2 = await getAccountAddress("Participant2");
  const participant3 = await getAccountAddress("Participant3");

  const code = createEventTransaction({
    adminAddress: admin,
    storageTarget: "/storage/wrl_s1_e1",
    validatorPath: "/private/validator_s1_e1",
    resultsPath: "/private/results_s1_e1",
    publicPath: "/public/wrl_s1_e1",
    participants: `[${participant1}, ${participant2}, ${participant3}]`,
    rewards: "[3.0, 2.0, 1.0]"
  });

  const args = ["wrl_s1_e1", "1.0"];

  const signers = [admin];

  return sendTransaction({ code, signers, args });
};

export const createValidatorCapReceiver = async () => {
  const validator1 = await getAccountAddress("Validator1");

  return sendTransaction("create_validator_cap_rec", [validator1]);
};

export const depositValidatorCap = async () => {};

export const createResultsCapReceiver = async () => {};

export const depositResultsCap = async () => {};

export const endEvent = async storagePath => {
  const adminAddress = await getAccountAddress("Admin");
  const code = endEventTransaction({ storagePath });
  const signers = [adminAddress];

  return sendTransaction({ code, signers });
};

export const getEvent = async publicPath => {
  const adminAddress = await getAccountAddress("Admin");

  const code = getEventScript({ publicPath, adminAddress });

  return executeScript({ code });
};
