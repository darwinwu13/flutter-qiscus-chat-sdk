// GENERATED CODE - DO NOT MODIFY BY HAND

part of qiscus_sdk;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QiscusAccount _$QiscusAccountFromJson(Map<String, dynamic> json) {
  return QiscusAccount(
    json['id'] as int,
    json['email'] as String,
    json['avatar'] as String,
    json['token'] as String,
    json['username'] as String,
    json['extras'] as Map<String, dynamic>,
  );
}

Map<String, dynamic> _$QiscusAccountToJson(QiscusAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'avatar': instance.avatar,
      'token': instance.token,
      'username': instance.username,
      'extras': instance.extras,
    };
