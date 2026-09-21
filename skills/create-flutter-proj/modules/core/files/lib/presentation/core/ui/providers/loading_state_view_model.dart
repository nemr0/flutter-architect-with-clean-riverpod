import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef LoadingState = ({bool isLoading, int tag, bool showLoadingText});

/// Global full-screen loading flag. `runLoad` toggles it; every
/// `ContainerWithLoading` whose `tag` matches shows the overlay.
final loadingStateProvider =
    NotifierProvider<LoadingStateViewModel, LoadingState>(
      LoadingStateViewModel.new,
    );

class LoadingStateViewModel extends Notifier<LoadingState> {
  @override
  LoadingState build() => (isLoading: false, tag: 0, showLoadingText: true);

  Future<T> whileLoading<T>(Future<T> Function() future) {
    toLoading();
    return future().whenComplete(toIdle);
  }

  void toLoading({bool showLoadingText = true, int tag = 0}) {
    if (state.isLoading) return;
    state = (isLoading: true, tag: tag, showLoadingText: showLoadingText);
  }

  void toIdle() {
    if (!state.isLoading) return;
    state = (
      isLoading: false,
      tag: state.tag,
      showLoadingText: state.showLoadingText,
    );
  }
}
