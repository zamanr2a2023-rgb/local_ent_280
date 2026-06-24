import 'package:local_transport/features/onboarding/domain/entities/onboarding_status.dart';
import 'package:local_transport/features/onboarding/domain/repositories/onboarding_repository.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({bool isComplete = true}) : _isComplete = isComplete;

  bool _isComplete;

  @override
  Future<void> completeOnboarding() async {
    _isComplete = true;
  }

  @override
  Future<OnboardingStatus> fetchStatus() async {
    return OnboardingStatus(isComplete: _isComplete);
  }

  @override
  Future<void> resetOnboarding() async {
    _isComplete = false;
  }
}
