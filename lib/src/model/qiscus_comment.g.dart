// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiscus_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
