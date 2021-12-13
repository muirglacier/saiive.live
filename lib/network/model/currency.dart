enum CurrencyEnum { USD, EUR, SGD, AUD, JPY, GBP }

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
    }
    return "US Dollar";
  }
}
