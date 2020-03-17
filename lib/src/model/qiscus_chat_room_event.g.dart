// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qiscus_chat_room_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiscusChatRoomEvent _$QiscusChatRoomEventFromJson(Map<String, dynamic> json) {
  return QiscusChatRoomEvent(
    json['roomId'] as int,
    json['commentId'] as int,
    json['commentUniqueId'] as String,
    json['typing'] as bool,
    json['user'] as String,
    _$enumDecodeNullable(_$EventEnumMap, json['event']),
    json['eventData'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$QiscusChatRoomEventToJson(
        QiscusChatRoomEvent instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'commentId': instance.commentId,
      'commentUniqueId': instance.commentUniqueId,
      'typing': instance.typing,
      'user': instance.user,
      'event': _$EventEnumMap[instance.event],
      'eventData': instance.eventData,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$EventEnumMap = {
  Event.TYPING: 'TYPING',
  Event.DELIVERED: 'DELIVERED',
  Event.READ: 'READ',
  Event.CUSTOM: 'CUSTOM',
};
