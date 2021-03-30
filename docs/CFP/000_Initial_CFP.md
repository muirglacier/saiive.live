# Overview
Dominik und Patrik Pfaffenbauer are actively developing a Light, non custodial Wallet for iOS, Android, Mac, Windows and Linux.  (https://github.com/DeFiCh-WalletApp).

**Smart DeFi Wallet** is a non-custodial light wallet Application that runs on iOS, Android, Windows, Mac and Linux. In it's current stage, it is fully functional and already working.

The goal of this project is not just to provide a mobile application to the DefiChain Ecosystem, it is much more. It includes many necessary components to further decentralize DeFiChain and move away from the Foundation and Cake, enhancing also security and future possible projects. Our application solves one of the main problems running the foundation app on desktop: We don't run a full-node, we run the infrastructure in the cloud. (thus reducing decentralization, but accelerate adoption)

# Funding proposal
 - Requester: Dominik and Patrik Pfaffenbauer
 - Amount: 530.000 DFI
    - In Total
       - Payout plan/calculation see below
    - Calculated at current DFI price
    - The amount for 2021 does not depend on a USD price. For the following years: We will create on-chain CFPs, depending on the current USD price. At now we assume a price of $3,-.
 - Address: dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs
 - We will create several funding proposal after the pink paper is presented and also implemented. Therefore we will propose only 100.000 DFI initially. For step 1 and 2 (see disbursement plan). After that we will create the CFPs on the blockchain.

# Offering
## Step 1 - Current Status
The current state of the app is in testing phase for users applied to be part in the testing program. The app is fully functioning and has already implementing following functions:
 - Offline signing of BTC transactions
 - Offline signing of DFI transactions
 - Send DAT and DFI (Converting account to UTXO if necessary)
 - Receiving of DAT and DFI
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
   - TBD: Remove Liquidity
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

## Step 2 - Atomic Swap
The long term goal of **Smart DeFi Wallet** is to be compatible with the Foundation provided application. That also means that our **Smart DeFi Wallet** needs to implement the same core functions. The next one on our roadmap is the Atomic Swap. We already prepared our infrastructure to also allow us to run a full bitcoin node and communicate with it.

## Step 3 - Stock / Securities
**Smart DeFi Wallet** also allows trading with Stocks / Securities. This is one of the most important steps for user adaptions. We don't have a KYC and we don't know the user. So our app is private as can be.

## Step 4 - Further ideas
We also have some further development ideas. Which are not handled in this proposal - but you can see the bigger picture more clear for our vision with the **Smart DeFi Wallet**. For all further ideas we will create new proposals.

 - Non KYC FIAT-DFI gateway
 - TOR Support
 - Allow other currencies as well (ETH, USDT, ...)
 - Options

# Funding - Costs
## Infrastructure
Running an app is not free. Infrastructure is one of very expensive part of it. The services currently runs in two data-centers for security and scalability reasons: Azure and Scaleway (AWS and GCP in future as well). Infrastructure currently costs around €1000/month and is estimated to cost around €5000/month once we reach a proper scale.

Running the infrastructure for the app costs per year: €12.000 - 60.000. Depending obviously on the scale.

## App Development 
Creating such an app is not an easy task. Fortunately, Software Development is our daily business allowing us that in the first place. Still, defichain is a new territory for us and the learning curve is quite steep. We started development in January. Worked on it after work and weekends. Overall, we calculated the time amount spent, which is around 1000 person hours. This ours went into following tasks:

 - Developing the app in dart with flutter
 - Developing the DeFiChain tx lib in dart with flutter (offline signing, lots of know how in there)
 - Forking and enhancing the dart bip32 and bs58 libs
 - Forking bitcore and extend the functionality to further get data from the DeFiChain network
 - Developing our super-node (web3-api) to get data from bitcore and exposing it to the outside world
 - Running the DeFiChain node in mainnet/testnet, bitcore and our supernode (web3) api on containerized cloud infrastructure.
   - we also ran it in a kubernetes cluster, but that currently exceeds the costs

A lot of time also ran into debugging the foundations app and DeFiChain node to understand how things work.

## Business Plan for 3 Years
## Expenses
Calculated in Euro.

|                                                   | 2021        | 2022        | 2023        | 2024        |
| ------------------------------------------------- | ----------- | ----------- | ----------- | ----------- |
| Staff <br />(Starting with 2-3 Full-Time Devs).   | 255.000     | 318.750     | 400.000     | 600.000     |
| Legal Services                                    | 20.000      | 25.000      | 32.000      | 40.000      |
| Tax Services                                      | 10.000      | 15.000      | 19.000      | 24.000      |
| Office                                            | 12.000      | 15.000      | 18.000      | 23.000      |
| Hardware                                          | 20.000      | 25.000      | 31.000      | 39.000      |
| Cloud and licenses                                | 50.000      | 62.500      | 78.000      | 97.000      |
| Ads (YouTube, Marketing,..)                       | 10.000      | 20.000      | 40.000      | 80.000      |
| Total                                             | **377.000** | **481.250** | **618.000** | **903.000** |
| Cumulative                                        | 377.000     | 795.250     | 1.413.250   | 2.316.250   |

## Income
Calculated in DFI (and USD).

| Income (in DFI)                 | 2021        | 2022          | 2023          | 2024          |
| ------------------------------- | ----------- | ------------- | ------------- | ------------- |
| Initial payout                  | 50.000      |               |               |               |
| iOS/Android Store release       | 50.000      |               |               |               |
| Atomic Swap for BTC             | 50.000      |               |               |               |
| Ledger Integration              | 20.000      |               |               |               |
| Decentralized Stocks/Securities |             | 50.000        |               |               |
| Infrastructure/Employee Payout  |             | 60.000        |               |               |
| Simplify onboarding             |             | 50.000        |               |               |
| Hosted Masternodes              |             | 50.000        |               |               |
| Infrastructure/Employee Payout  |             |               | 60.000        |               |
| Infrastructure/Employee Payout  |             |               |               | 60.000        |
| Milestone #1 (Store downloads)  |             | 30.000        |               |               |
| Total                           | 170.000     | 240.000       | 60.000        | 60.000        |
| Total USD                       | 510.000     | 720.000       | 180.000       | 180.000       |
| Cumulative                      | **510.000** | **1.230.000** | **1.410.000** | **1.590.000** |

# Open Source
We love Open Source and are also active in other Open Source Communities. Our personal concern is to open-source everything we produce that is necessary to run **Smart DeFi Wallet**. This helps building trust and allows other developers to review security of the app, or even provide Pull Requests to improve the **Smart DeFi Wallet**.

A lot of work for working the blockchain has already been made in dart for our purpose. This can be reused directly or can be ported over into other languages if needed. All of that is available for free, open source.

# Future - Further Ideas / Further Development / Further Progress
 - Found a company providing further development of the app and managing funds from the community proposal
 - Hire employees (UX / Developer) to further improve the app
 - Constantly reacting to user-feedback and enhancing/bug fixing the app.
 - <u>Provide</u> User Support for the app on telegram/reddit/twitter etc.
 - Further help defichain gain market by enabling easier onboarding into the **Smart DeFi Wallet**
 - Ledger integration
 - Running Managed private Masternodes from inside **Smart DeFi Wallet**

# Community Fund Money
The money will be used to fund the following:

 - Funding a company in Austria to further develop the application and manage the money from the proposal
 - Development of the **Smart DeFi Wallet** for iOS, Android, Windows, Mac and Linux
 - Create a Website
 - Release of the App under the name of the company in several app-stores: iOS App Store, Google Play Store, Mac App Store, Ubuntu Snaps, etc.
 - Operating the infrastructure for at least 3 years
 - Providing the infrastructure and application for FREE to the community
 - Provide tutorials to help the users

# Disbursement Plan
## Features/Rollout
 - After release of the **Smart DeFi Wallet** for testing *(ETA: immediately)* - <u>50.000 DFI</u>
 - After release in the iOS Store / Play Store *(ETA: Q2 2021)* - <u>50.000 DFI</u>
 - **<u>After that all CFPs will be on-chain</u>**
 - Atomic Swap *(ETA: Q3 2021)* - <u>50.000 DFI</u>
 - Ledger Integration *(ETA: Q3 2021)* - <u>20.000 DFI</u>
 - Decentraliced Securities/Stocks *(ETA: Q4/Q1 2021/2022)* - <u>50.000 DFI</u>
 - Simplify onboarding process by providing some DFI for new Users *(ETA 2022)* - <u>50.000 DFI</u> (<u>**25.000 DFI**</u> for onboarding process giveaway)
 - Hosted Masternode via **Smart DeFi Wallet** - providing the first 1000 Masternodes for free (*ETA 2022*) - <u>50.000 DFI</u>

## Infrastructure/employee payouts
 - 1. January 2022 - for successfully operating **Smart DeFi Wallet** without major issues (5.000 DFI/Month) - <u>60.000 DFI</u>
 - 1. January 2023 - for successfully operating **Smart DeFi Wallet** without major issues (5.000 DFI/Month) - <u>60.000 DFI</u>
 - 1. January 2024 - for successfully operating **Smart DeFi Wallet** without major issues (5.000 DFI/Month) - <u>60.000 DFI</u>

## Milestone Payouts
 - Over 50.000 downloads in Google Play Store + iOS App Store - 30.000 DFI

# What happens after 3 years?
The **Smart DeFi Wallet** company has no cash-flow for now - as we want to stay KYC free and provide anonymous services for our users. But within the first 3 years we want to create a platform where we want to find some cash-flow so that the **Smart DeFi Wallet** can stay free-of-charge for all our users.

# Transparency
The **Smart DeFi Wallet** company stays complete transparent. Every year we will provide updates for our current cash-flow and all important information's of our services/progress and future ideas.

# Epilogue
We know it is a big ask for the community. We don't want to look greedy, but developing software and providing the needed infrastructure is very expensive. The funds are  used for the product, not for us. That's why we create a transparent company structure as well.