import 'package:local_ent_280/core/services/client_functions_service.dart';

class SupportRequestRepository {
  SupportRequestRepository({ClientFunctionsService? functionsService})
      : _functionsService = functionsService ?? ClientFunctionsService();

  final ClientFunctionsService _functionsService;

  Future<void> requestTicket({
    required String subject,
    required String message,
  }) async {
    await _functionsService.requestSupportTicket(
      subject: subject,
      message: message,
    );
  }
}
