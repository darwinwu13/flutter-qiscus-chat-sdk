//
//  QiscusSdkHelper.swift
//  firebase_messaging
//
//  Created by bahaso on 08/06/20.
//

import Foundation
import QiscusCore

class QiscusSdkHelper {

    public func userModelToDic(withUser user: UserModel) -> [String: Any] {
        var userDictionary: [String: Any] = [:]
        userDictionary["id"] = user.id
        userDictionary["username"] = user.username
        userDictionary["email"] = user.email
        userDictionary["avatar_url"] = user.avatarUrl.absoluteString
        userDictionary["token"] = user.token
        userDictionary["extras"] = user.extras
        
        return userDictionary
    }
    
    public func qErrorToDic(withError qError: QError) -> [String: Any] {
        var qErrorDictionary: [String: Any] = [:]
        qErrorDictionary["message"] = qError.message
        
        return qErrorDictionary
    }
    
    public func qNonceToDic(withNonce qNonce: QNonce) -> [String: Any] {
        var qNonceDictionary: [String: Any] = [:]
        qNonceDictionary["expired_at"] = qNonce.expiredAt
        qNonceDictionary["nonce"] = qNonce.nonce
        
        return qNonceDictionary
    }
    
    public func roomModelsToDic(withRoomModels roomModels: [RoomModel]) -> [[String: Any]] {
        var chatRooms: [[String: Any]] = [[:]]
        
        for roomModel in roomModels {
            var tmpRoomModel: [String: Any] = [:]
            tmpRoomModel["id"] = roomModel.id
            tmpRoomModel["name"] = roomModel.name
            tmpRoomModel["uniqueId"] = roomModel.uniqueId
            tmpRoomModel["avatarUrl"] = roomModel.avatarUrl?.absoluteString
            tmpRoomModel["type"] = roomModel.type
            tmpRoomModel["options"] = roomModel.options
            tmpRoomModel["lastComment"] = roomModel.lastComment?.extras
            tmpRoomModel["participants"] = roomModel.participants
            tmpRoomModel["unreadCount"] = roomModel.unreadCount
            
            chatRooms.append(tmpRoomModel)
        }
        
        return chatRooms
    }
    
    public func memberModelToDic(withMemberModel memberModel: [MemberModel]) -> [[String: Any]] {
        return [[:]]
    }
    
    public func roomModelToDic(withRoomModel roomModel: RoomModel) -> [String: Any] {
        return [:]
    }
    
    public func commentModelToDic(withComment commentModel: CommentModel) -> [String: Any]{
        var comment: [String: Any] = [String: Any]()
        comment["id"] = commentModel.id
        comment["roomId"] = commentModel.roomId
        comment["uniqueId"] = commentModel.uniqId
        comment["commentBeforeId"] = commentModel.commentBeforeId
        comment["message"] = commentModel.message
        comment["sender"] =  commentModel.username
        comment["senderEmail"] = commentModel.userEmail // sender email
        comment["senderAvatar"] = commentModel.userAvatarUrl?.absoluteString
        comment["time"] = commentModel.date
        comment["state"] = mappingCommentState(commentStatus: commentModel.status)
        comment["deleted"] = commentModel.isDeleted
        comment["hardDeleted"] = commentModel.isDeleted // TODO is hard deleted
//        comment["roomName"] = roomModel.name
//        comment["roomAvatar"] = roomModel.avatarUrl?.absoluteString
//        comment["groupMessage"] = roomModel.type.rawValue // TODO group type check return boolean
        comment["selected"] = commentModel.payload?["selected"] as? Bool ?? false // TODO selected return boolean
        comment["highlighted"] = commentModel.payload?["highligted"] as? Bool ?? false // TODO Raw type return string
        comment["extras"] = commentModel.extras // TODO dictionary type
        comment["replyTo"] = commentModel.payload?["replyTo"] as? [String: Any] ?? [:]// TODO return QiscusComment
        comment["attachmentName"] = commentModel.payload?["attachmentName"] as? String ?? "" // TODO return String
        
        return comment
    }
    
    public func commentModelToDic(withComment commentModel: CommentModel, _ roomModel: RoomModel) -> [String: Any]{
        var comment: [String: Any] = [String: Any]()
        comment["id"] = commentModel.id
        comment["roomId"] = commentModel.roomId
        comment["uniqueId"] = commentModel.uniqId
        comment["commentBeforeId"] = commentModel.commentBeforeId
        comment["message"] = commentModel.message
        comment["sender"] =  commentModel.payload?["sender"] as? String ?? "" // sender
        comment["senderEmail"] = commentModel.userEmail // sender email
        comment["senderAvatar"] = commentModel.userAvatarUrl?.absoluteString
        comment["time"] = commentModel.date
        comment["state"] = mappingCommentState(commentStatus: commentModel.status)
        comment["deleted"] = commentModel.isDeleted
        comment["hardDeleted"] = commentModel.isDeleted // TODO is hard deleted
        comment["roomName"] = roomModel.name
        comment["roomAvatar"] = roomModel.avatarUrl?.absoluteString
        comment["groupMessage"] = roomModel.type.rawValue // TODO group type check return boolean
        comment["selected"] = commentModel.payload?["selected"] as? Bool ?? false // TODO selected return boolean
        comment["highlighted"] = commentModel.payload?["highligted"] as? Bool ?? false // TODO Raw type return string
        comment["extras"] = commentModel.extras // TODO dictionary type
        comment["replyTo"] = commentModel.payload?["replyTo"] as? [String: Any] ?? [:]// TODO return QiscusComment
        comment["attachmentName"] = commentModel.payload?["attachmentName"] as? String ?? "" // TODO return String
        
        return comment
    }
    
    private func mappingCommentState(commentStatus status: CommentStatus) -> Int {
        switch status {
        case .failed:
            return -1
        case .pending:
            return 0
        case .sending:
            return 1
        case .sent:
            return 2
        case .delivered:
            return 3
        case .read:
            return 4
        default:
            return -2 // TODO i don't know what deleted and deleting
        }
    }
    
    public func toJson(withData data: Any) -> String {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]) else {
            return ""
        }
            
        return String(data: theJSONData, encoding: String.Encoding.utf8)!
    }
    
    public func encodeQiscusChatRoom(withChatRoom chatRoom: RoomModel) {
        
    }
    
    public func dicToCommentModel(withDic dic: [String: Any]) -> CommentModel {
        let comment: CommentModel = CommentModel()
        
        return comment
    }
    
    public func dicToRoomModel(withDic dic: [String: Any]) -> RoomModel {
        let room: RoomModel = RoomModel()
        
        return room
    }
    
    public func convertToDictionary(string: String) -> [String: Any]? {
        if let data = string.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return nil
    }
}
