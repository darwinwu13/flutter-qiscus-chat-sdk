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
