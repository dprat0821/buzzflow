 

pub contract interface Mutable {
  pub event Mutated(target:UInt64, features: [String])
  
  pub event SourceAdded(sourceId: UInt64)

  pub struct Transition {
    pub let feature: String
    pub let newValue: AnyStruct
  }

  pub resource interface Target {
    pub let id: UInt64
  }

  pub struct Mutation {
    pub let targetId: UInt64
    pub let transitions: [Transition]
    pub let description: String
  }
  
  pub resource interface Source {
    pub let id: UInt64
    pub fun conduct(mutation: Mutation )
  }

  pub fun getFeatureValue(feature: String): AnyStruct 
  

  pub fun isValid(source sourceId:UInt64, for features:[String]): Bool 
  pub fun registerSource(source: AnyStruct{Mutable.Source}) 


}