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
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImM0MjkwZjNmZDNhZDgzZjBmNzFkYTJhZTk4YWVkYzY3Njk3NDViMTFjNmM2Yzg1MzM3NzY1NDdmMWJhOTFjZjFhZDVjNjkyZDkwZjlkM2M5In0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiJjNDI5MGYzZmQzYWQ4M2YwZjcxZGEyYWU5OGFlZGM2NzY5NzQ1YjExYzZjNmM4NTMzNzc2NTQ3ZjFiYTkxY2YxYWQ1YzY5MmQ5MGY5ZDNjOSIsImlhdCI6MTU4NzE5MjM0MiwibmJmIjoxNTg3MTkyMzQyLCJleHAiOjE2MTg3MjgzNDIsInN1YiI6IjVkYTNmN2U2ZjQ4YzNkMTc1NjQ5Mzg4YiIsInNjb3BlcyI6WyJmcmVlIl19.Y_T2KJapf2-DP-Cj_AQIdGDzOPel4rpRK5BDVLU2Vuu04aikXX81NXZor3DjaZJK7-WJyBZwyWZqjJ21VDjLYb9sOm2nGHHCwEUJTADMOftKB0uK2COXQ3mQC_Q2VBqA8dPBV_yZZuD5bTTmbPz-y1ktcG3R29c2NisoHqb22FElvNmsWOtyrokwu3beGLW2vaaw_Fjw5g7_YOO_Iq21t8ok35cDOUjvQN3XIlq4FJhXa-4g3rQED9R8gYuHmIa8-Ko4VNUGJWqEd3707_8xxAn1MxxYwpXCmEDRNALht_sOj9jsYa_SdQLzj-H3IGZV7mb-t3I6nm8fneRlCYYo_DXqQS0BBI0dXYWrMC8jQ4eJ6E54C6qR7z0kepti5XWx3EeDNLL_RRcSkHkZDqCxfayfKspSd1NvI-BHXFpNMZctno455q_nYNtdhJV4d60VOCh5U21aVW8bFVe18fMwYjra1XhUzJoGaAOaxuDUyGU0AmuPjXr9qmEqBMZ72Lh665Ra5zeXPAjqK1bVL7vMkA3EIsmLSw2tl02WkbTnfPd6yv5MWrqVrzUPF42ds14MgmdKK8fofL4oQY0DBAH5ShSHpekwLmAYETyYuGx5ens2LF271onQp6bAWmxKk9TlqoEwpQUdZY0yPL_m_Vy9WphgFm7aIn6DKRpkt-64ivQ";

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
                      final chatRoom = await ChatSdk.chatUser(
                          userId: '5da3f7e6f48c3d175649388b', extras: {'esss': "assad"});
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
