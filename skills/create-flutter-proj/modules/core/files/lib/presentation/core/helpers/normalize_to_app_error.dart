import 'package:__APP__/data/util/error/app_error.dart';

/// Runs [loader] and normalises whatever it throws to an [AppError].
///
/// Existing [AppError]s are rethrown untouched; anything else is wrapped via
/// `AppError.fromException` with the original stack trace attached. Use it in
/// a view model's `build()` — where you need the value back, so `runLoad`
/// doesn't fit — to keep a single error type reaching the UI.
Future<E> guard<E>(Future<E> Function() loader) async {
  try {
    return await loader();
  } catch (e, s) {
    if (e is AppError) rethrow;
    throw AppError.fromException(e, trace: s);
  }
}
