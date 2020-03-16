import 'dart:async';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';
import 'package:qiscus_sdk_example/chat_page.dart';

void main() => runApp(MyApp());

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
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImYzMzg0YjI4NzczNmYzMmIxYWVhMDFjZTZlNzRkNDhjY2JhNzExNjIzZjIxMzAwYjdlZDk4YWUyNzM1ODU0MjllOGU4ZDk0ZmNiZjg0NDQwIn0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiJmMzM4NGIyODc3MzZmMzJiMWFlYTAxY2U2ZTc0ZDQ4Y2NiYTcxMTYyM2YyMTMwMGI3ZWQ5OGFlMjczNTg1NDI5ZThlOGQ5NGZjYmY4NDQ0MCIsImlhdCI6MTU4NDExOTExNiwibmJmIjoxNTg0MTE5MTE2LCJleHAiOjE2MTU2NTUxMTYsInN1YiI6IjVkYTNmN2U2ZjQ4YzNkMTc1NjQ5Mzg4YiIsInNjb3BlcyI6WyJmcmVlIl19.U0rF6cIpMjM88oSrLDtZP5ZxUhzSsUaZU5pbvB6KwpVyL8YsOGY4U0srUzPee0r1LzxSf-p8WNIuTrCQqfqb-CgNHPibxRl3kJyiGgmEcAoe46Z23LtSOM8AjgQd-RM7vIWOcgiftxfdGUBDWHxz5zVPhGh03sdqsYx6hvxzxN3NNu14u-c5C35w0QvvvEYBdZI-9gau0DgW1Vnd9mZwwyNHrzKCkX3e6BuIgLwOAu3NuBe1ev344yHCPAlUEXzqLxVPTCfJoVN8tau2U26xoB58v3nFsr_RagE5jkp1rPH91FR6fnw7ql_wR1wB3NplmuwobdlES2KHwmxeuIIMeTW2igObxOyt_a9x7l7-oiYYvasc_rvl-PKykugE1ERrsVVcE_qaGwe4-I1rkrhQBJ3TxNbLYGsBydaSQdy9Dm1-UObhg5V_4T31_6Xae-IrGgwPbTrbiChCZO58ya5cxR0z1bRAZsqhjqw_L2-_WZQsgvnbnQwjwKp7RVEr4G6HXAX3ID1X5otm-NQQFYEKvj1aNwE-KT_wv5Ym7cv-pOcuJes48DwMTuYf4Ag8_9PnVu0dQgzvuhJDPbGBgtTO6401rUgrQJppm0e52IaZTteXPHRcr-TFIt8kgkTJ-ceMbsGO7aWITLayIsTVO5EBsseYvrpwEggB_pbQgQVno50";

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    ChatSdk.startListeningToEventChannel();
    await ChatSdk.setup(appId: "testapp-hl5q64wriaulf");
    await ChatSdk.enableDebugMode(true);
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
        builder: (context) =>
            Scaffold(
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
                          final chatRoom = await ChatSdk.chatUser(
                              userId: '5da3f7e6f48c3d175649388b');
                          print("chatRoom Id : ${chatRoom.id}");
                          roomId = chatRoom.id;
                          await ChatSdk.addOrUpdateLocalChatRoom(chatRoom);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(
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
                          await ChatSdk.addOrUpdateLocalChatRoom(chatRoom);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatPage(
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
                          dev.log(" all chat room : ${DateTime
                              .now()
                              .timeZoneOffset}");
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
