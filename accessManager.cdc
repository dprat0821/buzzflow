


pub contract interface AccessManager {

  pub enum AccessType: UInt8 {
      pub case generate
      pub case read
      pub case update
      pub case delete
  }

  pub resource interface Entity {
    pub let id: UInt64
    
    pub fun registerAccess(_ account: Address, for accessTypes:[AccessType], to field: AnyStruct )
    pub fun unregisterAccess(_ account: Address, for accessTypes:[AccessType], from fields: AnyStruct)
    
    pub fun getAccesses(): {Address: {String: [AccessManager.AccessType]}}

    pub fun can(_ account: Address, accessType: AccessType, to field: AnyStruct): Bool 
    pub fun query(_ entityId: UInt64, for field: AnyStruct, by account: Address): AnyStruct
    pub fun mutate(_ entityId: UInt64, for field: AnyStruct, with newValue: AnyStruct, by account: Address) 
  }


  
}