import 'constants.dart';

class CurrencyConverter {
  static final Map<String, double> _exchangeRates = AppConstants.exchangeRates;
  
  static double convertFromIDR(double amount, String toCurrency) {
    if (_exchangeRates.containsKey(toCurrency.toUpperCase())) {
      return amount * _exchangeRates[toCurrency.toUpperCase()]!;
    }
    return amount;
  }
  
  static double convertToIDR(double amount, String fromCurrency) {
    if (_exchangeRates.containsKey(fromCurrency.toUpperCase())) {
      return amount / _exchangeRates[fromCurrency.toUpperCase()]!;
    }
    return amount;
  }
  
  static String formatCurrency(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}';
      case 'SGD':
        return 'S\$${amount.toStringAsFixed(2)}';
      case 'MYR':
        return 'RM${amount.toStringAsFixed(2)}';
      case 'IDR':
      default:
        return 'Rp ${amount.toStringAsFixed(0)}';
    }
  }
  
  static List<String> getSupportedCurrencies() {
    return ['IDR', ..._exchangeRates.keys.toList()];
  }
  
  static Map<String, double> convertAllFromIDR(double idrAmount) {
    Map<String, double> results = {'IDR': idrAmount};
    
    _exchangeRates.forEach((currency, rate) {
      results[currency] = idrAmount * rate;
    });
    
    return results;
  }
  
  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'JPY':
        return '¥';
      case 'SGD':
        return 'S\$';
      case 'MYR':
        return 'RM';
      case 'IDR':
      default:
        return 'Rp';
    }
  }
  
  static String getCurrencyName(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'JPY':
        return 'Japanese Yen';
      case 'SGD':
        return 'Singapore Dollar';
      case 'MYR':
        return 'Malaysian Ringgit';
      case 'IDR':
      default:
        return 'Indonesian Rupiah';
    }
  }
}
