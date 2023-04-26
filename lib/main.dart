import 'dart:convert';

import 'package:appwrite/appwrite.dart';
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
  }) : super(key: key);
  final Client client;
  final Account account;
  final Storage storage;
  final Databases database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";
  User? user;
  File? uploadedFile;
  Jwt? jwt;
  String? realtimeEvent;
  RealtimeSubscription? subscription;
  final Uri? location = href == null ? null : Uri.parse(href!);

  @override
  void initState() {
    _getAccount();
    super.initState();
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

  _subscribe() {
    final realtime = Realtime(widget.client);
    subscription = realtime.subscribe(['files', 'documents']);
    setState(() {});
    subscription!.stream.listen((data) {
      print(data);
      setState(() {
        realtimeEvent = jsonEncode(data.toMap());
      });
    });
  }

  _unsubscribe() {
    subscription?.close();
    setState(() {
      subscription = null;
    });
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
                      await widget.account.createEmailSession(
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
                onPressed: subscription != null ? _unsubscribe : _subscribe,
                child: Text(
                  subscription != null ? "Unsubscribe" : "Subscribe",
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
                        provider: 'discord',
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
                            provider: 'github',
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
                            provider: 'google',
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
              if (user != null && uploadedFile != null)
                FutureBuilder<Uint8List>(
                  future: widget.storage.getFilePreview(
                      bucketId: ID.custom(bucketId),
                      fileId: ID.custom(uploadedFile!.$id),
                      width: 300),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data!);
                    }
                    if (snapshot.hasError) {
                      if (snapshot.error is AppwriteException) {
                        print((snapshot.error as AppwriteException).message);
                      }
                      print(snapshot.error);
                    }
                    return const CircularProgressIndicator();
                  },
                ),
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
