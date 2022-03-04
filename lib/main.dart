import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:appwrite/models.dart';

void main() {
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Database database = Database(client);

  client
          .setEndpoint(
              'https://localhost/v1') // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject('[YOUR PROJECT ID]') // Your project ID
          .setSelfSigned() // Do not use this in production
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

class Playground extends StatefulWidget {
  Playground(
      {required this.client,
      required this.account,
      required this.storage,
      required this.database});
  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

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

  _uploadFile() {
    FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false)
        .then((response) {
      if (response == null) return;
      final file = response.files.single;
      if (!kIsWeb) {
        final path = file.path;
        if (path == null) return;
        InputFile inFile = InputFile(path: file.path, filename: file.name);
        widget.storage.createFile(
            bucketId: 'testbucket',
            fileId: "unique()",
            file: inFile,
            read: [user != null ? "user:${user!.$id}" : '*'],
            write: ['*', 'role:member']).then((response) {
          print(response);
          setState(() {
            uploadedFile = response;
          });
        }).catchError((error) {
          print(error.message);
        }, test: (e) => e is AppwriteException);
      } else {
        if (file.bytes == null) return;
        List<int>? bytes = file.bytes?.map((i) => i).toList();
        final uploadFile =
            MultipartFile.fromBytes('file', bytes!, filename: file.name);
        widget.storage.createFile(
          bucketId: 'testbucket',
          fileId: "unique()",
          file: InputFile(file: uploadFile),
          read: [user != null ? "user:${user!.$id}" : '*'],
          write: ['*', 'role:member'],
        ).then((response) {
          print(response);
          setState(() {
            uploadedFile = response;
          });
        }).catchError((error) {
          print(error.message);
        }, test: (e) => e is AppwriteException);
      }
    }).catchError((error) {
      print(error);
    });
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
          title: Text("Appwrite + Flutter = ❤️"),
          backgroundColor: Colors.pinkAccent[200]),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                  child: Text(
                    "Anonymous Login",
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account.createAnonymousSession().then((value) {
                      print(value.toMap());
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  }),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  child: Text(
                    "Login with Email",
                    style: TextStyle(color: Colors.black, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account
                        .createSession(
                            email: 'user@appwrite.io', password: 'password')
                        .then((value) {
                      print(value.toMap());
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  }),
              Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                child: Text(
                  subscription != null ? "Unsubscribe" : "Subscribe",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(280, 50),
                  primary: Colors.blue,
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: subscription != null ? _unsubscribe : _subscribe,
              ),
              if (realtimeEvent != null) ...[
                const SizedBox(height: 10.0),
                Text(realtimeEvent!),
              ],
              const SizedBox(height: 30.0),
              ElevatedButton(
                  child: Text(
                    "Create Doc",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(280, 50),
                    primary: Colors.blue,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () {
                    widget.database
                        .createDocument(
                            collectionId:
                                'usernames', //change your collection id
                            documentId: 'unique()',
                            data: {'username': 'hello2'},
                            read: ['role:all'],
                            write: ['role:all'])
                        .then((value) => value.convertTo<MyDocument>((map) =>
                            MyDocument.fromMap(Map<String, dynamic>.from(map))))
                        .then((value) => print(value.userName))
                        .catchError((error) {
                          print(error.message);
                        }, test: (e) => e is AppwriteException);
                  }),
              const SizedBox(height: 10.0),
              ElevatedButton(
                  child: Text(
                    "Upload file",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () {
                    _uploadFile();
                  }),
              Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () async {
                    try {
                      jwt = await widget.account.createJWT();
                      setState(() {});
                    } on AppwriteException catch (e) {
                      print(e.message);
                    }
                  },
                  child: Text("Generate JWT",
                      style: TextStyle(color: Colors.white, fontSize: 20.0))),
              const SizedBox(height: 20.0),
              if (jwt != null) ...[
                SelectableText(
                  jwt!.jwt,
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 20.0),
              ],
              ElevatedButton(
                  child: Text(
                    "Login with Facebook",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account
                        .createOAuth2Session(
                            provider: 'discord',
                            success: 'http://localhost:43663/auth.html')
                        .then((value) {
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  }),
              Padding(padding: EdgeInsets.all(10.0)),
              ElevatedButton(
                  child: Text(
                    "Login with GitHub",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black87,
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account
                        .createOAuth2Session(
                            provider: 'github', success: '', failure: '')
                        .then((value) {
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  }),
              Padding(padding: EdgeInsets.all(10.0)),
              ElevatedButton(
                  child: Text(
                    "Login with Google",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
                  ),
                  onPressed: () {
                    widget.account
                        .createOAuth2Session(provider: 'google')
                        .then((value) {
                      _getAccount();
                    }).catchError((error) {
                      print(error.message);
                    }, test: (e) => e is AppwriteException);
                  }),
              if (user != null && uploadedFile != null)
                FutureBuilder<Uint8List>(
                  future: widget.storage.getFilePreview(bucketId: 'testbucket', fileId: uploadedFile!.$id, width: 300),
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
                    return CircularProgressIndicator();
                  },
                ),
              Padding(padding: EdgeInsets.all(20.0)),
              Divider(),
              Padding(padding: EdgeInsets.all(20.0)),
              Text(username,
                  style: TextStyle(color: Colors.black, fontSize: 20.0)),
              Padding(padding: EdgeInsets.all(20.0)),
              Divider(),
              Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                  child: Text('Logout',
                      style: TextStyle(color: Colors.white, fontSize: 20.0)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red[700],
                    padding: const EdgeInsets.all(16),
                    minimumSize: Size(280, 50),
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
                  }),
              Padding(padding: EdgeInsets.all(20.0)),
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
