import {
  executeScript,
  sendTransaction,
  getAccountAddress
} from "flow-js-testing";
import { depositResultSetterTransaction } from "../transaction-templates/oracle.template";

export const createResultSetterCapReceiver = oracleAddress => {
  return sendTransaction("create_results_cap_rec", [oracleAddress]);
};

export const depositResultSetterCap = async oracleAddress => {
  const admin = await getAccountAddress("Admin");
  const signers = [admin];
  const args = [oracleAddress];
  const code = depositResultSetterTransaction("/private/validator_s1_e1");

  return depositResultSetterTransaction({ code, signers, args });
};

export const setResults = async ({ results, oracle }) => {
  const args = [results];
  const signers = [oracle];

  return sendTransaction("set_event_results", signers, args);
};

export const isResultSetterAccountSetup = oracleAddress => {
  return executeScript("check_setter_receiver", [oracleAddress]);
};
