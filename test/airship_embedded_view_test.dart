import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Covers the two sizing decisions the embedded view makes before it hands a
/// size to the platform view. Both have shipped regressions twice.
void main() {
  group('isSelfSizing', () {
    test('measures its own content only when nothing else sets the height', () {
      expect(
        AirshipEmbeddedViewState.isSelfSizing(
          constraints: const BoxConstraints(maxWidth: 400),
          parentHeight: null,
        ),
        isTrue,
      );
    });

    test('an explicit parent height takes over the measurement', () {
      expect(
        AirshipEmbeddedViewState.isSelfSizing(
          constraints: const BoxConstraints(maxWidth: 400),
          parentHeight: 132,
        ),
        isFalse,
      );
    });

    test('a bounded parent takes over the measurement', () {
      expect(
        AirshipEmbeddedViewState.isSelfSizing(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          parentHeight: null,
        ),
        isFalse,
      );
    });
  });

  group('resolveSize', () {
    const bounded = BoxConstraints(maxWidth: 400, maxHeight: 500);
    const unboundedHeight = BoxConstraints(maxWidth: 400);
    const unbounded = BoxConstraints();

    test('takes a bounded parent as the size', () {
      expect(
        AirshipEmbeddedViewState.resolveSize(
          constraints: bounded,
          fallbackWidth: 1000,
          fallbackHeight: 2000,
        ),
        const Size(400, 500),
      );
    });

    test('falls back on each dimension the parent leaves unbounded', () {
      expect(
        AirshipEmbeddedViewState.resolveSize(
          constraints: unbounded,
          fallbackWidth: 1000,
          fallbackHeight: 2000,
        ),
        const Size(1000, 2000),
      );
    });

    test('adopts a reported content height when the parent is unbounded', () {
      expect(
        AirshipEmbeddedViewState.resolveSize(
          constraints: unboundedHeight,
          fallbackWidth: 1000,
          fallbackHeight: 2000,
          contentHeight: 250,
        ),
        const Size(400, 250),
      );
    });

    test('treats a degenerate report as unmeasured rather than as empty', () {
      for (final height in <double>[0, 1]) {
        expect(
          AirshipEmbeddedViewState.resolveSize(
            constraints: unboundedHeight,
            fallbackWidth: 1000,
            fallbackHeight: 2000,
            contentHeight: height,
          ),
          const Size(400, 2000),
          reason: 'a report of $height should not collapse the view',
        );
      }
    });

    test('an explicit parent height outranks a reported content height', () {
      expect(
        AirshipEmbeddedViewState.resolveSize(
          constraints: unboundedHeight,
          fallbackWidth: 1000,
          fallbackHeight: 2000,
          parentHeight: 132,
          contentHeight: 250,
        ),
        const Size(400, 132),
      );
    });

    test('an explicit parent width outranks the parent constraints', () {
      expect(
        AirshipEmbeddedViewState.resolveSize(
          constraints: bounded,
          fallbackWidth: 1000,
          fallbackHeight: 2000,
          parentWidth: 320,
        ),
        const Size(320, 500),
      );
    });
  });
}
