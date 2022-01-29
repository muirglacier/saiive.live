# Overview

1. Requester(s): Dominik and Patrik

2. Amount requested in DFI: 50.000 

3. Receiving address: dResgN7szqZ6rysYbbj2tUmqjcGHD4LmKs

4. Reddit discussion thread: [Reddit]

5. Proposal fee (10 DFI) txid: 0d1da58b47c9124a8563eaf906d3011c2bd0c0202288213beb336c945a93b670 

# Describe the purpose
As described in the CFP #4 (https://github.com/DeFiCh/dfips/issues/13) we successfully implemented and launched Loans, Stocks, Composite Swap and Auctions of liquidated Vaults.

## Implementations
Last couple of months we worked hard on implementing the dToken/Stock and Loan features. We did multiple daily TestFlight Builds as well as weekly Production Releases to Google Play Store and Apple AppStore.

So, what was necessary in order for us to implement all of that?

 - API:
   - Query Loans
   - Query Loan Tokens (Stocks)
   - Query Auctions
   - Query Oracle Data
 - UI:
   - UI for Loan Tokens (Stocks)
   - UI for Creating a Vault
   - UI for Showing the Vault
   - UI for transfer Vault to a different address
   - UI for Changing Vault Scheme
   - UI for Adding Collateral
   - UI for Removing Collateral
   - UI for Taking a Loan
   - UI for Payback of a Loan
   - UI for a Liquidated Vault
   - UI for Next Collateralization Value
   - UI for Auctions
   - UI for bidding on an Auction
   - UI for Composite Swap
 - TX:
   - Transaction "CreateVault"
   - Transaction "ChangeVault"
   - Transaction "DepositToVault"
   - Transaction "WithdrawFromVault"
   - Transaction "TakeLoan"
   - Transaction "PlaceAuctionBid"
   - Transaction "CompositeSwap"

We launched the first Version (0.10) end of November and have since then improved different features of the App. Current Version is 0.22 with many improvements since the initial Loan Feature Release in November 2021.

## Additional Features

### Single Address Mode
We heard from the Community that the multiple Address Management Feature doesn't work well for them. Reason is that funds are distributed across all addresses and transactions therefore take longer cause it needs to move funds to one address first. To solve that we implemented a "Single Address mode" feature. saiive.live then only ever uses one address. This also comes with the perk that with that, we are 100% compatible with the DeFichain Light Wallet and DFX Wallet.

### Manual Slippage Control
We heard from the Community that they want to manually control the Slippage when doing DEX Swaps. Therefore we implemented that feature so everybody can either use our presets, or manually put in a percentage to control the slippage.

## Amount
As stated in CFP #4 (https://github.com/DeFiCh/dfips/issues/13) we assumed a DFI-USD Price of $3 for 2021. we now have 2022 and they price fell for DFI (currently $2.5). Since we are here for the long run, we're going to estimate this Proposal again for $3. So we request as stated in CFP #4 for Loans DFI: 50.000.

# Next Steps

Let me give you some insights what our plan for 2022 is:

 - We need to have better communication. We had good help from a community member, due to personal issues, he is out for couple of months. So we are searching for new Help in that matter
 - Video Tutorials: We want to make onboarding of saiive.live easier and faster. Therefore we plan to make Video Tutorials to show how it works.
 - Written Tutorials: As well as Video Tutorials, we also want to make a Blog to release the Tutorials there.
 - Ledger Support: one of the main asked features for Defichain. And one of the most important one!

   

# How will the fund be spent?
Used for development expenses, infrastructure and support.




# How does this CFP benefit the DeFiChain community?
Providing an independent DeFiChain Wallet for beginners and experts, with more features as the light wallet. 
Quick and personal support from the saiive core developers. 
Providing infrastructure for other projects within the ecosystem.

