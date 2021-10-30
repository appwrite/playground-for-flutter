import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:playground_for_flutter/playground.dart';

void main() {
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Database database = Database(client);

  client
          .setEndpoint(
              'https://localhost/v1') // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject('60793ca4ce59e') // Your project ID
          .setSelfSigned() // Do not use this in production
      // .addHeader('Origin', 'http://localhost')
      ;

  runApp(MaterialApp(
    home: Playground(
      client: client,
      account: account,
      storage: storage,
      database: database,
    ),
  ));
}
