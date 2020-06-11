import Flutter
import UIKit
import QiscusCore
import CoreFoundation
import GenerateToDictionary

public class SwiftQiscusSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "qiscus_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftQiscusSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    
    switch call.method {
    case "setup":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let appId: String = arguments["appId"] as? String ?? ""
        
        setup(withAppId: appId)
        break
    case "enableDebugMode":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let value: Bool = arguments["value"] as? Bool ?? false
            
        enableDebugMode(withValue: value);
        break
    case "setNotificationListener":
        break
    case "setEnableFcmPushNotification":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let value: Bool = arguments["value"] as? Bool ?? false
            
        setEnableFcmPushNotification(withValue: value);
        break
    case "registerDeviceToken":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let token: String = arguments["value"] as? String ?? ""
        
        registerDeviceToken(withToken: token)
        break
    case "removeDeviceToken":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let token: String = arguments["value"] as? String ?? ""
        
        removeDeviceToken(withToken: token)
        break
    case "clearUser":
        clearUser()
        break
    case "login":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        
        let userId: String = arguments["userId"] as? String ?? ""
        let userKey: String = arguments["userKey"] as? String ?? ""
        let username: String = arguments["username"] as? String ?? ""
        
        let avatar: String = arguments["avatarUrl"] as? String ?? ""
        let avatarUrl: URL? = avatar != "" ? URL(string: avatar) : nil
        
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        
        login(withUserId: userId, withUserKey: userKey, withUsername: username, withAvatarUrl: avatarUrl, withExtras: extras, withResult: result)
        break
    case "getNonce":
        getNonce(withResult: result)
        break
    case "setUserWithIdentityToken":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let token: String = arguments["token"] as? String ?? ""
    
        setUserWithIdentityToken(withToken: token, withResult: result)
        break
    case "updateUser":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let username: String = arguments["username"] as? String ?? ""
    
        let avatar: String = arguments["avatarUrl"] as? String ?? ""
        let avatarUrl: URL? = avatar != "" ? URL(string: avatar) : nil
    
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        updateUser(withUsername: username, withAvatarUrl: avatarUrl, withExtras: extras, withResult: result)
        break
    case "hasLogin":
        hasLogin(withResult: result)
        break
    case "getQiscusAccount":
        getQiscusAccount(withResult: result)
        break
    case "getAllUsers":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let searchUsername: String = arguments["searchUsername"] as? String ?? ""
        let page: Int = arguments["page"] as? Int ?? ""
        let limit: Int = arguments["limit"] as? Int ?? ""
        
        getAllUsers(withSearchUsername: searchUsername, withPage: page, withLimit: limit, withResult: result)
        break
    case "chatUser":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let userId: String = arguments["userId"] as? String ?? ""
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        
        chatUser(withUserId: userId, withExtras: extras, withResult: result)
        break
    default:
        return
    }
  }
    
    private func setup(withAppId appId: String) {
        QiscusCore.setup(AppID: appId)
    }
    
    private func enableDebugMode(withValue value: Bool) {
        QiscusCore.enableDebugMode(value: value)
    }
    
    private func setEnableFcmPushNotification(withValue value: Bool) {
        
    }
    
    private func registerDeviceToken(withToken token: String) {
        QiscusCore.shared.registerDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in
            
            result(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = GenerateToDictionary.qError(withError: error)
            
            result(errorDictionary)
        })
    }
    
    private func removeDeviceToken(withToken token: String) {
        QiscusCore.shared.removeDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in
            
            result(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = GenerateToDictionary.qError(withError: error)
            
            result(errorDictionary)
        })
    }
    
    private func clearUser() {
        QiscusCore.clearUser(completion: {
            (error: QError?) -> () in
            let errorDictionary = GenerateToDictionary.qError(withError: error)
            
            result(errorDictionary)
        })
    }
    
    private func login(
        withUserId userId: String,
        withUserKey userKey: String,
        withUsername username: String,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?,
        withResult result: FlutterResult
    ) {
        QiscusCore.setUser(
            userId: userId,
            userKey: userKey,
            username:username,
            avatarURL: avatarUrl,
            extras: extras,
            onSuccess: {
                (user: UserModel) in
                let userDictionary = GenerateToDictionary.userModel(withUserModel: user)
                
                result(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func getNonce(withResult result: FlutterResult) {
        QiscusCore.getJWTNonce(
            onSuccess: {
                (nonce: QNonce) in
                let nonceDictionary = GenerateToDictionary.qNonce(withNonce: nonce)
                
                result(nonceDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func setUserWithIdentityToken(withToken token: String, withResult result: FlutterResult) {
        QiscusCore.setUserWithIdentityToken(
            token: token,
            onSuccess: {
                (user: UserModel) in
                let userDictionary = GenerateToDictionary.userModel(withUserModel: user)
                
                result(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func updateUser(
        withUsername username: String,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?,
        withResult result: FlutterResult
    ) {
        QiscusCore.shared.updateUser(
            name: username,
            avatarURL: avatarUrl,
            extras: extras,
            onSuccess: {
                (user: UserModel) in
                let userDictionary = GenerateToDictionary.userModel(withUserModel: user)
                
                result(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func hasLogin(withResult result: FlutterResult) {
        result(QiscusCore.hasSetupUser())
    }
    
    private func getAllUsers(
        withSearchUsername searchUsername: String,
        withPage page: Int,
        withLimit limit: Int,
        withResult result: FlutterResult
    ) {
        QiscusCore.shared.getUsers(
            searchUsername: searchUsername,
            page: page,
            limit: limit,
            onSuccess: {
                (memberModel: [MemberModel], Meta) in
                let memberDictionary = GenerateToDictionary.memberModel(withMemberModel: memberModel)
                
                result(memberDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func chatUser(
        withUserId userId: String,
        withExtras extras: [String: Any]?,
        withResult result: FlutterResult
    ) {
        QiscusCore.shared.chatUser(
            userId: userId,
            extras: extras,
            onSuccess: {
                (RoomModel, [CommentModel]) in
                let roomModelDictionary = GenerateToDictionary.roomModel()
                
                result(roomModelDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func updateChatRoom(
        withRoomId roomId: String,
        withName name: String?,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?,
        WithResult result: FlutterResult
    ) {
        QiscusCore.shared.updateChatRoom(
            roomId: roomId,
            name: name,
            avatarURL: avatarUrl,
            extras: extras,
            onSuccess: {
                (RoomModel) in
                let roomModelDictionary = GenerateToDictionary.roomModel()
                
                result(roomModelDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = GenerateToDictionary.qError(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func getQiscusAccount(withResult result: FlutterResult) {
//        do {
//            try result()
//        } catch (e: Error) {
            
//        }
    }
    
    
}
