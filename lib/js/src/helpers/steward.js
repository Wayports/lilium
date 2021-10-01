import {
  sendTransaction,
  executeScript,
  getAccountAddress
} from "flow-js-testing";
import { depositValidatorCapTransaction } from "../transaction-templates/steward.template";

export const createValidatorCapReceiver = async validatorAddress => {
  return sendTransaction("create_validator_cap_rec", [validatorAddress]);
};

export const depositValidatorCap = async validatorAddress => {
  const admin = await getAccountAddress("Admin");
  const signers = [admin];
  const args = [validatorAddress];
  const code = depositValidatorCapTransaction("/private/validator_s1_e1");

  return sendTransaction({ code, signers, args });
};

export const validateEvent = validatorAddress => {
  return sendTransaction("validate_event", [validatorAddress]);
};

export const isValidatorAccountSetup = validatorAddress => {
  return executeScript("check_validator_receiver", [validatorAddress]);
};

export const penalizeParticipant = ({
  participantAddress,
  penalty,
  validator
}) => {
  return sendTransaction(
    "add_penalty",
    [validator],
    [participantAddress, penalty]
  );
};
