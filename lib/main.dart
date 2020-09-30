import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  final Client client = Client();
  final Account account = Account(client);
  final Storage storage = Storage(client);

  //the value isn't being used, so commenting out for now
  // final Database database = Database(client);

  client
      .setEndpoint(
        'https://localhost/v1',
      ) // Make sure your endpoint is accessible from your emulator, use IP if needed
      .setProject('5e8cf4f46b5e8') // Your project ID
      .setSelfSigned(); // Do not use this in production

  runApp(
    MaterialApp(
      home: Playground(
        client: client,
        account: account,
        storage: storage,
      ),
    ),
  );
}

class Playground extends StatefulWidget {
  const Playground({
    this.client,
    this.account,
    this.storage,
    this.database,
    Key key,
  }) : super(key: key);
  final Client client;
  final Account account;
  final Storage storage;
  final Database database;

  @override
  PlaygroundState createState() => PlaygroundState();
}

class PlaygroundState extends State<Playground> {
  String username = 'Loading...';

  @override
  void initState() {
    super.initState();

    widget.account.get().then((response) {
      setState(() {
        username = '${response.data['name']}';
      });
    }).catchError((error) {
      debugPrint(error.toString());
      setState(() {
        username = 'Anonymous User';
      });
    });

    FilePicker.getFile(
      type: FileType.image,
    ).then(
      (response) {
        MultipartFile.fromFile(
          response.path,
          filename: response.path.split('/').last,
        ).then((response) {
          widget.storage.createFile(
            file: response,
            read: ['*'],
            write: [],
          ).then((response) {
            debugPrint(response.toString());
          }).catchError((error) {
            debugPrint(error.response.toString());
          });
        }).catchError((error) {
          debugPrint(error.toString());
        });
      },
    ).catchError((error) {
      debugPrint(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appwrite + Flutter = ❤️'),
        backgroundColor: Colors.pinkAccent[200],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0),
            ),
            ButtonTheme(
              minWidth: 280.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.grey,
                onPressed: () {
                  widget.account
                      .createSession(email: 'test2@appwrite.io', password: 'eldad12')
                      .then((value) {
                    debugPrint(value.toString());
                  }).catchError((error) {
                    debugPrint(error.message.toString());
                  });
                },
                child: Text(
                  'Login with Email',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
            ),
            ButtonTheme(
              minWidth: 280.0,
              height: 50.0,
              child: RaisedButton(
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
                        debugPrint(error.response.toString());
                      });
                },
                child: Text(
                  'Create Doc',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            ButtonTheme(
              minWidth: 280.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: () {
                  widget.account
                      .createOAuth2Session(
                        provider: 'facebook',
                      )
                      .then((value) => widget.account
                          .get()
                          .then((response) => setState(() {
                                username = '${response.data['name']}';
                              }))
                          .catchError((error) => setState(() {
                                username = 'Anonymous User';
                              })));
                },
                child: Text(
                  'Login with Facebook',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            ButtonTheme(
              minWidth: 280.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.black87,
                onPressed: () {
                  widget.account
                      .createOAuth2Session(
                        provider: 'github',
                        success: '',
                        failure: '',
                      )
                      .then(
                        (value) => widget.account
                            .get()
                            .then((response) => setState(() {
                                  username = '${response.data['name']}';
                                }))
                            .catchError((error) => setState(() {
                                  username = 'Anonymous User';
                                })),
                      );
                },
                child: Text(
                  'Login with GitHub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
            ),
            ButtonTheme(
              minWidth: 280.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.red,
                onPressed: () {
                  widget.account
                      .createOAuth2Session(
                        provider: 'google',
                      )
                      .then(
                        (value) => widget.account
                            .get()
                            .then((response) => setState(() {
                                  username = '${response.data['name']}';
                                }))
                            .catchError((error) => setState(() {
                                  username = 'Anonymous User';
                                })),
                      );
                },
                child: Text(
                  'Login with Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            Text(
              username,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
            ButtonTheme(
              minWidth: 280.0,
              height: 50.0,
              child: RaisedButton(
                color: Colors.red[700],
                onPressed: () {
                  widget.account
                      .deleteSession(
                        sessionId: 'current',
                      )
                      .then((response) => setState(() {
                            username = 'Anonymous User';
                          }))
                      .catchError(
                    (error) {
                      debugPrint('error');
                      debugPrint(error.response.toString());
                    },
                  );
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
            ),
          ],
        ),
      ),
    );
  }
}
