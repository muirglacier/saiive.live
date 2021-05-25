# Overview

1. Requester(s): Dominik and Patrik Pfaffenbauer (eg. in future saiive.defichain GmbH)

2. Amount requested in DFI: 50.000

3. Receiving address: dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs

4. Reddit discussion thread: https://www.reddit.com/r/defiblockchain/comments/nkyyhw/defichain_light_wallet_saiivelive_is_born/

5. Proposal fee (10 DFI) txid: TBD

   

Dominik und Patrik Pfaffenbauer are actively developing a Light, non custodial Wallet for iOS, Android, Mac, Windows and Linux.  (https://github.com/saiive).

**saiive.live** is a non-custodial light wallet Application that runs on iOS, Android, Windows, Mac and Linux. In it's current stage, it is fully functional and already working.

The goal of this project is not just to provide a mobile application to the DefiChain Ecosystem, it is much more. It includes many necessary components to further decentralize DeFiChain and move away from the Foundation and Cake, enhancing also security and future possible projects. Our application solves one of the main problems running the foundation app on desktop: We don't run a full-node, we run the infrastructure in the cloud. (thus reducing decentralization, but accelerate adoption)



# Release
## Current Status
The current state of the app is in testing phase for users applied to be part in the testing program. The app is fully functioning and has already implementing following functions:
 - Offline signing of BTC transactions
 - Offline signing of DFI transactions
 - Send DAT and DFI (Converting account to UTXO if necessary)
 - Receiving of DAT and DFI
 - Receiving of Bitcoin (for atomic swap - coming later)
 - HD Wallet Implementation
    - Supporting only 1 account for now, later on you can create as many as wanted
 - Show Balance of $DFI and DAT
 - DEX:
   - Swap DFI to DAT
   - Swap DAT to DFI
   - Create Transaction and send it to Blockchain
 - Liquidity Mining:
   - Show all available Pools with Liquidity
   - Show my Pools Shares
   - Calculate estimated earnings for my pool shares
   - Add Liquidity
   - Remove Liquidity
 - List all Tokens
 - Settings
   - Show Seed
   - Remove Seed
   - Change Theme (Dark and Light Mode)
   - Biotmetric Security for FaceID/TouchID or Fingerprint on Android / (TBD Pin Code and 2FA)
   - Mainnet and Testnet
 - Secure Storage for Mmenonic Seed on Mobile devices through system provided Secure Storage Systems

For the app to be functional, we also provide the necessary infrastructure which currently is distributed into several data centers. This infrastructure consists of following services:
 - Full Node in testnet
 - Full Node in mainnet
 - Bitcore as a proxy API and database for blocks/transactions
 - Supernode as our Web3 API



### How will the fund be spent?

Mostly for infrastructure and employees. In the meantime we will create masternodes to get more security to the network. In the time we need the money we will resign on of the masternodes to pay out the needs.



### How does this CFP benefit the DeFiChain community?

No more:

* Resync
* Initial sync
* high-end device to run the app

I guess the benefits of our app should be clear to all :)