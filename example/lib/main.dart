import 'dart:async';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';
import 'package:qiscus_sdk_example/chat_page.dart';
import 'package:qiscus_sdk_example/locator.dart';

void main() {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  int roomId;
  int unread = 0;
  String username = "";
  QiscusAccount qiscusAccount;

  String ACCESS_TOKEN =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjM3YjFlZjNkNTMxNmVlMGE1ZjJlNjQ0ODQ1YmZmN2IwNmYwMzViNzBmZTk5M2NkMzkzZjYyOTk5NDA2ODg0OTVlY2NkNmIzYjE4ZjEyODJiIn0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiIzN2IxZWYzZDUzMTZlZTBhNWYyZTY0NDg0NWJmZjdiMDZmMDM1YjcwZmU5OTNjZDM5M2Y2Mjk5OTQwNjg4NDk1ZWNjZDZiM2IxOGYxMjgyYiIsImlhdCI6MTU4NjI1MTE4NiwibmJmIjoxNTg2MjUxMTg2LCJleHAiOjE2MTc3ODcxODYsInN1YiI6IjVkYTNmN2U2ZjQ4YzNkMTc1NjQ5Mzg4YiIsInNjb3BlcyI6WyJmcmVlIl19.UM5bMUfjGi3iQ7BmSiKSjzMmSQAeVpjbJni8tzyq65F0qTrZzmtXjeAUKpXpIkWLM-jC0yU0qpHuCL5W8iw8kCumYLyzlf6AXk639vpobt1qmbAjVWzTrndjkg6O4dKFC9RuidAG2uH2BnDplUqm8t6EfBUfRcvEVrq7w5ulQ2gbwb9EbBrQsUtmt9mbOoqhOVgOPf1GCLgXqj5SjHGMjKcj485igdklLySBwUNsVWtntuHw3VoMZkoRbavToAYxMUZTCtdNq-LLfFR3epp3RUuuAoltUSKnLpt9JHOq67quYt8Wh4fDN7UGA-jOWX_r09wy4BWJvqPvRsE0B1Jqzfkull_66rv4iO1y82LAvoDnVYmXQu_CtkBD083n-4f1RtahxtDOyYHDPDWSmN0BNWyNEF4AFORe3TOZ1ay8n8-nM565LGsZ2ttrwtIyd720iZn9BGiRcRyv695yz7l_866szc5aV3QR-A8o9eR-hdtAYxstMcbUZI0WL57hZ1wMdJdKe0UB29otK-VjvBjgAt_AMZ7zP7TE-kgVV8GW7b17WEl7OVB8bBZTJ2KNZNZ7jNwpJa4DhAEHO92me_sLKOVirwPcxX1fkWo3RTRhH0rK2NHRfEf-i69pYot8FnepU0OY5vVCZFu_71A6OAM_kJwhxXUusfKT8tAVx0-COuE";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await ChatSdk.setup(appId: "testappdu-dktm3ffo7mg");
    await ChatSdk.enableDebugMode(true);
    await ChatSdk.enableFcmPushNotification(true);
    try {
      qiscusAccount = await ChatSdk.getQiscusAccount();
      setState(() {
        username = qiscusAccount.username;
      });
    } on Exception catch (e) {
      /// add logic if user hasn't login here
      /// example : loginWithJWT with REST API access token
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: ListView(
            children: [
              Column(
                children: <Widget>[
                  Center(
                    child: Text('User log on: $username\n'),
                  ),
                  RaisedButton(
                    child: Text('Logout'),
                    onPressed: () async {
                      await ChatSdk.clearUser();
                      setState(() {
                        username = '';
                      });
                    },
                  ),
                  RaisedButton(
                    child: Text('Login  Darwin'),
                    onPressed: () async {
                      //QiscusChatSdk.enableFcmPushNotification(true);
                      qiscusAccount = await ChatSdk.login(
                          userId: "darwinwu134", userKey: "dndndn", username: "Darwin 134");
                      print("acc:${qiscusAccount.toJson()}");
                      setState(() {
                        username = qiscusAccount.username;
                      });
                      // QiscusChatSdk.registerDeviceToken("asasdasd");
                      //QiscusChatSdk.clearUser();
                    },
                  ),
                  RaisedButton(
                    child: Text('Login  Edwin'),
                    onPressed: () async {
                      qiscusAccount = await loginWithJwt();
                      print("acc:${qiscusAccount.toJson()}");
                      setState(() {
                        username = qiscusAccount.username;
                      });
                    },
                  ),
                  RaisedButton(
                    child: Text('Update Pret'),
                    onPressed: () async {
                      ChatSdk.updateUser(
                          username: "Mr. Darwin X",
                          avatarUrl:
                              "https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png",
                          extras: {'key': "konci bos"});
                    },
                  ),
                  RaisedButton(
                    child: Text('all Users'),
                    onPressed: () async {
                      ChatSdk.getAllUsers(searchUsername: 'darwin');
                    },
                  ),
                  RaisedButton(
                    child: Text('Chat User Edwin'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.chatUser(userId: '5da3f7e6f48c3d175649388b');
                      print("chatRoom Id : ${chatRoom.id}");
                      roomId = chatRoom.id;
                      // if wanna test offline mode remove the comment below
                      //roomId = 11315282;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            roomId: roomId,
                            roomName: 'Edwin  Fadilah',
                            senderAccount: qiscusAccount,
                          ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Chat User Darwin'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.chatUser(userId: 'darwinwu134');
                      print("chatRoom Id : ${chatRoom.id}");
                      roomId = chatRoom.id;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            roomId: roomId,
                            roomName: 'Darwin wu',
                            senderAccount: qiscusAccount,
                          ),
                        ),
                      );
                    },
                  ),
                  RaisedButton(
                    child: Text('Chat with Messages'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.getChatRoomWithMessages(roomId);
                      print("chat with messages : $chatRoom");
                    },
                  ),
                  RaisedButton(
                    child: Text('get local chat room'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.getLocalChatRoom(11315282);
                      print("local chat room : $chatRoom");
                    },
                  ),
                  RaisedButton(
                    child: Text('get local chat room by RoomIds'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.getLocalChatRoomByIds([11315282]);
                      print("local chat room ids : $chatRoom");
                    },
                  ),
                  RaisedButton(
                    child: Text('get All chat rooms'),
                    onPressed: () async {
                      List<QiscusChatRoom> chatRoom =
                          await ChatSdk.getAllChatRooms(showEmpty: true);
                      dev.log(" all chat room : $chatRoom");
                      dev.log(" all chat room : ${chatRoom[0].lastComment.time.toLocal()}");
                      dev.log(" all chat room : ${DateTime.now().timeZoneOffset}");
                    },
                  ),
                  RaisedButton(
                    child: Text('get Local chat rooms with Limit, offset'),
                    onPressed: () async {
                      List<QiscusChatRoom> chatRoom =
                          await ChatSdk.getLocalChatRooms(limit: 100, offset: 0);
                      dev.log("local all chat room limit offset: $chatRoom");
                    },
                  ),
                  RaisedButton(
                    child: Text('get Local chat rooms with Limit '),
                    onPressed: () async {
                      List<QiscusChatRoom> chatRoom = await ChatSdk.getLocalChatRooms();
                      dev.log("local all chat room  limit: $chatRoom");
                    },
                  ),
                  RaisedButton(
                    child: Text('Refresh unread count '),
                    onPressed: () async {
                      int temp = await ChatSdk.getTotalUnreadCount();

                      setState(() {
                        unread = temp;
                      });
                    },
                  ),
                  Text("uread : $unread"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<QiscusAccount> loginWithJwt() {
    return ChatSdk.loginWithJWT((String nonce) async {
      Dio dio = Dio();
      BaseOptions baseOptions = new BaseOptions();
      Map<String, dynamic> headerJson = {
        'Authorization': "Bearer $ACCESS_TOKEN",
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      baseOptions.connectTimeout = 30000;
      baseOptions.receiveTimeout = 30000;
      baseOptions.headers = headerJson;
      dio.options = baseOptions;
      print("before dio");
      var response = await dio.get(
        "https://dev2.myislami.com/api/v1/consultation/chats/jwt",
        queryParameters: {'nonce': nonce},
      );
      String jwt = response.data['result']['jwt'];

      print("nonce: $nonce, jwt: $jwt");

      return jwt;
    });
  }
}
