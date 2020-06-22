//
//  QiscusEventHandler.swift
//  CocoaAsyncSocket
//
//  Created by ArifCebe on 17/06/20.
//

import Foundation
import QiscusCore
import Flutter

class QiscusEventHandler {
    private var eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink
    private let EVENT_CHANNEL_NAME: String = "bahaso.com/qiscus_chat_sdk/events"
    
    public func QiscusEventHandler(binary messanger: FlutterBinaryMessenger){
        eventChannel = FlutterEventChannel(name: EVENT_CHANNEL_NAME, binaryMessenger: messanger)
        eventChannel.setStreamHandler(self)
    }

    public func registerEventBus(){
        QiscusCore.delegate = self
    }
    
    public func unRegisterEventBus(){
        QiscusCore.delegate = nil
    }
    
}

extension QiscusEventHandler: QiscusCoreDelegate {
    func onRoomMessageReceived(_ room: RoomModel, message: CommentModel){
        // show in app notification
        print("receive new message: \(message.message)")
        // TODO make to json
        var args: [String: Any] = [String: Any]()
        args["type"] = "comment_received"
        args["comment"] = message
        if self.eventSink != nil {
            eventSink(args)
        }
    }

    func onRoomMessageDelivered(message : CommentModel){
     print("receive delivered message: \(message.message)")
        
    }

    func onRoomMessageRead(message : CommentModel){
    print("receive read message: \(message.message)")

    }

    func onChatRoomCleared(roomId : String){


    }

    func onRoomMessageDeleted(room: RoomModel, message: CommentModel) {
    print("receive deleted message: \(message.message)")

    }
}

extension QiscusEventHandler: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
