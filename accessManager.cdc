


pub contract interface AccessManager {
  /// contracts can define their own set of AccessTypes. See HelloWorldExample(0x02) and SimplifiedBuzzflowNFT(0x03)
  pub enum AccessType: UInt8 {}


  pub resource interface Entity {
    pub let id: UInt64 
  }

  pub resource interface Channel {
    pub fun register(_ entity: &AnyResource{Entity})
    pub fun unregister(_ entity: &AnyResource{Entity})

    pub fun allow(_ account: Address, _ accessTypes:[AccessManager.AccessType], to field: String ) 
    
    pub fun getAccesses(): {Address: {String: [AccessType]}}

    pub fun can(_ account: Address, _ accessType: AccessManager.AccessType, to field: String): Bool
    pub fun query(entity: UInt64, for field: String, by account: Address): AnyStruct
    pub fun mutate(entity: UInt64, for field: String, with newValue: AnyStruct, by account: Address)
  }


  
}