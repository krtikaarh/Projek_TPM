class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  double amount = 0;
  TextEditingController _amountController = TextEditingController();
  
  // Mock exchange rates (fixed rates for demo)
  final Map<String, double> exchangeRates = {
    'USD': 0.000067, // 1 IDR = 0.000067 USD
    'EUR': 0.000061, // 1 IDR = 0.000061 EUR
    'JPY': 0.0097,   // 1 IDR = 0.0097 JPY
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Care Cost Calculator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount in IDR (Rupiah)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
                helperText: 'Enter pet care costs in Indonesian Rupiah',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  amount = double.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 24),
            Text(
              'Converted Values',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildCurrencyCard('US Dollar', 'USD', '\$', amount * exchangeRates['USD']!),
            _buildCurrencyCard('Euro', 'EUR', '€', amount * exchangeRates['EUR']!),
            _buildCurrencyCard('Japanese Yen', 'JPY', '¥', amount * exchangeRates['JPY']!),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exchange Rate Info',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'These are fixed demo rates. In a real app, you would fetch current rates from a financial API like CurrencyAPI or ExchangeRate-API.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Useful when buying pet supplies from international stores or traveling abroad with pets.',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(String name, String code, String symbol, double value) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(code[0]),
          backgroundColor: Colors.green[100],
        ),
        title: Text(name),
        subtitle: Text(code),
        trailing: Text(
          '${symbol}${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ),
    );
  }
}
