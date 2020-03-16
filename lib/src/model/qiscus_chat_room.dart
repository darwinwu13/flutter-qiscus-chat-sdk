import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import 'qiscus_room_member.dart';
import 'qiscus_comment.dart';

part 'qiscus_chat_room.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class QiscusChatRoom extends Equatable {
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

  QiscusChatRoom(this.id,
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

  @override
  List<Object> get props => [id, distinctId, uniqueId, name];
}
