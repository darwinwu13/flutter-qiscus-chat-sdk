import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String ACCESS_TOKEN =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6Ijk0ZWQ5YTRmMDEwNzliMTg3N2I4ZTk0YTNiYjYxNjIwZGYzNWZjY2FkYTU4Mjg1NDFiODQ5ZTdkNTExMTk1MThmNzQxNTM5ZjA0MjQwMjZjIn0.eyJhdWQiOiI1ZDgyMThmMmY0OGMzZDZiOTQ2NDUxNDIiLCJqdGkiOiI5NGVkOWE0ZjAxMDc5YjE4NzdiOGU5NGEzYmI2MTYyMGRmMzVmY2NhZGE1ODI4NTQxYjg0OWU3ZDUxMTE5NTE4Zjc0MTUzOWYwNDI0MDI2YyIsImlhdCI6MTU4MzM5Mjk5NCwibmJmIjoxNTgzMzkyOTk0LCJleHAiOjE2MTQ5Mjg5OTQsInN1YiI6IjVkYTNmN2U2ZjQ4YzNkMTc1NjQ5Mzg4YiIsInNjb3BlcyI6WyJmcmVlIl19.CVgRvVddBBmXVutpVr287CKKMRWt1trdVA3t-blaMFZwZn5rJrCJqOIWydy5BVqzBl0NcAUPGnf7064fWTIxAoXrWuXUPBfxJ0atXOULk233W3jcrJW6WFrMrj2ma8ZP0aQjVzL5a4d698i8GTzvxUkZjdAe25DxSr38SeAzVCtJPaAIImctuaLniTpkod-oig3H30_mjA7-bUoRV45PvJBi5BihajbZ4BJBibfGSmnxvgD2faEqI8TwB_1nypLtbAkI-ccAMmMy4odD-9187vxNSgsTppM2q--KYYeYOMZa0ffG9WwvwLawFiaFZfLszhLu7VMwTjR52exSBBjL9S03w-nnlevVIHYPQa77oHN_KTjf4PxCGdizzE3gOGOw-qhPHjtekcyMIHadGSgjRW8eH3qDDf9SkIn4uHYwHJUUF9kimK2u-iVjid6zHqUjL2NR0vDV6lrwS47mCaDCS7RnL2-IOBacAGOJLDyTRPCxKYa4-eQaJhIw8nQIj-KbvAAmfsqKLbtUMdvZfXb99-LY5wkyABOLzkAwXpaYo_n1tKEHW9vdmmqL7ksiKeF3d3M4wraQnrU8huuT4SAshfX-mwnPFiX6t4EK-glYrzHOz2qEOVvoCVcmC005hVCC2lxUx6Mj53YdfSH5bLRgMpLRZpirVe8pW-7ZcRL_UMU";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await ChatSdk.setup(appId: "testapp-hl5q64wriaulf");
      await ChatSdk.enableDebugMode(true);
      platformVersion = "yehah";
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            RaisedButton(
              child: Text('Setup Qiscus'),
              onPressed: () async {
                //QiscusChatSdk.enableFcmPushNotification(true);
                QiscusAccount account = await ChatSdk.login(
                    userId: "darwinwu134", userKey: "dndndn", username: "Darwin 134");
                print("acc:${account.toJson()}");
                // QiscusChatSdk.registerDeviceToken("asasdasd");
                //QiscusChatSdk.clearUser();
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
              child: Text('Chat User'),
              onPressed: () async {
                final chatRoom = await ChatSdk.chatUser(userId: '5da3f7e6f48c3d175649388b');
                ChatSdk.addOrUpdateLocalChatRoom(chatRoom);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<QiscusAccount> loginWithJwt() async {
    QiscusAccount account = await ChatSdk.loginWithJWT((String nonce) async {
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

    print("acc:${account.toJson()}");
  }
}
