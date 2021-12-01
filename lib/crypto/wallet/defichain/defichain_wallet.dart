import 'dart:async';
import 'dart:math';

import 'package:defichaindart/defichaindart.dart';
import 'package:saiive.live/crypto/chain.dart';
import 'package:saiive.live/crypto/crypto/from_account.dart';
import 'package:saiive.live/crypto/crypto/hd_wallet_util.dart';
import 'package:saiive.live/crypto/errors/InsufficientBalanceError.dart';
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
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      var removeLiq = await _removePoolLiquidity(token, amount, shareAddress, returnAddress: returnAddress, loadingStream: loadingStream);
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
      var addLiq = await _addPoolLiquidity(tokenA, amountA, tokenB, amountB, shareAddress, returnAddress: returnAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      return await createTxAndWaitInternal(addLiq, onlyConfirmed: true, loadingStream: loadingStream);
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _removePoolLiquidity(int token, int amount, String shareAddress,
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

        if (tx.value > 0 && tx.value > DUST_AMOUNT) {
          txb.addOutput(tx.address, tx.value);
        }

        final witnessValue = tx.valueRaw;
        HdWalletUtil.signInput(txb, keyPair, addressInfo, vin, witnessValue);
      }
    });

    return txb;
  }

  Future<String> _addPoolLiquidity(String tokenA, int amountA, String tokenB, int amountB, String shareAddress,
      {String returnAddress, StreamController<String> loadingStream}) async {
    final useAmount = await prepareAccount(shareAddress, DeFiConstants.isDfiToken(tokenA) ? amountA : amountB, loadingStream: loadingStream);

    final tokenABalance = await walletDatabase.getAccountBalance(tokenA);
    final tokenBBalance = await walletDatabase.getAccountBalance(tokenB);

    if (tokenABalance.balance < amountA) {
      throw new InsufficientBalanceError("${tokenABalance.balance} is less than $amountA", "");
    }

    if (tokenBBalance.balance < amountB) {
      throw new InsufficientBalanceError("${tokenBBalance.balance} is less than $amountB", "");
    }

    if (DeFiConstants.isDfiToken(tokenA)) {
      amountA = useAmount.item1;
    } else {
      amountB = useAmount.item1;
    }
    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    await checkIfWeCanSpendTheChangeAddress(changeAddress);

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
      var swap = await _createSwap(fromToken, fromAmount, toToken, to, maxPrice, maxPriceFraction, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, onlyConfirmed: true, loadingStream: loadingStream);

      return tx;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _createSwap(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction,
      {String returnAddress, StreamController<String> loadingStream}) async {
    final fromTokenBalance = await walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new InsufficientBalanceError("${fromTokenBalance.balance} is less than $fromAmount", "");
    }

    if (DeFiConstants.isDfiToken(fromToken)) {
      var prep = await prepareAccount(to, fromAmount, loadingStream: loadingStream);
      fromAmount = prep.item1;
    }

    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    final fees = await getTxFee(1, 2) + 5000;

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

        if (tx.value > 0 && tx.value > DUST_AMOUNT) {
          txb.addOutput(tx.address, tx.value);
        }

        final witnessValue = tx.valueRaw;
        HdWalletUtil.signInput(txb, keyPair, addressInfo, vin, witnessValue);
      }
    });
    return txb;
  }

  Future<TransactionData> createAndSendSwapV2(String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction, List<int> poolIds,
      {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_create_swap_tx);
      var swap = await _createSwapV2(fromToken, fromAmount, toToken, to, maxPrice, maxPriceFraction, poolIds, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, onlyConfirmed: true, loadingStream: loadingStream);

      return tx;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _createSwapV2(
      String fromToken, int fromAmount, String toToken, String to, int maxPrice, int maxPriceFraction, List<int> poolIds,
      {String returnAddress, StreamController<String> loadingStream}) async {
    if (DeFiConstants.isDfiToken(fromToken)) {
      var prep = await prepareAccount(to, fromAmount, loadingStream: loadingStream);
      fromAmount = prep.item1;
    }

    final fromTokenBalance = await walletDatabase.getAccountBalance(fromToken);

    if (fromTokenBalance.balance < fromAmount) {
      throw new InsufficientBalanceError("${fromTokenBalance.balance} is less than $fromAmount", "");
    }

    if (DeFiConstants.isDfiToken(fromToken)) {
      var prep = await prepareAccount(to, fromAmount, loadingStream: loadingStream);
      fromAmount = prep.item1;
    }

    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    final fees = await getTxFee(1, 2) + 5000;

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

      txb.addSwapV2Output(fromTok.id, fromAccount.address, fromAmount, toTok.id, to, maxPrice, maxPriceFraction, poolIds);

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

        if (tx.value > 0 && tx.value > DUST_AMOUNT) {
          txb.addOutput(tx.address, tx.value);
        }

        final witnessValue = tx.valueRaw;
        HdWalletUtil.signInput(txb, keyPair, addressInfo, vin, witnessValue);
      }
    });
    return txb;
  }

  @override
  Future<String> createSendTransaction(int amount, String token, String to,
      {bool waitForConfirmation, String returnAddress, StreamController<String> loadingStream, bool sendMax = false}) async {
    final changeAddress = returnAddress ?? await this.getPublicKey(true, AddressType.P2SHSegwit);

    if (DeFiConstants.isDfiToken(token)) {
      var needsToRefresh = false;
      if (sendMax) {
        await moveAllTokensToUtxo(changeAddress);
      } else {
        var txHex = await prepareAccountToUtxosTransactions(changeAddress, amount, sendMax: sendMax, loadingStream: loadingStream);
        amount -= txHex.item2;
      }

      if (sendMax) {
        if (needsToRefresh) {
          await ensureUtxoUnsafe(loadingStream: loadingStream);
        }
        amount = (await BalanceHelper().getAccountBalance(token, chain)).balance;
      }

      return await createUtxoTransaction(amount, to, changeAddress, waitForConfirmation: waitForConfirmation, sendMax: sendMax, loadingStream: loadingStream);
    }
    return await createAccountTransaction(token, amount, to, waitForConfirmation: waitForConfirmation, loadingStream: loadingStream);
  }

  Future<String> updateVault(String vaultId, String schemeId, String ownerAddress, {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var action = await _updateVault(vaultId, schemeId, ownerAddress, returnAddress: returnAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(action, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _updateVault(String vaultId, String schemeId, String ownerAddress,
      {String returnAddress, StreamController<String> loadingStream}) async {
    var fees = await getTxFee(1, 2);
    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

    final address = await walletDatabase.getWalletAddress(ownerAddress);
    final walletAccount = await walletDatabase.getAccount(address.accountId);
    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    await checkIfWeCanSpendTheChangeAddress(changeAddress);

    var keyPair = await getPrivateKey(address, walletAccount);
    keys.add(Tuple2(address, keyPair));

    if (!unspentTxs.any((element) => element.address == ownerAddress)) {
      var inputTx = await createUtxoTransaction(fees, ownerAddress, ownerAddress, loadingStream: loadingStream);
      var tx = await walletDatabase.getUnspentTransactionByTxId(inputTx);
      useTxs.add(tx);
    } else {
      var inputTx = unspentTxs.where((element) => element.address == ownerAddress);
      useTxs.add(inputTx.first);
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, ownerAddress, 0, fees, changeAddress, (txb, inputTxs, nw) {
      txb.addUpdateVault(vaultId, ownerAddress, schemeId);
    }, chain, network);

    return Tuple3<String, List<tx.Transaction>, String>(txb, useTxs, ownerAddress);
  }

  Future<String> closeVault(String vaultId, String ownerAddress, {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var action = await _closeVault(vaultId, ownerAddress, returnAddress: returnAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(action, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _closeVault(String vaultId, String ownerAddress, {String returnAddress, StreamController<String> loadingStream}) async {
    var fees = await getTxFee(1, 2);
    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

    final address = await walletDatabase.getWalletAddress(ownerAddress);
    final walletAccount = await walletDatabase.getAccount(address.accountId);
    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    await checkIfWeCanSpendTheChangeAddress(changeAddress);

    var keyPair = await getPrivateKey(address, walletAccount);
    keys.add(Tuple2(address, keyPair));

    if (!unspentTxs.any((element) => element.address == ownerAddress)) {
      var inputTx = await createUtxoTransaction(fees, ownerAddress, ownerAddress, loadingStream: loadingStream);
      var tx = await walletDatabase.getUnspentTransactionByTxId(inputTx);
      useTxs.add(tx);
    } else {
      var inputTx = unspentTxs.where((element) => element.address == ownerAddress);
      useTxs.add(inputTx.first);
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, ownerAddress, 0, fees, changeAddress, (txb, inputTxs, nw) {
      txb.addCloseVault(vaultId, ownerAddress);
    }, chain, network);

    return Tuple3<String, List<tx.Transaction>, String>(txb, useTxs, ownerAddress);
  }

  Future<String> createVault(String schemeId, int vaultCreateFees, {String ownerAddress, String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var action = await _createVault(schemeId, vaultCreateFees, ownerAddress: ownerAddress, returnAddress: returnAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(action, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _createVault(String schemeId, int vaultCreateFees,
      {String ownerAddress, String returnAddress, StreamController<String> loadingStream}) async {
    var owner = ownerAddress;

    if (owner == null || owner == "") {
      owner = await getPublicKey(false, AddressType.P2SHSegwit);
    }

    final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
    await checkIfWeCanSpendTheChangeAddress(changeAddress);

    var fees = await getTxFee(1, 2);
    final minAmount = vaultCreateFees + fees;

    await prepareAccountToUtxosTransactions(owner, minAmount, loadingStream: loadingStream);

    final unspentTxs = await walletDatabase.getUnspentTransactions();
    final useTxs = List<tx.Transaction>.empty(growable: true);
    final keys = List<Tuple2<WalletAddress, ECPair>>.empty(growable: true);

    final address = await walletDatabase.getWalletAddress(owner);
    final walletAccount = await walletDatabase.getAccount(address.accountId);

    var keyPair = await getPrivateKey(address, walletAccount);
    keys.add(Tuple2(address, keyPair));

    if (!unspentTxs.any((element) => element.address == owner && element.value >= minAmount)) {
      var inputTx = await createUtxoTransaction(minAmount - fees, owner, owner, loadingStream: loadingStream);
      var tx = await walletDatabase.getUnspentTransactionByTxId(inputTx);
      useTxs.add(tx);
    } else {
      var inputTx = unspentTxs.where((element) => element.address == owner && element.value >= minAmount);
      useTxs.add(inputTx.first);
    }

    final txb = await HdWalletUtil.buildTransaction(useTxs, keys, owner, (minAmount - fees) * -1, fees, changeAddress, (txb, inputTxs, nw) {
      txb.addCreateVault(owner, schemeId, vaultCreateFees);
    }, chain, network);

    return Tuple3<String, List<tx.Transaction>, String>(txb, useTxs, ownerAddress);
  }

  Future<String> borrowLoan(String vaultId, String to, String token, int amount, {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);

      loadingStream?.add(S.current.wallet_operation_build_tx);
      var swap = await _borrowLoan(vaultId, to, token, amount, changeAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _borrowLoan(String vaultId, String to, String token, int amount, String returnAddress,
      {StreamController<String> loadingStream}) async {
    final fees = await getTxFee(1, 2) + 5000;

    final fromTok = await apiService.tokenService.getToken("DFI", token);
    final tokenBalance = await walletDatabase.getAccountBalanceForPubKey(to, token);

    if (tokenBalance != null && tokenBalance.balance < (amount)) {
      loadingStream?.add(S.current.wallet_operation_send_tx);
    }

    var txAuth = await getAuthInputsSmart(to, AuthTxMin, fees, loadingStream: loadingStream);

    final txb = await createBaseTransaction(0, to, returnAddress, fees, (txb, inputTxs, nw) async {
      var toSign = List<Tuple4<ECPair, WalletAddress, int, int>>.empty(growable: true);

      Future addAuthInput(tx.Transaction tx) async {
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

          if (tx.value > 0 && tx.value > DUST_AMOUNT) {
            txb.addOutput(tx.address, tx.value);
          }

          final witnessValue = tx.valueRaw;
          toSign.add(Tuple4(keyPair, addressInfo, vin, witnessValue));
        }
      }

      await addAuthInput(txAuth);

      txb.addTakeLoan(vaultId, to, fromTok.id, amount);

      for (var sign in toSign) {
        HdWalletUtil.signInput(txb, sign.item1, sign.item2, sign.item3, sign.item4);
      }
    });
    return txb;
  }

  Future<String> paybackLoan(String vaultId, String to, String token, int amount, {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var swap = await _paybackLoan(vaultId, to, token, amount, changeAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _paybackLoan(String vaultId, String to, String token, int amount, String returnAddress,
      {StreamController<String> loadingStream}) async {
    final fees = await getTxFee(1, 2) + 5000;

    final fromTok = await apiService.tokenService.getToken("DFI", token);
    final tokenBalance = await walletDatabase.getAccountBalanceForPubKey(to, token);
    final totalBalance = await walletDatabase.getAccountBalance(token);

    if (amount > totalBalance.balance) {
      throw new InsufficientBalanceError("${totalBalance.balance} is less than $amount", "");
    }

    if (tokenBalance == null || tokenBalance.balance < amount) {
      var transferBalance = amount;
      if (tokenBalance != null) {
        transferBalance -= tokenBalance.balance;
      }
      await createAccountTransaction(token, transferBalance, to);
    }

    if (tokenBalance != null && tokenBalance.balance < (amount)) {
      loadingStream?.add(S.current.wallet_operation_send_tx);
    }
    var txAuth = await getAuthInputsSmart(to, AuthTxMin, fees, loadingStream: loadingStream);

    final txb = await createBaseTransaction(0, to, returnAddress, fees, (txb, inputTxs, nw) async {
      var toSign = List<Tuple4<ECPair, WalletAddress, int, int>>.empty(growable: true);

      Future addAuthInput(tx.Transaction tx) async {
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

          if (tx.value > 0 && tx.value > DUST_AMOUNT) {
            txb.addOutput(tx.address, tx.value);
          }

          final witnessValue = tx.valueRaw;
          toSign.add(Tuple4(keyPair, addressInfo, vin, witnessValue));
        }
      }

      await addAuthInput(txAuth);

      txb.addPaybackLoan(vaultId, to, fromTok.id, amount);

      for (var sign in toSign) {
        HdWalletUtil.signInput(txb, sign.item1, sign.item2, sign.item3, sign.item4);
      }
    });
    return txb;
  }

  Future<String> withdrawFromVault(String vaultId, String to, String token, int amount, {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      if (to == null || to.isEmpty) {
        to = await getPublicKey(false, AddressType.P2SHSegwit);
      }

      final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var swap = await _withdrawFromVault(vaultId, to, token, amount, changeAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _withdrawFromVault(String vaultId, String to, String token, int amount, String returnAddress,
      {StreamController<String> loadingStream}) async {
    final fees = await getTxFee(1, 2) + 5000;

    final fromTok = await apiService.tokenService.getToken("DFI", token);
    final tokenBalance = await walletDatabase.getAccountBalanceForPubKey(to, token);

    if (tokenBalance != null && tokenBalance.balance < (amount)) {
      loadingStream?.add(S.current.wallet_operation_send_tx);
    }
    var txAuth = await getAuthInputsSmart(to, AuthTxMin, fees, loadingStream: loadingStream);
    final txb = await createBaseTransaction(0, to, returnAddress, fees, (txb, inputTxs, nw) async {
      var toSign = List<Tuple4<ECPair, WalletAddress, int, int>>.empty(growable: true);

      Future addAuthInput(tx.Transaction tx) async {
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

          if (tx.value > 0 && tx.value > DUST_AMOUNT) {
            txb.addOutput(tx.address, tx.value);
          }

          final witnessValue = tx.valueRaw;
          toSign.add(Tuple4(keyPair, addressInfo, vin, witnessValue));
        }
      }

      await addAuthInput(txAuth);

      txb.addWithdrawToVault(vaultId, to, fromTok.id, amount);

      for (var sign in toSign) {
        HdWalletUtil.signInput(txb, sign.item1, sign.item2, sign.item3, sign.item4);
      }
    });
    return txb;
  }

  Future<String> depositToVault(String vaultId, String from, String token, int amount, {String returnAddress, StreamController<String> loadingStream}) async {
    await ensureUtxo(loadingStream: loadingStream);
    await walletMutex.acquire();

    try {
      if (from == null || from.isEmpty) {
        from = await getPublicKey(false, AddressType.P2SHSegwit);
      }

      final changeAddress = returnAddress ?? await getPublicKey(true, AddressType.P2SHSegwit);
      loadingStream?.add(S.current.wallet_operation_build_tx);
      var swap = await _depositToVault(vaultId, from, token, amount, changeAddress, loadingStream: loadingStream);
      loadingStream?.add(S.current.wallet_operation_send_tx);
      var tx = await createTxAndWait(swap, onlyConfirmed: true, loadingStream: loadingStream);

      return tx.txId;
    } finally {
      walletMutex.release();
    }
  }

  Future<Tuple3<String, List<tx.Transaction>, String>> _depositToVault(String vaultId, String from, String token, int amount, String returnAddress,
      {StreamController<String> loadingStream}) async {
    if (DeFiConstants.isDfiToken(token)) {
      var prep = await prepareAccount(from, amount, loadingStream: loadingStream);
      amount = prep.item1;
    }

    final fees = await getTxFee(1, 2) + 5000;

    final fromTokenBalance = await walletDatabase.getAccountBalance(token);

    if (fromTokenBalance.balance < amount) {
      throw new InsufficientBalanceError("${fromTokenBalance.balance} is less than $amount", "");
    }

    final fromTok = await apiService.tokenService.getToken("DFI", token);
    final tokenBalance = await walletDatabase.getAccountBalanceForPubKey(from, token);

    if (tokenBalance != null && tokenBalance.balance < (amount)) {
      loadingStream?.add(S.current.wallet_operation_send_tx);
    }

    if (tokenBalance == null || amount > tokenBalance?.balance) {
      await createAccountTransaction(token, amount, from, loadingStream: loadingStream);
    }

    var txAuth = await getAuthInputsSmart(from, AuthTxMin, fees, loadingStream: loadingStream);
    final txb = await createBaseTransaction(0, from, returnAddress, fees, (txb, inputTxs, nw) async {
      var toSign = List<Tuple4<ECPair, WalletAddress, int, int>>.empty(growable: true);

      Future addAuthInput(tx.Transaction tx) async {
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

          if (tx.value > 0 && tx.value > DUST_AMOUNT) {
            txb.addOutput(tx.address, tx.value);
          }

          final witnessValue = tx.valueRaw;
          toSign.add(Tuple4(keyPair, addressInfo, vin, witnessValue));
        }
      }

      await addAuthInput(txAuth);

      txb.addDepositToVault(vaultId, from, fromTok.id, amount);

      for (var sign in toSign) {
        HdWalletUtil.signInput(txb, sign.item1, sign.item2, sign.item3, sign.item4);
      }
    });
    return txb;
  }

  Future<String> createAccountTransaction(String token, int amount, String to,
      {bool waitForConfirmation, bool sendMax = false, List<String> excludeAddresses, StreamController<String> loadingStream}) async {
    if (token == DeFiConstants.DefiTokenSymbol) {
      throw new ArgumentError("$token not supported for account transactions...");
    }
    final tokenBalance = await walletDatabase.getAccountBalance(token, excludeAddresses: excludeAddresses);

    if (amount > tokenBalance.balance) {
      throw new InsufficientBalanceError("${tokenBalance.balance} is less than $amount", "");
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
      await checkIfWeCanSpendTheChangeAddress(changeAddress);

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
      var txD = await createTxAndWait(Tuple3<String, List<tx.Transaction>, String>(txb, inputTxs, changeAddress), onlyConfirmed: waitForConfirmation, loadingStream: loadingStream);

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

    // if (amount > totalBalance) {
    //   throw ArgumentError("Insufficent funds"); //insufficent funds
    // }

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

  Future<Tuple2<List<tx.Transaction>, int>> prepareAccountToUtxosTransactions(String pubKey, int amount,
      {bool sendMax = false, StreamController<String> loadingStream, bool force = false}) async {
    var tokenBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiTokenSymbol);

    if (tokenBalance == null || tokenBalance.balance == 0) {
      throw new InsufficientBalanceError("Token balance must be greater than 0 to create any tx!", "");
    }

    // we have currently enough utxo
    if (tokenBalance.balance > amount && !force) {
      return null;
    }

    var accountBalance = await walletDatabase.getAccountBalance(DeFiConstants.DefiAccountSymbol);
    var totalBalance = accountBalance.balance + tokenBalance.balance;

    if (totalBalance < amount) {
      throw new InsufficientBalanceError("Balance $totalBalance is less than $amount", "");
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

        if (useAcc.balance > DUST_AMOUNT) {
          txb.addOutput(pubKey, useAcc.balance);
          txb.addAccountToUtxoOutput(tokenType.id, acc.address, useAcc.balance, mintingStartsAt);
        }
      }, chain, network);

      if (txHex != null) {
        final tx = await createTxAndWaitInternal(txHex, loadingStream: loadingStream);

        for (final unspentTx in tx.details.outputs) {
          if (unspentTx.address == pubKey) {
            var address = await walletDatabase.getWalletAddress(unspentTx.address);
            var walletAccount = await walletDatabase.getAccount(address.accountId);
            await walletDatabase.addUnspentTransaction(unspentTx, walletAccount);
          }
        }
        await walletDatabase.removeUnspentTransactions(useInputs);
      }

      if (accBalance >= neededUtxo) {
        break;
      }
    }

    if (accBalance < neededUtxo) {
      throw new ArgumentError("should not happen at all now...");
    }

    return Tuple2(usedInputs, fees * txs.length);
  }

  Future<Tuple2<int, List<TransactionData>>> prepareAccount(String toAddress, int amount, {StreamController<String> loadingStream, bool force = false}) async {
    return await prepareUtxoToAccountTransaction(toAddress, amount, loadingStream: loadingStream, force: force);
  }

  @override
  Future<bool> refreshBefore() {
    return Future.value(true);
  }
}
