import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

void main() {
  Client client = Client();
  Account account = Account(client);

  client
      .setEndpoint('https://localhost/v1') // Your project ID
      .setProject('5e8cf4f46b5e8') // Your project ID
      .setSelfSigned()
  ;
  
  runApp(
    new MaterialApp(
      home: new Playground(account: account),
    )
  );
}

class Playground extends StatefulWidget {
  Playground({this.account});
  final Account account;

  @override
  PlaygroundState createState() => new PlaygroundState();
}

class PlaygroundState extends State<Playground> {

  String username = "Loading...";

  @override
  void initState() {
    widget.account.get()
      .then((response) {
        setState(() {
          username = response.data['name'];
        });
      })
      .catchError((error) {
        setState(() {
          username = 'Anonymous User';
        });
      });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(title: new Text("Appwrite + Flutter = ❤️"), backgroundColor: Colors.pinkAccent[200]),
      body: new Container(
        child: new Center(
          child: new Column(
            children: <Widget>[
              new Padding(padding: new EdgeInsets.all(20.0)),

              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: new RaisedButton(
                  child: new Text("Login with Facebook", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                  color: Colors.blue,
                  onPressed: () {
                    widget.account.createOAuth2Session(provider: 'facebook', success: '', failure: '')
                      .then((value) {
                          widget.account.get()
                          .then((response) {
                            setState(() {
                              username = response.data['name'];
                            });
                          })
                          .catchError((error) {
                            setState(() {
                              username = 'Anonymous User';
                            });
                          });
                      });
                  }
                ),
              ),

              new Padding(padding: new EdgeInsets.all(10.0)),

              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: new RaisedButton(
                  child: new Text("Login with GitHub", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                  color: Colors.black87,
                  onPressed: () {
                    widget.account.createOAuth2Session(provider: 'github', success: '', failure: '')
                      .then((value) {
                        widget.account.get()
                        .then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        })
                        .catchError((error) {
                          setState(() {
                            username = 'Anonymous User';
                          });
                        });
                      });
                  }
                ),
              ),

              new Padding(padding: new EdgeInsets.all(10.0)),

              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: new RaisedButton(
                  child: new Text("Login with Google", style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                  color: Colors.red,
                  onPressed: () {
                    widget.account.createOAuth2Session(provider: 'google', success: '', failure: '')
                      .then((value) {
                        widget.account.get()
                        .then((response) {
                          setState(() {
                            username = response.data['name'];
                          });
                        })
                        .catchError((error) {
                          setState(() {
                            username = 'Anonymous User';
                          });
                        });
                      });
                  }
                ),
              ),
              
              new Padding(padding: new EdgeInsets.all(20.0)),
              new Divider(),
              new Padding(padding: new EdgeInsets.all(20.0)),
              
              new Text(username, style: new TextStyle(color: Colors.black, fontSize: 20.0)),
              
              new Padding(padding: new EdgeInsets.all(20.0)),
              new Divider(),
              new Padding(padding: new EdgeInsets.all(20.0)),

              ButtonTheme(
                minWidth: 280.0,
                height: 50.0,
                child: new RaisedButton(
                  child: new Text('Logout', style: new TextStyle(color: Colors.white, fontSize: 20.0)),
                  color: Colors.red[700],
                  onPressed: () {
                    widget.account.deleteSession(sessionId: 'current')
                      .then((response) {
                        setState(() {
                          username = 'Anonymous User';
                        });
                      }).catchError((error) {
                        print('error');
                        print(error.response.data);
                      });
                  }
                ),
              ),
            ]
          )
        )
      )
    );
  }
}