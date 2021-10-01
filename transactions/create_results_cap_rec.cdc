import WRLEvent from 0xf8d6e0586b0a20c7

transaction {
    prepare(oracleAccount: AuthAccount) {
        oracleAccount.save(<-WRLEvent.createOracle(), to: /storage/resultSetter)

        oracleAccount.link<&WRLEvent.Oracle{WRLEvent.ResultSetterReceiver}>(
            /public/resultSetter,
            target: /storage/resultSetter
        )
    }
}
