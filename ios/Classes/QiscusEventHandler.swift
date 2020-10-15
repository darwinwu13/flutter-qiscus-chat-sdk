//
//  QiscusEventHandler.swift
//  CocoaAsyncSocket
//
//  Created by ArifCebe on 17/06/20.
//

import Foundation
import Flutter
import QiscusCore

class QiscusEventHandler {
    private var eventChannel: FlutterEventChannel!
    private let EVENT_CHANNEL_NAME: String = "bahaso.com/qiscus_chat_sdk/events"
    private let qiscusSdkHelper: QiscusSdkHelper = QiscusSdkHelper()
    private var eventStreamHandler: QiscusEventStreamHandler
    
    private func getEventSink() -> FlutterEventSink? {
        return eventStreamHandler.eventSink
    }
    
    init(binary messenger: FlutterBinaryMessenger) {
        eventStreamHandler = QiscusEventStreamHandler()
        eventChannel = FlutterEventChannel(name: EVENT_CHANNEL_NAME, binaryMessenger: messenger)
        eventChannel.setStreamHandler(eventStreamHandler)
        
        self.connect()
    }
    
    private func connect() {
        if QiscusCore.hasSetupUser() {
            let _ = QiscusCore.connect(delegate: self)
        }
    }

    public func registerEventBus(){
        QiscusCore.delegate = self
    }
    
    public func unRegisterEventBus(){
        QiscusCore.delegate = nil
    }
    
    public func onFileUploadProgress(withProgress progress: Double) {
        if let eventSink = getEventSink() {
            var result: [String: Any] = [:]
            result["type"] = "file_upload_progress"
            result["progress"] = Int(progress)
            DispatchQueue.main.async {
                eventSink(self.qiscusSdkHelper.toJson(withData: result))
            }
            
        }
    }
}

// MARK: Core Delegate List of Chat Rooms
extension QiscusEventHandler: QiscusCoreDelegate {
    
    func onRoomMessageReceived(_ room: RoomModel, message: CommentModel) {
        if message.status == CommentStatus.read{
            QiscusCore.shared.markAsRead(roomId: message.roomId, commentId: message.id)
        }
        self.mappingChatRoomEvent(withRoom: room, messageComment: message)
    }
    
    func onRoomMessageDeleted(room: RoomModel, message: CommentModel) {

    }
    
    func onRoomMessageDelivered(message: CommentModel) {
        // ROOM meessage deliverd
    }
    
    func onRoomMessageRead(message: CommentModel) {
        // TODO message has been read
        print("List of Chat Room | has been read \(message.message) \(message.status.rawValue)")
//        if message.status == CommentStatus.read{
//            QiscusCore.shared.markAsRead(roomId: message.roomId, commentId: message.id)
//        }
    }
    
    func onChatRoomCleared(roomId: String) {
        // chat room cleared
    }
    
    func onRoomDidChangeComment(comment: CommentModel, changeStatus status: CommentStatus) {
        /// TODO untuk next disini untuk merubah status comment ketika terkirim, diterima dan terbaca.
        /// sebelumnya perlu menyimpan list chat disini terlebih dahulu, kemudian merubah statusnya bisa cek berdasarkan comment id
        /// untuk di case ini sementara bisa dikeep dulu
        print("did change comment \(comment.message) \(status)")
    }
    
    func onRoom(update room: RoomModel) {
        // depracated method
    }
    
    func onRoom(deleted room: RoomModel) {
        // depracated method
    }
    
    func gotNew(room: RoomModel) {
        // depracated method
    }
    
}

// MARK: Core Delegate of Chat Room
extension QiscusEventHandler: QiscusCoreRoomDelegate{
    func onMessageReceived(message: CommentModel) {
        if message.status == CommentStatus.read{
            QiscusCore.shared.markAsRead(roomId: message.roomId, commentId: message.id)
        }
        mappingCommentReceive(messageComment: message)
    }
    
    func didComment(comment: CommentModel, changeStatus status: CommentStatus) {
        /// TODO untuk next disini untuk merubah status comment ketika terkirim, diterima dan terbaca.
        /// sebelumnya perlu menyimpan list chat disini terlebih dahulu, kemudian merubah statusnya bisa cek berdasarkan comment id
        print("comment status in \(comment.message) \(status.rawValue)")
    }
    
    func onMessageDelivered(message: CommentModel) {
       
    }
    
    func onMessageRead(message: CommentModel) {
//        print("Chat Room | has been read \(message.message) \(message.status.rawValue)")
//        mappingCommentReceive(messageComment: message)
//        if message.status == CommentStatus.read{
//            QiscusCore.shared.markAsRead(roomId: message.roomId, commentId: message.id)
//        }
    }
    
    func onMessageDeleted(message: CommentModel) {
        
    }
    
    func onUserTyping(userId: String, roomId: String, typing: Bool) {
        // TODO handle user typing
        if let user = QiscusCore.database.member.find(byUserId: userId) {
            QiscusCore.shared.publishTyping(roomID: roomId, isTyping: typing)
        }
    }
    
    func onUserOnlinePresence(userId: String, isOnline: Bool, lastSeen: Date) {
        // TODO handle state on Qiscus
        let user = QiscusCore.database.member.find(byUserId: userId)
        
    }
    
    private func mappingChatRoomEvent(withRoom room: RoomModel, messageComment message: CommentModel){
        var args: [String: Any] = [String: Any]()
        let commentDic = self.qiscusSdkHelper.commentModelToDic(withComment: message)
        var chatRoomEvent: [String: Any] = [String: Any]()
        chatRoomEvent["roomId"] = Int(room.id)
        chatRoomEvent["commentId"] = Int(message.id)
        chatRoomEvent["commentUniqueId"] = message.uniqId
        chatRoomEvent["typing"] = false
        chatRoomEvent["user"] = message.userEmail
        chatRoomEvent["event"] = qiscusSdkHelper.mappingEventState(commentStatus: message.status).rawValue
        chatRoomEvent["eventData"] = qiscusSdkHelper.convertToDictionary(string: room.options!)
        args["type"] = "chat_room_event_received"
        args["chatRoomEvent"] = commentDic
//        args["chatRoomEvent"] = chatRoomEvent
        
        if let eventSink = getEventSink() {
            DispatchQueue.main.async {
                eventSink(self.qiscusSdkHelper.toJson(withData: args))
            }
        }
    }
    
    private func mappingCommentReceive(messageComment message: CommentModel){
        var args: [String: Any] = [String: Any]()
        let commentDic = self.qiscusSdkHelper.commentModelToDic(withComment: message)
        print("comment state \(commentDic["state"] as? Int ?? 0)")
        args["type"] = "comment_received"
        args["comment"] = commentDic
        
        if let eventSink = getEventSink() {
            DispatchQueue.main.async {
                eventSink(self.qiscusSdkHelper.toJson(withData: args))
            }
        }
    }
    
}

extension QiscusEventHandler: QiscusConnectionDelegate {
    func connectionState(change state: QiscusConnectionState) {
        sendConnectionState(change: state)
    }
    
    func onConnected() {
        sendConnectionState(change: .connected)
    }
    
    func onReconnecting() {
        sendConnectionState(change: .connecting)
    }
    
    func onDisconnected(withError err: QError?) {
        sendConnectionState(change: .disconnected)
    }
    
    private func sendConnectionState(change state: QiscusConnectionState){
        var connectionState: String = ""
        switch state {
        case .connected:
            connectionState = "connected"
            break
        case .connecting:
            connectionState = "reconnecting"
            break
        case .disconnected:
            connectionState = "disconnected"
            break
        }
        var args: [String: Any] = [String: Any]()
        args["status"] = connectionState
        
        if let eventSink = getEventSink() {
            eventSink(self.qiscusSdkHelper.toJson(withData: args))
        }
    }
    
}

class QiscusEventStreamHandler: NSObject, FlutterStreamHandler {
    var eventSink: FlutterEventSink?
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        
        return nil
    }
}

public enum Event: String {
    case TYPING = "TYPING"
    case DELIVERED = "DELIVERED"
    case READ = "READ"
    case CUSTOM = "CUSTOM"
}
