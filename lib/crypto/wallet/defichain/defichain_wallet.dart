import 'dart:async';
import 'dart:math';

import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/from_account.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/errors/ReadOnlyAccountError.dart';
import 'package:saiive.live/crypto/model/wallet_account.dart';
import 'package:saiive.live/crypto/model/wallet_address.dart';
import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet_helper.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/balance.dart';
import 'package:saiive.live/network/model/account.dart';
import 'package:saiive.live/network/model/token.dart';
import 'package:saiive.live/network/model/transaction_data.dart';
import 'package:tuple/tuple.dart';
import '../address_type.dart';
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

  static const int AuthTxMin = 200000;
  static const int MinKeepUTXO = 2000000;

  @override
  Future<TransactionData> createAndSendRemovePoolLiquidity(int token, int amount, String shareAddress, {String returnAddress, StreamController<String> loadingStream}) async {
    await walletMutex.acquire();

    try {
      var removeLiq = await removePoolLiquidity(token, amount, shareAddress, returnAddress: returnAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWait(removeLiq, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  @override
  Future<TransactionData> createAndSendAddPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress,
      {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      var addLiq = await addPoolLiquidity(tokenA, amountA, tokenB, amountB, shareAddress, returnAddress: returnAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWaitInternal(addLiq, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> removePoolLiquidity(int token, int amount, String shareAddress,
      {String returnAddress, StreamController<String> loadingStream}) async {
    var fees = await getTxFee(0, 0);
    await prepareAccount(shareAddress, fees, loadingStream: loadingStream);

    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    var tx = await getAuthInputsSmart(shareAddress, AuthTxMin, fees, loadingStream: loadingStream);

    final txb = await createBaseTransaction(0, shareAddress, changeAddress, fees, (txb, inputTxs, nw) async {
      txb.addRemoveLiquidityOutput(token, amount, shareAddress);

      final addressInfo = await walletDatabase.getWalletAddress(tx.address);
      final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);

      if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
        throw new ReadOnlyAccountError();
      }
      var keyPair = await getPrivateKey(addressInfo, walletAccount);

      final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
      if (inputContainsAuthTx.isEmpty) {
        var chainNetwork = HdWalletUtil.getNetworkType(chain, network);

        var vin = HdWalletUtil.addInput(txb, keyPair, tx, addressInfo, chainNetwork);

        if (tx.value > 0) {
          txb.addOutput(tx.address, tx.value);
        }

        final witnessValue = tx.valueRaw;
        HdWalletUtil.signInput(txb, keyPair, addressInfo, vin, witnessValue);
      }
    });

    return txb;
  }

  Future<String> addPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress,
      {String returnAddress, StreamController<String> loadingStream}) async {
    final useAmount = await prepareAccount(shareAddress, DeFiConstants.isDfiToken(tokenA) ? amountA : amountB, loadingStream: loadingStream);

    if (DeFiConstants.isDfiToken(tokenA)) {
      amountA = useAmount.item1;
    } else {
      amountB = useAmount.item1;
    }
    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
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

    final accountsA = await walletDatabase.getAccountBalancesForToken(tokenA);
    final accountsB = await walletDatabase.getAccountBalancesForToken(tokenB);

    final fee = await getTxFee(0, 0);

    final accountA = await DefichainWalletHelper.getHighestAmountAddressForSymbol(accountsA, amountA);
    final accountB = await DefichainWalletHelper.getHighestAmountAddressForSymbol(accountsB, amountB);

    if (amountA > accountA.balance) {
      //handle account to account - move account balance to make sure we have enough balance
      await createAccountTransaction(tokenA, amountA - accountA.balance, accountA.address, loadingStream: loadingStream);
    }

    if (amountB > accountB.balance || accountA.address != accountB.address) {
      //handle account to account - move account balance to make sure we have enough balance
      await createAccountTransaction(tokenB, amountB, accountA.address, loadingStream: loadingStream);
    }

    final authInputA = await getAuthInputsSmart(accountA.address, AuthTxMin, 0, loadingStream: loadingStream);

    var inputTxs = List<tx.Transaction>.empty(growable: true);
    inputTxs.add(authInputA);

    final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

    for (final tx in inputTxs) {
      final address = await walletDatabase.getWalletAddress(tx.address);
      final walletAccount = await walletDatabase.getAccount(address.accountId);

      if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
        continue;
      }

      final key = await getPrivateKey(address, walletAccount);
      keys.add(Tuple2(address, key));
    }

    final txb = await HdWalletUtil.buildTransaction(inputTxs, keys, shareAddress, authInputA.value, fee, changeAddress, (txb, txIn, nw) {
      txb.addAddLiquidityOutputSingleAddress(accountA.address, tokenAType.id, amountA, tokenBType.id, amountB, shareAddress);
    }, chain, network);

    return txb;
  }

  Future<TransactionData> createAndSendSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {String returnAddress, StreamController<String> loadingStream}) async {
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
      {String returnAddress, StreamController<String> loadingStream}) async {
    if (DeFiConstants.isDfiToken(fromToken)) {
      var prep = await prepareAccount(to, fromAmount, loadingStream: loadingStream);
      fromAmount = prep.item1;
    }

    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    final fees = await getTxFee(1, 2) + 5000;

    final fromTokenBalance = await walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new ArgumentError("Insufficient balance...");
    }

    final fromTok = await apiService.tokenService.getToken("DFI", fromToken);
    final toTok = await apiService.tokenService.getToken("DFI", toToken);
    final fromAccounts = await walletDatabase.getAccountBalancesForToken(fromToken);
    final fromAccount = await DefichainWalletHelper.getHighestAmountAddressForSymbol(fromAccounts, fromAmount);

    final tokenBalance = await walletDatabase.getAccountBalance(fromToken, excludeAddresses: [fromAccount.address]);

    if (tokenBalance.balance < (fromAmount - fromAccount.balance)) {
      loadingStream?.add(S.current.wallet_operation_send_tx);
    }

    if (fromAmount > fromAccount.balance) {
      await createAccountTransaction(fromToken, fromAmount - fromAccount.balance, fromAccount.address, excludeAddresses: [fromAccount.address], loadingStream: loadingStream);
    }
    await getAuthInputsSmart(fromAccount.address, AuthTxMin, fees, loadingStream: loadingStream);

    final txb = await createBaseTransaction(0, to, changeAddress, fees, (txb, inputTxs, nw) async {
      var tx = await getAuthInputsSmart(fromAccount.address, AuthTxMin, fees, loadingStream: loadingStream);

      txb.addSwapOutput(fromTok.id, fromAccount.address, fromAmount, toTok.id, to, maxPrice, maxPriceFraction);

      final inputContainsAuthTx = inputTxs.where((element) => element.mintTxId == tx.mintTxId && element.mintIndex == tx.mintIndex);
      if (inputContainsAuthTx.isEmpty) {
        final addressInfo = await walletDatabase.getWalletAddress(tx.address);
        final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);

        if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
          throw new ReadOnlyAccountError();
        }
        var keyPair = await getPrivateKey(addressInfo, walletAccount);
        var chainNetwork = HdWalletUtil.getNetworkType(chain, network);

        var vin = HdWalletUtil.addInput(txb, keyPair, tx, addressInfo, chainNetwork);

        if (tx.value > 0) {
          txb.addOutput(tx.address, tx.value);
        }

        final witnessValue = tx.valueRaw;
        HdWalletUtil.signInput(txb, keyPair, addressInfo, vin, witnessValue);
      }
    });
    return txb;
  }

  @override
  Future<String> createSendTransaction(int amount, String token, String to, {String returnAddress, StreamController<String> loadingStream, bool sendMax = false}) async {
    final changeAddress = returnAddress ?? await this.getPublicKey(true, AddressType.P2SHSegwit);

    if (DeFiConstants.isDfiToken(token)) {
      var needsToRefresh = false;
      if (sendMax) {
        await moveAllTokensToUtxo(changeAddress);
      } else {
        var txHex = await prepareAccountToUtxosTransactions(changeAddress, amount, sendMax: sendMax, loadingStream: loadingStream);

        if (txHex != null) {
          needsToRefresh = true;
          for (var txHexStr in txHex.item1) {
            final tx = await createTxAndWaitInternal(txHexStr, loadingStream: loadingStream);

            for (final unspentTx in tx.details.outputs) {
              if (unspentTx.address == changeAddress) {
                var address = await walletDatabase.getWalletAddress(unspentTx.address);
                var walletAccount = await walletDatabase.getAccount(address.accountId);
                await walletDatabase.addUnspentTransaction(unspentTx, walletAccount);
              }
            }
          }
          await walletDatabase.removeUnspentTransactions(txHex.item2);
          amount -= txHex.item3;
        }
      }

      if (sendMax) {
        if (needsToRefresh) {
          await ensureUtxoUnsafe(loadingStream: loadingStream);
        }
        amount = (await BalanceHelper().getAccountBalance(token, chain)).balance;
      }

      return await createUtxoTransaction(amount, to, changeAddress, sendMax: sendMax, loadingStream: loadingStream);
    }
    return await createAccountTransaction(token, amount, to, loadingStream: loadingStream);
  }

  Future<String> createVault(String schemeId, int vaultCreateFees, {String ownerAddress, StreamController<String> loadingStream}) async {
    var owner = ownerAddress;

    if (owner == null || owner == "") {
      owner = await getPublicKey(false, AddressType.P2SHSegwit);
    }

    var fees = await getTxFee(1, 2);
    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

    final address = await walletDatabase.getWalletAddress(owner);
    final walletAccount = await walletDatabase.getAccount(address.accountId);

    var keyPair = await getPrivateKey(address, walletAccount);
    keys.add(Tuple2(address, keyPair));

    final minAmount = vaultCreateFees + fees;

    if (!unspentTxs.any((element) => element.address == owner && element.value >= minAmount)) {
      var inputTx = await createUtxoTransaction(minAmount - fees, owner, owner, loadingStream: loadingStream);
      var tx = await walletDatabase.getUnspentTransactionById(inputTx);
      useTxs.add(tx);
    } else {
      var inputTx = unspentTxs.where((element) => element.address == owner && element.value >= minAmount);
      useTxs.add(inputTx.first);
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, owner, (minAmount - fees) * -1, fees, owner, (txb, inputTxs, nw) {
      txb.addCreateVault(owner, schemeId, vaultCreateFees);
    }, chain, network);

    var txi = await createTxAndWait(Tuple3<String, List<tx.Transaction>, String>(txb, useTxs, ownerAddress), loadingStream: loadingStream);

    loadingStream?.add(S.current.wallet_operation_send_tx);

    return txi.txId;
  }

  Future<String> depositToVault() {}

  Future<String> createAccountTransaction(String token, int amount, String to,
      {bool sendMax = false, List<String> excludeAddresses, StreamController<String> loadingStream}) async {
    if (token == DeFiConstants.DefiTokenSymbol) {
      throw new ArgumentError("$token not supported for account transactions...");
    }
    final tokenBalance = await walletDatabase.getAccountBalance(token, excludeAddresses: excludeAddresses);

    if (amount > tokenBalance.balance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    final tokenType = await apiService.tokenService.getToken("DFI", token);

    final accounts = await walletDatabase.getAccountBalancesForToken(token);
    final useAccounts = List<FromAccount>.empty(growable: true);
    var fee = await getTxFee(0, 0);

    if (sendMax) {
      fee *= -1;
    }

    var curAmount = 0;
    var lastTxId = "";
    for (final txs in accounts) {
      if (txs.address == to) {
        continue;
      }
      final addressInfo = await walletDatabase.getWalletAddress(txs.address);
      final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);

      final changeAddress = await getPublicKey(true, AddressType.P2SHSegwit);
      if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
        continue;
      }
      final inputTxs = List<tx.Transaction>.empty(growable: true);
      final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

      final fromAccount = FromAccount(address: txs.address, amount: txs.balance);
      useAccounts.add(fromAccount);

      var inputTx = await getAuthInputsSmart(txs.address, AuthTxMin, fee, loadingStream: loadingStream);
      inputTxs.add(inputTx);

      var keyPair = await getPrivateKey(addressInfo, walletAccount);
      keys.add(Tuple2(addressInfo, keyPair));

      final txb = await HdWalletUtil.buildTransaction(inputTxs, keys, fromAccount.address, inputTx.valueRaw, fee, changeAddress, (txb, txIn, nw) {
        var useAmount = amount;
        if (fromAccount.amount < useAmount) {
          useAmount = fromAccount.amount;
        }
        txb.addAccountToAccountOutputAt(tokenType.id, fromAccount.address, to, useAmount, 0);
      }, chain, network);

      loadingStream?.add(S.current.wallet_operation_send_tx);
      var txD = await createTxAndWait(Tuple3<String, List<tx.Transaction>, String>(txb, inputTxs, changeAddress), loadingStream: loadingStream);

      lastTxId = txD.txId;

      if ((curAmount + txs.balance) >= amount) {
        break;
      }
      curAmount += txs.balance;
    }

    return lastTxId;
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> createAuthTx(String pubKey, int amount, {StreamController<String> loadingStream, bool sendMax = false}) async {
    final tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance.balance < amount) {
      amount = tokenBalance.balance;
    }
    //
    var baseTx = await createBaseTransaction(amount, pubKey, pubKey, 0, (txb, inputTxs, nw) {
      txb.addAuthOutput(outputIndex: 0);
    }, sendMax: tokenBalance.balance == amount);
    loadingStream?.add(S.current.wallet_operation_create_auth_tx);
    return baseTx;
  }

  Future<tx.Transaction> getAuthInputsSmart(String pubKey, int amount, int minFee, {StreamController<String> loadingStream, bool sendMax = false}) async {
    var authTxs = await walletDatabase.getUnspentTransactionsForPubKey(pubKey, minFee);

    if (authTxs.isNotEmpty) {
      return authTxs.first;
    }

    var txHex = await createAuthTx(pubKey, amount, loadingStream: loadingStream);
    var txData = await createTxAndWait(txHex, loadingStream: loadingStream);
    final retOut = txData.details.outputs.firstWhere((element) => element.spentHeight <= 0 && element.address == pubKey);
    // loadingStream?.add(S.current.wallet_operation_wait_for_confirmation);
    // await Future.delayed(Duration(seconds: 5));
    return retOut;
  }

  Future<Tuple2<int, List<TransactionData>>> prepareUtxoToAccountTransaction(String toAddress, int amount, {StreamController<String> loadingStream, bool force = false}) async {
    final tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);
    final accBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);

    final accountBalance = accBalance.balance != null ? accBalance.balance : 0;
    final totalBalance = (tokenBalance.balance != null ? tokenBalance.balance : 0) + accountBalance;

    if (accountBalance > amount && !force) {
      // we already have enough acc balance
      return Tuple2(amount, List<TransactionData>.empty(growable: false));
    }

    if (totalBalance == amount) {
      amount -= MinKeepUTXO;
    }

    if (amount > totalBalance) {
      throw ArgumentError("Insufficent funds"); //insufficent funds
    }

    loadingStream?.add(S.current.wallet_operation_create_pepare_acc_tx);

    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final fee = await getTxFee(0, 0);

    var checkAmount = (amount - accountBalance) + fee;

    if (force) {
      checkAmount = amount + fee;
    }

    var curAmount = 0;
    for (final tx in unspentTxs) {
      useTxs.add(tx);
      curAmount += tx.valueRaw;

      if (!await walletDatabase.isOwnAddress(tx.address)) {
        continue;
      }

      final addressInfo = await walletDatabase.getWalletAddress(tx.address);
      final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);

      if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
        throw new ReadOnlyAccountError();
      }

      if (curAmount >= checkAmount) {
        break;
      }
    }
    final changeAddress = await getPublicKey(true, AddressType.P2SHSegwit);

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    var txData = List<TransactionData>.empty(growable: true);
    for (final input in useTxs) {
      var needAmount = min(checkAmount, input.value);
      var burnFees = needAmount + fee;

      if (fee + needAmount > input.value) {
        needAmount -= fee;
        burnFees = input.value;
      }

      final txs = await createBaseTransaction(0, toAddress, changeAddress, burnFees, (txb, inputTxs, nw) {
        txb.addUtxosToAccountOutput(tokenType.id, input.address, needAmount, nw);

        checkAmount -= needAmount;
      });

      var tx = await createTxAndWait(txs, loadingStream: loadingStream);

      txData.add(tx);

      var existingBalance = await walletDatabase.getAccountBalanceForPubKey(input.address, DeFiConstants.DefiAccountSymbol);

      final uaccBalance = new Account(
          address: input.address,
          balance: needAmount + (existingBalance == null ? 0 : existingBalance.balance),
          token: DeFiConstants.DefiAccountSymbol,
          chain: ChainHelper.chainTypeString(chain),
          network: ChainHelper.chainNetworkString(network));
      final addressInfo = await walletDatabase.getWalletAddress(input.address);
      final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);

      await walletDatabase.setAccountBalance(uaccBalance, walletAccount);
      if (checkAmount <= 0) {
        break;
      }
    }
    return Tuple2(amount, txData);
  }

  Future moveAllTokensToUtxo(String pubKey) async {
    var tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError("Token balance must be greater than 0 to create any tx!");
    }

    final accounts = await walletDatabase.getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts == null) {
      return;
    }

    final fees = await getTxFee(0, 0);

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);

    for (final account in accounts) {
      var txData = await prepareAccountToUtxo(pubKey, tokenType, account, fees);

      var createTx = Tuple3<String, List<tx.Transaction>, String>(txData.item1, txData.item2, "");
      await createTxAndWait(createTx);
    }
  }

  Future<Tuple2<String, List<tx.Transaction>>> prepareAccountToUtxo(String pubKey, Token tokenType, Account account, int fees) async {
    final useInputs = List<tx.Transaction>.empty(growable: true);
    final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

    final authTx = await getAuthInputsSmart(account.address, AuthTxMin, fees, sendMax: true);
    useInputs.add(authTx);

    if (!await walletDatabase.isOwnAddress(authTx.address)) {
      return null;
    }

    final addressInfo = await walletDatabase.getWalletAddress(authTx.address);
    final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);
    walletDatabase.addUnspentTransaction(authTx, walletAccount);

    if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
      throw new ReadOnlyAccountError();
    }
    var keyPair = await getPrivateKey(addressInfo, walletAccount);

    keys.add(Tuple2(addressInfo, keyPair));

    var txHex = await HdWalletUtil.buildTransaction(useInputs, keys, pubKey, 0, fees, pubKey, (txb, inputTxs, network) async {
      final mintingStartsAt = txb.tx.ins.length + 1;

      if (account.balance > 0) {
        txb.addOutput(pubKey, account.balance);
      }
      txb.addAccountToUtxoOutput(tokenType.id, account.address, account.balance, mintingStartsAt);
    }, chain, network);

    return Tuple2<String, List<tx.Transaction>>(txHex, useInputs);
  }

  Future<Tuple3<List<String>, List<tx.Transaction>, int>> prepareAccountToUtxosTransactions(String pubKey, int amount,
      {bool sendMax = false, StreamController<String> loadingStream, bool force = false}) async {
    var tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new ArgumentError("Token balance must be greater than 0 to create any tx!");
    }

    // we have currently enough utxo
    if (tokenBalance.balance > amount && !force) {
      return null;
    }

    var accountBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance.balance + tokenBalance.balance;

    if (totalBalance < amount) {
      throw new ArgumentError("Balance $totalBalance is less than $amount");
    }

    var neededUtxo = amount - tokenBalance.balance;

    if (neededUtxo < MinKeepUTXO) {
      neededUtxo = MinKeepUTXO;

      if (neededUtxo > accountBalance.balance) {
        neededUtxo = accountBalance.balance;
      }
    }

    if (force) {
      neededUtxo = amount;
    }

    final accounts = await walletDatabase.getAccountBalancesForToken(DeFiConstants.DefiAccountSymbol);

    if (accounts.length == 0) {
      throw new ArgumentError("No accounts found..");
    }
    final usedInputs = List<tx.Transaction>.empty(growable: true);
    final fees = await getTxFee(0, 0);

    var accBalance = 0;

    final tokenType = await apiService.tokenService.getToken("DFI", DeFiConstants.DefiAccountSymbol);
    final txs = List<String>.empty(growable: true);

    for (final acc in accounts) {
      final useInputs = List<tx.Transaction>.empty(growable: true);
      final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

      final authTx = await getAuthInputsSmart(acc.address, AuthTxMin, fees, loadingStream: loadingStream);
      useInputs.add(authTx);
      usedInputs.add(authTx);

      if (!await walletDatabase.isOwnAddress(authTx.address)) {
        continue;
      }

      final addressInfo = await walletDatabase.getWalletAddress(authTx.address);
      final walletAccount = await walletDatabase.getAccount(addressInfo.accountId);
      walletDatabase.addUnspentTransaction(authTx, walletAccount);
      walletDatabase.setAccountBalance(
          Account(token: DeFiConstants.DefiTokenSymbol, address: acc.address, balance: acc.balance, chain: acc.chain, network: acc.network), walletAccount);

      if (walletAccount.walletAccountType == WalletAccountType.PublicKey) {
        continue;
      }
      var keyPair = await getPrivateKey(addressInfo, walletAccount);

      keys.add(Tuple2(addressInfo, keyPair));
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

        if (useAcc.balance > 0) {
          txb.addOutput(pubKey, useAcc.balance);
          txb.addAccountToUtxoOutput(tokenType.id, acc.address, useAcc.balance, mintingStartsAt);
        }
      }, chain, network);

      txs.add(txHex);

      if (accBalance >= neededUtxo) {
        break;
      }
    }

    if (accBalance < neededUtxo) {
      throw new ArgumentError("should not happen at all now...");
    }

    return Tuple3(txs, usedInputs, fees * txs.length);
  }

  Future<Tuple2<int, List<TransactionData>>> prepareAccount(String toAddress, int amount, {StreamController<String> loadingStream, bool force = false}) async {
    return await prepareUtxoToAccountTransaction(toAddress, amount, loadingStream: loadingStream, force: force);
  }

  @override
  Future<bool> refreshBefore() {
    return Future.value(true);
  }
}
