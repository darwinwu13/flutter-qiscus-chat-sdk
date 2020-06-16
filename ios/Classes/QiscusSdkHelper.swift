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
        userDictionary["avatar_url"] = user.avatarUrl
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
    
    public func memberModelToDic(withMemberModel memberModel: [MemberModel]) -> [[String: Any]] {
        return [[:]]
    }
    
    public func roomModelToDic(withRoomModel roomModel: RoomModel) -> [String: Any] {
        return [:]
    }
    
    public func toJson(withData data: Any) -> String {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]) else {
            return ""
        }
            
        return String(data: theJSONData, encoding: String.Encoding.utf8)!
    }
    
    public func encodeQiscusChatRoom(withChatRoom chatRoom: RoomModel) {
        
    }
}
