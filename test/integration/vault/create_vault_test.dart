import 'package:saiive.live/crypto/wallet/defichain/defichain_wallet.dart';
import 'package:saiive.live/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'integration_test_base.dart';

void main() async {
  await testSetupIntegration(
      "sample visa rain lab truly dwarf hospital uphold stereo ride combine arrest aspect exist oil just boy garment estate enable marriage coyote blue yellow");

  group("#1 integration vault", () {
    String vaultId;
    test("#0 init", () async {
      await baseInit();
    });
    test("#1 create vault", () async {
      final wallet = sl.get<DeFiChainWallet>();

      vaultId = await wallet.createVault("C1000", 100000000, ownerAddress: "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv");
    }, timeout: Timeout(Duration(minutes: 10)));

    test("#1 deposit to vault", () async {
      final wallet = sl.get<DeFiChainWallet>();

      await wallet.depositToVault(vaultId, "tXmZ6X4xvZdUdXVhUKJbzkcN2MNuwVSEWv", "DFI", 10 * 100000000);
    }, timeout: Timeout(Duration(minutes: 10)));

    test("#99 destroy", () async {
      await destoryTest();
    });
  });
}
