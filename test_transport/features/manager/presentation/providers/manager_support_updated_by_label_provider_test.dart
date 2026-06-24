import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/admin/application/providers/admin_audit_domain_providers.dart';
import 'package:local_transport/features/admin/domain/entities/audit_entry.dart';
import 'package:local_transport/features/admin/domain/entities/audit_entry_draft.dart';
import 'package:local_transport/features/admin/domain/entities/audit_query.dart';
import 'package:local_transport/features/admin/domain/entities/audit_subject_identity.dart';
import 'package:local_transport/features/admin/domain/repositories/admin_audit_repository.dart';
import 'package:local_transport/features/admin/domain/usecases/resolve_audit_subject_identities.dart';
import 'package:local_transport/features/manager/presentation/providers/manager_support_updated_by_label_provider.dart';

void main() {
  group('managerSupportUpdatedByLabelProvider', () {
    test('devolve email original quando o valor já é email', () async {
      final container = ProviderContainer(
        overrides: [
          resolveAuditSubjectIdentitiesProvider.overrideWithValue(
            ResolveAuditSubjectIdentities(_FakeAdminAuditRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        managerSupportUpdatedByLabelProvider('gestor@example.com').future,
      );

      expect(result, 'gestor@example.com');
    });

    test('resolve uid antigo para email', () async {
      final container = ProviderContainer(
        overrides: [
          resolveAuditSubjectIdentitiesProvider.overrideWithValue(
            ResolveAuditSubjectIdentities(
              _FakeAdminAuditRepository(
                identities: const <String, AuditSubjectIdentity>{
                  'manager_1': AuditSubjectIdentity(
                    email: 'gestor@example.com',
                  ),
                },
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        managerSupportUpdatedByLabelProvider('manager_1').future,
      );

      expect(result, 'gestor@example.com');
    });

    test('mantém uid quando não consegue resolver email', () async {
      final container = ProviderContainer(
        overrides: [
          resolveAuditSubjectIdentitiesProvider.overrideWithValue(
            ResolveAuditSubjectIdentities(_FakeAdminAuditRepository()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        managerSupportUpdatedByLabelProvider('manager_1').future,
      );

      expect(result, 'manager_1');
    });
  });
}

class _FakeAdminAuditRepository implements AdminAuditRepository {
  const _FakeAdminAuditRepository({
    this.identities = const <String, AuditSubjectIdentity>{},
  });

  final Map<String, AuditSubjectIdentity> identities;

  @override
  Future<void> createAuditEntry(AuditEntryDraft entry) async {}

  @override
  Future<Map<String, String>> resolveAdminEmails(
    Iterable<String> adminIds,
  ) async {
    return const <String, String>{};
  }

  @override
  Future<Map<String, AuditSubjectIdentity>> resolveSubjectIdentities(
    Iterable<String> userIds,
  ) async {
    return Map<String, AuditSubjectIdentity>.fromEntries(
      userIds
          .where(identities.containsKey)
          .map(
            (userId) => MapEntry(userId, identities[userId]!),
          ),
    );
  }

  @override
  Stream<List<AuditEntry>> watchAuditEntries(AuditQuery query) {
    return const Stream<List<AuditEntry>>.empty();
  }
}
