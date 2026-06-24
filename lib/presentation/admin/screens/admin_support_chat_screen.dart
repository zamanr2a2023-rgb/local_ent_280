import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:local_ent_280/core/localization/l10n_extensions.dart';
import 'package:local_ent_280/core/theme/app_colors.dart';
import 'package:local_ent_280/core/theme/app_screen_util.dart';
import 'package:local_ent_280/core/theme/app_typography.dart';
import 'package:local_ent_280/features/admin/data/admin_functions_service.dart';
import 'package:local_ent_280/features/admin/data/admin_modules_repository.dart';
import 'package:local_ent_280/features/admin/data/models/admin_records.dart';
import 'package:local_ent_280/features/support/data/models/chat_message.dart';
import 'package:local_ent_280/features/support/data/support_chat_repository.dart';

class AdminSupportChatScreen extends StatefulWidget {
  const AdminSupportChatScreen({
    super.key,
    required this.request,
    this.repository,
    this.chatRepository,
  });

  final AdminSupportRequestRecord request;
  final AdminModulesRepository? repository;
  final SupportChatRepository? chatRepository;

  @override
  State<AdminSupportChatScreen> createState() => _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState extends State<AdminSupportChatScreen> {
  late final AdminModulesRepository _repo;
  late final SupportChatRepository _chatRepo;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  StreamSubscription? _messagesSub;
  List<ChatMessage> _messages = const [];
  bool _sending = false;

  String get _threadId =>
      widget.request.chatThreadId ??
      supportRequestThreadId(widget.request.id);

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? AdminModulesRepository();
    _chatRepo = widget.chatRepository ?? SupportChatRepository();
    _messagesSub = _chatRepo.watchThreadMessages(_threadId).listen((messages) {
      if (!mounted) return;
      setState(() => _messages = messages);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _sending || !widget.request.isOpen) return;
    setState(() => _sending = true);
    try {
      await _repo.sendSupportReply(
        requestId: widget.request.id,
        message: body,
        chatThreadId: _threadId,
      );
      _messageController.clear();
    } on AdminFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _resolve() async {
    try {
      await _repo.resolveSupportRequest(widget.request.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.adminSupportResolveSuccess)),
      );
      Navigator.of(context).pop();
    } on AdminFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    return DateFormat('dd/MM HH:mm').format(value.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final request = widget.request;
    final readOnly = !request.isOpen;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        title: Text(
          request.displayName,
          style: AppTypography.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (request.isOpen)
            TextButton(
              onPressed: _resolve,
              child: Text(l10n.adminSupportResolveAction),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppLayout.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request.subject.isNotEmpty)
                  Text(
                    request.subject,
                    style: AppTypography.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                if (request.message.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    request.message,
                    style: AppTypography.inter(
                      fontSize: 13.sp,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      l10n.adminSupportReplyHint,
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppLayout.md),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _ChatBubble(
                        message: message,
                        timeLabel: _formatTime(message.createdAt),
                      );
                    },
                  ),
          ),
          if (!readOnly)
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppLayout.md,
                  AppLayout.sm,
                  AppLayout.md,
                  AppLayout.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.adminSupportReplyHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    SizedBox(width: AppLayout.sm),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      icon: _sending
                          ? SizedBox(
                              width: 18.w,
                              height: 18.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(AppLayout.md),
              child: Text(
                l10n.adminStatusResolved,
                textAlign: TextAlign.center,
                style: AppTypography.inter(color: AppColors.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.timeLabel,
  });

  final ChatMessage message;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final isStaff = message.isFromStaff;
    final alignment = isStaff ? Alignment.centerRight : Alignment.centerLeft;
    final bg = isStaff ? AppColors.secondaryContainer : AppColors.surfaceContainerLow;
    final fg = isStaff ? AppColors.onSecondaryContainer : AppColors.onSurface;

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.only(bottom: AppLayout.sm),
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment:
              isStaff ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.senderDisplayName.isNotEmpty)
              Text(
                message.senderDisplayName,
                style: AppTypography.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: fg.withValues(alpha: 0.8),
                ),
              ),
            Text(
              message.body,
              style: AppTypography.inter(fontSize: 14.sp, color: fg),
            ),
            if (timeLabel.isNotEmpty)
              Text(
                timeLabel,
                style: AppTypography.inter(
                  fontSize: 10.sp,
                  color: fg.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void openAdminSupportChat(
  BuildContext context,
  AdminSupportRequestRecord request,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AdminSupportChatScreen(request: request),
    ),
  );
}
