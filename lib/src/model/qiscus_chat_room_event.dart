import 'dart:io';

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
  // factory QiscusChatRoomEvent.fromJson(Map<String, dynamic> json) =>
  //     Platform.isIOS
  //         ? _aaaa(json)
  //         : _$QiscusChatRoomEventFromJson(json);
/*  factory QiscusChatRoomEvent.fromJson(Map<String, dynamic> json) =>
      Platform.isIOS
          ? QiscusChatRoomEvent(
              json['roomId'] as int,
              json['commentId'] as int,
              json['commentUniqueId'] as String,
              json['typing'] as bool,
              json['user'] as String,
              mappingEvent(json['event'] as String),
              json['eventData'] as Map<String, dynamic>,
            )
          : _$QiscusChatRoomEventFromJson(json);*/

  Map<String, dynamic> toJson() => _$QiscusChatRoomEventToJson(this);

  static Event mappingEvent(String json){
    switch (json){
      case "TYPING":
        return Event.TYPING;
      case "DELIVERED":
        return Event.DELIVERED;
      case "READ":
        return Event.READ;
      default:
        return Event.CUSTOM;
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  List<Object> get props => [roomId, commentId, commentUniqueId, user];
}

enum Event { TYPING, DELIVERED, READ, CUSTOM }
