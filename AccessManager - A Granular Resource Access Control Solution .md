# AccessManager - A Granular Resource Access Control Solution 

## Problem Statement


Cadence provides both [capability-based access control](https://developers.flow.com/cadence/language/capability-based-access-control) and [access modifiers](https://developers.flow.com/cadence/language/access-control) to assist the resource access control. With proper implementation, these controls are sufficient to protect user resources in most of common transactions. One restriction however is: Once a capability is created,  **all** accounts will equally have **full** access to the related resource's **all** public declarations. 

Due to this restriction,  we faced some challenges when scaling the dapp Buzzflow. 

> As the background, users can create AR videos with their NFT's 3D variants through Buzzflow's mobile app, then post these videos to the binded social platforms. Buzzflow will aggregate the metrics such as likes and followers through the se platform's APIs to update the NFT's storage, and eventually impact the NFT's rareness and market value. For security and scaling measures, an obvious architecture decision is to manage each social platform through an exclusive delegate account on Flow blockchain.

![AccessOrig](AccessOrig.jpg)

### Problem 1: How to limit delegate account's access to just designated fields of the NFTs

Ideally, we want the Tictok delegate account only be able to read and update the NFT's Tictok-related metrics, while never touch the Instagram or Twitter ones. Through it's technically impossible to avoid intentional access due to above mentioned restrictions, we can still provide solution to avoid incautious mistakes. 

### Problem 2: How to control a particular NFT of a collection with a different access policy

We want the owner to be able to cut down Instgram delegate's access to just one NFT (say: due to malicious data), while keeping the Tictok/Twitter delegates, without impacting other NFTs from the same collection. 



## Solution

As a part of Buzzflow submission for Flow's Hackathon, this repository proposes the interface contract **AccessManager** to help above mentioned problems. This section will discuss the solution. 

Again, AccessManager is designed to prevent the damage of incautious transactions from arbitrarily accessing resources. Technically, it cannot prevent intentional damages.

>  AccessManager is used in Buzzflow NFT smart contract. You can try AccessManager along with sample implementations and transaction tests in the [Playground](https://play.flow.com/87a940a4-33cb-41e3-94c1-80cb71c35bfe). The next section will walk you through how to test it. This 

### Key Concepts

We call a resource under access management as an *Entity*. An *Entity* has one or more declared *Fields*. Accounts can only access a *Field* through a *Channel*, if the *Channel* explicitly pre-allowed.

**AccessManager** allows different set of access types defined for contract's own demand. Typical sets are (Query, Mutation) or (Create, Read, Update, Delete)



## How to use this Playground

Playground address [Here](https://play.flow.com/87a940a4-33cb-41e3-94c1-80cb71c35bfe). Steps to play:

1. Deploy `AccessManager(0x01)`
2. Deploy `HelloWorldExample(0x02)` . Then  try the following transactions to understand how does AccessManager works:
   1. HW: CreateResource
   2. HW: RegisterAccess
   3. HW: TestAccess
3. Deploy `SimplifiedBuzzflowNFT(0x03)`. This is the simplified version of Buzzflow NFT smart contract. It allows 
4. Then  try the following transactions:
   1. **SBuzzflow: GrantAccess**: create resource, grant access to Tictok delegate and Twitter delegate to different set of fields
   2. **SBuzzflow: TestAccess** : test how delegate can mutate ticktok-related fields now.

## Extra