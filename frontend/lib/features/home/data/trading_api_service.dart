// Autoria: Felipe Sousa - RA: 22018160

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/auth/auth_session_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/app_dio.dart';
import '../../../core/network/auth_error_mapper.dart';

class TradingApiService {
  factory TradingApiService({Dio? dio, AuthSessionStorage? sessionStorage}) {
    final resolvedSessionStorage = sessionStorage ?? AuthSessionStorage();
    final resolvedDio =
        dio ??
        createAppDio(
          baseUrl: 'http://localhost',
          sessionStorage: resolvedSessionStorage,
        );
    return TradingApiService._(dio: resolvedDio, ownsDio: dio == null);
  }

  TradingApiService._({required Dio dio, required bool ownsDio})
    : _dio = dio,
      _ownsDio = ownsDio;

  final Dio _dio;
  final bool _ownsDio;

  bool get hasRemoteWalletConfig =>
      AppConfig.walletFunctionUrl.trim().isNotEmpty &&
      AppConfig.creditWalletFunctionUrl.trim().isNotEmpty &&
      AppConfig.buyTokensFunctionUrl.trim().isNotEmpty &&
      AppConfig.sellTokensFunctionUrl.trim().isNotEmpty &&
      AppConfig.transactionsFunctionUrl.trim().isNotEmpty &&
      AppConfig.privateQuestionFunctionUrl.trim().isNotEmpty;

  Future<WalletSnapshot> fetchWallet() async {
    final url = AppConfig.walletFunctionUrl.trim();
    final response = await _dio.get(url);
    final body = _decodeBody(response.data);
    return WalletSnapshot.fromApi(body);
  }

  Future<WalletSnapshot> creditBalance(double amount) async {
    final response = await _dio.post(
      AppConfig.creditWalletFunctionUrl.trim(),
      data: <String, dynamic>{'amount': amount},
    );
    final body = _decodeBody(response.data);
    return WalletSnapshot.fromApi(body);
  }

  Future<WalletSnapshot> buyTokens({
    required String startupId,
    required int quantity,
  }) async {
    final response = await _dio.post(
      AppConfig.buyTokensFunctionUrl.trim(),
      data: <String, dynamic>{'startupId': startupId, 'quantity': quantity},
    );
    final body = _decodeBody(response.data);
    return WalletSnapshot.fromApi(body);
  }

  Future<WalletSnapshot> sellTokens({
    required String startupId,
    required int quantity,
  }) async {
    final response = await _dio.post(
      AppConfig.sellTokensFunctionUrl.trim(),
      data: <String, dynamic>{'startupId': startupId, 'quantity': quantity},
    );
    final body = _decodeBody(response.data);
    return WalletSnapshot.fromApi(body);
  }

  Future<List<WalletTransaction>> fetchTransactions() async {
    final response = await _dio.get(AppConfig.transactionsFunctionUrl.trim());
    final body = _decodeBody(response.data);
    final dynamic rawItems = body['items'];
    if (rawItems is! List) {
      return const <WalletTransaction>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => WalletTransaction.fromApi(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Future<String> sendPrivateQuestion({
    required String startupId,
    required String question,
  }) async {
    final response = await _dio.post(
      AppConfig.privateQuestionFunctionUrl.trim(),
      data: <String, dynamic>{'startupId': startupId, 'question': question},
    );
    final body = _decodeBody(response.data);
    return _readString(body, 'message') ?? 'Pergunta enviada com sucesso';
  }

  Future<String?> extractErrorMessage(DioException error) async {
    final body = _decodeBody(error.response?.data);
    final raw = _readString(body, 'error') ?? _readString(body, 'message');
    return mapAuthErrorMessage(raw) ?? raw;
  }

  void dispose() {
    if (_ownsDio) {
      _dio.close();
    }
  }

  Map<String, dynamic> _decodeBody(dynamic rawBody) {
    if (rawBody is Map<String, dynamic>) {
      return rawBody;
    }
    if (rawBody is Map) {
      return Map<String, dynamic>.from(rawBody);
    }
    if (rawBody is String) {
      final trimmed = rawBody.trim();
      if (trimmed.isEmpty) {
        return <String, dynamic>{};
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{'message': trimmed};
      }
    }
    return <String, dynamic>{};
  }

  String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class WalletSnapshot {
  const WalletSnapshot({
    required this.balance,
    required this.holdings,
    required this.transactions,
  });

  final double balance;
  final List<WalletHolding> holdings;
  final List<WalletTransaction> transactions;

  factory WalletSnapshot.fromApi(Map<String, dynamic> source) {
    final rawHoldings = source['holdings'];
    final rawTransactions = source['transactions'];
    return WalletSnapshot(
      balance: _readDouble(source['balance']),
      holdings: rawHoldings is List
          ? rawHoldings
                .whereType<Map>()
                .map(
                  (item) =>
                      WalletHolding.fromApi(Map<String, dynamic>.from(item)),
                )
                .toList(growable: false)
          : const <WalletHolding>[],
      transactions: rawTransactions is List
          ? rawTransactions
                .whereType<Map>()
                .map(
                  (item) => WalletTransaction.fromApi(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const <WalletTransaction>[],
    );
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class WalletHolding {
  const WalletHolding({
    required this.startupId,
    required this.startupName,
    required this.quantity,
    required this.averagePrice,
    required this.currentTokenPrice,
    required this.totalInvested,
    required this.totalValue,
    required this.imageUrl,
  });

  final String startupId;
  final String startupName;
  final int quantity;
  final double averagePrice;
  final double currentTokenPrice;
  final double totalInvested;
  final double totalValue;
  final String imageUrl;

  factory WalletHolding.fromApi(Map<String, dynamic> source) {
    return WalletHolding(
      startupId: _readString(source['startupId']) ?? '',
      startupName: _readString(source['startupName']) ?? 'Startup',
      quantity: _readInt(source['quantity']),
      averagePrice: _readDouble(source['averagePrice']),
      currentTokenPrice: _readDouble(source['currentTokenPrice']),
      totalInvested: _readDouble(source['totalInvested']),
      totalValue: _readDouble(source['totalValue']),
      imageUrl: _readString(source['imageUrl']) ?? '',
    );
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.startupId,
    required this.startupName,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    required this.createdAtIso,
  });

  final String id;
  final String type;
  final String? startupId;
  final String? startupName;
  final int quantity;
  final double unitPrice;
  final double amount;
  final String? createdAtIso;

  factory WalletTransaction.fromApi(Map<String, dynamic> source) {
    return WalletTransaction(
      id: _readString(source['id']) ?? '',
      type: _readString(source['type']) ?? 'UNKNOWN',
      startupId: _readString(source['startupId']),
      startupName: _readString(source['startupName']),
      quantity: _readInt(source['quantity']),
      unitPrice: _readDouble(source['unitPrice']),
      amount: _readDouble(source['amount']),
      createdAtIso: _readString(source['createdAt']),
    );
  }
}

String? _readString(dynamic value) {
  if (value is! String) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}
