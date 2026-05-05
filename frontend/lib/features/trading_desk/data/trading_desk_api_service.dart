// Autoria: Felipe Sousa - RA: 22018160

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/auth/auth_session_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/app_dio.dart';

class TradingDeskApiService {
  factory TradingDeskApiService({
    Dio? dio,
    AuthSessionStorage? sessionStorage,
  }) {
    final resolvedSessionStorage = sessionStorage ?? AuthSessionStorage();
    final resolvedDio =
        dio ??
        createAppDio(
          baseUrl: 'http://localhost',
          sessionStorage: resolvedSessionStorage,
        );
    return TradingDeskApiService._(dio: resolvedDio, ownsDio: dio == null);
  }

  TradingDeskApiService._({required Dio dio, required bool ownsDio})
    : _dio = dio,
      _ownsDio = ownsDio;

  final Dio _dio;
  final bool _ownsDio;

  bool get hasListOffersConfig =>
      AppConfig.marketOffersFunctionUrl.trim().isNotEmpty &&
      AppConfig.myOffersFunctionUrl.trim().isNotEmpty;
  bool get hasCreateOfferConfig =>
      AppConfig.createOfferFunctionUrl.trim().isNotEmpty;
  bool get hasCancelOfferConfig =>
      AppConfig.cancelOfferFunctionUrl.trim().isNotEmpty;
  bool get hasStartupCatalogConfig =>
      AppConfig.startupsFunctionUrl.trim().isNotEmpty;
  bool get hasAcceptOfferConfig =>
      AppConfig.acceptOfferFunctionUrl.trim().isNotEmpty;

  Future<List<TradingDeskOffer>> listMarketOffers() async {
    final response = await _dio.get(AppConfig.marketOffersFunctionUrl.trim());
    final body = _decodeBody(response.data);
    return _readOffersFromBody(body);
  }

  Future<List<TradingDeskOffer>> listMyOffers() async {
    final response = await _dio.get(AppConfig.myOffersFunctionUrl.trim());
    final body = _decodeBody(response.data);
    return _readOffersFromBody(body);
  }

  Future<List<TradingDeskStartup>> listActiveStartups() async {
    final response = await _dio.get(AppConfig.startupsFunctionUrl.trim());
    final body = _decodeBody(response.data);
    final rawItems = body['items'];
    if (rawItems is! List) {
      return const <TradingDeskStartup>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => TradingDeskStartup.fromApi(Map<String, dynamic>.from(item)),
        )
        .where((startup) => startup.id.isNotEmpty && startup.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> cancelOffer(String offerId) async {
    await _dio.post(
      AppConfig.cancelOfferFunctionUrl.trim(),
      data: <String, dynamic>{'offerId': offerId},
    );
  }

  Future<void> createOffer({
    required String startupId,
    required String type,
    required int quantity,
    required double pricePerToken,
  }) async {
    await _dio.post(
      AppConfig.createOfferFunctionUrl.trim(),
      data: <String, dynamic>{
        'startupId': startupId,
        'type': type,
        'quantity': quantity,
        'pricePerToken': pricePerToken,
      },
    );
  }

  Future<void> acceptOffer(String offerId) async {
    await _dio.post(
      AppConfig.acceptOfferFunctionUrl.trim(),
      data: <String, dynamic>{'offerId': offerId},
    );
  }

  String? extractErrorMessage(Object error) {
    if (error is! DioException) {
      return null;
    }
    final body = _decodeBody(error.response?.data);
    final fromError = _readString(body['error']);
    if (fromError != null) {
      return fromError;
    }
    return _readString(body['message']);
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
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  List<TradingDeskOffer> _readOffersFromBody(Map<String, dynamic> source) {
    final rawItems = source['items'];
    if (rawItems is! List) {
      return const <TradingDeskOffer>[];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) => TradingDeskOffer.fromApi(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }
}

class TradingDeskOffer {
  const TradingDeskOffer({
    required this.id,
    required this.uid,
    required this.startupId,
    required this.startupName,
    required this.startupImageUrl,
    required this.type,
    required this.quantity,
    required this.pricePerToken,
    required this.status,
    required this.userName,
    this.createdAtIso,
  });

  final String id;
  final String uid;
  final String startupId;
  final String startupName;
  final String startupImageUrl;
  final String type;
  final int quantity;
  final double pricePerToken;
  final String status;
  final String userName;
  final String? createdAtIso;

  factory TradingDeskOffer.fromApi(Map<String, dynamic> source) {
    return TradingDeskOffer(
      id: _readString(source['id']) ?? '',
      uid: _readString(source['uid']) ?? '',
      startupId: _readString(source['startupId']) ?? '',
      startupName: _readString(source['startupName']) ?? 'Startup',
      startupImageUrl: _readString(source['startupImageUrl']) ?? '',
      type: _readString(source['type']) ?? 'BUY',
      quantity: _readInt(source['quantity']),
      pricePerToken: _readDouble(source['pricePerToken']),
      status: _readString(source['status']) ?? 'ACTIVE',
      userName: _readString(source['userName']) ?? 'Usuario',
      createdAtIso: _readString(source['createdAt']),
    );
  }
}

class TradingDeskStartup {
  const TradingDeskStartup({
    required this.id,
    required this.name,
    required this.tokenPrice,
    required this.sector,
  });

  final String id;
  final String name;
  final double tokenPrice;
  final String sector;

  factory TradingDeskStartup.fromApi(Map<String, dynamic> source) {
    return TradingDeskStartup(
      id: _readString(source['id']) ?? '',
      name: _readString(source['name']) ?? '',
      tokenPrice: _readDouble(source['tokenPrice']),
      sector: _readString(source['sector']) ?? 'Startup',
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
