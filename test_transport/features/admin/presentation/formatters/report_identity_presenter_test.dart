import 'package:flutter_test/flutter_test.dart';
import 'package:local_transport/features/admin/presentation/formatters/report_identity_presenter.dart';

void main() {
  const presenter = ReportIdentityPresenter();

  test('tripReference uses a stable short reference format', () {
    expect(
      presenter.tripReference('1234567890abcdef'),
      'Viagem 1234...cdef',
    );
  });

  test('movementReference uses a stable short reference format', () {
    expect(
      presenter.movementReference('abcdef1234567890'),
      'Mov. abcd...7890',
    );
  });

  test('technicalId falls back for empty values', () {
    expect(presenter.technicalId(''), '—');
    expect(presenter.technicalId(null), '—');
  });
}
