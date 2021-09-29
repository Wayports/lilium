import path from "path";
import {
  init,
  emulator,
  shallPass,
  sendTransaction,
  getAccountAddress,
  deployContractByName
} from "flow-js-testing";

jest.setTimeout(10000);

describe("WRL Events", () => {
  beforeEach(async () => {
    const basePath = path.resolve(__dirname, "../../../");

    console.log("BASEPATH ======> ", basePath);

    const port = 8080;
    await init(basePath, { port });
    await emulator.start(port);

    const to = await getAccountAddress("Alice");

    console.log("MF TO ADDRESS: ", to);

    const y = await deployContractByName({ to, name: "WRLEvent" });
    console.log(y);
    console.log("Done");
  });

  afterEach(async () => {
    return emulator.stop();
  });

  it("Strouts", async () => {});

  // test("Create event", async () => {
  //   const AdminAccount = await getAccountAddress("");
  //   const signers = [AdminAccount];
  //   const args = [];

  // const txResult = await shallPass(
  //   sendTransaction({
  //     code,
  //     signers,
  //     args
  //   })
  // );
  // });
});
