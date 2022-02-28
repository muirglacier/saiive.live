enum CurrencyEnum { USD, EUR, SGD, AUD, JPY, GBP, CAD, BTC, ETH }

class Currency {
  static String getCurrencySymbol(CurrencyEnum currency) {
    switch (currency) {
      case CurrencyEnum.USD:
        return "\$";
      case CurrencyEnum.EUR:
        return "€";
      case CurrencyEnum.SGD:
        return "S\$";
      case CurrencyEnum.AUD:
        return "A\$";
      case CurrencyEnum.JPY:
        return "¥";
      case CurrencyEnum.GBP:
        return "£";
      case CurrencyEnum.CAD:
        return "C\$";
      case CurrencyEnum.BTC:
        return "₿";
      case CurrencyEnum.ETH:
        return "Ξ";
    }

    return "UNDEFINED CURRENCY";
  }

  static String getCurrencyShortage(CurrencyEnum currency) {
    switch (currency) {
      case CurrencyEnum.USD:
        return "USD";
      case CurrencyEnum.EUR:
        return "EUR";
      case CurrencyEnum.SGD:
        return "SGD";
      case CurrencyEnum.AUD:
        return "AUD";
      case CurrencyEnum.JPY:
        return "JPY";
      case CurrencyEnum.GBP:
        return "GBP";
      case CurrencyEnum.CAD:
        return "CAD";
      case CurrencyEnum.BTC:
        return "BTC";
      case CurrencyEnum.ETH:
        return "ETH";
    }
    return "USD";
  }

  static String getCurrencyName(CurrencyEnum currency) {
    switch (currency) {
      case CurrencyEnum.USD:
        return "US Dollar";
      case CurrencyEnum.EUR:
        return "Euro";
      case CurrencyEnum.SGD:
        return "Singapore Dollar";
      case CurrencyEnum.AUD:
        return "Australian Dollar";
      case CurrencyEnum.JPY:
        return "Japanese Yen";
      case CurrencyEnum.GBP:
        return "British Pound";
      case CurrencyEnum.CAD:
        return "Canadian Dollar";
      case CurrencyEnum.BTC:
        return "Bitcoin";
      case CurrencyEnum.ETH:
        return "Ethereum";
    }
    return "US Dollar";
  }
}
