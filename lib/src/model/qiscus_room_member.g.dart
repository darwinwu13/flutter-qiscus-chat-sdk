// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiscus_room_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
