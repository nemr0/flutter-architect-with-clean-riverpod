import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/util/error/app_error.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Whole-body failure state for a screen whose `build()` load failed.
/// Pair with `state.when(error: ...)` and `ref.invalidate(xProvider)` to retry.
class ErrorScreen extends ConsumerWidget {
  const ErrorScreen({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    final isNetwork =
        error is AppError && (error as AppError).type == AppErrorType.network;
    final title = isNetwork
        ? t.errorScreen.network.title
        : t.errorScreen.server.title;
    final subtitle = isNetwork
        ? t.errorScreen.network.subtitle
        : t.errorScreen.server.subtitle;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacings.s6),
        child: Column(
          mainAxisSize: .min,
          spacing: AppSpacings.s2,
          children: [
            Icon(
              isNetwork ? Icons.wifi_off : Icons.warning_amber,
              size: 64,
              color: colors.brand,
            ),
            Text(title, style: ref.textTheme.textXL.semiBold()),
            Text(
              subtitle,
              style: ref.textTheme.textMd.withColor(colors.gray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacings.s4),
            OutlinedButton(onPressed: onRetry, child: Text(t.common.retryButton)),
          ],
        ),
      ),
    );
  }
}
