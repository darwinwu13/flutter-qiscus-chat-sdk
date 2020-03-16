import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'qiscus_chat_room_event.g.dart';

@immutable
@JsonSerializable()
class QiscusChatRoomEvent extends Equatable {
  final int roomId;
  final int commentId;
  final String commentUniqueId;
  final bool typing;
  final String user;
  final Event event;
  final Map<String, dynamic> eventData;

  QiscusChatRoomEvent(
    this.roomId,
    this.commentId,
    this.commentUniqueId,
    this.typing,
    this.user,
    this.event,
    this.eventData,
  );

  factory QiscusChatRoomEvent.fromJson(Map<String, dynamic> json) =>
      _$QiscusChatRoomEventFromJson(json);

  Map<String, dynamic> toJson() => _$QiscusChatRoomEventToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  List<Object> get props => [roomId, commentId, commentUniqueId, user];
}

enum Event { TYPING, DELIVERED, READ, CUSTOM }
