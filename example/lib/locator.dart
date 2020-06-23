import 'dart:developer' as dev;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';

GetIt locator = GetIt.instance;

Future<bool> setupLocator() async {
  await ChatSdk.setup(appId: "aminin-5nxnotkgv9fvrk");
  await ChatSdk.enableDebugMode(true);
  await ChatSdk.enableFcmPushNotification(true);

  locator.registerSingleton(FirebaseMessaging());

  var fcm = locator<FirebaseMessaging>();
  fcm.getToken().then((token) {
    dev.log(token, name: 'fcm token');
    ChatSdk.registerDeviceToken(token);
  });
  fcm.configure(
    onMessage: (Map<String, dynamic> result) {
      dev.log(result.toString(), name: "on message fcm flutter");
      return;
    },
    onResume: (Map<String, dynamic> result) {
      dev.log(result.toString(), name: "on resume fcm flutter");
      return;
    },
  );

  String chandraId = "5dba91daf48c3d33bb41a6f5";
  String edwinId = "5da3f7e6f48c3d175649388b";
  String topic = 'receive_chat_from_sender_$chandraId';
  fcm.subscribeToTopic(topic);

  print('fcm initiated');

  return true;
}
