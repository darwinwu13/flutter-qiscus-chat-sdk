// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiscus_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiscusComment _$QiscusCommentFromJson(Map<String, dynamic> json) {
  return QiscusComment(
    id: json['id'] as int,
    roomId: json['roomId'] as int,
    uniqueId: json['uniqueId'] as String,
    commentBeforeId: json['commentBeforeId'] as int,
    message: json['message'] as String,
    sender: json['sender'] as String,
    senderEmail: json['senderEmail'] as String,
    senderAvatar: json['senderAvatar'] as String,
    time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
    state: json['state'] as int,
    deleted: json['deleted'] as bool,
    hardDeleted: json['hardDeleted'] as bool,
    roomName: json['roomName'] as String,
    roomAvatar: json['roomAvatar'] as String,
    groupMessage: json['groupMessage'] as bool,
    selected: json['selected'] as bool,
    highlighted: json['highlighted'] as bool,
    downloading: json['downloading'] as bool,
    progress: json['progress'] as int,
    urls: (json['urls'] as List)?.map((e) => e as String)?.toList(),
    rawType: json['rawType'] as String,
    extraPayload: QiscusComment._extraPayloadFromJson(json['extraPayload']),
    extras: json['extras'] as Map<String, dynamic>,
    replyTo: json['replyTo'] == null
        ? null
        : QiscusComment.fromJson(json['replyTo'] as Map<String, dynamic>),
    attachmentName: json['attachmentName'] as String,
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
      'extras': instance.extras,
      'replyTo': instance.replyTo,
      'attachmentName': instance.attachmentName,
      'extraPayload': instance.extraPayload,
    };
