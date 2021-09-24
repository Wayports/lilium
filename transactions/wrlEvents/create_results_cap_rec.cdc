import WRLEvent from 0xf8d6e0586b0a20c7

transaction {
    prepare(botAccount: AuthAccount) {
        botAccount.save(<-WRLEvent.createBot(), to: /storage/resultSetter)

        botAccount.link<&WRLEvent.Bot{WRLEvent.ResultSetterReceiver}>(
            /public/resultSetter,
            target: /storage/resultSetter
        )
    }
}
