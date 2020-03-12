import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qiscus_chat_room.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class QiscusChatRoom {
  final int id;
  final String distinctId;
  final String uniqueId;
  final String name;
  final Map<String, dynamic> options;
  final bool group;
  final bool channel;
  final String avatarUrl;

  //  @JsonKey(toJson: _memberToJson)
  final List<QiscusRoomMember> member;
  final int unreadCount;

  //  @JsonKey(toJson: _lastCommentToJson)
  final QiscusComment lastComment;
  final int memberCount;

  //  static String _memberToJson(List<QiscusRoomMember> member) => member.toString();

  //  static String _lastCommentToJson(QiscusComment lastComment) => lastComment.toString();

  QiscusChatRoom(
      this.id,
      this.distinctId,
      this.uniqueId,
      this.name,
      this.options,
      this.group,
      this.channel,
      this.avatarUrl,
      this.member,
      this.unreadCount,
      this.lastComment,
      this.memberCount);

  factory QiscusChatRoom.fromJson(Map<String, dynamic> json) => _$QiscusChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$QiscusChatRoomToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@immutable
@JsonSerializable()
class QiscusComment {
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
  final int state;
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
  final String caption;
  final String attachmentName;

  static QiscusComment fromJson(Map<String, dynamic> json) => _$QiscusCommentFromJson(json);

  QiscusComment(
    this.id,
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
    this.caption,
    this.attachmentName,
  );

  Map<String, dynamic> toJson() => _$QiscusCommentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@immutable
@JsonSerializable()
class QiscusRoomMember {
  final String email;
  final String username;
  final String avatar;
  final int lastDeliveredCommentId;
  final int lastReadCommentId;
  final Map<String, dynamic> extras;

  factory QiscusRoomMember.fromJson(Map<String, dynamic> json) => _$QiscusRoomMemberFromJson(json);

  QiscusRoomMember(
    this.email,
    this.username,
    this.avatar,
    this.lastDeliveredCommentId,
    this.lastReadCommentId,
    this.extras,
  );

  Map<String, dynamic> toJson() => _$QiscusRoomMemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

class CommentType {
  static const String FILE_ATTACHMENT = "file_attachment";
  static const String TEXT = "text";

//todo other type havent been implemented
}
