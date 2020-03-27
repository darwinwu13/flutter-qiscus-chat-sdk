library qiscus_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'model/qiscus_account.dart';
import 'model/qiscus_chat_room.dart';
import 'model/qiscus_chat_room_event.dart';
import 'model/qiscus_comment.dart';

export 'model/qiscus_account.dart';
export 'model/qiscus_chat_room.dart';
export 'model/qiscus_chat_room_event.dart';
export 'model/qiscus_comment.dart';
export 'model/qiscus_room_member.dart';

class ChatSdk {
  static const MethodChannel _channel = const MethodChannel('bahaso.com/qiscus_chat_sdk');
  static const EventChannel _eventChannelCommentReceive =
      const EventChannel('bahaso.com/qiscus_chat_sdk/events');

  static Stream<dynamic> _eventStream;
  static StreamSubscription<dynamic> _eventSubscription;
  static StreamController<QiscusComment> _commentReceiveController = StreamController.broadcast();
  static StreamController<QiscusChatRoomEvent> _chatRoomEventController =
      StreamController.broadcast();
  static StreamController<int> _fileUploadProgressController = StreamController.broadcast();

  static Stream<QiscusComment> get commentReceivedStream => _commentReceiveController.stream;

  static Stream<QiscusChatRoomEvent> get chatRoomEventStream => _chatRoomEventController.stream;

  static Stream<int> get fileUploadProgressStream => _fileUploadProgressController.stream;

  /// call this method to start listening to event channel, to
  /// distribute into each events stream
  static void startListeningToEventChannel() {
    _eventStream = _eventChannelCommentReceive.receiveBroadcastStream();
    _eventSubscription = _eventStream.listen((data) {
      print('event channel data received');
      Map<String, dynamic> result = jsonDecode(data);
      switch (result['type']) {
        case "comment_received":
          _commentReceiveController.add(QiscusComment.fromJson(result['comment']));
          break;
        case "chat_room_event_received":
          dev.log(result.toString(), name: "chat sdk event channel");
          _chatRoomEventController.add(QiscusChatRoomEvent.fromJson(result['chatRoomEvent']));
          break;
        case "file_upload_progress":
          _fileUploadProgressController.add(result['progress']);
          dev.log(result.toString(), name: "chat sdk file upload progress");

          break;
      }
    });
  }

  static Future<bool> subscribeToChatRoom(QiscusChatRoom chatRoom) {
    return _channel.invokeMethod('subscribeToChatRoom', {'chatRoom': jsonEncode(chatRoom)});
  }

  static Future<bool> unsubscribeToChatRoom(QiscusChatRoom chatRoom) {
    return _channel.invokeMethod('unsubscribeToChatRoom', {'chatRoom': jsonEncode(chatRoom)});
  }

  static void dispose() {
    _eventSubscription.cancel();
    _eventStream = null;
  }

  static Future<void> setup({@required String appId}) {
    dev.log("chat Sdk setup", name: "Qiscus Chat SDK");
    return _channel.invokeMethod('setup', {'appId': appId});
  }

  static Future<void> clearUser() {
    dev.log("chat sdk clearing user", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("clearUser");
  }

  static Future<void> registerDeviceToken(String token) {
    dev.log("chat sdk register device token", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("registerDeviceToken", {"token": token});
  }

  static Future<void> removeDeviceToken(String token) {
    dev.log("chat sdk remove device token", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("removeDeviceToken", {"token": token});
  }

  static Future<void> enableFcmPushNotification(bool value) {
    dev.log("chat sdk enable fcm push notification", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("setEnableFcmPushNotification", {"value": value});
  }

  static Future<void> enableDebugMode(bool value) {
    dev.log("chat sdk enable debug mode", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("enableDebugMode", {"value": value});
  }

  static Future<void> setNotificationListener() {}

  static Future<QiscusAccount> login({
    @required String userId,
    @required String userKey,
    @required String username,
    String avatarUrl: '',
    Map<String, dynamic> extras,
  }) async {
    dev.log("chat sdk login", name: "Qiscus Chat SDK");
    Map<String, dynamic> arguments = _prepareLoginArguments(
      userId: userId,
      userKey: userKey,
      username: username,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    String jsonStr = await _channel.invokeMethod("login", arguments);
    return QiscusAccount.fromJson(jsonDecode(jsonStr));
  }

  static Map<String, dynamic> _prepareLoginArguments({
    @required String userId,
    @required String userKey,
    @required String username,
    String avatarUrl: '',
    Map<String, dynamic> extras,
  }) {
    Map<String, dynamic> arguments = {
      'userId': userId,
      'userKey': userKey,
      'username': username,
    };
    if (avatarUrl != null && avatarUrl != '') arguments['avatarUrl'] = avatarUrl;
    if (extras != null) arguments['extras'] = extras;
    return arguments;
  }

  static Future<QiscusAccount> loginWithJWT(Future<String> getJWTToken(String nonce)) async {
    dev.log("chat sdk loginWithJWT", name: "Qiscus Chat SDK");
    String nonce = await _channel.invokeMethod('getNonce');

    dev.log("sdk before jwt", name: 'Qiscus chat sdk');

    String jwt = await getJWTToken(nonce);

    String jsonStr = await _channel.invokeMethod("setUserWithIdentityToken", {'token': jwt});

    return QiscusAccount.fromJson(jsonDecode(jsonStr));
  }

  static Future<QiscusAccount> updateUser({
    @required String username,
    @required String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    dev.log("chat sdk updateUser", name: "Qiscus Chat SDK");

    Map<String, dynamic> arguments = {
      'username': username,
      'avatarUrl': avatarUrl,
    };
    if (extras != null) arguments['extras'] = extras;

    String jsonStr = await _channel.invokeMethod('updateUser', arguments);

    return QiscusAccount.fromJson(jsonDecode(jsonStr));
  }

  static Future<bool> hasLogin() {
    return _channel.invokeMethod('hasLogin');
  }

  static Future<List<QiscusAccount>> getAllUsers(
      {String searchUsername: '', int page, int limit}) async {
    List<String> list = await _channel.invokeMethod(
        'getAllUsers', {'searchUsername': searchUsername, 'page': page, 'limit': limit});

    return list.map((jsonStr) {
      return QiscusAccount.fromJson(jsonDecode(jsonStr));
    });
  }

  static Future<QiscusChatRoom> chatUser({
    @required String userId,
    Map<String, dynamic> extras,
  }) async {
    Map<String, dynamic> arguments = {
      'userId': userId,
    };
    if (extras != null) arguments['extras'] = extras;

    String json = await _channel.invokeMethod('chatUser', arguments);

    return QiscusChatRoom.fromJson(jsonDecode(json));
  }

  static Future<bool> addOrUpdateLocalChatRoom(QiscusChatRoom chatRoom) async {
    var args = {'chatRoom': jsonEncode(chatRoom)};
    return await _channel.invokeMethod(
      'addOrUpdateLocalChatRoom',
      args,
    );
  }

  static Future<bool> addOrUpdateLocalComment(QiscusComment comment) async {
    var args = {'comment': jsonEncode(comment)};

    return await _channel.invokeMethod(
      'addOrUpdateLocalComment',
      args,
    );
  }

  /// only return 20 latest messages with chat room
  static Future<Tuple2<QiscusChatRoom, List<QiscusComment>>> getChatRoomWithMessages(
      int roomId) async {
    Map<String, String> chatRoomListPairJsonStr = await _channel
        .invokeMapMethod<String, String>('getChatRoomWithMessages', {'roomId': roomId});
    QiscusChatRoom qiscusChatRoom =
        QiscusChatRoom.fromJson(jsonDecode(chatRoomListPairJsonStr['chatRoom']));
    List<QiscusComment> messages =
        (jsonDecode(chatRoomListPairJsonStr['messages']) as List).map((each) {
      return QiscusComment.fromJson(each);
    }).toList();

    return Tuple2(qiscusChatRoom, messages);
  }

  static Future<QiscusChatRoom> getLocalChatRoom(int roomId) async {
    String jsonStr = await _channel.invokeMethod('getLocalChatRoom', {'roomId': roomId});
    Map<String, dynamic> map = jsonDecode(jsonStr);

    return map == null ? null : QiscusChatRoom.fromJson(map);
  }

  static Future<List<QiscusChatRoom>> getLocalChatRoomByIds(List<int> roomIds) async {
    String json = await _channel.invokeMethod('getLocalChatRoomByRoomIds', {'roomIds': roomIds});
    return (jsonDecode(json) as List).map((each) {
      return QiscusChatRoom.fromJson(each);
    }).toList();
  }

  static Future<List<QiscusChatRoom>> getAllChatRooms({
    bool showParticipant: true,
    bool showRemoved: false,
    bool showEmpty: false,
    int page: 1,
    int limit: 100,
  }) async {
    String json = await _channel.invokeMethod('getAllChatRooms', {
      'showParticipant': showParticipant,
      'showRemoved': showRemoved,
      'showEmpty': showEmpty,
      'page': page,
      'limit': limit,
    });

    return (jsonDecode(json) as List).map((each) {
      return QiscusChatRoom.fromJson(each);
    }).toList();
  }

  static Future<List<QiscusChatRoom>> getLocalChatRooms({int limit: 100, int offset}) async {
    Map<String, int> arguments = {'limit': limit};
    if (offset != null) arguments['offset'] = offset;
    String json = await _channel.invokeMethod('getLocalChatRooms', arguments);

    return (jsonDecode(json) as List).map((each) {
      return QiscusChatRoom.fromJson(each);
    }).toList();
  }

  static Future<int> getTotalUnreadCount() async {
    return await _channel.invokeMethod('getTotalUnreadCount');
  }

  static Future<QiscusComment> sendMessage({
    @required int roomId,
    String message,
    String type,
    File imageFile,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  }) async {
    String caption = "";
    if (type == CommentType.FILE_ATTACHMENT) {
      caption = message;
      return _sendFileMessage(
          roomId: roomId, caption: caption, imageFile: imageFile, extras: extras);
    } else if (type == CommentType.TEXT) {
      var args = {
        'roomId': roomId,
        'message': message,
        'type': CommentType.TEXT,
      };
      if (extras != null) args['extras'] = extras;
      String json = await _channel.invokeMethod('sendMessage', args);

      return QiscusComment.fromJson(jsonDecode(json));
    }
  }

  static Future<QiscusComment> _sendFileMessage({
    @required int roomId,
    String caption,
    Map<String, dynamic> extras,
    @required File imageFile,
  }) async {
    var args = {'roomId': roomId, 'caption': caption, 'filePath': imageFile.absolute.path};
    if (extras != null) args['extras'] = extras;
    String json = await _channel.invokeMethod('sendFileMessage', args);

    return QiscusComment.fromJson(jsonDecode(json));
  }

  /// get Qiscus account that has been log in
  static Future<QiscusAccount> getQiscusAccount() async {
    String json = await _channel.invokeMethod('getQiscusAccount');

    return QiscusAccount.fromJson(jsonDecode(json));
  }

  static Future<List<QiscusComment>> getLocalComments({int roomId, int limit}) async {
    var args = {'roomId': roomId};
    if (limit != null) args['limit'] = limit;

    String json = await _channel.invokeMethod("getLocalComments", args);

    List<dynamic> comments = jsonDecode(json);

    return comments.map((comment) {
      return QiscusComment.fromJson(comment);
    }).toList();
  }

  static Future<bool> markCommentAsRead(int roomId, int commentId) {
    return _channel.invokeMethod('markCommentAsRead', {
      'roomId': roomId,
      'commentId': commentId,
    });
  }

  static Future<bool> deleteLocalCommentsByRoomId(int roomId) {
    return _channel.invokeMethod('deleteLocalCommentsByRoomId', {
      'roomId': roomId,
    });
  }

  static Future<bool> deleteLocalComment(QiscusComment comment) async {
    var args = {'comment': jsonEncode(comment)};
    return await _channel.invokeMethod(
      'deleteLocalComment',
      args,
    );
  }

  static Future<bool> deleteLocalChatRoom(int roomId) async {
    var args = {'roomId': roomId};
    return await _channel.invokeMethod(
      'deleteLocalChatRoom',
      args,
    );
  }

  static Future<void> downloadImage() {
    //todo implement download image and save to local database
  }

  static Future<QiscusComment> getPrevMessages() {}
}
