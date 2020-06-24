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
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijc4ZmY4ODRiYjBkMDlhM2ZhODkxMDJkN2ZkZDc5YWYzYWE1NDZiODhkZmViZTYwZTAwZmFhNGM0ZTI2ODEwYWFjOTYzYTRiOTAwMDEwYWMyIn0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiI3OGZmODg0YmIwZDA5YTNmYTg5MTAyZDdmZGQ3OWFmM2FhNTQ2Yjg4ZGZlYmU2MGUwMGZhYTRjNGUyNjgxMGFhYzk2M2E0YjkwMDAxMGFjMiIsImlhdCI6MTU5Mjg5OTUwMywibmJmIjoxNTkyODk5NTAzLCJleHAiOjE2MjQ0MzU1MDMsInN1YiI6IjVlM2JiOTRhZjQ4YzNkMmFkNzAzNTQ2YSIsInNjb3BlcyI6WyJmcmVlIl19.gL9CCxUbKzFi_23Xea8nQ3xhqW8VEgN3DE7zyXVX_iUEn-QXJ8f3wbSPMArHZv_vo0Byuj414x6R7OIIyLEtjbbvBfwNb8Ri6LVMiaOw4PPX_Vis7368JGZKeHOWS5wBMSHK3gsHWtm48wsK7YZB3Hn7-Aj9WLz_pEkHOaDyiwHjd59KzxgXfPrGtL9u5VVMqpjnuPY6Ia7eH5RG53zyxDiFHcRU9505exkK9rTl1x36PG34zxDUZWPQALK0UMzhk4_KeYhr6KO7tKOgn3v5qn0jXUiBQTDDFGgh2nqyuGJLWiku3VA1oMWsJ7U4rM8XN0rxGu3fEEUizBS6HUR8zDCCcoVjJVcb-Dqcvbdt13iMUXExgzoPA9rhg5-y3zIFiKbQQIERQ8RK9i33l6Y3c0BIzMOAVSVLiGMbvng3FOESgUp3Se6J2tx5l9mh1UAcVFgBQYuwLSgpbV5HFgUmqOSFRikK3d1mSttArr-Mx4oBWo_v7rMGpUiQlG596DVUMdsRcMBimrbBYtIJ4LPmsG-JDAciWbTVPJ51C7MZrz80IlT_Dk4pKC7Ce7NTipvzBTVRTJNtKykDn5xZ2btIpJ-JPsBuDEFzdjq6B_C7WNAbkswOOPpE7D6qw_3RPD9VyX4-uAU1HfY1OR2zxzBxEk-arxOvhmLRaFBwDapE3Hg";
      //"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjdlZmMwMmU2YmE2NjVlY2YzY2ZlZTNhYTBlNzIzYWIyMmE3MWM0NDVjZWZjNTBiOWI0NWQzYWU2ZWQyOWQwMjZjZDM4NTQwYTgzNzQyZTQ1In0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiI3ZWZjMDJlNmJhNjY1ZWNmM2NmZWUzYWEwZTcyM2FiMjJhNzFjNDQ1Y2VmYzUwYjliNDVkM2FlNmVkMjlkMDI2Y2QzODU0MGE4Mzc0MmU0NSIsImlhdCI6MTU4NzM1Njc5MCwibmJmIjoxNTg3MzU2NzkwLCJleHAiOjE2MTg4OTI3OTAsInN1YiI6IjVlMmZjYjM2ZjQ4YzNkMzQzNTdhODI0ZCIsInNjb3BlcyI6WyJmcmVlIl19.DT_SafqSDeHh2K-mryliREgMQZvydCA0J8pASbu9aE3YBpfROpTTWa1LBgw5GnaZctbXXhrW79TUqHBD0TiH2ORneFinaVRNS0rJ_qk9425cLSu9hxvUXZSh7sH_vC0JWHDcnEsYiyvwJPnUsDc7Ju0xK8ByeDmXTLwWP9nRbqO2_-XlBEZOqYMRmerVWXcCxtO8Kg-LGZmZ5JnUYPaNgatdr_PVJVS5txwR8r77zjErZq1609LqjP6Szb4X56WZMbo_hQvzUI_sTWh_Eh4MLbQTDZO_L5SUU_1K2M4_lMUUqPOtqYw9Rm7xXsnv0Sk6ChcjhD4zXdBZ7wSJFcVVvlxmynSqBJl1YQgbdCytV94iTHU9eLCfW-T_UqILAj6BNNfxL3EuDZtJJnbbfU9XT0abnyqg8ncPzFeH0ecOzhIpg0ovsvRSLJxgTa00v2EpvvSE0l7rjmjdpYmP1ZzocrSQr17rMIajI8p0jYGNIX5ajjhDDZY92gvHZ5hm18u1u8D6meLeorK843d808ez_V5Z8hFlkkC0mB_0YKpts1tMoDh9g-Ngs0qTvIEFZVHYt4kUmc_jTZWNX32ikayHmWejRhoa8KkfyYu-B66A2pq_pegR5E89kajJmyifPnCL_BIsFHDT79BCDYbT79n23OA-y9EpyrHfzo4uMQCSmlw";
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
