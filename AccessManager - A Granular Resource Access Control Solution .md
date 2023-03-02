# AccessManager - A Granular Resource Access Control Solution 



Playground for this article: [LINK](https://play.flow.com/000db34a-81ee-4709-9d39-948bf953138d)

## Problem Statement


Cadence provides both [capability-based access control](https://developers.flow.com/cadence/language/capability-based-access-control) and [access modifiers](https://developers.flow.com/cadence/language/access-control) to assist the resource access control. With proper implementation, these controls are sufficient to protect user resources in most of common transactions. One restriction however is: Once a capability is created, **all** accounts will equally have **full** access to **all** the public declarations of the linked resource.

What if we want only **designated** accounts to have **particular** types of access, to **particular** set of fields of the resource?  We faced related challenges when scaling the dapp Buzzflow. 

> As the background, users can create AR videos with their NFT's 3D variants through Buzzflow's mobile app, then post these videos to the binded social platforms. Buzzflow will aggregate the metrics such as likes and followers through these platform's APIs to update the NFT's storage, and eventually impact the NFT's rareness and market value. For security and scaling measures, an obvious architecture decision is **to interface each social platform through an designated delegate account** on Flow blockchain.

![AccessOrig](AccessOrig.jpg)

### Problem 1: How to limit a delegate account's access to just designated fields of the NFTs

Ideally, we want the Tictok delegate account only be able to read and update the NFT's Tictok-related metrics, while never touch the Instagram or Twitter ones. Through it's technically impossible to avoid intentional access due to above mentioned restrictions, we can still provide solution to avoid incautious mistakes. 

### Problem 2: How to control a particular NFT of a collection with a different access policy

We want the owner to be able to cut down Instgram delegate's access to just one NFT of his/her whole collection (eg. due to malicious data), while

1. keep the Tictok/Twitter delegates functional for this particular NFT
2. No impacting other NFTs from the same collection. 



### Definitions

To continue further discussion, let's first define some terminologies.

We call a resource an **Entity** in this context, if the resource is deemed by its owner as having at least one public declaration that the owner does not want to expose to all other accounts. We can such public declaration a **Field**.

There could be a set of **Accesse Types**. Either (Read/Write), or (Create/Read/Update/Delete) or (Query/Mutation), or simply (Access). Ideally, the owner should have the control of **Allowing** certain accounts with certain access types to the entity.

A **Breach** is a transaction in which the authorizer account trying at least one disallowed access types and/or to disallowed fields of an entity.

There are two major types of breaches:

1. **Intentional Breach**: the breach is intentionally conducted by the authorizer account. the Authorizer may even try special technical tactics to bypass security countermeasures.
2. **Incautious Breach**: this is happening when the transactions was sent with good wills but bad or defective logic. Incautious breaches wouldn't attempt complex techical tactics to bypass security coutermeasures, however still possible to make a damage due to lack of preventive measures.

For the usecases in the section Problem Statement, We didn't find any effective way to protect entities from intentional breaches. However, there can be a solution or design pattern to prevent incautious breaches.

## Solution

As a part of Buzzflow submission for Flow's Hackathon, we propose **AccessManager** to help previous mentioned incautious breaches. AccessManager is used in Buzzflow NFT smart contract. You can try AccessManager along with sample implementations and transaction tests in the [Playground](https://play.flow.com/87a940a4-33cb-41e3-94c1-80cb71c35bfe). Steps to play:

1. Deploy `AccessManager(0x01)`
2. Deploy `HelloWorldExample(0x02)` . Then  try the following transactions to understand how does AccessManager works:
   1. HW: CreateResource
   2. HW: RegisterAccess
   3. HW: TestAccess
3. Deploy `SimplifiedBuzzflowNFT(0x03)`. This is the simplified version of Buzzflow NFT smart contract.  
4. Then  try the following transactions:
   1. **SBuzzflow: GrantAccess**: create resource, grant access to Tictok delegate and Twitter delegate to different set of fields
   2. **SBuzzflow: TestAccess** : test how delegate can mutate ticktok-related fields now.

## Extra