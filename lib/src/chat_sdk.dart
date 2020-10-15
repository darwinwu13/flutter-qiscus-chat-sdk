library qiscus_sdk;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:qiscus_sdk/src/utilities/qiscus_mqtt_status_event.dart';
import 'package:rxdart/rxdart.dart';
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

extension SortExtension<T> on Stream<T> {
  Stream<T> sort(Function(T lhs, T rhs) comparator) {
    return toList()
        .asStream()
        .map((list) => list..sort(comparator))
        .flatMap((list) => Stream.fromIterable(list));
  }
}

class ChatSdk {
  static bool _hasSetup = false;

  static const MethodChannel _channel = const MethodChannel('bahaso.com/qiscus_chat_sdk');
  static const EventChannel _eventChannelCommentReceive =
      const EventChannel('bahaso.com/qiscus_chat_sdk/events');

  static Stream<dynamic> _eventStream;
  static StreamSubscription<dynamic> _eventSubscription;
  static StreamController<QiscusComment> _commentReceiveController = StreamController.broadcast();
  static StreamController<QiscusMqttStatusEvent> _mqttStatusEventController =
      StreamController.broadcast();
  static StreamController<QiscusChatRoomEvent> _chatRoomEventController =
      StreamController.broadcast();
  static StreamController<int> _fileUploadProgressController = StreamController.broadcast();

  static Stream<QiscusMqttStatusEvent> get mqttStatusEventStream =>
      _mqttStatusEventController.stream;

  static Stream<QiscusComment> get commentReceivedStream => _commentReceiveController.stream;

  static Stream<QiscusChatRoomEvent> get chatRoomEventStream => _chatRoomEventController.stream;

  static Stream<int> get fileUploadProgressStream => _fileUploadProgressController.stream;

  static QiscusComment _lastSentComment;

  static Function(QiscusComment a, QiscusComment b) commentComparator =
      (QiscusComment a, QiscusComment b) => b.time.compareTo(a.time);

  /// call this method to start listening to event channel, to
  /// distribute into each events stream
  static void _startListeningToEventChannel() {
    if (_eventStream == null && _eventSubscription == null) {
      _eventStream = _eventChannelCommentReceive.receiveBroadcastStream();
      _eventSubscription = _eventStream.listen((data) {
        Map<String, dynamic> result = jsonDecode(data);
        print('event channel data received ${result.toString()}');
        dev.log('event channel data received ${result.toString()}',
            name: 'chat sdk stream listener');

        switch (result['type']) {
          case "comment_received":
            _commentReceiveController.add(QiscusComment.fromJson(result["comment"]));
            break;
          case "chat_room_event_received":
            _chatRoomEventController.add(QiscusChatRoomEvent.fromJson(result['chatRoomEvent']));
            break;
          case "file_upload_progress":
            _fileUploadProgressController.add(result['progress']);
            dev.log(result.toString(), name: "chat sdk file upload progress");
            break;
          case "mqtt_status_event":
            QiscusMqttStatusEvent statusEvent;
            if (result['status'] == "connected") {
              statusEvent = QiscusMqttStatusEvent.CONNECTED;
              _loadNewComment();
              dev.log("MQTT CONNECTErm -rf D", name: "mqtt status event");
            } else if (result['status'] == "disconnected") {
              statusEvent = QiscusMqttStatusEvent.DISCONNECTED;
              dev.log("MQTT DISCONNECTED", name: "mqtt status event");
            } else if (result['status'] == "reconnecting") {
              statusEvent = QiscusMqttStatusEvent.RECONNECTING;
              dev.log("MQTT RECONNECTING", name: "mqtt status event");
            }

            _mqttStatusEventController.add(statusEvent);
            break;
        }
      });
    }
  }

  static Future<Tuple2<QiscusChatRoom, Stream<QiscusComment>>> loadChatRoomWithCommentsStream(
    int roomId,
  ) async {
    bool hasConnection = await DataConnectionChecker().hasConnection;
    QiscusChatRoom chatRoom;
    List<QiscusComment> comments = [];
    if (hasConnection) {
      var chatRoomTuple = await getChatRoomWithComments(roomId);
      chatRoom = chatRoomTuple.item1;
      comments = chatRoomTuple.item2;
      addOrUpdateLocalChatRoom(chatRoom);
    } else {
      chatRoom = await getLocalChatRoom(roomId);
    }
    var localComments = await getLocalComments(roomId: roomId, limit: 20);
    var commentsStream = Stream.fromIterable(comments)
        .mergeWith([Stream.fromIterable(localComments)])
        .distinct()
        .sort(commentComparator)
        .doOnData((QiscusComment comment) {
          if (hasConnection && comments.isNotEmpty) addOrUpdateLocalComment(comment);
        });
    _lastSentComment = chatRoom?.lastComment;

    return Tuple2(chatRoom, commentsStream);
  }

  static Future<Tuple2<QiscusChatRoom, List<QiscusComment>>> loadChatRoomWithComments(
    int roomId,
  ) async {
    var tuple = await loadChatRoomWithCommentsStream(roomId);

    return Tuple2(tuple.item1, await tuple.item2.toList());
  }

  static Stream<QiscusComment> loadOlderCommentsStream(
    QiscusComment comment, {
    int limit: 20,
  }) async* {
    bool hasConnection = await DataConnectionChecker().hasConnection;
    List<QiscusComment> comments = [];
    if (hasConnection) {
      comments = await getPrevMessages(comment, limit: limit);
    }
    var localComments = await getLocalPrevMessages(comment, limit: limit);
    yield* Stream.fromIterable(comments)
        .mergeWith([Stream.fromIterable(localComments)])
        .distinct()
        .sort(commentComparator)
        .doOnData((QiscusComment comment) {
          if (hasConnection && comments.isNotEmpty) addOrUpdateLocalComment(comment);
        });
  }

  static Future<List<QiscusComment>> loadOlderComments(QiscusComment comment, {int limit: 20}) {
    var stream = loadOlderCommentsStream(comment, limit: limit);

    return stream.toList();
  }

  static Stream<QiscusComment> loadNextCommentsStream(
    QiscusComment comment, {
    int limit: 20,
  }) async* {
    bool hasConnection = await DataConnectionChecker().hasConnection;
    List<QiscusComment> comments = [];
    if (hasConnection) {
      comments = await getNextMessages(comment, limit: limit);
    }
    var localComments = await getLocalNextMessages(comment, limit: limit);
    yield* Stream.fromIterable(comments)
        .mergeWith([Stream.fromIterable(localComments)])
        .distinct()
        .sort(commentComparator)
        .doOnData((QiscusComment comment) {
          if (hasConnection && comments.isNotEmpty) addOrUpdateLocalComment(comment);
        });
  }

  static Future<List<QiscusComment>> loadNextComments(QiscusComment comment, {int limit: 20}) {
    var stream = loadOlderCommentsStream(comment, limit: limit);

    return stream.toList();
  }

  static Future<void> _loadNewComment() async {
    if (_lastSentComment != null) {
      List<QiscusComment> comments = await getNextMessages(_lastSentComment);
      comments.forEach((comment) {
        _commentReceiveController.add(comment);
        addOrUpdateLocalComment(comment);
      });
      dev.log("new comments load after mqtt connected", name: "chat sdk mqtt");
    }
  }

  static Future<bool> subscribeToChatRoom(QiscusChatRoom chatRoom) {
    checkSetup();

    return _channel.invokeMethod('subscribeToChatRoom', {'chatRoom': jsonEncode(chatRoom)});
  }

  static Future<bool> unsubscribeToChatRoom(QiscusChatRoom chatRoom) {
    checkSetup();

    return _channel.invokeMethod('unsubscribeToChatRoom', {'chatRoom': jsonEncode(chatRoom)});
  }

  static void dispose() {
    _eventSubscription.cancel();
    _eventStream = null;
  }

  static Future<void> setup({@required String appId}) async {
    if (!_hasSetup) {
      _startListeningToEventChannel();
      dev.log("chat Sdk setup", name: "Qiscus Chat SDK");
      await _channel.invokeMethod('setup', {'appId': appId});
      _hasSetup = true;

      return;
    }
  }

  static Future<void> clearUser() {
    checkSetup();
    _lastSentComment = null;
    dev.log("chat sdk clearing user", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("clearUser");
  }

  static bool checkSetup() {
    if (!_hasSetup) throw Exception("Chat Sdk has not been setup");

    return true;
  }

  static Future<void> registerDeviceToken(String token) {
    checkSetup();

    dev.log("chat sdk register device token", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("registerDeviceToken", {"token": token});
  }

  static Future<void> removeDeviceToken(String token) {
    checkSetup();

    dev.log("chat sdk remove device token", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("removeDeviceToken", {"token": token});
  }

  static Future<void> enableFcmPushNotification(bool value) {
    checkSetup();

    dev.log("chat sdk enable fcm push notification", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("setEnableFcmPushNotification", {"value": value});
  }

  static Future<void> enableDebugMode(bool value) {
    checkSetup();

    dev.log("chat sdk enable debug mode", name: "Qiscus Chat SDK");
    return _channel.invokeMethod("enableDebugMode", {"value": value});
  }

  static Future<void> _setNotificationListener() {}

  static Future<QiscusAccount> login({
    @required String userId,
    @required String userKey,
    @required String username,
    String avatarUrl: '',
    Map<String, dynamic> extras,
  }) async {
    checkSetup();

    dev.log("chat sdk login", name: "Qiscus Chat SDK");
    Map<String, dynamic> arguments = _prepareLoginArguments(
      userId: userId,
      userKey: userKey,
      username: username,
      avatarUrl: avatarUrl,
      extras: extras,
    );
    String jsonStr = await _channel.invokeMethod("login", arguments);
    dev.log(jsonStr, name: "HANSEN");
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
    checkSetup();

    dev.log("chat sdk loginWithJWT", name: "Qiscus Chat SDK");
    String nonce = await _channel.invokeMethod('getNonce');

    dev.log("sdk before jwt", name: 'Qiscus chat sdk $nonce');

    String jwt = await getJWTToken(nonce);

    String jsonStr = await _channel.invokeMethod("setUserWithIdentityToken", {'token': jwt});

    return QiscusAccount.fromJson(jsonDecode(jsonStr));
  }

  static Future<QiscusAccount> updateUser({
    @required String username,
    @required String avatarUrl,
    Map<String, dynamic> extras,
  }) async {
    checkSetup();

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
    checkSetup();

    return _channel.invokeMethod('hasLogin');
  }

  static Future<List<QiscusAccount>> getAllUsers(
      {String searchUsername: '', int page, int limit}) async {
    checkSetup();

    List<String> list = await _channel.invokeMethod(
        'getAllUsers', {'searchUsername': searchUsername, 'page': page, 'limit': limit});

    print("value list get all users $list");

    return list.map((jsonStr) {
      return QiscusAccount.fromJson(jsonDecode(jsonStr));
    });
  }

  static Future<QiscusChatRoom> chatUser({
    @required String userId,
    Map<String, dynamic> extras,
  }) async {
    checkSetup();
    if (await hasLogin()) {
      Map<String, dynamic> arguments = {
        'userId': userId,
      };

      if (extras != null) {
        arguments['extras'] = extras;
      }

      String json = await _channel.invokeMethod('chatUser', arguments);
      print("result chat user $json");
      var chatRoom = QiscusChatRoom.fromJson(jsonDecode(json));
      print("chat room last comment ${chatRoom.lastComment}");
      _lastSentComment = chatRoom.lastComment;

      return chatRoom;
    }

    throw Exception("Can't chat user hasn't login yet");
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
    print("Flutter || save comment $args");
    return await _channel.invokeMethod(
      'addOrUpdateLocalComment',
      args,
    );
  }

  static Future<Tuple2<QiscusChatRoom, List<QiscusComment>>> getChatRoomWithComments(int roomId) {
    return getChatRoomWithMessages(roomId);
  }

  /// only return 20 latest messages with chat room
  /// @deprecated name is inconsistent with model name, instead you should use getChatRoomWithComments
  static Future<Tuple2<QiscusChatRoom, List<QiscusComment>>> getChatRoomWithMessages(
      int roomId) async {
    print("room id $roomId");
    Map<String, String> chatRoomListPairJsonStr = await _channel
        .invokeMapMethod<String, String>('getChatRoomWithMessages', {'roomId': roomId});

    QiscusChatRoom qiscusChatRoom =
        QiscusChatRoom.fromJson(jsonDecode(chatRoomListPairJsonStr['chatRoom']));

    List<QiscusComment> messages =
        (jsonDecode(chatRoomListPairJsonStr['messages']) as List).map((each) {
      return QiscusComment.fromJson(each);
    }).toList();

    _lastSentComment = qiscusChatRoom.lastComment;

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

  /// retrieve all chat room a logged user has
  static Future<List<QiscusChatRoom>> getAllChatRooms({
    bool showParticipant: true,
    bool showRemoved: false,
    bool showEmpty: false,
    int page: 1,
    int limit: 100,
  }) async {
    checkSetup();

    if (await hasLogin()) {
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

    throw Exception("Can't get all chat rooms, you need to login ");
  }

  static Future<List<QiscusChatRoom>> getLocalChatRooms({int limit: 100, int offset}) async {
    Map<String, int> arguments = {'limit': limit};
    if (offset != null) arguments['offset'] = offset;
    String json = await _channel.invokeMethod('getLocalChatRooms', arguments);

    return (jsonDecode(json) as List).map((each) {
      print("chat room decode $each");
      return QiscusChatRoom.fromJson(each);
    }).toList();
  }

  static Future<int> getTotalUnreadCount() async {
    return await _channel.invokeMethod('getTotalUnreadCount');
  }

  static Future<QiscusComment> sendMessage({
    @required int roomId,
    String type: CommentType.TEXT,
    File imageFile,
    String message,
    Map<String, dynamic> extras,
    Map<String, dynamic> payload,
  }) async {
    checkSetup();
    if (await hasLogin()) {
      String caption = "";

      const String environment = "dev2";

      if (type == CommentType.FILE_ATTACHMENT) {
        caption = message;
        extras['environment'] = environment;

        return sendFileMessage(
          roomId: roomId,
          caption: caption,
          imageFile: imageFile,
          extras: extras,
        );
      } else if (type == CommentType.TEXT) {
        var args = {
          'roomId': roomId,
          'message': message,
          'type': CommentType.TEXT,
        };
        if (extras != null) {
          extras['environment'] = environment;
          args['extras'] = extras;
        } else {
          args['extras'] = {"environment": environment};
        }

        String json = await _channel.invokeMethod('sendMessage', args);
        print("Flutter Chat || comment model $json");
        dev.log("Comment Model $json", name: "Flutter Chat");
        return _lastSentComment = QiscusComment.fromJson(jsonDecode(json));
      } else {
        return sendCustomMessage(
          roomId: roomId,
          message: message,
          payload: payload,
          type: type,
        );
      }
    }

    throw Exception("Can't send message, you need to login");
  }

  static Future<QiscusComment> sendCustomMessage({
    @required int roomId,
    @required String message,
    @required String type,
    @required Map<String, dynamic> payload,
  }) async {
    checkSetup();
    if (await hasLogin()) {
      var args = {
        'roomId': roomId,
        'message': message,
        'type': type,
        'payload': payload,
      };
      String json = await _channel.invokeMethod('sendCustomMessage', args);

      return _lastSentComment = QiscusComment.fromJson(jsonDecode(json));
    }
    return null;
  }

  static Future<QiscusComment> sendFileMessage({
    @required int roomId,
    String caption,
    Map<String, dynamic> extras,
    @required File imageFile,
  }) async {
    checkSetup();
    if (await hasLogin()) {
//      var args = {'roomId': roomId, 'caption': caption, 'filePath': imageFile.absolute.path};
      var args = {'roomId': roomId, 'caption': caption, 'filePath': imageFile.absolute.path};
      print("Flutter || send file args $args");
      if (extras != null) args['extras'] = extras;
      String json = await _channel.invokeMethod('sendFileMessage', args);

      return _lastSentComment = QiscusComment.fromJson(jsonDecode(json));
    }

    return null;
  }

  static Future<QiscusComment> sendCustomFileMessage({
    @required int roomId,
    @required String type,
    @required Map<String, dynamic> payload,
    @required File imageFile,
    String caption: "",
  }) async {
    checkSetup();
    if (await hasLogin()) {
      var args = {
        'roomId': roomId,
        'caption': caption,
        'type': type,
        'payload': payload,
        'filePath': imageFile.absolute.path,
      };
      String json = await _channel.invokeMethod('sendCustomFileMessage', args);

      return _lastSentComment = QiscusComment.fromJson(jsonDecode(json));
    }

    return null;
  }

  /// get Qiscus account that has been log in
  static Future<QiscusAccount> getQiscusAccount() async {
    checkSetup();
    if (await hasLogin()) {
      String json = await _channel.invokeMethod('getQiscusAccount');

      return QiscusAccount.fromJson(jsonDecode(json));
    }
    throw Exception("Can't get qiscus account, you need to login first");
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

  static Future<bool> deleteLocalCommentByUniqueId(String uniqueId, int commentId) async {
    var args = {
      'commentId': commentId,
      'uniqueId': uniqueId,
    };
    return await _channel.invokeMethod(
      'deleteLocalCommentByUniqueId',
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

  static Future<List<QiscusComment>> getPrevMessages(QiscusComment comment, {int limit: 20}) async {
    checkSetup();

    if (await hasLogin()) {
      var args = {
        'roomId': comment.roomId,
        'messageId': comment.id,
        'limit': limit,
      };

      String json = await _channel.invokeMethod(
        'getPrevMessages',
        args,
      );

      List<dynamic> comments = jsonDecode(json);

      return comments.map((comment) {
        return QiscusComment.fromJson(comment);
      }).toList();
    }

    throw Exception("Can't get previous message, you need to login");
  }

  static Future<List<QiscusComment>> getLocalPrevMessages(
    QiscusComment comment, {
    int limit: 20,
  }) async {
    checkSetup();

    var args = {
      'roomId': comment.roomId,
      'uniqueId': comment.uniqueId,
      'limit': limit,
    };

    String json = await _channel.invokeMethod(
      'getLocalPrevMessages',
      args,
    );

    List<dynamic> comments = jsonDecode(json);

    return comments.map((comment) {
      return QiscusComment.fromJson(comment);
    }).toList();
  }

  static Future<List<QiscusComment>> getNextMessages(QiscusComment comment, {int limit: 20}) async {
    checkSetup();
    if (await hasLogin()) {
      var args = {
        'roomId': comment.roomId,
        'messageId': comment.id,
        'limit': limit,
      };

      String json = await _channel.invokeMethod(
        'getNextMessages',
        args,
      );

      List<dynamic> comments = jsonDecode(json);

      return comments.map((comment) {
        return QiscusComment.fromJson(comment);
      }).toList();
    }

    throw Exception("Can't get next message, you need to login");
  }

  static Future<List<QiscusComment>> getLocalNextMessages(
    QiscusComment comment, {
    int limit: 20,
  }) async {
    checkSetup();
    if (await hasLogin()) {
      var args = {
        'roomId': comment.roomId,
        'uniqueId': comment.uniqueId,
        'limit': limit,
      };

      String json = await _channel.invokeMethod(
        'getLocalNextMessages',
        args,
      );

      List<dynamic> comments = jsonDecode(json);

      return comments.map((comment) {
        return QiscusComment.fromJson(comment);
      }).toList();
    }

    throw Exception("Can't get next message, you need to login");
  }

  static Future<QiscusChatRoom> updateChatRoom({
    @required int roomId,
    @required String name,
    String avatarUrl: "",
    Map<String, dynamic> extras,
  }) async {
    checkSetup();
    if (await hasLogin()) {
      var args = {
        'roomId': roomId,
        'name': name,
        'avatarUrl': avatarUrl,
      };
      if (extras != null) args['extras'] = extras;

      String json = await _channel.invokeMethod('updateChatRoom', args);

      return QiscusChatRoom.fromJson(jsonDecode(json));
    }

    throw Exception("Can't update chat room you need to login");
  }
}
