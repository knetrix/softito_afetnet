import 'package:afetnet/core/theme/app_colors.dart';
import 'package:afetnet/core/theme/app_status_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStatusColors tests', () {
    test('forPriority maps 1 to critical, 2 to urgent, 3 to normal', () {
      const colors = AppStatusColors.dark;

      expect(colors.forPriority(1), equals(AppColors.danger));
      expect(colors.forPriority(2), equals(AppColors.warning));
      expect(colors.forPriority(3), equals(AppColors.success));
      // Fallback
      expect(colors.forPriority(99), equals(AppColors.success));
    });

    test('copyWith updates specified color', () {
      const colors = AppStatusColors.dark;
      final updated = colors.copyWith(critical: AppColors.primary);

      expect(updated.critical, equals(AppColors.primary));
      expect(updated.urgent, equals(AppColors.warning));
    });
  });
}

