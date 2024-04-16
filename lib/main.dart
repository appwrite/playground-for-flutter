import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_location_href/window_location_href.dart';

import 'constants.dart';

void main() {
  // required if you are initializing your client in main() like we do here
  WidgetsFlutterBinding.ensureInitialized();
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Databases databases = Databases(client);
  Realtime realtime = Realtime(client);

  client
          .setEndpoint(
              endpoint) // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject(project) // Your project ID
          .setSelfSigned() // Do not use this in production
      ;

  runApp(MaterialApp(
    home: Playground(
      client: client,
      account: account,
      storage: storage,
      database: databases,
      realtime: realtime,
    ),
  ));
}

class Playground extends StatefulWidget {
  const Playground({
    Key? key,
    required this.client,
    required this.account,
    required this.storage,
    required this.database,
    required this.realtime,
  }) : super(key: key);
  final Client client;
  final Account account;
  final Storage storage;
  final Databases database;
  final Realtime realtime;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";
  User? user;
  File? uploadedFile;
  Jwt? jwt;
  String? realtimeEvent;
  Map<int, RealtimeSubscription> subscriptions = {};
  final Uri? location = href == null ? null : Uri.parse(href!);
  String fileId = '644f756980c4c0dbacec';

  @override
  void initState() {
    _getAccount();
    super.initState();
    _listAndSubscribe();
  }

  _listAndSubscribe() async {
    try {
      final document = await widget.database.listDocuments(
        databaseId: ID.custom(databaseId),
        collectionId: ID.custom(collectionId), //change your collection id
      );
      for (var doc in document.documents) {
        _subscribe(
            ['databases.default.collections.usernames.documents.${doc.$id}']);
      }
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  _getAccount() async {
    try {
      user = await widget.account.get();
      if (user!.email.isEmpty) {
        username = "Anonymous Login";
      } else {
        username = user!.name;
      }
      user = user;
      setState(() {});
    } on AppwriteException catch (error) {
      print(error.message);
      setState(() {
        username = 'No Session';
      });
    }
  }

  _uploadFile() async {
    try {
      final response = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (response == null) return;
      final pickedFile = response.files.single;
      late InputFile inFile;
      if (kIsWeb) {
        inFile = InputFile.fromBytes(
          filename: pickedFile.name,
          bytes: pickedFile.bytes!,
        );
      } else {
        inFile = InputFile.fromPath(
          path: pickedFile.path!,
          filename: pickedFile.name,
        );
      }
      final file = await widget.storage.createFile(
        bucketId: ID.custom(bucketId),
        fileId: ID.unique(),
        file: inFile,
        permissions: [
          Permission.read(user != null ? Role.user(user!.$id) : Role.any()),
          Permission.write(Role.users())
        ],
      );
      print(file);
      setState(() {
        uploadedFile = file;
      });
    } on AppwriteException catch (e) {
      print(e.message);
    } catch (e) {
      print(e);
    }
  }

  _getHashCode(List<String> channels) {
    return channels
        .map((e) => e.hashCode)
        .reduce((value, element) => value.hashCode ^ element.hashCode);
  }

  _subscribe(List<String> channels) {
    // final realtime = Realtime(widget.client);
    final subscription = widget.realtime.subscribe(channels);
    subscription!.stream.listen((data) {
      print(data);
      setState(() {
        realtimeEvent = jsonEncode(data.toMap());
      });
    });

    setState(() {
      final hashCode = _getHashCode(channels);
      subscriptions[hashCode] = subscription;
    });
  }

  _unsubscribe(List<String> channels) {
    final hashCode = _getHashCode(channels);

    if (subscriptions.containsKey(hashCode)) {
      subscriptions[hashCode]!.close();
      setState(() {
        subscriptions.remove(hashCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Appwrite + Flutter = ❤️"),
          backgroundColor: Colors.pinkAccent[200]),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(280, 50),
                ),
                onPressed: () async {
                  try {
                    await widget.account.createAnonymousSession();
                    _getAccount();
                  } on AppwriteException catch (e) {
                    print(e.message);
                  }
                },
                child: const Text(
                  "Anonymous Login",
                  style: TextStyle(color: Colors.black, fontSize: 20.0),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(280, 50),
                  ),
                  onPressed: () async {
                    try {
                      await widget.account.createEmailPasswordSession(
                        email: 'user@appwrite.io',
                        password: 'password',
                      );
                      _getAccount();
                      print(user);
                    } on AppwriteException catch (e) {
                      print(e.message);
                    }
                  },
                  child: const Text(
                    "Login with Email",
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  )),
              const Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(280, 50),
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  for (var subscription in subscriptions.values) {
                    subscription.close();
                  }
                  setState(() {
                    subscriptions.clear();
                  });
                },
                child: const Text(
                  "Unsubscribe All",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              const Padding(padding: EdgeInsets.all(10.0)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(280, 50),
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () {
                  final channels = [
                    'databases.default.collections.usernames.documents'
                  ];
                  final hashCode = _getHashCode(channels);
                  if (subscriptions.containsKey(hashCode)) {
                    _unsubscribe(channels);
                  } else {
                    _subscribe(channels);
                  }
                },
                child: Text(
                  (subscriptions.containsKey(_getHashCode([
                    'databases.default.collections.usernames.documents'
                  ])))
                      ? "Unsubscribe"
                      : "Subscribe",
                  style: const TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              if (realtimeEvent != null) ...[
                const SizedBox(height: 10.0),
                Text(realtimeEvent!),
              ],
              const SizedBox(height: 30.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(280, 50),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    try {
                      final document = await widget.database.createDocument(
                        databaseId: ID.custom(databaseId),
                        collectionId:
                            ID.custom(collectionId), //change your collection id
                        documentId: ID.unique(),
                        data: {'username': 'hello2'},
                        permissions: [
                          Permission.read(Role.any()),
                          Permission.write(Role.any()),
                        ],
                      );
                      print(document.toMap());
                      _subscribe([
                        'databases.default.collections.usernames.documents.${document.$id}'
                      ]);
                    } on AppwriteException catch (e) {
                      print(e.message);
                    }
                  },
                  child: const Text(
                    "Create Doc",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(280, 50),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    try {
                      final document = await widget.database.listDocuments(
                        databaseId: ID.custom(databaseId),
                        collectionId:
                            ID.custom(collectionId), //change your collection id
                      );
                      for (var doc in document.documents) {
                        _subscribe([
                          'databases.default.collections.usernames.documents.${doc.$id}'
                        ]);
                      }
                    } on AppwriteException catch (e) {
                      print(e.message);
                    }
                  },
                  child: const Text(
                    "List Docs",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(280, 50),
                  ),
                  onPressed: () {
                    _uploadFile();
                  },
                  child: const Text(
                    "Upload file",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
              const Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(280, 50),
                  ),
                  onPressed: () async {
                    try {
                      jwt = await widget.account.createJWT();
                      setState(() {});
                    } on AppwriteException catch (e) {
                      print(e.message);
                    }
                  },
                  child: const Text("Generate JWT",
                      style: TextStyle(color: Colors.white, fontSize: 20.0))),
              const SizedBox(height: 20.0),
              if (jwt != null) ...[
                SelectableText(
                  jwt!.jwt,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 20.0),
              ],
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(280, 50),
                  ),
                  onPressed: () async {
                    try {
                      await widget.account.createOAuth2Session(
                        provider: OAuthProvider.discord,
                        success:
                            kIsWeb ? '${location?.origin}/auth.html' : null,
                      );
                      _getAccount();
                    } on AppwriteException catch (e) {
                      print(e.message);
                    }
                  },
                  child: const Text(
                    "Login with Discord",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
              const Padding(padding: EdgeInsets.all(10.0)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account
                        .createOAuth2Session(
                            provider: OAuthProvider.github,
                            success:
                                kIsWeb ? '${location?.origin}/auth.html' : null,
                            failure: '')
                        .then((value) {
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  },
                  child: const Text(
                    "Login with GitHub",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
              const Padding(padding: EdgeInsets.all(10.0)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                    minimumSize: const Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account
                        .createOAuth2Session(
                            provider: OAuthProvider.google,
                            success:
                                kIsWeb ? '${location?.origin}/auth.html' : null)
                        .then((value) {
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  },
                  child: const Text(
                    "Login with Google",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  )),
              // if (user != null )//&& uploadedFile != null)
              // FutureBuilder<String>(
              //   future: widget.storage.getFilePreview(
              //       bucketId: ID.custom(bucketId),
              //       fileId: ID.custom(fileId),
              //       width: 300),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       return Image.network(snapshot.data!);
              //     }
              //     if (snapshot.hasError) {
              //       if (snapshot.error is AppwriteException) {
              //         print((snapshot.error as AppwriteException).message);
              //       }
              //       print(snapshot.error);
              //     }
              //     return const CircularProgressIndicator();
              //   },
              // ),
              const Padding(padding: EdgeInsets.all(20.0)),
              const Divider(),
              const Padding(padding: EdgeInsets.all(20.0)),
              Text(username,
                  style: const TextStyle(color: Colors.black, fontSize: 20.0)),
              const Padding(padding: EdgeInsets.all(20.0)),
              const Divider(),
              const Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(280, 50),
                ),
                onPressed: () {
                  widget.account
                      .deleteSession(sessionId: 'current')
                      .then((response) {
                    setState(() {
                      username = 'No Session';
                    });
                  }).catchError((error) {
                    print(error.message);
                  }, test: (e) => e is AppwriteException);
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              const Padding(padding: EdgeInsets.all(20.0)),
            ],
          ),
        ),
      ),
    );
  }
}

class MyDocument {
  final String userName;
  final String id;
  MyDocument({
    required this.userName,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'id': id,
    };
  }

  factory MyDocument.fromMap(Map<String, dynamic> map) {
    return MyDocument(
      userName: map['username'],
      id: map['\$id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory MyDocument.fromJson(String source) =>
      MyDocument.fromMap(json.decode(source));

  @override
  String toString() => 'MyDocument(userName: $userName, id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MyDocument && other.userName == userName && other.id == id;
  }

  @override
  int get hashCode => userName.hashCode ^ id.hashCode;
}
