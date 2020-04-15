import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qiscus_sdk/src/utilities/qiscus_utility.dart';

part 'qiscus_comment.g.dart';

@JsonSerializable()
// ignore: must_be_immutable
class QiscusComment extends Equatable {
  static const int STATE_FAILED = -1;
  static const int STATE_PENDING = 0;
  static const int STATE_SENDING = 1;
  static const int STATE_ON_QISCUS = 2;
  static const int STATE_DELIVERED = 3;
  static const int STATE_READ = 4;

  int id;
  int roomId;
  String uniqueId;
  int commentBeforeId;
  String message;
  String sender;
  String senderEmail;
  String senderAvatar;
  DateTime time;
  int state;
  bool deleted;
  bool hardDeleted;
  String roomName;
  String roomAvatar;
  bool groupMessage;
  bool selected;
  bool highlighted;
  bool downloading;
  int progress;
  List<String> urls;
  String rawType;
  Map<String, dynamic> extras;
  QiscusComment replyTo;
  String attachmentName;

  @JsonKey(fromJson: _extraPayloadFromJson)
  final Map<String, dynamic> extraPayload;

  static Map<String, dynamic> _extraPayloadFromJson(source) =>
      source == "{}" || source == null ? null : jsonDecode(source);

  String get attachmentUrl => extraPayload != null ? extraPayload['url'] : null;

  bool get isDummy => extraPayload != null ? extraPayload['dummy'] ?? false : false;

  String get caption => extraPayload != null ? extraPayload['caption'] : null;

  factory QiscusComment.generateDummyFileMessage(
    int roomId,
    String senderEmail,
    Map<String, dynamic> extraPayload,
  ) {
    return QiscusComment(
      roomId: roomId,
      uniqueId: _generateUniqueId(),
      senderEmail: senderEmail,
      sender: "",
      senderAvatar: "",
      time: DateTime.now(),
      state: STATE_SENDING,
      urls: [],
      rawType: CommentType.FILE_ATTACHMENT,
      extraPayload: extraPayload
        ..addAll(
          {'dummy': true},
        ),
    );
  }

  factory QiscusComment.generateDummyTextMessage(int roomId,
      String senderEmail,
      Map<String, dynamic> extras,) {
    return QiscusComment(
      roomId: roomId,
      uniqueId: _generateUniqueId(),
      senderEmail: senderEmail,
      sender: "",
      senderAvatar: "",
      time: DateTime.now(),
      state: STATE_SENDING,
      urls: [],
      rawType: CommentType.TEXT,
      extraPayload: {'dummy': true},
      extras: extras,
    );
  }

  static String _generateUniqueId() {
    String platform;
    platform = Platform.isAndroid ? "android_" : "ios_";

    return platform + QiscusUtility.getRandomString(13) + "_" + QiscusUtility.getUuid();
  }

  QiscusComment({
    this.id: -1,
    this.roomId: -1,
    this.uniqueId: "",
    this.commentBeforeId: -1,
    this.message,
    this.sender,
    this.senderEmail,
    this.senderAvatar,
    this.time,
    this.state,
    this.deleted: false,
    this.hardDeleted: false,
    this.roomName: "",
    this.roomAvatar: "",
    this.groupMessage: false,
    this.selected: false,
    this.highlighted: false,
    this.downloading: false,
    this.progress: 0,
    this.urls,
    this.rawType,
    this.extraPayload,
    this.extras,
    this.replyTo,
    this.attachmentName: "",
  });

  Map<String, dynamic> toJson() => _$QiscusCommentToJson(this);

  static QiscusComment fromJson(Map<String, dynamic> json) => _$QiscusCommentFromJson(json);

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  List<Object> get props => [id, roomId, uniqueId];
}

class CommentType {
  static const String FILE_ATTACHMENT = "file_attachment";
  static const String TEXT = "text";

//todo other type havent been implemented
}
