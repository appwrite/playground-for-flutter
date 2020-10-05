import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  Client client = Client();
  Account account = Account(client);
  Storage storage = Storage(client);
  Database database = Database(client);

  client.setEndpoint(
              'https://localhost/v1') // Make sure your endpoint is accessible from your emulator, use IP if needed
          .setProject('5e8cf4f46b5e8') // Your project ID
          .setSelfSigned(); // Do not use this in production

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]
  );

  runApp(MaterialApp(
    title: "AppwriteFlutter",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.pinkAccent[200],
      backgroundColor: Colors.white,
      dividerColor: Colors.grey,
    ),
    home: Playground(client: client, account: account, storage: storage),
  ));
}

class Playground extends StatefulWidget {
  Playground({this.client, this.account, this.storage, this.database});
  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = "Loading...";

  @override
  void initState() {
    widget.account.get().then((response) {
      setState(() {
        username = response.data['name'];
      });
    }).catchError((error) {
      print(error);
      setState(() {
        username = 'Anonymous User';
      });
    });

    FilePicker.getFile(type: FileType.image).then((response) {
      MultipartFile.fromFile(response.path,
              filename: response.path.split('/').last)
          .then((response) {
        widget.storage.createFile(file: response, read: ['*'], write: []).then(
            (response) {
          print(response);
        }).catchError((error) {
          print(error.response);
        });
      }).catchError((error) {
        print(error);
      });
    }).catchError((error) {
      print(error);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Center(child: Text("Appwrite + Flutter = ❤️")),
            backgroundColor: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Container(
              child: SingleChildScrollView(
                  child: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.all(20.0)),
                        ButtonTheme(
                          minWidth: 280.0,
                          height: 50.0,
                          child: RaisedButton(
                              child: Text("Login with Email", style: TextStyle(
                                  color: Colors.black, fontSize: 20.0)
                              ),
                              color: Colors.grey,
                              onPressed: () {
                                widget.account.createSession(
                            email: 'test2@appwrite.io', password: 'eldad12')
                        .then((value) {
                          print(value);
                        }).catchError((error) {
                          print(error.message);
                        });
                              }),
                        ),
                        Padding(padding: EdgeInsets.all(20.0)),
                        ButtonTheme(
                          minWidth: 280.0,
                          height: 50.0,
                          child: RaisedButton(
                              child: Text("Create Doc",
                                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
                              color: Colors.blue,
                              onPressed: () {
                                widget.database
                                    .createDocument(
                                    collectionId: '5f2e3c52f03c0',
                                    data: {'username': 'hello2'},
                                    read: ['*'],
                                    write: ['*'])
                                    .then((value) {})
                                    .catchError((error) {
                                  print(error.response);
                                });
                              }),
                        ),
                        Padding(padding: EdgeInsets.all(20.0)),
                        ButtonTheme(
                          minWidth: 280.0,
                          height: 50.0,
                          child: RaisedButton(
                              child: Text("Login with Facebook",
                                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
                              color: Colors.blue,
                              onPressed: () {
                                widget.account
                                    .createOAuth2Session(provider: 'facebook')
                                    .then((value) {
                                  widget.account.get().then((response) {
                                    setState(() {
                                      username = response.data['name'];
                                    });
                                  }).catchError((error) {
                                    setState(() {
                                      username = 'Anonymous User';
                                    });
                                  });
                                });
                              }),
                        ),
                        Padding(padding: EdgeInsets.all(20.0)),
                        ButtonTheme(
                          minWidth: 280.0,
                          height: 50.0,
                          child: RaisedButton(
                              child: Text("Login with GitHub",
                                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
                              color: Colors.black87,
                              onPressed: () {
                                widget.account
                                    .createOAuth2Session(
                                    provider: 'github', success: '', failure: '')
                                    .then((value) {
                                  widget.account.get().then((response) {
                                    setState(() {
                                      username = response.data['name'];
                                    });
                                  }).catchError((error) {
                                    setState(() {
                                      username = 'Anonymous User';
                                    });
                                  });
                                });
                              }),
                        ),
                        Padding(padding: EdgeInsets.all(20.0)),
                        ButtonTheme(
                          minWidth: 280.0,
                          height: 50.0,
                          child: RaisedButton(
                              child: Text("Login with Google",
                                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
                              color: Colors.red,
                              onPressed: () {
                                widget.account
                                    .createOAuth2Session(provider: 'google')
                                    .then((value) {
                                  widget.account.get().then((response) {
                                    setState(() {
                                      username = response.data['name'];
                                    });
                                  }).catchError((error) {
                                    setState(() {
                                      username = 'Anonymous User';
                                    });
                                  });
                                });
                              }),
                        ),
                        Padding(padding: EdgeInsets.all(15.0)),
                        Divider(),
                        Padding(padding: EdgeInsets.all(15.0)),
                        Text(username, style: TextStyle(color: Colors.black, fontSize: 20.0)),
                        Padding(padding: EdgeInsets.all(15.0)),
                        Divider(),
                        Padding(padding: EdgeInsets.all(15.0)),
                        ButtonTheme(
                          minWidth: 280.0,
                          height: 50.0,
                          child: RaisedButton(
                              child: Text('Logout',
                                  style: TextStyle(color: Colors.white, fontSize: 20.0)),
                              color: Colors.red[700],
                              onPressed: () {
                                widget.account
                                    .deleteSession(sessionId: 'current')
                                    .then((response) {
                                  setState(() {
                                    username = 'Anonymous User';
                                  });
                                }).catchError((error) {
                                  print('error');
                                  print(error.response);
                                }
                                );
                              }
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(20.0)),
                      ]
                  )
              )
          ),
        )
    );
  }
}
