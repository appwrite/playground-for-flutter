// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playground_for_flutter/main.dart';

void main() {
  testWidgets('Playground loads', (WidgetTester tester) async {
    Client client = Client();
    Account account = Account(client);
    Databases databases = Databases(client);
    Storage storage = Storage(client);
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
        home: Playground(
      client: client,
      account: account,
      database: databases,
      storage: storage,
    )));

    expect(find.text('Anonymous Login'), findsOneWidget);
  });
}
