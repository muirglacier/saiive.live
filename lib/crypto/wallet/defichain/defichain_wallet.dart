import 'dart:async';
import 'dart:math';

import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/from_account.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet_helper.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/transaction_data.dart';
import 'package:tuple/tuple.dart';
import '../impl/wallet.dart' as wallet;
import 'package:saiive.live/network/model/transaction.dart' as tx;

abstract class IDeFiCHainWallet {
  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream});

  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress, {StreamController<String> loadingStream});
  Future<TransactionData> createAndSendRemovePoolLiquidity(int token, int amount, String shareAddress, {StreamController<String> loadingStream});
}

class DeFiChainWallet extends wallet.Wallet implements IDeFiCHainWallet {
  DeFiChainWallet(bool checkUtxo) : super(ChainType.DeFiChain, checkUtxo);

  @override
  Future<TransactionData> createAndSendRemovePoolLiquidity(int token, int amount, String shareAddress, {StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      var addLiq = await removePoolLiquidity(token, amount, shareAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWait(addLiq, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  @override
  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress,
      {StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      var addLiq = await addPoolLiquidity(tokenA, amountA, tokenB, amountB, shareAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWaitInternal(addLiq, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> removePoolLiquidity(int token, int amount, String shareAddress, {StreamController<String> loadingStream}) async {
    var fees = await getTxFee(0, 0);
    await prepareAccount(fees, loadingStream: loadingStream);

    final key = mnemonicToSeed(seed);

    final txb = await createBaseTransaction(0, shareAddress, shareAddress, fees, (txb, inputTxs, nw) async {
      var tx = await getAuthInputsSmart(shareAddress, fees);

      txb.addRemoveLiquidityOutput(token, amount, shareAddress);

      final addressInfo = await walletDatabase.getWalletAddress(tx.address);

      final keyPair = HdWalletUtil.getKeyPair(
          key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

      final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
      if (inputContainsAuthTx.isEmpty) {
        var vin = txb.addInput(tx.mintTxId, tx.mintIndex);
        txb.addOutput(tx.address, tx.value);
        final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data;
        final redeemScript = p2wpkh.output;

        txb.sign(vin: vin, keyPair: keyPair, witnessValue: tx.value, redeemScript: redeemScript);
      }
    });

    return txb;
  }

  Future<String> addPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress, {StreamController<String> loadingStream}) async {
    if (!DeFiConstants.isDfiToken(tokenA) && !DeFiConstants.isDfiToken(tokenB)) {
      throw ArgumentError("One of the 2 tokens must be DFI!");
    }

    await prepareAccount(DeFiConstants.isDfiToken(tokenA) ? amountA : amountB);

    final tokenABalance = await walletDatabase.getAccountBalance(tokenA);
    final tokenBBalance = await walletDatabase.getAccountBalance(tokenB);

    if (tokenABalance.balance < amountA) {
      throw new ArgumentError("Insufficient balance...");
    }

    if (tokenBBalance.balance < amountB) {
      throw new ArgumentError("Insufficient balance...");
    }

    final tokenAType = await apiService.tokenService.getToken("DFI", tokenA);
    final tokenBType = await apiService.tokenService.getToken("DFI", tokenB);
    final key = mnemonicToSeed(seed);

    final accountsA = await walletDatabase.getAccountBalancesForToken(tokenA);
    final accountsB = await walletDatabase.getAccountBalancesForToken(tokenB);

    final fee = await getTxFee(0, 0);

    final accountA = await DefichainWalletHelper.getHighestAmountAddressForSymbol(accountsA, amountA);
    final accountB = await DefichainWalletHelper.getHighestAmountAddressForSymbol(accountsB, amountB);

    if (amountA > accountA.balance) {
      var accountTxA = await createAccountTransaction(tokenA, amountA, accountA.address);

      loadingStream?.add(S.current.wallet_operation_send_tx);
      await createTxAndWait(accountTxA);
      //handle account to account - move account balance to new address
    }
    if (amountB > accountB.balance) {
      var accountTxB = await createAccountTransaction(tokenB, amountB, accountB.address);

      loadingStream?.add(S.current.wallet_operation_send_tx);
      await createTxAndWait(accountTxB);
      //handle account to account - move account balance to new address
    }

    final useableAccountsA = await _getNeededAccounts(accountsA, amountA);
    final useableAccountsB = await _getNeededAccounts(accountsB, amountB);

    var inputTxs = List<tx.Transaction>.empty(growable: true);
    inputTxs.addAll(useableAccountsA.item2.where((element) => element.address == accountA.address));

    for (final input in useableAccountsB.item2) {
      if (!inputTxs.any((element) => element.mintTxId == input.mintTxId && element.mintHeight == input.mintHeight)) {
        inputTxs.add(input);
      }
    }

    final txb = await HdWalletUtil.buildAddPollLiquidityTransaction(inputTxs, accountA.toFromAccount(), accountB.toFromAccount(), walletDatabase, tokenAType.id, tokenBType.id,
        shareAddress, amountA, amountB, fee, shareAddress, key, chain, network);
    return txb.build().toHex();
  }

  Future<Tuple2<List<FromAccount>, List<tx.Transaction>>> _getNeededAccounts(List<Account> accounts, int amount, {List<String> excludeAddresses}) async {
    var curAmount = 0;
    var useAccounts = List<FromAccount>.empty(growable: true);
    final fees = 0;

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    for (final tx in accounts) {
      if (excludeAddresses != null && excludeAddresses.contains(tx.address)) {
        continue;
      }

      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      inputTxs.add(await getAuthInputsSmart(tx.address, fees));
      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = amount;
        break;
      } else {
        fromAccount.amount = tx.balance - curAmount;
      }
      curAmount += tx.balance;
    }

    return Tuple2(useAccounts, inputTxs);
  }

  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_create_swap_tx);
      var swap = await createSwap(fromToken, fromAmount, toToken, to, maxPrice, maxPriceFraction, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, loadingStream: loadingStream);

      return tx;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {StreamController<String> loadingStream}) async {
    if (DeFiConstants.isDfiToken(fromToken)) {
      await prepareAccount(fromAmount);
    }

    final changeAddress = await getPublicKeyFromAccount(account, true);
    final fees = await getTxFee(1, 2) + 5000;

    final fromTokenBalance = await walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new ArgumentError("Insufficient balance...");
    }

    final fromTok = await apiService.tokenService.getToken("DFI", fromToken);
    final toTok = await apiService.tokenService.getToken("DFI", toToken);
    final fromAccounts = await walletDatabase.getAccountBalancesForToken(fromToken);

    var inAmount = fromAmount;
    final key = mnemonicToSeed(seed);

    for (var acc in fromAccounts) {
      await getAuthInputsSmart(acc.address, fees);
      inAmount -= acc.balance;

      if (inAmount <= 0) {
        break;
      }
    }
    inAmount = fromAmount;

    final txb = await createBaseTransaction(0, to, changeAddress, fees, (txb, inputTxs, nw) async {
      for (var acc in fromAccounts) {
        var tx = await getAuthInputsSmart(acc.address, fees);

        var useValue = min(inAmount, acc.balance);
        txb.addSwapOutput(fromTok.id, acc.address, useValue, toTok.id, to, maxPrice, maxPriceFraction);

        final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
        if (inputContainsAuthTx.isEmpty) {
          final addressInfo = await walletDatabase.getWalletAddress(tx.address);

          final keyPair = HdWalletUtil.getKeyPair(
              key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

          var vin = txb.addInput(tx.mintTxId, tx.mintIndex);
          txb.addOutput(tx.address, tx.value);
          final p2wpkh = P2WPKH(data: PaymentData(pubkey: keyPair.publicKey)).data;
          final redeemScript = p2wpkh.output;

          txb.sign(vin: vin, keyPair: keyPair, witnessValue: tx.value, redeemScript: redeemScript);
        }

        inAmount -= acc.balance;

        if (inAmount <= 0) {
          break;
        }
      }
    });
    return txb;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createSendTransaction(int amount, String token, String to) async {
    final changeAddress = await this.getPublicKeyFromAccount(account, true);

    if (chain == ChainType.Bitcoin || DeFiConstants.isDfiToken(token)) {
      var txHex = await prepareAccountToUtxosTransactions(changeAddress, amount);

      if (txHex != null) {
        for (var txHexStr in txHex.item1) {
          final tx = await createTxAndWaitInternal(txHexStr);

          for (final unspentTx in tx.details.outputs) {
            if (unspentTx.address == changeAddress) {
              await walletDatabase.addUnspentTransaction(unspentTx);
            }
          }
        }
        await walletDatabase.removeUnspentTransactions(txHex.item2);
        amount -= txHex.item3;
      }

      return await createUtxoTransaction(amount, to, changeAddress);
    }
    return await createAccountTransaction(token, amount, to);
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createAccountTransaction(String token, int amount, String to) async {
    if (token == DeFiConstants.DefiTokenSymbol) {
      throw new ArgumentError("$token not supported for account transactions...");
    }

    final tokenBalance = await walletDatabase.getAccountBalance(token);

    if (amount > tokenBalance.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    final tokenType = await apiService.tokenService.getToken("DFI", token);
    final key = mnemonicToSeed(seed);

    final accounts = await walletDatabase.getAccountBalancesForToken(token);
    final useAccounts = List<FromAccount>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    final inputTxs = List<tx.Transaction>.empty(growable: true);

    var curAmount = 0;
    for (final tx in accounts) {
      if (tx.address == to) {
        continue;
      }

      final fromAccount = FromAccount(address: tx.address, amount: tx.balance);
      useAccounts.add(fromAccount);

      final addressInfo = await walletDatabase.getWalletAddress(tx.address);

      inputTxs.add(await getAuthInputsSmart(tx.address, fee));

      final keyPair = HdWalletUtil.getKeyPair(key, addressInfo.account, addressInfo.isChangeAddress, addressInfo.index, addressInfo.chain, addressInfo.network);
      keys.add(keyPair);

      if ((curAmount + tx.balance) >= amount) {
        fromAccount.amount = amount;
        break;
      } else {
        fromAccount.amount = tx.balance - curAmount;
      }
      curAmount += tx.balance;
    }

    final changeAddress = await getPublicKeyFromAccount(account, true);
    final txb = await HdWalletUtil.buildAccountToAccountTransaction(inputTxs, useAccounts, keys, tokenType.id, to, amount, fee, changeAddress, chain, network);

    return Tuple3<String, List<tx.Transaction>, String>(txb.build().toHex(), inputTxs, changeAddress);
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createAuthTx(String pubKey, {StreamController<String> loadingStream}) async {
    final changeAddress = await getPublicKeyFromAccount(account, true);
    var baseTx = await createBaseTransaction(200000, pubKey, changeAddress, 0, (txb, inputTxs, nw) {
      txb.addAuthOutput(outputIndex: 0);
    });
    loadingStream?.add(S.current.wallet_operation_create_auth_tx);
    return baseTx;
  }

  Future<tx.Transaction> getAuthInputsSmart(String pubKey, int minFee, {StreamController<String> loadingStream}) async {
    var authTxs = await walletDatabase.getUnspentTransactionsForPubKey(pubKey, minFee);

    if (authTxs.isNotEmpty) {
      return authTxs.first;
    }

    var txHex = await createAuthTx(pubKey, loadingStream: loadingStream);
    var txData = await createTxAndWait(txHex, loadingStream: loadingStream);
    final retOut = txData.details.outputs.firstWhere((element) => element.spentHeight <= 0 && element.address == pubKey);

    return retOut;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> prepareUtxoToAccountTransaction(int amount, {StreamController<String> loadingStream}) async {
    final tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);
    final accBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);

    final accountBalance = accBalance.balance != null ? accBalance.balance : 0;
    final totalBalance = (tokenBalance.balance != null ? tokenBalance.balance : 0) + accountBalance;

    if (amount > totalBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    if (accountBalance > amount) {
      // we already have enough acc balance
      return null;
    }
    loadingStream?.add(S.current.wallet_operation_create_pepare_acc_tx);

    final key = mnemonicToSeed(seed);

    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<ECPair>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    var checkAmount = (amount - accountBalance) + fee;

    var curAmount = 0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      if (!await walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final address = await walletDatabase.getWalletAddress(tx.address);
      final keyPair =
          HdWalletUtil.getKeyPair(key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(tx.chain), ChainHelper.networkFromString(tx.network));

      keys.add(keyPair);

      if (curAmount >= checkAmount) {
        break;
      }
    }
    final changeAddress = await getPublicKeyFromAccount(account, true);

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = await createBaseTransaction(0, changeAddress, changeAddress, fee + checkAmount, (txb, inputTxs, nw) {
      for (var input in useTxs) {
        var needAmount = min(checkAmount, input.value);

        txb.addUtxosToAccountOutput(tokenType.id, input.address, needAmount, nw);

        checkAmount -= needAmount;

        if (checkAmount <= 0) {
          break;
        }
      }
    });
    return txs;
  }

  Future<Tuple3<List<String>, List<tx.Transaction>, int>> prepareAccountToUtxosTransactions(String pubKey, int amount) async {
    var tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError("Token balance must be greater than 0 to create any tx!");
    }
    // we have currently enough utxo
    if (tokenBalance.balance > amount) {
      return null;
    }

    var accountBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance.balance + tokenBalance.balance;

    if (totalBalance < amount) {
      throw new ArgumentError("Balance $totalBalance is less than $amount");
    }

    var neededUtxo = amount - tokenBalance.balance;
    final accounts = await walletDatabase.getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts.length == 0) {
      throw new ArgumentError("No accounts found..");
    }
    final key = mnemonicToSeed(seed);
    final usedInputs = List<tx.Transaction>.empty(growable: true);
    final fees = await getTxFee(0, 0);

    var accBalance = 0;

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = List<String>.empty(growable: true);

    for (final acc in accounts) {
      final useInputs = List<tx.Transaction>.empty(growable: true);
      final keys = List<ECPair>.empty(growable: true);

      final authTx = await getAuthInputsSmart(acc.address, fees);
      useInputs.add(authTx);
      usedInputs.add(authTx);

      walletDatabase.addUnspentTransaction(authTx);
      walletDatabase.setAccountBalance(Account(token: DeFiConstants.DefiTokenSymbol, address: acc.address, balance: acc.balance, chain: acc.chain, network: acc.network));

      if (!await walletDatabase.isOwnAddress(authTx.address)) {
        continue;
      }

      final address = await walletDatabase.getWalletAddress(authTx.address);
      final keyPair = HdWalletUtil.getKeyPair(
          key, address.account, address.isChangeAddress, address.index, ChainHelper.chainFromString(authTx.chain), ChainHelper.networkFromString(authTx.network));

      keys.add(keyPair);
      var useAcc = acc;

      if ((accBalance + acc.balance) >= neededUtxo) {
        var neededAccBalance = min(acc.balance, neededUtxo - accBalance);
        accBalance += neededAccBalance;
        useAcc = Account(address: acc.address, balance: neededAccBalance, chain: acc.chain, network: acc.network, raw: acc.raw, token: acc.token);
      } else {
        useAcc = acc;
        accBalance += acc.balance;
      }

      var txHex = await HdWalletUtil.buildTransaction(useInputs, keys, pubKey, 0, fees, pubKey, (txb, inputTxs, network) async {
        final mintingStartsAt = txb.tx.ins.length + 1;

        txb.addOutput(pubKey, useAcc.balance);
        txb.addAccountToUtxoOutput(tokenType.id, acc.address, useAcc.balance, mintingStartsAt);
      }, chain, network);

      txs.add(txHex);

      if (accBalance > neededUtxo) {
        break;
      }
    }

    if (accBalance < neededUtxo) {
      throw new ArgumentError("should not happen at all now...");
    }

    return Tuple3(txs, usedInputs, fees * txs.length);
  }

  Future<TransactionData> prepareAccount(int amount, {StreamController<String> loadingStream}) async {
    final txHex = await prepareUtxoToAccountTransaction(amount, loadingStream: loadingStream);
    if (txHex != null) {
      var txData = await createTxAndWait(txHex, loadingStream: loadingStream);

      for (var input in txData.details.inputs) {
        if (await walletDatabase.isOwnAddress(input.address)) {
          final accBalance = new Account(
              address: input.address,
              balance: amount,
              token: DeFiConstants.DefiAccountSymbol,
              chain: ChainHelper.chainTypeString(chain),
              network: ChainHelper.chainNetworkString(network));
          await walletDatabase.setAccountBalance(accBalance);
        }
      }

      return txData;
    }
    return null;
  }
}
