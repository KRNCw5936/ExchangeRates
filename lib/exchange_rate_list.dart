import 'package:flutter/material.dart';
import 'exchange_rate_service.dart';
import 'exchange_rate.dart';

class ExchangeRateList extends StatefulWidget {
  @override
  _ExchangeRateListState createState() => _ExchangeRateListState();
}

class _ExchangeRateListState extends State<ExchangeRateList> {
  late Future<ExchangeRate> futureExchangeRate;
  String searchQuery = '';
  Map<String, double> filteredRates = {};
  Map<String, double> allRates = {};
  final TextEditingController _searchController = TextEditingController();
  bool isDarkTheme = false;

  final Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'JPY': '¥',
    'GBP': '£',
    'AUD': 'A\$',
    'CAD': 'C\$',
    'CHF': 'CHF',
    'CNY': '¥',
  };

  final Map<String, String> currencyCountries = {
    'USD': 'United States',
    'EUR': 'Eurozone',
    'JPY': 'Japan',
    'GBP': 'United Kingdom',
    'AUD': 'Australia',
  };

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    futureExchangeRate = ExchangeRateService().fetchExchangeRate();
    futureExchangeRate.then((exchangeRate) {
      setState(() {
        allRates = exchangeRate.rates;
        filteredRates = allRates;
      });
    });
  }

  void filterRates(String query) {
    setState(() {
      searchQuery = query;
      if (searchQuery.isEmpty) {
        filteredRates = allRates;
      } else {
        filteredRates = Map.fromEntries(
          allRates.entries.where((entry) =>
              entry.key.toLowerCase().contains(searchQuery.toLowerCase())),
        );
      }
    });
  }

  void clearSearch() {
    setState(() {
      searchQuery = '';
      filteredRates = allRates;
      _searchController.clear();
    });
  }

  void sortRates(bool ascending) {
    setState(() {
      var entries = allRates.entries.toList();
      entries.sort((a, b) => ascending
          ? a.key.compareTo(b.key)
          : b.key.compareTo(a.key));
      filteredRates = Map.fromEntries(entries);
    });
  }

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false, // Menonaktifkan banner debug
    theme: isDarkTheme
        ? ThemeData.dark().copyWith(
            primaryColor: Colors.purple[300],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[850],
              titleTextStyle: TextStyle(color: Colors.amber[700]),
            ),
            textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.white)),
          )
        : ThemeData.light().copyWith(
            primaryColor: const Color.fromARGB(255, 175, 118, 185),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.purple[300],
              titleTextStyle: TextStyle(color: Colors.amber[700]),
            ),
            textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.black)),
          ),
    home: Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Text(
            'Exchange Rates',
            key: ValueKey<bool>(isDarkTheme),
            style: TextStyle(color: isDarkTheme ? Colors.amber[700] : Colors.black),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchExchangeRates,
          ),
          IconButton(
            icon: Icon(isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: () {
              setState(() {
                isDarkTheme = !isDarkTheme;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<ExchangeRate>(
        future: futureExchangeRate,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No exchange rates available.'));
          } else {
            final exchangeRate = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Currency',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: isDarkTheme ? Colors.grey[800] : Colors.white,
                            prefixIcon: Icon(Icons.search, color: Colors.purple[300]),
                          ),
                          onChanged: (value) {
                            filterRates(value);
                          },
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.purple[300]),
                          onPressed: clearSearch,
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => sortRates(true),
                      child: Text('Sort A-Z'),
                    ),
                    TextButton(
                      onPressed: () => sortRates(false),
                      child: Text('Sort Z-A'),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRates.length,
                    itemBuilder: (context, index) {
                      String currency = filteredRates.keys.elementAt(index);
                      double rate = filteredRates[currency]!;
                      String symbol = currencySymbols[currency] ?? currency;
                      String country = currencyCountries[currency] ?? 'Unknown Country';

                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(currency),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Rate: $rate $symbol'),
                                    Text('Symbol: $symbol'),
                                    Text('Country: $country'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple[300],
                              child: Text(currency[0]),
                            ),
                            title: Text(
                              '$currency: $rate',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    ))
    ;
  }
}