import 'package:flutter_test/flutter_test.dart';

import 'package:canvas_demo/main.dart';

void main() {
  testWidgets('Canvas editor renders core actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('标准打印板'), findsOneWidget);
    expect(find.text('打印'), findsOneWidget);
    expect(find.text('上传'), findsOneWidget);
    expect(find.text('文字'), findsOneWidget);
  });
}
