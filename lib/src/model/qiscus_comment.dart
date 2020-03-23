import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qiscus_comment.g.dart';

@immutable
@JsonSerializable()
// ignore: must_be_immutable
class QiscusComment extends Equatable {
  static const int STATE_FAILED = -1;
  static const int STATE_PENDING = 0;
  static const int STATE_SENDING = 1;
  static const int STATE_ON_QISCUS = 2;
  static const int STATE_DELIVERED = 3;
  static const int STATE_READ = 4;

  final int id;
  final int roomId;
  final String uniqueId;
  final int commentBeforeId;
  final String message;
  final String sender;
  final String senderEmail;
  final String senderAvatar;
  final DateTime time;
  int state;
  final bool deleted;
  final bool hardDeleted;
  final String roomName;
  final String roomAvatar;
  final bool groupMessage;
  final bool selected;
  final bool highlighted;
  final bool downloading;
  final int progress;
  final List<String> urls;
  final String rawType;
  final String extraPayload;
  final Map<String, dynamic> extras;
  final QiscusComment replyTo;
  final String attachmentName;

  Map<String, dynamic> _extraPayloadMap;

  static QiscusComment fromJson(Map<String, dynamic> json) => _$QiscusCommentFromJson(json);

  String get attachmentUrl {
    if (_extraPayloadMap == null) _extraPayloadMap = jsonDecode(extraPayload);
    return _extraPayloadMap != null ? _extraPayloadMap['url'] : null;
  }

  String get caption {
    if (_extraPayloadMap == null) _extraPayloadMap = jsonDecode(extraPayload);
    return _extraPayloadMap != null ? _extraPayloadMap['caption'] : null;
  }

  QiscusComment(this.id,
      this.roomId,
      this.uniqueId,
      this.commentBeforeId,
      this.message,
      this.sender,
      this.senderEmail,
      this.senderAvatar,
      this.time,
      this.state,
      this.deleted,
      this.hardDeleted,
      this.roomName,
      this.roomAvatar,
      this.groupMessage,
      this.selected,
      this.highlighted,
      this.downloading,
      this.progress,
      this.urls,
      this.rawType,
      this.extraPayload,
      this.extras,
      this.replyTo,
      this.attachmentName,);

  Map<String, dynamic> toJson() => _$QiscusCommentToJson(this);

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
