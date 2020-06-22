import Flutter
import UIKit
import QiscusCore
import CoreFoundation

public class SwiftQiscusSdkPlugin: NSObject, FlutterPlugin {
  let qiscusSdkHelper: QiscusSdkHelper = QiscusSdkHelper()
    private var eventHandler: QiscusEventHandler!
    

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "qiscus_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftQiscusSdkPlugin()
    instance.setupEventHandler(binary: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        eventHandler.unRegisterEventBus()
    }
    
    private func setupEventHandler(binary messenger: FlutterBinaryMessenger){
        self.eventHandler = QiscusEventHandler(binary: messenger)
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
            
        enableDebugMode(withValue: value)
        break
    case "setNotificationListener":
        break
    case "setEnableFcmPushNotification":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let value: Bool = arguments["value"] as? Bool ?? false
            
        setEnableFcmPushNotification(withValue: value)
        break
    case "registerDeviceToken":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let token: String = arguments["value"] as? String ?? ""
        
        registerDeviceToken(withToken: token, withResult: result)
        break
    case "removeDeviceToken":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let token: String = arguments["value"] as? String ?? ""
        
        removeDeviceToken(withToken: token, withResult: result)
        break
    case "clearUser":
        clearUser(withResult: result)
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
        let page: Int = arguments["page"] as? Int ?? 0
        let limit: Int = arguments["limit"] as? Int ?? 0
        
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
    
    private func registerDeviceToken(withToken token: String, withResult result: FlutterResult) {
        QiscusCore.shared.registerDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in

            result(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

            result(errorDictionary)
        })
    }
    
    private func removeDeviceToken(withToken token: String, withResult result: FlutterResult) {
        QiscusCore.shared.removeDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in

            result(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

            result(errorDictionary)
        })
    }
    
    private func clearUser(withResult result: FlutterResult) {
        QiscusCore.clearUser(completion: {
            (error: QError?) -> () in
            guard let qiscusError = error else {
                result(FlutterMethodNotImplemented)
                return
            }

            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: qiscusError)
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
                let userDictionary = self.qiscusSdkHelper.userModelToDic(withUser: user)

                result(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func getNonce(withResult result: FlutterResult) {
        QiscusCore.getJWTNonce(
            onSuccess: {
                (nonce: QNonce) in
                let nonceDictionary = self.qiscusSdkHelper.qNonceToDic(withNonce: nonce)

                result(nonceDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func setUserWithIdentityToken(withToken token: String, withResult result: FlutterResult) {
        QiscusCore.setUserWithIdentityToken(
            token: token,
            onSuccess: {
                (user: UserModel) in
                let userDictionary = self.qiscusSdkHelper.userModelToDic(withUser: user)

                result(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

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
                let userDictionary = self.qiscusSdkHelper.userModelToDic(withUser: user)

                result(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

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
                let memberDictionary = self.qiscusSdkHelper.memberModelToDic(withMemberModel: memberModel)

                result(memberDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func chatUser(
        withUserId userId: String,
        withExtras extras: [String: Any]?,
        withResult result: FlutterResult
    ) {
        var extrasString: String?

        if let _extras = extras {
            extrasString = self.qiscusSdkHelper.toJson(withData: _extras)
        }

        QiscusCore.shared.chatUser(
            userId: userId,
            extras: extrasString,
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                let roomModelDictionary = self.qiscusSdkHelper.roomModelToDic(withRoomModel: room)

                result(roomModelDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

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
        var extrasString: String?

        if let _extras = extras {
            extrasString = self.qiscusSdkHelper.toJson(withData: _extras)
        }

        QiscusCore.shared.updateChatRoom(
            roomId: roomId,
            name: name,
            avatarURL: avatarUrl,
            extras: extrasString,
            onSuccess: {
                (room: RoomModel) in
                let roomModelDictionary = self.qiscusSdkHelper.roomModelToDic(withRoomModel: room)

                result(roomModelDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func addOrUpdateLocalChatRoom(withChatRoom chatRoom: [RoomModel], withResult result: FlutterResult) {
        do {
            try QiscusCore.database.room.save(chatRoom)

            result(true)
        } catch let error {
            result("ERR_FAILED_ADD_OR_UPDATE_LOCAL_CHAT_ROOM \(error.localizedDescription)")
        }
    }
    
    private func getChatRoomWithMessages(withRoomId roomId: String, withResult result: FlutterResult) {
        QiscusCore.shared.getChatRoomWithMessages(
            roomId: roomId,
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                print(room)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func getLocalChatRoom(withRoomId roomId: String, withResult result: FlutterResult) {
        let localChatRooms: [RoomModel] = QiscusCore.database.room.all()
        let localChatRoomsJson: String = self.qiscusSdkHelper.toJson(withData: localChatRooms)
        
        result(localChatRoomsJson)
    }
    
    private func getChatRoomByRoomIds(
        withRoomIds roomIds: [String],
        withShowRemoved showRemoved: Bool,
        withShowParticipant showParticipant: Bool,
        withResult result: FlutterResult
    ) {
        QiscusCore.shared.getChatRooms(
            roomIds: roomIds,
            showRemoved: showRemoved,
            showParticipant: showParticipant,
            onSuccess: {
                (rooms: [RoomModel]) in
                let roomsJson: String = self.qiscusSdkHelper.toJson(withData: rooms)
                result(roomsJson)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func getLocalChatRoomByRoomIds(
        withRoomIds roomIds: [Int],
        withResult result: FlutterResult
    ) {
       // todo
    }
    
    private func getAllChatRooms(
        withShowParticipant showParticipant: Bool,
        withShowRemoved showRemoved: Bool,
        withShowEmpty showEmpty: Bool,
        withPage page: Int,
        withLimit limit: Int,
        withResult result: FlutterResult
    ) {
        QiscusCore.shared.getAllChatRooms(
            showParticipant: showParticipant,
            showRemoved: showRemoved,
            showEmpty: showEmpty,
            page: page,
            limit: limit,
            onSuccess: {
                (rooms: [RoomModel], meta: Meta?) -> () in
                let roomsJson: String = self.qiscusSdkHelper.toJson(withData: rooms)
                result(roomsJson)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                result(errorDictionary)
            }
        )
    }
    
    private func getLocalChatRooms(withLimit limit: Int, withOffset offset: Int, withResult result: FlutterResult) {
        let predicate: NSPredicate = NSPredicate(format: "LIMIT \(limit) OFFSET \(offset)")
        let localChatRooms: [RoomModel]? = QiscusCore.database.room.find(predicate: predicate)
        if let _localChatRooms = localChatRooms {
            result(_localChatRooms)
        }else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getLocalChatRooms(withLimit limit: Int, withResult result: FlutterResult) {
        // todo
    }
    
    private func getTotalUnreadCount(result: FlutterResult) {
        // todo
        QiscusCore.shared.getTotalUnreadCount {
            (totalUnreadCount: Int, error: QError?) in
            if let _error = error {
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: _error)
                
                result(errorDictionary)
                return
            }
            
            result(totalUnreadCount)
        }
    }
    
    private func sendMessage(
        withRoomId roomId: Int,
        withMessage message: String,
        withPayload extras: [String: Any]?,
        withResult result: FlutterResult
    ) {
        
    }
    
    private func sendFileMessage(
        withRoomId roomId: Int,
        withCaption caption: String,
        withFilePath filePath: String,
        withExtras extras: [String: Any]?,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func getQiscusAccount(withResult result: FlutterResult) {
        // todo
    }

    private func getLocalComments(withRoomId roomId: Int, withResult result: FlutterResult) {
        // todo
    }
    
    private func getLocalComments(withRoomId roomId: Int, withLimit limit: Int, withResult result: FlutterResult) {
        // todo
    }
    
    private func registerEventHandler(withResult result: FlutterResult) {
        // todo
        self.eventHandler.registerEventBus()
    }
    
    private func unregisterEventHandler(withResult result: FlutterResult) {
        // todo
        self.eventHandler.unRegisterEventBus()
    }
    
    private func markCommentAsRead(
        withRoomId roomId: Int,
        withCommentId commentId: Int,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func addOrUpdateLocalComment(
        withComment comment: QiscusComment,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func subscribeToChatRoom(withChatRoom chatRoom: RoomModel, withResult result: FlutterResult) {
        // todo
    }
    
    private func unsubscribeToChatRoom(withChatRoom chatRoom: RoomModel, withResult result: FlutterResult) {
        // todo
    }
    
    private func deleteLocalCommentsByRoomId(withRoomId roomId: Int, withResult result: FlutterResult) {
        // todo
    }
    
    private func deleteLocalCommentByUniqueId(
        withUniqueId uniqueId: String,
        withCommentId commentId: Int,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func deleteLocalComment(withComment comment: QiscusComment, withResult result: FlutterResult) {
        // todo
    }
    
    private func deleteLocalChatRoom(withRoomId roomId: Int, withResult result: FlutterResult) {
        // todo
    }
    
    private func getPrevMessages(
        withRoomId roomId: Int,
        withLimit limit: Int,
        withMessageId messageId: Int,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func getLocalPrevMessages(
        withRoomId roomId: Int,
        withLimit limit: Int,
        withUniqueId uniqueId: String,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func getLocalNextMessages(
        withRoomId roomId: Int,
        withLimit limit: Int,
        withUniqueId uniqueId: String,
        withResult result: FlutterResult
    ) {
        // todo
    }
    
    private func getNextMessages(
        withRoomId roomId: Int,
        withLimit limit: Int,
        withMessageId messageId: Int,
        withResult result: FlutterResult
    ) {
        // todo
    }
}
