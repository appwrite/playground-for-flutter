import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:playground_for_flutter/splited_widgets/custom_elevatedbutton.dart';

class Playground extends StatefulWidget {
  Playground({
    required this.client,
    required this.account,
    required this.storage,
    required this.database,
  });

  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";
  Map<String, dynamic>? user;
  Map<String, dynamic>? uploadedFile;
  String? jwt;
  String? realtimeEvent;
  RealtimeSubscription? subscription;

  @override
  void initState() {
    _getAccount();
    super.initState();
  }

  _getAccount() async {
    try {
      final response = await widget.account.get();
      if (response.data['email'] == null || response.data['email'] == '') {
        username = "Anonymous Login";
      } else {
        username = response.data['name'];
      }
      user = response.data;
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
        MultipartFile.fromPath('file', path, filename: file.name)
            .then((response) {
          widget.storage.createFile(
              file: response,
              read: [user != null ? "user:${user!['\$id']}" : '*'],
              write: ['*', 'role:member']).then((response) {
            print(response);
            setState(() {
              uploadedFile = response.data;
            });
          }).catchError((error) {
            print(error.message);
          }, test: (e) => e is AppwriteException);
        }).catchError((error) {
          print(error.message);
        }, test: (e) => e is AppwriteException);
      } else {
        if (file.bytes == null) return;
        List<int>? bytes = file.bytes?.map((i) => i).toList();
        final uploadFile =
            MultipartFile.fromBytes('file', bytes!, filename: file.name);
        widget.storage.createFile(
          file: uploadFile,
          read: [user != null ? "user:${user!['\$id']}" : '*'],
          write: ['*', 'role:member'],
        ).then((response) {
          print(response);
          setState(() {
            uploadedFile = response.data;
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
        backgroundColor: Colors.pinkAccent[200],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              padding(context),
              CustomElevatedButton(
                buttonname: "Anonymous Login",
                textcolor: Colors.black,
                buttoncolor: HexColor('#dadcd3'),
                onpressed: () {
                  widget.account.createAnonymousSession().then((value) {
                    print(value);
                    _getAccount();
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              const SizedBox(height: 10.0),
              CustomElevatedButton(
                buttonname: "Login with Email",
                textcolor: Colors.black,
                buttoncolor: HexColor('#5D5D5D'),
                onpressed: () {
                  widget.account
                      .createSession(
                          email: 'testuser@appwrite.io', password: 'password')
                      .then((value) {
                    print(value);
                    _getAccount();
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              padding(context),
              CustomElevatedButton(
                buttonname: subscription != null ? "Unsubscribe" : "Subscribe",
                textcolor: Colors.white,
                buttoncolor: Colors.blue,
                onpressed: subscription != null ? _unsubscribe : _subscribe,
              ),
              if (realtimeEvent != null) ...[
                const SizedBox(height: 10.0),
                Text(realtimeEvent!),
              ],
              const SizedBox(height: 30.0),
              CustomElevatedButton(
                buttonname: "Create Doc",
                textcolor: Colors.white,
                buttoncolor: HexColor('#4a86e8'),
                onpressed: () {
                  widget.database.createDocument(
                    collectionId: '608faab562521', //change your collection id
                    data: {'username': 'hello2'},
                    read: ['*'],
                    write: ['*'],
                  ).then((value) {
                    print(value);
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              const SizedBox(height: 10.0),
              CustomElevatedButton(
                buttonname: "Upload file",
                textcolor: Colors.white,
                buttoncolor: Colors.blue,
                onpressed: () {
                  _uploadFile();
                },
              ),
              padding(context),
              CustomElevatedButton(
                buttonname: "Generate JWT",
                textcolor: Colors.white,
                onpressed: () async {
                  try {
                    final res = await widget.account.createJWT();
                    setState(() {
                      jwt = res.data.toString();
                    });
                  } on AppwriteException catch (e) {
                    print(e.message);
                  }
                },
              ),
              const SizedBox(height: 20.0),
              if (jwt != null) ...[
                SelectableText(
                  jwt!,
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 20.0),
              ],
              CustomElevatedButton(
                buttonname: "Login with Facebook",
                textcolor: Colors.white,
                buttoncolor: HexColor('#3b5998'),
                onpressed: () {
                  widget.account
                      .createOAuth2Session(provider: 'facebook')
                      .then((value) {
                    widget.account.get().then((response) {
                      setState(() {
                        username = response.data['name'];
                      });
                    }).catchError(
                      (error) {
                        setState(() {
                          username = 'Anonymous User';
                        });
                      },
                      test: (e) => e is AppwriteException,
                    );
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              padding(context),
              CustomElevatedButton(
                buttonname: "Login with GitHub",
                textcolor: Colors.white,
                buttoncolor: HexColor('#333333'),
                onpressed: () {
                  widget.account
                      .createOAuth2Session(
                          provider: 'github', success: '', failure: '')
                      .then((value) {
                    widget.account.get().then((response) {
                      setState(() {
                        username = response.data['name'];
                      });
                    }).catchError(
                      (error) {
                        print(error.message);
                        setState(() {
                          username = 'Anonymous User';
                        });
                      },
                      test: (e) => e is AppwriteException,
                    );
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              padding(context),
              CustomElevatedButton(
                buttonname: "Login with Google",
                textcolor: Colors.white,
                buttoncolor: HexColor('#db4a39'),
                onpressed: () {
                  widget.account
                      .createOAuth2Session(provider: 'google')
                      .then((value) {
                    widget.account.get().then((response) {
                      setState(() {
                        username = response.data['name'];
                      });
                    }).catchError(
                      (error) {
                        print(error.message);
                        setState(() {
                          username = 'Anonymous User';
                        });
                      },
                      test: (e) => e is AppwriteException,
                    );
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              if (user != null && uploadedFile != null)
                FutureBuilder<Response>(
                  future: widget.storage.getFileView(
                    fileId: uploadedFile!['\$id'],
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data?.data);
                    }
                    if (snapshot.hasError) {
                      if (snapshot.error is AppwriteException) {
                        print(
                          (snapshot.error as AppwriteException).message,
                        );
                      }
                      print(snapshot.error);
                    }
                    return CircularProgressIndicator();
                  },
                ),
              dividerPadding(context),
              Text(
                username,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                ),
              ),
              dividerPadding(context),
              CustomElevatedButton(
                buttonname: 'Logout',
                textcolor: Colors.white,
                buttoncolor: HexColor('#B23B3B'),
                onpressed: () {
                  widget.account
                      .deleteSession(sessionId: 'current')
                      .then((response) {
                    setState(() {
                      username = 'No Session';
                    });
                  }).catchError(
                    (error) {
                      print(error.message);
                    },
                    test: (e) => e is AppwriteException,
                  );
                },
              ),
              padding(context),
            ],
          ),
        ),
      ),
    );
  }
}

dividerPadding(BuildContext context) {
  return Column(children: <Widget>[
    Padding(padding: EdgeInsets.all(20.0)),
    Divider(),
    Padding(padding: EdgeInsets.all(20.0)),
  ]);
}

padding(BuildContext context) {
  return Padding(padding: EdgeInsets.all(20.0));
}
