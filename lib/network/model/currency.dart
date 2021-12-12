enum CurrencyEnum { USD, EUR, SGD }

class Currency {
  static String getCurrencySymbol(CurrencyEnum currency) {
    switch (currency) {
      case CurrencyEnum.USD:
        return "\$";
      case CurrencyEnum.EUR:
        return "€";
      case CurrencyEnum.SGD:
        return "S\$";
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
    }
    return "USD";
  }

  static String getCurrencyName(CurrencyEnum currency) {
    switch (currency) {
      case CurrencyEnum.USD:
        return "Dollar";
      case CurrencyEnum.EUR:
        return "Euro";
      case CurrencyEnum.SGD:
        return "Singapore Dollar";
    }
    return "Dollar";
  }
}
