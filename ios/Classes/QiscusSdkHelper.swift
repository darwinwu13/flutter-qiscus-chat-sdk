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
        var userDictionary: [String: Any] = [String: Any]()
        userDictionary["id"] = Int(user.id)
        userDictionary["username"] = user.username
        userDictionary["email"] = user.email
        userDictionary["avatar_url"] = user.avatarUrl.absoluteString
        userDictionary["token"] = user.token
        userDictionary["extras"] = convertToDictionary(string: self.removeNewLineAndWhiteSpace(string: user.extras))
        
        return userDictionary
    }
    
    public func qNonceToDic(withNonce qNonce: QNonce) -> [String: Any] {
        var qNonceDictionary: [String: Any] = [String: Any]()
        qNonceDictionary["expired_at"] = qNonce.expiredAt
        qNonceDictionary["nonce"] = qNonce.nonce
        
        return qNonceDictionary
    }
    
    public func roomModelsToListJson(withRoomModels roomModels: [RoomModel]) -> [String] {
        var chatRooms: [String] = [String]()
        
        for roomModel in roomModels {
            let tmpRoomModel: [String: Any] = self.roomModelToDic(withRoomModel: roomModel)
            let tmpRoomModelEncode = self.toJson(withData: tmpRoomModel)
            
            chatRooms.append(tmpRoomModelEncode)
        }
        
        return chatRooms
    }
    
    public func roomModelsToDic(withRoomModels roomModels: [RoomModel]) -> [[String: Any]] {
        var chatRooms: [[String: Any]] = [[String: Any]]()
        
        for roomModel in roomModels {
            let tmpRoomModel: [String: Any] = self.roomModelToDic(withRoomModel: roomModel)
            
            chatRooms.append(tmpRoomModel)
        }
        
        return chatRooms
    }
    
    public func memberModelsToListJson(withMemberModel memberModels: [MemberModel]) -> [String] {
        var members: [String] = [String]()
        
        for memberModel in memberModels {
            let tmpMemberModel: [String: Any] = self.memberModelToDic(withMemberModel: memberModel)
            let tmpMemberModelDecode = self.toJson(withData: tmpMemberModel)
            
            members.append(tmpMemberModelDecode)
        }
        
        return members
    }
    
    public func commentModelsToListJson(withCommentModels commentModels: [CommentModel]) -> [String] {
        var comments: [String] = [String]()
        
        for commentModel in commentModels {
            let tmpCommentModel: [String: Any] = self.commentModelToDic(withComment: commentModel)
            
            let tmpCommentModelEncode = self.toJson(withData: tmpCommentModel)
            comments.append(tmpCommentModelEncode)
        }
        
        return comments
    }
    
    public func commentModelsToListDic(withCommentModels commentModels: [CommentModel]) -> [[String: Any]] {
        var comments: [[String: Any]] = [[String: Any]]()
    
        for commentModel in commentModels {
            let tmpCommentModel: [String: Any] = self.commentModelToDic(withComment: commentModel)
            
            comments.append(tmpCommentModel)
        }
        
        return comments
    }
    
    public func memberModelToDic(withMemberModel memberModel: MemberModel) -> [String: Any] {
        var tmpMemberModel: [String: Any] = [:]
        tmpMemberModel["id"] = Int(memberModel.id)
        tmpMemberModel["avatarUrl"] = memberModel.avatarUrl?.absoluteString
        tmpMemberModel["email"] = memberModel.email
        tmpMemberModel["lastCommentReadId"] = memberModel.lastCommentReadId
        tmpMemberModel["lastCommentReceivedId"] = memberModel.lastCommentReceivedId
        tmpMemberModel["username"] = memberModel.username
        
        return tmpMemberModel
    }
    
    public func roomModelToDic(withRoomModel roomModel: RoomModel) -> [String: Any] {
        var tmpRoomModel: [String: Any] = [String: Any]()
        tmpRoomModel["id"] = Int(roomModel.id)
        tmpRoomModel["name"] = roomModel.name
        tmpRoomModel["uniqueId"] = roomModel.uniqueId
        tmpRoomModel["avatarUrl"] = roomModel.avatarUrl?.absoluteString
        tmpRoomModel["type"] = roomModel.type.rawValue
        tmpRoomModel["unreadCount"] = roomModel.unreadCount
        
        if let participants = roomModel.participants {
            tmpRoomModel["participants"] = self.memberModelsToListJson(withMemberModel: participants)
        }else {
            tmpRoomModel["participants"] = []
        }
        
        if let lastComment = roomModel.lastComment {
            tmpRoomModel["lastComment"] = self.commentModelToDic(withComment: lastComment)
        }else {
            tmpRoomModel["lastComment"] = [:]
        }
        
        if let options = roomModel.options {
            tmpRoomModel["options"] = convertToDictionary(string: self.removeNewLineAndWhiteSpace(string: options))
        }else {
            tmpRoomModel["options"] = [:]
        }
        
        return tmpRoomModel
    }
    
    public func commentModelToDic(withComment commentModel: CommentModel) -> [String: Any] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var comment: [String: Any] = [String: Any]()
        comment["id"] = Int(commentModel.id)
        comment["roomId"] = Int(commentModel.roomId)
        comment["uniqueId"] = commentModel.uniqId
        comment["commentBeforeId"] = Int(commentModel.commentBeforeId)
        comment["message"] = commentModel.message
        comment["sender"] =  commentModel.username
        comment["senderEmail"] = commentModel.userEmail // sender email
        comment["senderAvatar"] = commentModel.userAvatarUrl?.absoluteString
        comment["time"] = formatter.string(from: commentModel.date)
        comment["state"] = mappingCommentState(commentStatus: commentModel.status)
        comment["deleted"] = commentModel.isDeleted
        comment["hardDeleted"] = commentModel.isDeleted // TODO is hard deleted
        comment["rawType"] = commentModel.type // TODO nanti diganti cari dari comment model
        comment["selected"] = commentModel.payload?["selected"] as? Bool ?? false // TODO selected return boolean
        comment["highlighted"] = commentModel.payload?["highligted"] as? Bool ?? false // TODO Raw type return string
        comment["extras"] = commentModel.extras
        comment["extraPayload"] = self.toJson(withData: commentModel.payload ?? [:])
        comment["replyTo"] = commentModel.payload?["replyTo"] as? [String: Any] ?? [:]
        comment["attachmentName"] = commentModel.payload?["attachmentName"] as? String ?? "" // TODO return String
    
        return comment
    }
    
    public func commentModelToDicWithRomm(withComment commentModel: CommentModel, _ roomModel: RoomModel) -> [String: Any] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        var comment: [String: Any] = [String: Any]()
        comment["id"] = Int(commentModel.id)
        comment["roomId"] = Int(commentModel.roomId)
        comment["uniqueId"] = commentModel.uniqId
        comment["commentBeforeId"] = Int(commentModel.commentBeforeId)
        comment["message"] = commentModel.message
        comment["sender"] =  commentModel.payload?["sender"] as? String ?? "" // sender
        comment["senderEmail"] = commentModel.userEmail // sender email
        comment["senderAvatar"] = commentModel.userAvatarUrl?.absoluteString
        comment["time"] = formatter.string(from: commentModel.date)
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
    
    public func mergeRoomModelAndCommentModelDic(withRoomModel roomModel: RoomModel, withCommentModel commentModel: [CommentModel]) -> [String: String] {
        let roomModelDic = self.roomModelToDic(withRoomModel: roomModel)
        let commentModelDic = self.commentModelsToListDic(withCommentModels: commentModel)
        
        var roomAndComment: [String: String] = [String: String]()
        roomAndComment["chatRoom"] = self.toJson(withData: roomModelDic)
        roomAndComment["messages"] = self.toJson(withData: commentModelDic)
        
        return roomAndComment
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
    
    public func removeNewLineAndWhiteSpace(string: String) -> String {
        return String(string.filter { !" \n\t\r".contains($0) })
    }
    
    public func covertToListOfString(data: [Int]) -> [String] {
        var listOfString: [String] = [String]()
        
        for datum in data {
            listOfString.append(String(datum))
        }
        
        return listOfString
    }
    
    public func getLastQiscusComment(withRoomModel roomModel: RoomModel) -> CommentModel? {
        return roomModel.lastComment
    }
}
