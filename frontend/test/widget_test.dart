import 'package:flutter_test/flutter_test.dart';

import 'package:autown26/widgets/common.dart';

void main() {
  test('iconFor falls back for unknown names', () {
    expect(iconFor('does-not-exist'), isNotNull);
  });
}
