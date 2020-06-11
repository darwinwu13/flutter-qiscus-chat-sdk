//
//  GenerateToDictonary.swift
//  Alamofire
//
//  Created by bahaso on 11/06/20.
//

import Foundation
import QiscusCore

public class GenerateToDictionary {
    public func userModel(withUser user: UserModel) -> [String: Any] {
        var userDictionary: [String: Any] = [:]
        userDictionary["id"] = user.id
        userDictionary["username"] = user.username
        userDictionary["email"] = user.email
        userDictionary["avatar_url"] = user.avatarUrl
        userDictionary["token"] = user.token
        userDictionary["extras"] = user.extras
        
        return userDictionary
    }
    
    public func qError(withError qError: QError) -> [String: Any] {
        var qErrorDictionary: [String: Any] = [:]
        qErrorDictionary["message"] = QError.message
        
        return qErrorDictionary
    }
    
    public func qNonce(withNonce qNonce: QNonce) -> [String: Any] {
        var qNonceDictionary: [String: Any] = [:]
        qNonceDictionary["expired_at"] = qNonce.expiredAt
        qNonceDictionary["nonce"] = qNonce.nonce
        
        return qNonceDictionary
    }
    
    public func memberModel(withMemberModel memberModel: [MemberModel]) -> [[String: Any]] {
        return [[:]]
    }
    
    public func roomModel(withRoomModel roomModel: RoomModel) -> [String: Any] {
        return [:]
    }
}
