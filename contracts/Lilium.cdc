import FungibleToken from 0xFUNGIBLE

pub contract Lilium: FungibleToken {
    pub var totalSupply: UFix64
    pub var maxSupply: UFix64

    pub event BurnerCreated()
    pub event TokensMinted(amount: UFix64)
    pub event TokensBurned(amount: UFix64)
    pub event MinterCreated(allowedAmount: UFix64)
    pub event TokensInitialized(initialSupply: UFix64)
    pub event TokensDeposited(amount: UFix64, to: Address?)
    pub event TokensWithdrawn(amount: UFix64, from: Address?)

    pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {
        pub var balance: UFix64

        init(balance: UFix64) {
            self.balance = balance
        }

        pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
            self.balance = self.balance - amount
            emit TokensWithdrawn(amount: amount, from: self.owner?.address)
            return <- create Vault(balance: amount)
        }

        pub fun deposit(from: @FungibleToken.Vault) {
            let vault <- from as! @Lilium.Vault
            self.balance = self.balance + vault.balance
            emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
            vault.balance = 0.0
            destroy vault
        }

        destroy() {
            Lilium.totalSupply = Lilium.totalSupply - self.balance
        }
    }

    pub fun createEmptyVault(): @Vault {
        return <-create Vault(balance: 0.0)
    }

    pub resource Administrator {

        pub fun createNewMinter(allowedAmount: UFix64): @Minter {
            emit MinterCreated(allowedAmount: allowedAmount)
            return <-create Minter(allowedAmount: allowedAmount)
        }

        pub fun createNewBurner(): @Burner {
            emit BurnerCreated()
            return <-create Burner()
        }
    }

    pub resource Minter {
        pub var allowedAmount: UFix64

        pub fun mintTokens(amount: UFix64): @Lilium.Vault {
            pre {
                amount > 0.0: "Amount minted must be greater than zero"
                amount <= self.allowedAmount: "Amount minted must be less than the allowed amount"
            }

            Lilium.totalSupply = Lilium.totalSupply + amount
            self.allowedAmount = self.allowedAmount - amount
            emit TokensMinted(amount: amount)
            return <-create Vault(balance: amount)
        }

        init(allowedAmount: UFix64) {
            self.allowedAmount = allowedAmount
        }
    }

    pub resource Burner {
        pub fun burnTokens(from: @FungibleToken.Vault) {
            let vault <- from as! @Lilium.Vault
            let amount = vault.balance
            destroy vault
            emit TokensBurned(amount: amount)
        }
    }

    init() {
        self.totalSupply = 1_000.0
        self.maxSupply = 100_000_000.0

        let vault <- create Vault(balance: self.totalSupply)
        self.account.save(<-vault, to: /storage/liliumVault)

        self.account.link<&{FungibleToken.Receiver}>(
            /public/liliumReceiver,
            target: /storage/liliumVault
        )

        self.account.link<&Lilium.Vault{FungibleToken.Balance}>(
            /public/liliumBalance,
            target: /storage/liliumVault
        )

        let admin <- create Administrator()
        self.account.save(<-admin, to: /storage/liliumAdmin)

        emit TokensInitialized(initialSupply: self.totalSupply)
    }
}
 
