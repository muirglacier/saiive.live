import 'package:saiive.live/network/model/loan_vault_price.dart';
import 'package:saiive.live/network/model/loan_vault_price_block.dart';

class LoanVaultActivePrice {
  final String id;
  final String key;
  final bool isLive;
  final String sort;
  final LoanVaultPrice active;
  final LoanVaultPrice next;
  final LoanVaultPriceBlock block;

  LoanVaultActivePrice(
      {this.id,
      this.key,
      this.isLive,
      this.sort,
      this.active,
      this.next,
      this.block});

  factory LoanVaultActivePrice.fromJson(Map<String, dynamic> json) {
    return LoanVaultActivePrice(
      id: json['id'],
      key: json['key'],
      isLive: json['isLive'],
      sort: json['sort'],
      active: LoanVaultPrice.fromJson(json['active']),
      next: LoanVaultPrice.fromJson(json['next']),
      block: LoanVaultPriceBlock.fromJson(json['block']),
    );
  }
}
