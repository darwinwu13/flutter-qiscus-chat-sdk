library qiscus_sdk;

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qiscus_account.g.dart';

@immutable
@JsonSerializable()
class QiscusAccount {
  final int id;
  final String email;
  final String avatar;
  final String token;
  final String username;
  final Map<String, dynamic> extras;

  QiscusAccount(this.id, this.email, this.avatar, this.token, this.username, this.extras);

  factory QiscusAccount.fromJson(Map<String, dynamic> json) => _$QiscusAccountFromJson(json);

  Map<String, dynamic> toJson() => _$QiscusAccountToJson(this);
}
