import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ispect/ispect.dart';

/// Routes Riverpod provider lifecycle into the ISpect log pipeline.
///
/// `ispectify_riverpod` still pins riverpod 2.x, so this is the riverpod 3
/// equivalent — the same four trace helpers the package emits.
final class ISpectRiverpodObserver extends ProviderObserver {
  const ISpectRiverpodObserver();

  static const _source = 'riverpod';

  static String _target(ProviderObserverContext context) =>
      context.provider.name ?? context.provider.runtimeType.toString();

  @override
  void didAddProvider(ProviderObserverContext context, Object? value) =>
      ISpect.logger.riverpodAdd(
        source: _source,
        target: _target(context),
        meta: {'value': value},
      );

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) => ISpect.logger.riverpodUpdate(
    source: _source,
    target: _target(context),
    meta: {'previous': previousValue, 'new': newValue},
  );

  @override
  void didDisposeProvider(ProviderObserverContext context) =>
      ISpect.logger.riverpodDispose(source: _source, target: _target(context));

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) => ISpect.logger.riverpodFail(
    source: _source,
    target: _target(context),
    error: error,
    errorStackTrace: stackTrace,
  );
}
