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

  ///edwin
  //String ACCESS_TOKEN =
  //    "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImM0MjkwZjNmZDNhZDgzZjBmNzFkYTJhZTk4YWVkYzY3Njk3NDViMTFjNmM2Yzg1MzM3NzY1NDdmMWJhOTFjZjFhZDVjNjkyZDkwZjlkM2M5In0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiJjNDI5MGYzZmQzYWQ4M2YwZjcxZGEyYWU5OGFlZGM2NzY5NzQ1YjExYzZjNmM4NTMzNzc2NTQ3ZjFiYTkxY2YxYWQ1YzY5MmQ5MGY5ZDNjOSIsImlhdCI6MTU4NzE5MjM0MiwibmJmIjoxNTg3MTkyMzQyLCJleHAiOjE2MTg3MjgzNDIsInN1YiI6IjVkYTNmN2U2ZjQ4YzNkMTc1NjQ5Mzg4YiIsInNjb3BlcyI6WyJmcmVlIl19.Y_T2KJapf2-DP-Cj_AQIdGDzOPel4rpRK5BDVLU2Vuu04aikXX81NXZor3DjaZJK7-WJyBZwyWZqjJ21VDjLYb9sOm2nGHHCwEUJTADMOftKB0uK2COXQ3mQC_Q2VBqA8dPBV_yZZuD5bTTmbPz-y1ktcG3R29c2NisoHqb22FElvNmsWOtyrokwu3beGLW2vaaw_Fjw5g7_YOO_Iq21t8ok35cDOUjvQN3XIlq4FJhXa-4g3rQED9R8gYuHmIa8-Ko4VNUGJWqEd3707_8xxAn1MxxYwpXCmEDRNALht_sOj9jsYa_SdQLzj-H3IGZV7mb-t3I6nm8fneRlCYYo_DXqQS0BBI0dXYWrMC8jQ4eJ6E54C6qR7z0kepti5XWx3EeDNLL_RRcSkHkZDqCxfayfKspSd1NvI-BHXFpNMZctno455q_nYNtdhJV4d60VOCh5U21aVW8bFVe18fMwYjra1XhUzJoGaAOaxuDUyGU0AmuPjXr9qmEqBMZ72Lh665Ra5zeXPAjqK1bVL7vMkA3EIsmLSw2tl02WkbTnfPd6yv5MWrqVrzUPF42ds14MgmdKK8fofL4oQY0DBAH5ShSHpekwLmAYETyYuGx5ens2LF271onQp6bAWmxKk9TlqoEwpQUdZY0yPL_m_Vy9WphgFm7aIn6DKRpkt-64ivQ";

  ///nadia
  //  String ACCESS_TOKEN =
  //      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijc1ZmY1YTRhNjg4NzA0YTZmMWQxM2NhOTIyMmM0OTc2YTA1YzhmYzJhYWNhNTY3ZWM3Nzc5MzgxYzJhNzZjNzk4ODMwNzA3MGVmODRmZmJhIn0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiI3NWZmNWE0YTY4ODcwNGE2ZjFkMTNjYTkyMjJjNDk3NmEwNWM4ZmMyYWFjYTU2N2VjNzc3OTM4MWMyYTc2Yzc5ODgzMDcwNzBlZjg0ZmZiYSIsImlhdCI6MTU4NzMwNjQyNiwibmJmIjoxNTg3MzA2NDI2LCJleHAiOjE2MTg4NDI0MjYsInN1YiI6IjVlMjZhODQwZjQ4YzNkMWZmODM2ZmMwNCIsInNjb3BlcyI6WyJmcmVlIl19.zPHOT24-8Qe9jDKX1a__FFLgylSng_v9hxzBV6NfXNxVotNQdWTUjzKvHtvH-WCwZGDGNXAwdl-Ryya_0ab-ObOr7dmABs6Rcc-tJhht1rE_4X7pHzMnfc2KgJCEPCA4XGJlbZNCcF4ukxbohOuUmsGcvliHUWqy2mFTMHODqmvZdzUqHoHlPcBNmA4P5yMFeJTuEHI6ttu5o2zgRTlrFSuz9ofRbbnF0OhC6DRmB91raGn4eKAP5a916ELnWR_Bux7NYqUKmar86bTUcU7wj4lqKmgy5ZRLAiul3jDKx5wooiENyXJ5LwZKWzUzi9PlUu0L1-cX5pVQxcYPS0wcXLqd8TxEvSXgbhMA8aAJkWc93ZVt4OyS9b0XoCzDOcxg-5zUCa5HoB5AYGPvQDxRDBdGtqFfjrn2GFKcbWfwOzaDwiAKOapYIxF2eqSAXmwk_yF5gPxsW6MeHcVKJMytvGENw99XMf6kyb1cW94UWrAY-U9FmkJs1hzyH-96KfJT_8KQ9mC4kq45eaUHJnf5dHqaSQXkO1EuaOX305Rxwh2pZeiHU4p5MSzMptsg-knMWFLM--aea2YmydOMxxpWptVpKSnno6m4KS1Lk5j1_XrX7GWDig0_U_8GuigqOt7-sYAy0akFCwhfmmboyHyyHnmtbyv0d-fdxqtQL_XMfz0";

  /// darwin wu test
  String ACCESS_TOKEN =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjM4Zjk4NTQyYWEzMDc5Y2NjY2M3ZDk0MTZiZDIxOWYwNDY2ZDVmMWYyOWI4Mjc0MzcyMGUwN2MzMDVkOTRkZTY3M2FhNDMxMGI4ZTZiN2VmIn0.eyJhdWQiOiI1ZDgyMThjY2Y0OGMzZDZiOGY1Y2M5MTQiLCJqdGkiOiIzOGY5ODU0MmFhMzA3OWNjY2NjN2Q5NDE2YmQyMTlmMDQ2NmQ1ZjFmMjliODI3NDM3MjBlMDdjMzA1ZDk0ZGU2NzNhYTQzMTBiOGU2YjdlZiIsImlhdCI6MTU5Mzc1MjAwMiwibmJmIjoxNTkzNzUyMDAyLCJleHAiOjE2MjUyODgwMDIsInN1YiI6IjVkOWVkMGI4ZjQ4YzNkMGFiODVhOTRiOSIsInNjb3BlcyI6WyJmcmVlIl19.VktejoTD1xiRgoLFfRZugot49meoWKYb93x5CWexhqCQ6EeWq2BubFMe9CtylGjoi65goPY5YwM96CrorqleAU9UsMlO_O854IhVPiW-WL6PzchN6QngTGO8846ul6cVgV09p65hY9kzWabNGXU-Re196wILQybUNpMHmIcVjvY7JIodpwkQP5aMqgrUz0hQ51_dlVSZRNE5kBnOFRateY24pJraj1jKRtaONwlHi8GAPtiA2uN9VfSEtAeEHGxK1WaxQomHNSauXNc9fDnbwpi61nsOeQXjAAwS6VaY0paqX29fg6HO2xD96civl_WGYD2XE9PFbMCCpLE6K0heqDtAJbkna-ftLcucwikdUpXmmPNBv-wax4JbMjk9oWP4Xy7aT0No0FGz5J5jlcqLNhx1Ynyl1QNM6H_hdI0f6EO-psbf-LUVXPjGis3QVeAZmqo9rzy7Kdo0WZCs3J5SN498k1p84iYMVbDvUN0LJpfTiDNm6vOSFU182HU5iDguHU_vn6jFTX0fGWftCj0hRWe5PY58tu4wFyWjX3qcj1dXxxkqGshJ-QATmbeb3GZ5XX00uS3MzP5JKDhP60eq6onHyNeB_k1JG4eM1_E1KK222BI4H5t7bScpY54lqQtBxStdQrj0NpOb8Aq4eUPQz6PT2NFA5xI9U0WiARRpeVI";
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
                    child: Text('Chat User Peter'),
                    onPressed: () async {
                      final chatRoom = await ChatSdk.chatUser(userId: '5e9ec521cce84c13933effe2');
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
                          userId: '5e9afe293204c952bb1ee8e2', extras: {'esss': "assad"});
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
                      final chatRoom = await ChatSdk.chatUser(userId: '5d9ed0b8f48c3d0ab85a94b9');
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
      print("response dioo value ${response.data}");

      String jwt = response.data['result']['jwt'];

      print("nonce: $nonce, jwt: $jwt");

      return jwt;
    });
  }
}
