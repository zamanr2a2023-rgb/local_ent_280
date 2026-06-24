import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/presentation/admin/admin_drawer.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_scaffold.dart';
import 'package:local_ent_280/presentation/admin/screens/admin_support_chat_screen.dart';
import 'package:local_ent_280/presentation/admin/widgets/admin_support_ticket_card.dart';

class AdminSupportRequestsScreen extends StatefulWidget {
  const AdminSupportRequestsScreen({super.key, this.repository});

  final AdminModulesRepository? repository;

  @override
  State<AdminSupportRequestsScreen> createState() =>
      _AdminSupportRequestsScreenState();
}

class _AdminSupportRequestsScreenState extends State<AdminSupportRequestsScreen> {
  late final AdminModulesRepository _repo;
  StreamSubscription? _sub;
  List<AdminSupportRequestRecord> _requests = const [];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _sub = _repo.watchSupportRequests().listen((items) {
      if (!mounted) return;
      setState(() => _requests = items);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _resolve(AdminSupportRequestRecord request) async {
    try {
      await _repo.resolveSupportRequest(request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminSupportResolveSuccess)),
      );
    } on AdminFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _openChat(AdminSupportRequestRecord request) {
    openAdminSupportChat(context, request);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AdminScaffold(
      title: l10n.adminSupportRequestsTitle,
      drawerSection: AdminDrawerSection.support,
      body: _requests.isEmpty
          ? AdminEmptyState(message: l10n.adminSupportEmpty)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                AppLayout.marginMobile,
                AppLayout.md,
                AppLayout.marginMobile,
                AppLayout.xxl,
              ),
              itemCount: _requests.length,
              separatorBuilder: (_, __) => SizedBox(height: AppLayout.md),
              itemBuilder: (context, index) {
                final item = _requests[index];
                return AdminSupportTicketCard(
                  request: item,
                  onReply: () => _openChat(item),
                  onResolve: item.isOpen ? () => _resolve(item) : null,
                );
              },
            ),
    );
  }
}
