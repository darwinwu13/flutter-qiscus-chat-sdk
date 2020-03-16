import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qiscus_room_member.g.dart';

@immutable
@JsonSerializable()
class QiscusRoomMember extends Equatable {
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

  @override
  List<Object> get props => [email, username, avatar];
}
