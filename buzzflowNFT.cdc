import BuzzToken from 0x02
import NonFungibleToken from 0x05
import Mutable from 0x04


pub contract BuzzflowNFT: NonFungibleToken {

    // Declare Path constants so paths do not have to be hardcoded
    // in transactions and scripts

    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath
    pub let MinterStoragePath: StoragePath

    pub var totalSupply: UInt64

    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Minted(id: UInt64, origin: UInt8, origin_contract: String, origin_id: String)
    pub event ImagesAddedForNewKind(kind: UInt8)

    pub enum Origin: UInt8 {
        pub case ethereum
        pub case flow
        pub case solana
    }

    pub fun originToString(_ origin: Origin): String {
        switch origin {
            case Origin.ethereum:
                return "Ethereum"
            case Origin.flow:
                return "Flow"
            case Origin.solana:
                return "Solana"
        }

        return ""
    }




    pub resource NFT: NonFungibleToken.INFT{
        // The unique ID that differentiates each NFT
        pub let id: UInt64

        pub let origin: Origin

        pub let origin_contract: String

        pub let origin_id: String




        // Initialize both fields in the init function
        init(initID: UInt64, origin: Origin, origin_contract: String, origin_id: String ) {
            self.id = initID
            self.origin = origin
            self.origin_contract = origin_contract
            self.origin_id = origin_id
        }

    }

    

    // The definition of the Collection resource that
    // holds the NFTs that a user owns
    pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
        
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        // Initialize the NFTs field to an empty collection
        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)

            return <-token
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @BuzzflowNFT.NFT

            let id: UInt64 = token.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)

            destroy oldToken
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        // idExists checks to see if a NFT
        // with the given ID exists in the collection
        pub fun idExists(id: UInt64): Bool {
            return self.ownedNFTs[id] != nil
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // creates a new empty Collection resource and returns it
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }



    pub resource NFTMinter {

        pub fun mintNFT(
            recipient: &{NonFungibleToken.CollectionPublic}, 
            origin: Origin,
            origin_contract: String,
            origin_id: String,
        ) {
            let metadata: {String: AnyStruct} = {}
            let currentBlock = getCurrentBlock()
            metadata["mintedBlock"] = currentBlock.height
            metadata["mintedTime"] = currentBlock.timestamp
            metadata["minter"] = recipient.owner!.address


            // create a new NFT
            var newNFT <- create BuzzflowNFT.NFT(
                initID: BuzzflowNFT.totalSupply,
                origin: origin,
                origin_contract: origin_contract,
                origin_id: origin_id,
            )

            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            emit Minted(
                id: BuzzflowNFT.totalSupply,

                origin: origin.rawValue,
                origin_contract: origin_contract,
                origin_id: origin_id,
            )

            BuzzflowNFT.totalSupply = BuzzflowNFT.totalSupply + 1
        }

       
    }
    

	init() {
        self.totalSupply = 0

        // Set our named paths
        self.CollectionStoragePath = /storage/buzzflowCollection
        self.CollectionPublicPath = /public/buzzflowCollection
        self.MinterStoragePath = /storage/buzzflowMinter

        // Create a Collection resource and save it to storage
        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)



        // Create a Minter resource and save it to storage
        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.MinterStoragePath)

        emit ContractInitialized()
	}
}