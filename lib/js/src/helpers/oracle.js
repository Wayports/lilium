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
  const code = depositResultSetterTransaction("/private/results_s1_e1");

  return sendTransaction({ code, signers, args });
};

export const setResults = async ({ results, oracle }) => {
  const args = [results];
  const signers = [oracle];

  return sendTransaction("set_event_results", signers, args);
};

export const isResultSetterAccountSetup = oracleAddress => {
  return executeScript("check_setter_receiver", [oracleAddress]);
};

// This is a helper function to test other components that depends on
// the final stands
export const updateFinalStands = async () => {
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

  await createResultSetterCapReceiver(oracle);
  await depositResultSetterCap(oracle);

  return setResults({ oracle, results });
};
