// Autoria: Felipe Sousa - RA: 22018160

import 'package:flutter/foundation.dart';

import '../presentation/models/startup_data.dart';

class PortfolioHolding {
  const PortfolioHolding({
    required this.startup,
    required this.quantity,
    required this.averagePrice,
  });

  final StartupData startup;
  final int quantity;
  final double averagePrice;

  double get totalCost => quantity * averagePrice;
  double get totalValue => quantity * startup.tokenPrice;
  double get profit => totalValue - totalCost;

  PortfolioHolding copyWith({int? quantity, double? averagePrice}) {
    return PortfolioHolding(
      startup: startup,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
    );
  }
}

class PortfolioStore extends ChangeNotifier {
  PortfolioStore._();

  static final PortfolioStore instance = PortfolioStore._();

  double _balance = 50000;
  final Map<String, PortfolioHolding> _holdings = <String, PortfolioHolding>{};

  double get balance => _balance;

  List<PortfolioHolding> get holdings =>
      _holdings.values.toList(growable: false);

  bool get hasHoldings => _holdings.isNotEmpty;

  double get totalInvested =>
      _holdings.values.fold(0, (total, item) => total + item.totalCost);

  double get totalCurrentValue =>
      _holdings.values.fold(0, (total, item) => total + item.totalValue);

  double get totalVariationPercent {
    if (totalInvested == 0) {
      return 0;
    }

    return ((totalCurrentValue - totalInvested) / totalInvested) * 100;
  }

  PortfolioHolding? holdingFor(String startupName) {
    return _holdings[startupName];
  }

  bool canBuy(StartupData startup, int quantity) {
    return quantity > 0 && _balance >= startup.tokenPrice * quantity;
  }

  bool canSell(StartupData startup, int quantity) {
    final holding = _holdings[startup.name];
    if (holding == null) {
      return false;
    }

    return quantity > 0 && holding.quantity >= quantity;
  }

  bool buyTokens(StartupData startup, int quantity) {
    if (!canBuy(startup, quantity)) {
      return false;
    }

    final total = startup.tokenPrice * quantity;
    _balance -= total;

    final current = _holdings[startup.name];
    if (current == null) {
      _holdings[startup.name] = PortfolioHolding(
        startup: startup,
        quantity: quantity,
        averagePrice: startup.tokenPrice,
      );
    } else {
      final totalQuantity = current.quantity + quantity;
      final totalCost = current.totalCost + total;
      final newAverage = totalCost / totalQuantity;
      _holdings[startup.name] = current.copyWith(
        quantity: totalQuantity,
        averagePrice: newAverage,
      );
    }

    notifyListeners();
    return true;
  }

  bool sellTokens(StartupData startup, int quantity) {
    if (!canSell(startup, quantity)) {
      return false;
    }

    final current = _holdings[startup.name]!;
    _balance += startup.tokenPrice * quantity;

    final remaining = current.quantity - quantity;
    if (remaining <= 0) {
      _holdings.remove(startup.name);
    } else {
      _holdings[startup.name] = current.copyWith(quantity: remaining);
    }

    notifyListeners();
    return true;
  }

  void addBalance(double value) {
    if (value <= 0) {
      return;
    }

    _balance += value;
    notifyListeners();
  }
}
