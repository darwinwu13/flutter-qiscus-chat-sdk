import Flutter
import UIKit
import QiscusCore
import CoreFoundation

public class SwiftQiscusSdkPlugin: NSObject, FlutterPlugin {
    let qiscusSdkHelper: QiscusSdkHelper = QiscusSdkHelper()
    let qiscusRepository: QiscusRepository = QiscusRepository()
    private var eventHandler: QiscusEventHandler!
    
    static let CHANNEL_NAME: String = "bahaso.com/qiscus_chat_sdk"
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = SwiftQiscusSdkPlugin()
        instance.setupEventHandler(binary: registrar.messenger())
        instance.registerEventHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        eventHandler.unRegisterEventBus()
    }
    
    
    private func setupEventHandler(binary messenger: FlutterBinaryMessenger){
        print("setup event handler")
        self.eventHandler = QiscusEventHandler(binary: messenger)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("call handle method \(call.method)")
        QiscusCore.enableDebugMode(value: true)
        switch call.method {
        case "setup":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let appId: String = arguments["appId"] as? String ?? ""
            
            setup(withAppId: appId, withResult: result)
            break
        case "enableDebugMode":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let value: Bool = arguments["value"] as? Bool ?? false
            
            enableDebugMode(withValue: value, withResult: result)
            break
        case "setNotificationListener":
            break
        case "setEnableFcmPushNotification":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let value: Bool = arguments["value"] as? Bool ?? false
            
            setEnableFcmPushNotification(withValue: value, withResult: result)
            break
        case "registerDeviceToken":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let token: String = arguments["token"] as? String ?? ""
            print("ios : device token \(token)")
            
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
            
            let stringExtras: String = arguments["extras"] as? String ?? String()
            var extras: [String: Any]? = [:]
            if stringExtras != String() {
                extras = self.qiscusSdkHelper.convertToDictionary(string: stringExtras)
            }
            let mainPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            print("main path \(mainPath)")
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
            
            let stringExtras: String = arguments["extras"] as? String ?? String()
            var extras: [String: Any]? = [:]
            if stringExtras != String() {
                extras = self.qiscusSdkHelper.convertToDictionary(string: stringExtras)
            }
            
            updateUser(withUsername: username, withAvatarUrl: avatarUrl, withExtras: extras, withResult: result)
            break
        case "hasLogin":
            hasLogin(withResult: result)
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
            let stringExtras: String = arguments["extras"] as? String ?? String()
            var extras: [String: Any]? = [:]
            if stringExtras != String() {
                extras = self.qiscusSdkHelper.convertToDictionary(string: stringExtras)
            }
            
            chatUser(withUserId: userId, withExtras: extras, withResult: result)
            break
        case "updateChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? ""
            let name: String? = arguments["name"] as? String ?? ""
            let avatar: String = arguments["avatarUrl"] as? String ?? ""
            let avatarUrl: URL? = avatar != "" ? URL(string: avatar) : nil
            let stringExtras: String = arguments["extras"] as? String ?? String()
            var extras: [String: Any]? = [:]
            if stringExtras != String() {
                extras = self.qiscusSdkHelper.convertToDictionary(string: stringExtras)
            }
            
            updateChatRoom(withRoomId: roomId, withName: name, withAvatarUrl: avatarUrl, withExtras: extras, withResult: result)
            break
        case "addOrUpdateLocalChatRoom":
            result(true)
            break
        case "getChatRoomWithMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            
            getChatRoomWithMessages(withRoomId: String(roomId), withResult: result)
            break
        case "getLocalChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            
            getLocalChatRoom(withRoomId: String(roomId), withResult: result)
            break
        case "getChatRoomByRoomIds":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomIds: [Int] = arguments["roomIds"] as? [Int] ?? [Int]()
            let stringRoomIds: [String] = self.qiscusSdkHelper.covertToListOfString(data: roomIds)
            let showRemoved: Bool = arguments["showRemoved"] as? Bool ?? Bool()
            let showParticipant: Bool = arguments["showParticipant"] as? Bool ?? Bool()
            
            getChatRoomByRoomIds(
                withRoomIds: stringRoomIds,
                withShowRemoved: showRemoved,
                withShowParticipant: showParticipant,
                withResult: result
            )
            break
        case "getLocalChatRoomByRoomIds":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomIds: [Int] = arguments["roomIds"] as? [Int] ?? [Int]()
            let stringRoomIds: [String] = self.qiscusSdkHelper.covertToListOfString(data: roomIds)
            
            getLocalChatRoomByRoomIds(withRoomIds: stringRoomIds, withResult: result)
            break
        case "getAllChatRooms":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let showParticipant: Bool = arguments["showParticipant"] as? Bool ?? Bool()
            let showEmpty: Bool = arguments["showEmpty"] as? Bool ?? Bool()
            let showRemoved: Bool = arguments["showRemoved"] as? Bool ?? Bool()
            let page: Int = arguments["page"] as? Int ?? Int()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            
            getAllChatRooms(
                withShowParticipant: showParticipant,
                withShowRemoved: showRemoved,
                withShowEmpty: showEmpty,
                withPage: page,
                withLimit: limit,
                withResult: result
            )
            break
        case "getLocalChatRooms":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let offset = arguments["offset"] as? Int ?? nil
            
            let path = NSSearchPathForDirectoriesInDomains(
                .applicationSupportDirectory, .userDomainMask, true
            ).first!
            
            print("path \(path)")
            getLocalChatRooms(withLimit: limit, withOffset: offset, withResult: result);
            break
        case "getTotalUnreadCount":
            getTotalUnreadCount(withResult: result)
            break
        case "sendMessage":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let message: String = arguments["message"] as? String ?? String()
            let stringPayload: String = arguments["payload"] as? String ?? String()
            var payload: [String: Any]? = [:]
            if stringPayload != String() {
                payload = self.qiscusSdkHelper.convertToDictionary(string: stringPayload)
            }
            
            sendMessage(
                withRoomId: String(roomId),
                withMessage: message,
                withPayload: payload,
                withResult: result
            )
            break
        case "sendFileMessage":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let caption: String = arguments["caption"] as? String ?? String()
            let filePath: String = arguments["filePath"] as? String ?? String()
            let stringExtras: String = arguments["extras"] as? String ?? String()
            var extras: [String: Any]? = [:]
            if stringExtras != String() {
                extras = self.qiscusSdkHelper.convertToDictionary(string: stringExtras)
            }
            
            sendFileMessage(
                withRoomId: String(roomId),
                withCaption: caption,
                withFilePath: filePath,
                withExtras: extras,
                withResult: result
            )
            break
        case "getQiscusAccount":
            getQiscusAccount(withResult: result)
            break
        case "getLocalComments":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let limit: Int? = arguments["limit"] as? Int ?? Int()
            
            getLocalComments(withRoomId: String(roomId), withLimit: limit, withResult: result)
            break
        case "registerEventHandler":
            //registerEventHandler(withResult: result)
            result(true)
            break
        case "unregisterEventHandler":
            //unregisterEventHandler(withResult: result)
            result(true)
            break
        case "markCommentAsRead":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let commentId: String = arguments["commentId"] as? String ?? String()
            
            markCommentAsRead(withRoomId: String(roomId), withCommentId: commentId, withResult: result)
            break
        case "addOrUpdateLocalComment":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let comment: [String: Any] = qiscusSdkHelper.convertToDictionary(string: arguments["comment"] as! String)!
            
            addOrUpdateLocalComment(withComment: comment, withResult: result)
            break
        case "subscribeToChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let chatRoom: String = arguments["chatRoom"] as? String ?? String()
            let chatRoomDic: [String: Any]! = self.qiscusSdkHelper.convertToDictionary(string: chatRoom)
            
            subscribeToChatRoom(withChatRoom: chatRoomDic, withResult: result)
            break
        case "unsubscribeToChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let chatRoom: String = arguments["chatRoom"] as? String ?? String()
            let chatRoomDic: [String: Any]! = self.qiscusSdkHelper.convertToDictionary(string: chatRoom)
            
            unsubscribeToChatRoom(withChatRoom: chatRoomDic, withResult: result)
            break
        case "deleteLocalCommentsByRoomId":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            
            deleteLocalCommentsByRoomId(withRoomId: String(roomId), withResult: result)
            break
        case "getPrevMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let messageId: String? = arguments["messageId"] as? String ?? nil
            
            getPrevMessages(withRoomId: String(roomId), withLimit: limit, withMessageId: messageId, withResult: result)
            break
        case "getLocalPrevMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let uniqueId: String = arguments["uniqueId"] as? String ?? String()
            
            getLocalPrevMessages(withRoomId: String(roomId), withLimit: limit, withUniqueId: uniqueId, withResult: result)
            break
        case "getNextMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let messageId: String = arguments["messageId"] as? String ?? String()
            
            getNextMessages(withRoomId: String(roomId), withLimit: limit, withMessageId: messageId, withResult: result)
            break
        case "getLocalNextMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: Int = arguments["roomId"] as? Int ?? Int()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let uniqueId: String = arguments["uniqueId"] as? String ?? String()
            
            getLocalNextMessages(withRoomId: String(roomId), withLimit: limit, withUniqueId: uniqueId, withResult: result)
            break
        default:
            return
        }
    }
    
    private func setup(withAppId appId: String, withResult result: @escaping FlutterResult) {
        QiscusCore.setup(AppID: appId)
        result(nil)
    }
    
    private func enableDebugMode(withValue value: Bool, withResult result: @escaping FlutterResult) {
        QiscusCore.enableDebugMode(value: value)
        result(nil)
    }
    
    private func setEnableFcmPushNotification(withValue value: Bool, withResult result: @escaping FlutterResult) {
        result(value)
    }
    
    private func registerDeviceToken(withToken token: String, withResult result: @escaping FlutterResult) {
        QiscusCore.shared.registerDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in
            result(isSuccess)
        }, onError: {
            (error: QError) in
            result(FlutterError(code: "ERR_REGISTER_DEVICE_TOKEN", message: error.message, details: ""))
        })
    }
    
    private func removeDeviceToken(withToken token: String, withResult result: @escaping FlutterResult) {
        QiscusCore.shared.removeDeviceToken(
            token: token,
            onSuccess: {
                (isSuccess: Bool) in
                result(isSuccess)
            }, onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_REMOVE_DEVICE_TOKEN", message: error.message, details: ""))
            }
        )
    }
    
    private func clearUser(withResult result: @escaping FlutterResult) {
        QiscusCore.clearUser(
            completion: {
                (error: QError?) in
                if let _error = error {
                    result(FlutterError(code: "ERR_CLEAR_USER", message: _error.message, details: ""))
                }else {
                    result(nil)
                }
            }
        )
    }
    
    private func login(
        withUserId userId: String,
        withUserKey userKey: String,
        withUsername username: String,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.setUser(
            userId: userId,
            userKey: userKey,
            username: username,
            avatarURL: avatarUrl,
            extras: extras,
            onSuccess: {
                (user: UserModel) in
                let userDic = self.qiscusSdkHelper.userModelToDic(withUser: user)
                let userDicEndcode = self.qiscusSdkHelper.toJson(withData: userDic)
                
                result(userDicEndcode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_LOGIN", message: error.message, details: ""))
            }
        )
    }
    
    private func getNonce(withResult result: @escaping FlutterResult) {
        QiscusCore.getJWTNonce(
            onSuccess: {
                (nonce: QNonce) in
                let nonceDic = self.qiscusSdkHelper.qNonceToDic(withNonce: nonce)
                
                result(nonceDic["nonce"])
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_LOGIN_JWT", message: error.message, details: ""))
            }
        )
    }
    
    private func setUserWithIdentityToken(withToken token: String, withResult result: @escaping FlutterResult) {
        QiscusCore.setUserWithIdentityToken(
            token: token,
            onSuccess: {
                (user: UserModel) in
                let userDic = self.qiscusSdkHelper.userModelToDic(withUser: user)
                let userDicEncode = self.qiscusSdkHelper.toJson(withData: userDic)
                
                result(userDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_LOGIN_JWT", message: error.message, details: ""))
            }
        )
    }
    
    private func updateUser(
        withUsername username: String,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.updateUser(
            name: username,
            avatarURL: avatarUrl,
            extras: extras,
            onSuccess: {
                (user: UserModel) in
                let userDic = self.qiscusSdkHelper.userModelToDic(withUser: user)
                let userDicEncode = self.qiscusSdkHelper.toJson(withData: userDic)
                
                result(userDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_LOGIN_JWT", message: error.message, details: ""))
            }
        )
    }
    
    private func hasLogin(withResult result: @escaping FlutterResult) {
        result(QiscusCore.hasSetupUser())
    }
    
    private func getAllUsers(
        withSearchUsername searchUsername: String,
        withPage page: Int,
        withLimit limit: Int,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.getUsers(
            searchUsername: searchUsername,
            page: page,
            limit: limit,
            onSuccess: {
                (memberModel: [MemberModel], Meta) in
                let memberDic: [String] = self.qiscusSdkHelper.memberModelsToListJson(withMemberModel: memberModel)
                
                result(memberDic)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_GET_ALL_USERS", message: error.message, details: ""))
            }
        )
    }
    
    private func chatUser(
        withUserId userId: String,
        withExtras extras: [String: Any]?,
        withResult result: @escaping FlutterResult
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
                let roomModelDic = self.qiscusSdkHelper.roomModelToDic(withRoomModel: room)
                let roomModelDicEncode = self.qiscusSdkHelper.toJson(withData: roomModelDic)
                
                result(roomModelDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_CHAT_USER", message: error.message.description, details: ""))
            }
        )
    }
    
    private func updateChatRoom(
        withRoomId roomId: String,
        withName name: String?,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?,
        withResult result: @escaping FlutterResult
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
                let roomModelDic = self.qiscusSdkHelper.roomModelToDic(withRoomModel: room)
                let roomModelDicEncode = self.qiscusSdkHelper.toJson(withData: roomModelDic)
                if let room = QiscusCore.database.room.find(id: roomId){
                    print("room name \(room.id) \(room.name)")
                }
                result(roomModelDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_UPDATE_CHAT_ROOM", message: error.message, details: ""))
            }
        )
    }
    
    private func addOrUpdateLocalChatRoom(withChatRoom chatRoom: [String: Any]?, withResult result: @escaping FlutterResult) {
        // add or update
        
    }
    
    private func getChatRoomWithMessages(withRoomId roomId: String, withResult result: @escaping FlutterResult) {
        print("room id \(String(roomId))")
        QiscusCore.shared.getChatRoomWithMessages(
            roomId: roomId,
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                let roomModelAndCommentModelDic: [String: String] = self.qiscusSdkHelper.mergeRoomModelAndCommentModelDic(
                    withRoomModel: room,
                    withCommentModel: comments
                )
                
                result(roomModelAndCommentModelDic)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_FAILED_GET_CHATROOM_MESSAGES", message: error.message, details: ""))
            }
        )
    }
    
    private func getLocalChatRoom(withRoomId roomId: String, withResult result: @escaping FlutterResult) {
        let localChatRoom: RoomModel? = QiscusCore.database.room.find(id: roomId)
        
        if let _localChatRoom = localChatRoom {
            let localChatRoomDic = self.qiscusSdkHelper.roomModelToDic(withRoomModel: _localChatRoom)
            let localChatRoomDicEncode: String = self.qiscusSdkHelper.toJson(withData: localChatRoomDic)
            
            result(localChatRoomDicEncode)
        }else {
            result(FlutterError(code: "ERR_GET_LOCAL_CHAT_ROOM", message: "Local chat room not found", details: ""))
        }
    }
    
    private func getChatRoomByRoomIds(
        withRoomIds roomIds: [String],
        withShowRemoved showRemoved: Bool,
        withShowParticipant showParticipant: Bool,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.getChatRooms(
            roomIds: roomIds,
            showRemoved: showRemoved,
            showParticipant: showParticipant,
            onSuccess: {
                (rooms: [RoomModel]) in
                let roomModelsDic: [String] = self.qiscusSdkHelper.roomModelsToListJson(withRoomModels: rooms)
                let roomModelsDicEncode: String = self.qiscusSdkHelper.toJson(withData: roomModelsDic)
                
                result(roomModelsDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_GET_CHATROOM_BY_IDS", message: error.message, details: ""))
            }
        )
    }
    
    private func getLocalChatRoomByRoomIds(withRoomIds roomIds: [String], withResult result: @escaping FlutterResult) {
        QiscusCore.shared.getChatRooms(
            roomIds: roomIds,
            onSuccess: {
                (rooms: [RoomModel]) in
                let roomModelsDic: [[String: Any]] = self.qiscusSdkHelper.roomModelsToDic(withRoomModels: rooms)
                let roomModelsDicEncode: String = self.qiscusSdkHelper.toJson(withData: roomModelsDic)
                
                result(roomModelsDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_GET_CHATROOM_BY_IDS", message: error.message, details: ""))
            }
        )
    }
    
    private func getAllChatRooms(
        withShowParticipant showParticipant: Bool,
        withShowRemoved showRemoved: Bool,
        withShowEmpty showEmpty: Bool,
        withPage page: Int,
        withLimit limit: Int,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.getAllChatRooms(
            showParticipant: showParticipant,
            showRemoved: showRemoved,
            showEmpty: showEmpty,
            page: page,
            limit: limit,
            onSuccess: {
                (rooms: [RoomModel], meta: Meta?) -> () in
                let roomModelsDic: [[String: Any]] = self.qiscusSdkHelper.roomModelsToDic(withRoomModels: rooms)
                let roomModelsDicEncode: String = self.qiscusSdkHelper.toJson(withData: roomModelsDic)
                
                result(roomModelsDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_GET_ALL_CHAT_ROOMS", message: error.message, details: ""))
            }
        )
    }
    
    private func getLocalChatRooms(withLimit limit: Int, withOffset offset: Int?, withResult result: @escaping FlutterResult) {
        print("get local chat rooms limit \(limit)")
        let roomModels: [RoomModel] = QiscusCore.database.room.findChatRooms(limit: limit, offset: offset!)!
        let roomModelsDic = qiscusSdkHelper.roomModelsToDic(withRoomModels: roomModels)
        let roomModelsDicEncode = self.qiscusSdkHelper.toJson(withData: roomModelsDic)
        
        for room in roomModels {
            print("distinc id \(room.id)")
        }
        //qiscusRepository.getLocalChatRooms(withLimit: 10);
        result(roomModelsDicEncode)
        
        
    }
    
    private func getTotalUnreadCount(withResult result: @escaping FlutterResult) {
        QiscusCore.shared.getTotalUnreadCount {
            (totalUnreadCount: Int, error: QError?) in
            if let _error = error {
                result(FlutterError(code: "ERR_GET_TOTAL_UNREAD_COUNT", message: _error.message, details: ""))
                return
            }
            
            result(totalUnreadCount)
        }
    }
    
    private func sendMessage(
        withRoomId roomId: String,
        withMessage message: String,
        withPayload extras: [String: Any]?,
        withResult result: @escaping FlutterResult
    ) {
        let messageModel = CommentModel()
        messageModel.message = message
        messageModel.type = "text"
        messageModel.roomId = roomId
        
        if let _extras = extras {
            messageModel.extras = _extras
        }
        
        QiscusCore.shared.sendMessage(
            message: messageModel,
            onSuccess: {
                (commentModel: CommentModel) in
                let commentModelDictonary = self.qiscusSdkHelper.commentModelToDic(withComment: commentModel)
                let commentModelDictionaryEncode = self.qiscusSdkHelper.toJson(withData: commentModelDictonary)
                
                result(commentModelDictionaryEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_SEND_MESSAGE", message: "", details: ""))
            }
        )
    }
    
    private func sendFileMessage(
        withRoomId roomId: String,
        withCaption caption: String,
        withFilePath filePath: String,
        withExtras extras: [String: Any]?,
        withResult result: @escaping FlutterResult
    ) {
        let filePathURL = URL(fileURLWithPath: filePath)
        do {
            let fileData = try Data(contentsOf: filePathURL)
            let file = FileUploadModel()
            file.data = fileData
            file.name = filePathURL.lastPathComponent
            
            let messageModel = CommentModel()
            messageModel.message = caption
            messageModel.type = "file_attachment"
            messageModel.roomId = roomId
            
            QiscusCore.shared.sendFileMessage(
                message: messageModel,
                file: file,
                progressUploadListener: {
                    (progress: Double) in
                    self.eventHandler.onFileUploadProgress(withProgress: progress)
            },
                onSuccess: {
                    (commentModel: CommentModel) in
                    let commentModelDictonary = self.qiscusSdkHelper.commentModelToDic(withComment: commentModel)
                    let commentModelDictionaryEncode = self.qiscusSdkHelper.toJson(withData: commentModelDictonary)
                    result(commentModelDictionaryEncode)
            },
                onError: {
                    (error: QError) in
                    result(FlutterError(code: "ERR_SEND_FILE_MESSAGE QError", message: error.message, details: ""))
            }
            )
            
        } catch {
            result(FlutterError(code: "ERR_SEND_FILE_MESSAGE CATCH", message: error.localizedDescription, details: ""))
        }
    }
    
    private func getQiscusAccount(withResult result: @escaping FlutterResult) {
        if let userModel = QiscusCore.getUserData() {
            let userModelDic = self.qiscusSdkHelper.userModelToDic(withUser: userModel)
            let userModelDicEncode = self.qiscusSdkHelper.toJson(withData: userModelDic)
            
            result(userModelDicEncode);
            return
        }
        
        result(FlutterError(code: "ERR_FAILED_GET_ACCOUNT", message: "Fail get account", details: ""))
    }
    
    private func getLocalComments(
        withRoomId roomId: String,
        withLimit limit: Int?,
        withResult result: @escaping FlutterResult
    ) {
        var comments: [CommentModel]?
        if let _limit = limit {
            let localChatRoom: RoomModel? = QiscusCore.database.room.find(id: roomId)
                
            if let _localChatRoom = localChatRoom {
                let qiscusComment: CommentModel? = self.qiscusSdkHelper.getLastQiscusComment(withRoomModel: _localChatRoom)
                
                if let _qiscusComment = qiscusComment {
                    comments = QiscusCore.database.comment.findOlderCommentsThan(roomId: roomId, message: _qiscusComment, limit: _limit)
                }
            }
        }else {
            comments = QiscusCore.database.comment.find(roomId: roomId)
        }
        
        if let _comments = comments {
            let commentModelsDic = self.qiscusSdkHelper.commentModelsToListDic(withCommentModels: _comments)
            let commentModelsDicEncode = self.qiscusSdkHelper.toJson(withData: commentModelsDic)
            
            result(commentModelsDicEncode)
            return
        }
        
        result(self.qiscusSdkHelper.toJson(withData: []))
    }
    
    private func registerEventHandler() {
        self.eventHandler.registerEventBus()

        print("register event handler")
    }
    
    private func unregisterEventHandler() {
        self.eventHandler.unRegisterEventBus()
        print("unregister event handler")
    }
    
    private func markCommentAsRead(
        withRoomId roomId: String,
        withCommentId commentId: String,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.markAsRead(roomId: roomId, commentId: commentId)
        
        result(true)
    }
    
    private func addOrUpdateLocalComment(withComment comment: [String: Any], withResult result: @escaping FlutterResult) {
        // add or update
        if comment.count > 0 {
            let commentId: Int = comment["id"] as? Int ?? 0
            let commentState: Int = comment["state"] as? Int ?? 0
            if let commentModel: CommentModel = QiscusCore.database.comment!.find(id: String(commentId)){
                //print("comment Status \(commentModel.status.rawValue) message \(commentModel.message)")
                commentModel.status = qiscusSdkHelper.convertStateToCommentStatus(commentState: commentState)
                //            commentModel.status = CommentStatus.read
                QiscusCore.database.comment!.save([commentModel])
            }
        }
        result(true)
    }
    
    private func subscribeToChatRoom(withChatRoom chatRoom: [String: Any], withResult result: @escaping FlutterResult) {
        let chatRoomId: Int = chatRoom["id"] as? Int ?? Int()
        
        QiscusCore.shared.getChatRoomWithMessages(
            roomId: String(chatRoomId),
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                room.delegate = self.eventHandler
                QiscusCore.shared.subscribeChatRoom(room)
                
                result(true)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_SUBSCRIBE_TO_CHAT_ROOM", message: error.message, details: ""))
            }
        )
    }
    
    private func unsubscribeToChatRoom(withChatRoom chatRoom: [String: Any], withResult result: @escaping FlutterResult) {
        let chatRoomId: Int = chatRoom["id"] as? Int ?? Int()
        
        QiscusCore.shared.getChatRoomWithMessages(
            roomId: String(chatRoomId),
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                room.delegate = nil
                QiscusCore.shared.unSubcribeChatRoom(room)
                
                result(true)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_UNSUBSCRIBE_TO_CHAT_ROOM", message: error.message, details: ""))
            }
        )
    }
    
    private func deleteLocalCommentsByRoomId(withRoomId roomId: String, withResult result: @escaping FlutterResult) {
        let comment: CommentModel? = QiscusCore.database.comment.find(id: roomId)
        if let _comment = comment {
            result(QiscusCore.database.comment.delete(_comment))
        }else {
            result(FlutterError(code: "ERR_DELETE_LOCAL_COMMENTS_BY_ROOM_ID", message: "", details: ""))
        }
    }
    
    private func deleteLocalCommentByUniqueId(
        withUniqueId uniqueId: String,
        withCommentId commentId: Int,
        withResult result: @escaping FlutterResult
    ) {
        let comment: CommentModel? = QiscusCore.database.comment.find(uniqueId: uniqueId)
        if let _comment = comment {
            result(QiscusCore.database.comment.delete(_comment))
        }else {
            result(FlutterError(code: "ERR_DELETE_LOCAL_COMMENT_BY_UNIQUE_ID", message: "", details: ""))
        }
    }
    
    private func deleteLocalComment(
        withComment comment: [String: Any],
        withResult result: @escaping FlutterResult
    ) {
        let commentId: String = comment["id"] as? String ?? ""
        let comment: CommentModel? = QiscusCore.database.comment.find(id: commentId)
        
        if let _comment = comment {
            result(QiscusCore.database.comment.delete(_comment))
        }else {
            result(FlutterError(code: "ERR_DELETE_LOCAL_COMMENT", message: "", details: ""))
        }
    }
    
    private func deleteLocalChatRoom(
        withRoomId roomId: String,
        withResult result: @escaping FlutterResult
    ) {
        let room: RoomModel? = QiscusCore.database.room.find(id: roomId)
        if let _room = room {
            result(QiscusCore.database.room.delete(_room))
        }else {
            result(FlutterError(code: "ERR_DELETE_LOCAL_CHAT_ROOM", message: "", details: ""))
        }
    }
    
    private func getPrevMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withMessageId messageId: String?,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.getPreviousMessagesById(
            roomID: roomId,
            limit: limit,
            messageId: messageId,
            onSuccess: {
                (comments: [CommentModel]) in
                let commentModelsDic = self.qiscusSdkHelper.commentModelsToListDic(withCommentModels: comments)
                let commentModelsDicEncode = self.qiscusSdkHelper.toJson(withData: commentModelsDic)
                
                result(commentModelsDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_GET_PREV_MESSAGES", message: "", details: ""))
            }
        )
    }
    
    private func getLocalPrevMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withUniqueId uniqueId: String,
        withResult result: @escaping FlutterResult
    ) {
        let localChatRoom: RoomModel? = QiscusCore.database.room.find(id: roomId)
        if let _localChatRoom = localChatRoom {
            let qiscusComment: CommentModel? = self.qiscusSdkHelper.getLastQiscusComment(withRoomModel: _localChatRoom)
            
            if let _qiscusComment = qiscusComment {
                let comments = QiscusCore.database.comment.findOlderCommentsThan(roomId: roomId, message: _qiscusComment, limit: limit)
                
                if let _comments = comments {
                    let commentModelsDic = self.qiscusSdkHelper.commentModelsToListDic(withCommentModels: _comments)
                    let commentModelsDicEncode = self.qiscusSdkHelper.toJson(withData: commentModelsDic)
                    
                    result(commentModelsDicEncode)
                    return
                }
            }
        }
        
        result(nil)
    }
    
    private func getLocalNextMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withUniqueId uniqueId: String,
        withResult result: @escaping FlutterResult
    ) {
        // todo get next message from database
        let predicate = NSPredicate(format: " uniqueId == \(uniqueId) LIMIT \(limit)")
        let comments: [CommentModel]? = QiscusCore.database.comment.find(predicate: predicate)
        
        if let _comments = comments {
            let commentsModelsDic = self.qiscusSdkHelper.commentModelsToListJson(withCommentModels: _comments)
            let commentModelsDicEncode = self.qiscusSdkHelper.toJson(withData: commentsModelsDic)
            
            result(commentModelsDicEncode)
            return
        }
        
        result(nil)
    }
    
    private func getNextMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withMessageId messageId: String,
        withResult result: @escaping FlutterResult
    ) {
        QiscusCore.shared.getNextMessagesById(
            roomId: roomId,
            limit: limit,
            messageId: messageId,
            onSuccess: {
                (comments: [CommentModel]) in
                let commentModelsDic = self.qiscusSdkHelper.commentModelsToListJson(withCommentModels: comments)
                let commentModelsDicEncode = self.qiscusSdkHelper.toJson(withData: commentModelsDic)
                
                result(commentModelsDicEncode)
            },
            onError: {
                (error: QError) in
                result(FlutterError(code: "ERR_GET_NEXT_MESSAGES", message: error.message, details: ""))
            }
        )
    }
}
