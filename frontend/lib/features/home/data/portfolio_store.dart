// Autoria: Felipe Sousa - RA: 22018160

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../presentation/models/startup_data.dart';
import 'trading_api_service.dart';

class PortfolioHolding {
  const PortfolioHolding({
    required this.startup,
    required this.quantity,
    required this.averagePrice,
    required this.totalInvested,
  });

  final StartupData startup;
  final int quantity;
  final double averagePrice;
  final double totalInvested;

  double get totalCost => totalInvested;
  double get totalValue => quantity * startup.tokenPrice;
  double get profit => totalValue - totalCost;
}

class PortfolioStore extends ChangeNotifier {
  PortfolioStore._();

  static final PortfolioStore instance = PortfolioStore._();

  final TradingApiService _api = TradingApiService();

  double _balance = 50000;
  bool _isLoading = false;
  String? _lastErrorMessage;
  final Map<String, PortfolioHolding> _holdings = <String, PortfolioHolding>{};
  List<WalletTransaction> _transactions = const <WalletTransaction>[];

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get lastErrorMessage => _lastErrorMessage;
  bool get hasRemoteConfig => _api.hasRemoteWalletConfig;

  List<PortfolioHolding> get holdings =>
      _holdings.values.toList(growable: false);

  List<WalletTransaction> get transactions => _transactions;

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

  Future<void> hydrate() async {
    if (!hasRemoteConfig) {
      return;
    }

    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final walletSnapshot = await _api.fetchWallet();
      _applyWalletSnapshot(walletSnapshot);
      _isLoading = false;
      notifyListeners();
    } on DioException catch (error) {
      _isLoading = false;
      _lastErrorMessage = await _api.extractErrorMessage(error);
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      _lastErrorMessage = 'Falha ao carregar carteira';
      notifyListeners();
    }
  }

  Future<void> refreshTransactions() async {
    if (!hasRemoteConfig) {
      return;
    }

    try {
      _transactions = await _api.fetchTransactions();
      notifyListeners();
    } catch (_) {
      // Mantem a lista atual em caso de falha de rede.
    }
  }

  PortfolioHolding? holdingFor(StartupData startup) {
    return _holdings[_startupKey(startup)];
  }

  bool isInvestorForStartup(StartupData startup) {
    final holding = holdingFor(startup);
    return holding != null && holding.quantity > 0;
  }

  bool canBuy(StartupData startup, int quantity) {
    return quantity > 0 && _balance >= startup.tokenPrice * quantity;
  }

  bool canSell(StartupData startup, int quantity) {
    final holding = holdingFor(startup);
    if (holding == null) {
      return false;
    }

    return quantity > 0 && holding.quantity >= quantity;
  }

  Future<PortfolioActionResult> buyTokens(
    StartupData startup,
    int quantity,
  ) async {
    if (!hasRemoteConfig) {
      return _buyLocally(startup, quantity);
    }

    if (quantity <= 0) {
      return const PortfolioActionResult(
        success: false,
        message: 'Quantidade invalida',
      );
    }

    try {
      final snapshot = await _api.buyTokens(
        startupId: _startupKey(startup),
        quantity: quantity,
      );
      _applyWalletSnapshot(snapshot);
      notifyListeners();
      return const PortfolioActionResult(
        success: true,
        message: 'Compra realizada com sucesso',
      );
    } on DioException catch (error) {
      return PortfolioActionResult(
        success: false,
        message:
            await _api.extractErrorMessage(error) ??
            'Falha ao concluir a compra',
      );
    } catch (_) {
      return const PortfolioActionResult(
        success: false,
        message: 'Falha ao concluir a compra',
      );
    }
  }

  Future<PortfolioActionResult> sellTokens(
    StartupData startup,
    int quantity,
  ) async {
    if (!hasRemoteConfig) {
      return _sellLocally(startup, quantity);
    }

    if (quantity <= 0) {
      return const PortfolioActionResult(
        success: false,
        message: 'Quantidade invalida',
      );
    }

    try {
      final snapshot = await _api.sellTokens(
        startupId: _startupKey(startup),
        quantity: quantity,
      );
      _applyWalletSnapshot(snapshot);
      notifyListeners();
      return const PortfolioActionResult(
        success: true,
        message: 'Venda realizada com sucesso',
      );
    } on DioException catch (error) {
      return PortfolioActionResult(
        success: false,
        message:
            await _api.extractErrorMessage(error) ??
            'Falha ao concluir a venda',
      );
    } catch (_) {
      return const PortfolioActionResult(
        success: false,
        message: 'Falha ao concluir a venda',
      );
    }
  }

  Future<PortfolioActionResult> addBalance(double value) async {
    if (value <= 0) {
      return const PortfolioActionResult(
        success: false,
        message: 'Valor invalido',
      );
    }

    if (!hasRemoteConfig) {
      _balance += value;
      notifyListeners();
      return const PortfolioActionResult(
        success: true,
        message: 'Saldo adicionado com sucesso',
      );
    }

    try {
      final snapshot = await _api.creditBalance(value);
      _applyWalletSnapshot(snapshot);
      notifyListeners();
      return const PortfolioActionResult(
        success: true,
        message: 'Saldo adicionado com sucesso',
      );
    } on DioException catch (error) {
      return PortfolioActionResult(
        success: false,
        message:
            await _api.extractErrorMessage(error) ?? 'Falha ao adicionar saldo',
      );
    } catch (_) {
      return const PortfolioActionResult(
        success: false,
        message: 'Falha ao adicionar saldo',
      );
    }
  }

  Future<PortfolioActionResult> sendPrivateQuestion({
    required StartupData startup,
    required String question,
  }) async {
    final trimmedQuestion = question.trim();
    if (trimmedQuestion.isEmpty) {
      return const PortfolioActionResult(
        success: false,
        message: 'Informe a pergunta antes de enviar',
      );
    }

    if (!isInvestorForStartup(startup)) {
      return const PortfolioActionResult(
        success: false,
        message: 'Disponivel apenas para investidores desta startup',
      );
    }

    if (!hasRemoteConfig) {
      return const PortfolioActionResult(
        success: false,
        message: 'Configure as URLs de funcoes para perguntas privadas',
      );
    }

    try {
      final responseMessage = await _api.sendPrivateQuestion(
        startupId: _startupKey(startup),
        question: trimmedQuestion,
      );
      return PortfolioActionResult(success: true, message: responseMessage);
    } on DioException catch (error) {
      return PortfolioActionResult(
        success: false,
        message:
            await _api.extractErrorMessage(error) ??
            'Falha ao enviar pergunta privada',
      );
    } catch (_) {
      return const PortfolioActionResult(
        success: false,
        message: 'Falha ao enviar pergunta privada',
      );
    }
  }

  PortfolioActionResult _buyLocally(StartupData startup, int quantity) {
    if (!canBuy(startup, quantity)) {
      return const PortfolioActionResult(
        success: false,
        message: 'Saldo insuficiente para concluir a compra.',
      );
    }

    final key = _startupKey(startup);
    final total = startup.tokenPrice * quantity;
    _balance -= total;

    final current = _holdings[key];
    if (current == null) {
      _holdings[key] = PortfolioHolding(
        startup: startup,
        quantity: quantity,
        averagePrice: startup.tokenPrice,
        totalInvested: total,
      );
    } else {
      final totalQuantity = current.quantity + quantity;
      final totalCost = current.totalInvested + total;
      final newAverage = totalCost / totalQuantity;
      _holdings[key] = PortfolioHolding(
        startup: startup,
        quantity: totalQuantity,
        averagePrice: newAverage,
        totalInvested: totalCost,
      );
    }

    notifyListeners();
    return const PortfolioActionResult(
      success: true,
      message: 'Compra realizada com sucesso',
    );
  }

  PortfolioActionResult _sellLocally(StartupData startup, int quantity) {
    if (!canSell(startup, quantity)) {
      return const PortfolioActionResult(
        success: false,
        message: 'Quantidade indisponivel para venda.',
      );
    }

    final key = _startupKey(startup);
    final current = _holdings[key]!;
    _balance += startup.tokenPrice * quantity;

    final remaining = current.quantity - quantity;
    if (remaining <= 0) {
      _holdings.remove(key);
    } else {
      final remainingInvested =
          current.totalInvested * (remaining / current.quantity);
      _holdings[key] = PortfolioHolding(
        startup: current.startup,
        quantity: remaining,
        averagePrice: current.averagePrice,
        totalInvested: remainingInvested,
      );
    }

    notifyListeners();
    return const PortfolioActionResult(
      success: true,
      message: 'Venda realizada com sucesso',
    );
  }

  void _applyWalletSnapshot(WalletSnapshot snapshot) {
    _balance = snapshot.balance;
    _transactions = snapshot.transactions;
    _holdings.clear();

    for (final holding in snapshot.holdings) {
      final startup = StartupData(
        id: holding.startupId,
        name: holding.startupName,
        description: 'Posicao do investidor',
        stage: 'Operacao',
        tokenValue: _formatCurrency(holding.currentTokenPrice),
        tokenPrice: holding.currentTokenPrice,
        variation: '+0.00%',
        imageUrl: holding.imageUrl,
        sector: 'Nao informado',
        totalTokens: 0,
        raisedCapital: _formatCurrency(holding.totalInvested),
        executiveSummary: 'Ativo em carteira',
        founders: '',
        ownershipStructure: '',
        mentorsCouncil: '',
        demoVideoUrl: '',
      );

      _holdings[holding.startupId] = PortfolioHolding(
        startup: startup,
        quantity: holding.quantity,
        averagePrice: holding.averagePrice,
        totalInvested: holding.totalInvested,
      );
    }
  }

  String _startupKey(StartupData startup) {
    final startupId = startup.id.trim();
    if (startupId.isNotEmpty) {
      return startupId;
    }

    return startup.name.trim().toLowerCase().replaceAll(' ', '-');
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

class PortfolioActionResult {
  const PortfolioActionResult({required this.success, required this.message});

  final bool success;
  final String message;
}
