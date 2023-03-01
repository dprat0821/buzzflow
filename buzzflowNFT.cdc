
import AccessManager from 0x01


pub contract SimplifiedBuzzflowNFT: AccessManager {


    

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub var idCount: UInt64
    
    pub enum AccessType: UInt8 {
      pub case read
      pub case update
      pub case generate
    }

    pub enum PlatformType: UInt8 {
        pub case buzzflow
        pub case tictok
        pub case instagram
    }

    pub resource NFT: AccessManager.Entity {
        pub let id: UInt64

        access(contract) let likes: {PlatformType: Int}
        access(contract) let followers: {PlatformType: Int}

        init(initID: UInt64) {
            self.id = initID
            self.likes = {}

            self.followers = {}
        }

        access(contract) fun changeLikes(on platform: PlatformType, to count: Int) {
            self.likes[platform] =  count
        }

        access(contract) fun changeFollowers(on platform: PlatformType, to count: Int) {
            self.followers[platform] = count
        }
    }

    pub resource interface NFTReceiver {
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
        pub fun idExists(id: UInt64): Bool
    }

    pub resource Collection: NFTReceiver, AccessManager.Channel {
        pub var ownedNFTs: @{UInt64: NFT}
        pub var accessMatrix: {Address: {String: [AccessManager.AccessType]}}


        init () {
            self.ownedNFTs <- {}
            self.accessMatrix = {}
        }

        // withdraw
        pub fun withdraw(withdrawID: UInt64): @NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID)
                ?? panic("Cannot withdraw the specified NFT ID")
            
            self.unregister(&token as &AnyResource{AccessManager.Entity})
            return <-token
        }

        // deposit
        pub fun deposit(token: @NFT) {
            self.register(&token as &AnyResource{AccessManager.Entity})
            self.ownedNFTs[token.id] <-! token
        }

        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        destroy() {
            destroy self.ownedNFTs
        }

        pub fun register(_ entity: &AnyResource{AccessManager.Entity}) {
        }
        pub fun unregister(_ entity: &AnyResource{AccessManager.Entity}) {
        }

        pub fun allow(_ account: Address, _ accessTypes:[AccessManager.AccessType], to field: String ){
            if self.accessMatrix.containsKey(account) {
                var accDict = self.accessMatrix[account]!
                accDict[field] = accessTypes
                self.accessMatrix[account] = accDict
            } else {

                self.accessMatrix.insert(key: account, {field: accessTypes})
            }
        
        }

        pub fun getAccesses(): {Address: {String: [AccessManager.AccessType]}} {
            return self.accessMatrix
        }

        pub fun can(_ account: Address, _ accessType: AccessManager.AccessType, to field: String): Bool {
            let accesses = self.accessMatrix[account]
            if accesses == nil {
                return false
            } else {
                let accessField = accesses![field] 
                if accessField == nil {
                return false
                }
                else {
                for a in accessField! {
                    if a == accessType {
                    return true
                    }
                }
                return false
                }
            }
        }


        pub fun query(entity: UInt64, for field: String, by account: Address): AnyStruct {
            if (!self.can(account, AccessType.read, to: field) ) {
                panic("access denied")
            }

            let token <- self.ownedNFTs.remove(key: entity)
                ?? panic("entity does not exist")

            var ret = 0 
            var valid = true
            switch field {
                case "tt_likes":
                    ret = token.likes[PlatformType.tictok] ?? 0
                case "tt_subs":
                    ret = token.followers[PlatformType.tictok] ?? 0
                case "bf_likes":
                    ret = token.likes[PlatformType.buzzflow] ?? 0
                case "bf_subs":
                    ret = token.followers[PlatformType.buzzflow] ?? 0
                case "ig_likes":
                    ret = token.likes[PlatformType.instagram] ?? 0
                case "ig_subs":
                    ret = token.followers[PlatformType.instagram] ?? 0
                default:
                    valid = false
                    
            }
            self.ownedNFTs[token.id] <-! token
            if ! valid {
                panic("querying invalid field")
            }
            return ret
        }

        pub fun mutate(entity: UInt64, for field: String, with newValue: AnyStruct, by account: Address) {
            if (!self.can(account, AccessType.update, to: field) ) {
                panic("access denied")
            }


            let token <- self.ownedNFTs.remove(key: entity)
                ?? panic("entity does not exist")
            
            let count = newValue as? Int
                ?? panic("invalid newValue type")

            var valid = true

            switch field {
                case "tt_likes":
                    token.changeLikes(on: PlatformType.tictok, to: count)
                case "tt_subs":
                    token.changeFollowers(on: PlatformType.tictok, to: count)
                case "bf_likes":
                    token.changeLikes(on: PlatformType.buzzflow, to: count)
                case "bf_subs":
                    token.changeFollowers(on: PlatformType.buzzflow, to: count)
                case "ig_likes":
                    token.changeLikes(on: PlatformType.instagram, to: count)
                case "ig_subs":
                    token.changeFollowers(on: PlatformType.instagram, to: count)
                default:
                    valid = false
            }
            self.ownedNFTs[token.id] <-! token
            if ! valid {
                panic("mutating invalid field")
            }
        }
    }


    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }


    pub fun mintNFT(): @NFT {
        var newNFT <- create NFT(initID: self.idCount)
        self.idCount = self.idCount + 1
        return <-newNFT
    }

	init() {
        self.CollectionStoragePath = /storage/buzzflowCollection
        self.CollectionPublicPath = /public/buzzflowCollection
        self.MinterStoragePath = /storage/buzzflowMinter

        self.idCount = 1

        self.account.save(<-self.createEmptyCollection(), to: self.CollectionStoragePath)

        self.account.link<&{NFTReceiver}>(self.CollectionPublicPath, target: self.CollectionStoragePath)
	}
}