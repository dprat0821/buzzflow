/**
BuzzToken is a standard FungibleToken 
Note: This is minimized implementation as it's not the essential part of submission
*/
import FungibleToken from 0x03

pub contract BuzzToken: FungibleToken{
  pub var totalSupply: UFix64

  pub event TokensInitialized(initialSupply: UFix64)

  pub event TokensWithdrawn(amount: UFix64, from: Address?)

  pub event TokensDeposited(amount: UFix64, to: Address?)

  // pub var totalSupply: UFix64
  pub let TokenStoragePath: StoragePath
  pub let TokenPublicPath: PublicPath

  init() {
    self.TokenStoragePath = /storage/buzzTokenVault
    self.TokenPublicPath = /public/buzzTokenVault
    
    self.totalSupply = 1000000.0
    let vault <-create Vault(balance: self.totalSupply )

    self.account.save(<-vault, to: self.TokenStoragePath)

    self.account.link<&BuzzToken.Vault>(BuzzToken.TokenPublicPath, target: BuzzToken.TokenStoragePath)
    emit TokensInitialized(initialSupply: self.totalSupply)
  }

  pub resource Vault: FungibleToken.Provider, FungibleToken.Receiver, FungibleToken.Balance {
  
    pub var balance: UFix64

    init(balance: UFix64) {
      self.balance = balance
    }

    pub fun withdraw(amount: UFix64): @FungibleToken.Vault {
      self.balance = self.balance - amount
      emit TokensWithdrawn(amount: amount, from: self.owner?.address)
      return <-create Vault(balance: amount)
    }

    pub fun deposit(from: @FungibleToken.Vault) {
      let vault <- from as! @BuzzToken.Vault
      self.balance = self.balance + vault.balance
      emit TokensDeposited(amount: vault.balance, to: self.owner?.address)
      destroy vault
    }

  }

  pub fun createEmptyVault(): @BuzzToken.Vault {
      return <-create Vault(balance: 0.0)
  }

}
 