import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_ent_280/core/services/app_currency_formatter.dart';

class ClientBalance {
  const ClientBalance({
    required this.balanceMinor,
    required this.currency,
  });

  final int balanceMinor;
  final String currency;

  String get formattedAmount =>
      AppCurrencyFormatter.instance.formatStoredMinor(
        balanceMinor,
        storedCurrency: currency,
      );
}

class ClientBalanceProfile {
  const ClientBalanceProfile({
    required this.clientId,
    required this.balanceMinor,
    required this.debtLimitMinor,
    required this.currency,
    this.updatedAt,
  });

  final String clientId;
  final int balanceMinor;
  final int debtLimitMinor;
  final String currency;
  final DateTime? updatedAt;

  bool get isBlockedByDebtLimit => balanceMinor <= debtLimitMinor;

  String formatMoney(int minor) =>
      AppCurrencyFormatter.instance.formatStoredMinor(
        minor,
        storedCurrency: currency,
      );

  String get formattedBalance => formatMoney(balanceMinor);

  String get formattedDebtLimit => formatMoney(debtLimitMinor);
}

class BalanceAdjustmentRecord {
  const BalanceAdjustmentRecord({
    required this.id,
    required this.deltaMinor,
    required this.currency,
    required this.reason,
    required this.createdAt,
    required this.adminEmail,
  });

  final String id;
  final int deltaMinor;
  final String currency;
  final String reason;
  final DateTime? createdAt;
  final String adminEmail;

  String get formattedDelta {
    final formatted = AppCurrencyFormatter.instance.formatStoredMinor(
      deltaMinor.abs(),
      storedCurrency: currency,
    );
    if (deltaMinor > 0) return '+$formatted';
    if (deltaMinor < 0) return '-$formatted';
    return formatted;
  }
}

class BalanceRepository {
  BalanceRepository({
    FirebaseFirestore? firestore,
    this.disabled = false,
    ClientBalance? mockBalance,
    ClientBalanceProfile? mockProfile,
    List<BalanceAdjustmentRecord>? mockAdjustments,
  })  : _firestore = firestore,
        _mockBalance = mockBalance,
        _mockProfile = mockProfile,
        _mockAdjustments = mockAdjustments;

  final FirebaseFirestore? _firestore;
  final bool disabled;
  final ClientBalance? _mockBalance;
  final ClientBalanceProfile? _mockProfile;
  final List<BalanceAdjustmentRecord>? _mockAdjustments;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  int _moneyMinor(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['amountMinor'] as num?)?.toInt() ?? 0;
    }
    if (value is num) return value.toInt();
    return 0;
  }

  DateTime? _timestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  Stream<ClientBalance?> watchClientBalance(String clientId) {
    return watchClientBalanceProfile(clientId).map(
      (profile) => profile == null
          ? (_mockBalance)
          : ClientBalance(
              balanceMinor: profile.balanceMinor,
              currency: profile.currency,
            ),
    );
  }

  Stream<ClientBalanceProfile?> watchClientBalanceProfile(String clientId) {
    if (disabled) {
      return Stream<ClientBalanceProfile?>.value(_mockProfile);
    }
    return _db.collection('balances').doc(clientId).snapshots().map((doc) {
      if (!doc.exists) {
        return ClientBalanceProfile(
          clientId: clientId,
          balanceMinor: 0,
          debtLimitMinor: -2000,
          currency: 'EUR',
        );
      }
      final data = doc.data() ?? {};
      final balance = data['balance'] as Map<String, dynamic>?;
      final debtLimit = data['debtLimit'] as Map<String, dynamic>?;
      return ClientBalanceProfile(
        clientId: clientId,
        balanceMinor: _moneyMinor(balance ?? data['amount']),
        debtLimitMinor: _moneyMinor(debtLimit),
        currency: balance?['currency'] as String? ?? 'EUR',
        updatedAt: _timestamp(data['updatedAt']),
      );
    });
  }

  Stream<List<BalanceAdjustmentRecord>> watchClientBalanceAdjustments(
    String clientId,
  ) {
    if (disabled) {
      return Stream<List<BalanceAdjustmentRecord>>.value(
        _mockAdjustments ?? const [],
      );
    }
    return _db
        .collection('balance_adjustments')
        .where('clientId', isEqualTo: clientId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs.map((doc) {
        final data = doc.data();
        final delta = data['delta'] as Map<String, dynamic>?;
        return BalanceAdjustmentRecord(
          id: doc.id,
          deltaMinor: _moneyMinor(delta),
          currency: delta?['currency'] as String? ?? 'EUR',
          reason: data['reason'] as String? ?? '',
          createdAt: _timestamp(data['createdAt']),
          adminEmail: data['adminEmail'] as String? ?? '',
        );
      }).toList();
      records.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return records;
    });
  }
}
