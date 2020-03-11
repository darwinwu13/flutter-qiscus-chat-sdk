// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiscus_chat_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiscusChatRoom _$QiscusChatRoomFromJson(Map<String, dynamic> json) {
  return QiscusChatRoom(
    json['id'] as int,
    json['distinctId'] as String,
    json['uniqueId'] as String,
    json['name'] as String,
    json['options'] as Map<String, dynamic>,
    json['group'] as bool,
    json['channel'] as bool,
    json['avatarUrl'] as String,
    (json['member'] as List)
        ?.map((e) => e == null
            ? null
            : QiscusRoomMember.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['unreadCount'] as int,
    json['lastComment'] == null
        ? null
        : QiscusComment.fromJson(json['lastComment'] as Map<String, dynamic>),
    json['memberCount'] as int,
  );
}

Map<String, dynamic> _$QiscusChatRoomToJson(QiscusChatRoom instance) =>
    <String, dynamic>{
      'id': instance.id,
      'distinctId': instance.distinctId,
      'uniqueId': instance.uniqueId,
      'name': instance.name,
      'options': instance.options,
      'group': instance.group,
      'channel': instance.channel,
      'avatarUrl': instance.avatarUrl,
      'member': instance.member?.map((e) => e?.toJson())?.toList(),
      'unreadCount': instance.unreadCount,
      'lastComment': instance.lastComment?.toJson(),
      'memberCount': instance.memberCount,
    };

QiscusComment _$QiscusCommentFromJson(Map<String, dynamic> json) {
  return QiscusComment(
    json['id'] as int,
    json['roomId'] as int,
    json['uniqueId'] as String,
    json['commentBeforeId'] as int,
    json['message'] as String,
    json['sender'] as String,
    json['senderEmail'] as String,
    json['senderAvatar'] as String,
    json['time'] == null ? null : DateTime.parse(json['time'] as String),
    json['state'] as int,
    json['deleted'] as bool,
    json['hardDeleted'] as bool,
    json['roomName'] as String,
    json['roomAvatar'] as String,
    json['groupMessage'] as bool,
    json['selected'] as bool,
    json['highlighted'] as bool,
    json['downloading'] as bool,
    json['progress'] as int,
    (json['urls'] as List)?.map((e) => e as String)?.toList(),
    json['rawType'] as String,
    json['extraPayload'] as String,
    json['extras'] as Map<String, dynamic>,
    json['replyTo'] == null
        ? null
        : QiscusComment.fromJson(json['replyTo'] as Map<String, dynamic>),
    json['caption'] as String,
    json['attachmentName'] as String,
  );
}

Map<String, dynamic> _$QiscusCommentToJson(QiscusComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'uniqueId': instance.uniqueId,
      'commentBeforeId': instance.commentBeforeId,
      'message': instance.message,
      'sender': instance.sender,
      'senderEmail': instance.senderEmail,
      'senderAvatar': instance.senderAvatar,
      'time': instance.time?.toIso8601String(),
      'state': instance.state,
      'deleted': instance.deleted,
      'hardDeleted': instance.hardDeleted,
      'roomName': instance.roomName,
      'roomAvatar': instance.roomAvatar,
      'groupMessage': instance.groupMessage,
      'selected': instance.selected,
      'highlighted': instance.highlighted,
      'downloading': instance.downloading,
      'progress': instance.progress,
      'urls': instance.urls,
      'rawType': instance.rawType,
      'extraPayload': instance.extraPayload,
      'extras': instance.extras,
      'replyTo': instance.replyTo,
      'caption': instance.caption,
      'attachmentName': instance.attachmentName,
    };

QiscusRoomMember _$QiscusRoomMemberFromJson(Map<String, dynamic> json) {
  return QiscusRoomMember(
    json['email'] as String,
    json['username'] as String,
    json['avatar'] as String,
    json['lastDeliveredCommentId'] as int,
    json['lastReadCommentId'] as int,
    json['extras'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$QiscusRoomMemberToJson(QiscusRoomMember instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'avatar': instance.avatar,
      'lastDeliveredCommentId': instance.lastDeliveredCommentId,
      'lastReadCommentId': instance.lastReadCommentId,
      'extras': instance.extras,
    };
