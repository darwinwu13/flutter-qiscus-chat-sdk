import 'dart:async';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';
import 'package:qiscus_sdk_example/chat_page.dart';
import 'package:qiscus_sdk_example/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator().then((bool value) {
    runApp(MyApp());
  });
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
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImI3NzhiM2RmMGRhNDkzYjQzMmY0ZGU0ZDIzMzA3N2U2MTY4NjE3ZjhkN2UzNmI5NWI3M2FmMTZlNGE1MTZkMWU5NjFjN2ZlMjE0ZDM5ZGU3In0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiJiNzc4YjNkZjBkYTQ5M2I0MzJmNGRlNGQyMzMwNzdlNjE2ODYxN2Y4ZDdlMzZiOTViNzNhZjE2ZTRhNTE2ZDFlOTYxYzdmZTIxNGQzOWRlNyIsImlhdCI6MTU4NjU5MTIyNSwibmJmIjoxNTg2NTkxMjI1LCJleHAiOjE2MTgxMjcyMjUsInN1YiI6IjVkYTNmN2U2ZjQ4YzNkMTc1NjQ5Mzg4YiIsInNjb3BlcyI6WyJmcmVlIl19.k4nQNbbKKJeYHW8iblyuahh8zGDc2iavaojo297gsSZDXeDz97LbHrFBttRN35rzaf7jMLPq-hCrD_i2vgXKH82-Yo1hT0MqxDpACuzUoAsZU3hRuO0lhCBpGfi8a82BwMUwpGj8cT7ZKY_vC5_zq42Pzi5h_af5P7EAyTougn0k_pLgfSiLkZR9ltrgWrtO5J_CRcxueQDp0eTNp0p7DkEuZvuLs2lKGGAFJ8XhW6lmmZUq5vEbcLtxdfsKHYXw4sviqVvgX8vbF-bBzVUt6I9TXB5sQpSRJ4D5wG3YTJbwZrSYydS4Hb7npIovTSkxEiXRri3vsqRD5mUU0IABmIM58RerqxHXCse2Ouqdaz1yNxJIzbkZb4Zr27k191zxC-jfGP8Gok8QCI1a1b6EG0LjwQwoB-eg1MjhfenY7UFrVRwrY68joN6PgF0F7VKEYHaeeBGsNJFQzBDqvOQ6deE_UrO9FOY26olTHvLUtgRQT8Q4lSmgvNH8hJdE4eWx4nLKOrLWHhcOefw2TMbcjbmH5EKu6lhMZLBpA487VVvMLQyFNDqLFzVa1tVdXRWjvsj3BNA8Sz3m8cqzI0U7ImN8yhNsh5trbkcbGUiwxJS1Xjy0vY3pGm3okRwQsRVvkJWAjKaN9CbYMuQGxMHB0Z4KTMb3ObzNafvHNIZYLJo";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
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
                      qiscusAccount = await ChatSdk.login(
                          userId: "darwinwu134", userKey: "dndndn", username: "Darwin 134");
                      print("acc:${qiscusAccount.toJson()}");
                      setState(() {
                        username = qiscusAccount.username;
                      });
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
                    child: Text('Chat User Chandra'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.chatUser(userId: '5dba91daf48c3d33bb41a6f5');
                      print("chatRoom Id : ${chatRoom.id}");
                      roomId = chatRoom.id;
                      // if wanna test offline mode remove the comment below
                      //roomId = 11315282;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            roomId: roomId,
                            roomName: 'Chandra',
                            senderAccount: qiscusAccount,
                          ),
                        ),
                      );
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
