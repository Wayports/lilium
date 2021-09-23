import WRLEvent from 0xf8d6e0586b0a20c7

transaction {
    prepare(stewardAccount: AuthAccount) {
        stewardAccount.save(<-WRLEvent.createSteward(), to: /storage/steward)

        stewardAccount.link<&WRLEvent.Steward{WRLEvent.ValidatorReceiver}>(
            /public/steward,
            target: /storage/steward
        )
    }
}
