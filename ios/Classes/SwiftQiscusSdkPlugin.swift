import Flutter
import UIKit
import QiscusCore
import CoreFoundation

public class SwiftQiscusSdkPlugin: NSObject, FlutterPlugin {
    let qiscusSdkHelper: QiscusSdkHelper = QiscusSdkHelper()
    private var eventHandler: QiscusEventHandler!
    
    static let CHANNEL_NAME: String = "bahaso.com/qiscus_chat_sdk"
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
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
        print("call handle method \(call.method)")
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
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let room: [String: Any]? = arguments["chatRoom"] as? [String: Any] ?? nil
            
            addOrUpdateLocalChatRoom(withChatRoom: room, withResult: result)
            break
        case "getChatRoomWithMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? ""
            
            getChatRoomWithMessages(withRoomId: roomId, withResult: result)
            break
        case "getLocalChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? ""
            
            getLocalChatRoom(withRoomId: roomId, withResult: result)
            break
        case "getChatRoomByRoomIds":
            // todo
            break
        case "getLocalChatRoomByRoomIds":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomIds: [String]? = arguments["roomIds"] as? [String] ?? nil
            
            getLocalChatRoomByRoomIds(withRoomIds: roomIds)
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
            
            getLocalChatRooms(withLimit: limit, withOffset: offset, withResult: result);
            break
        case "getTotalUnreadCount":
            getTotalUnreadCount(withResult: result)
            break
        case "sendMessage":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let message: String = arguments["message"] as? String ?? String()
            let stringPayload: String = arguments["payload"] as? String ?? String()
            var payload: [String: Any]? = [:]
            if stringPayload != String() {
                payload = self.qiscusSdkHelper.convertToDictionary(string: stringPayload)
            }
            
            sendMessage(withRoomId: roomId, withMessage: message, withPayload: payload, withResult: result)
            break
        case "sendFileMessage":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let caption: String = arguments["caption"] as? String ?? String()
            let filePath: String = arguments["filePath"] as? String ?? String()
            let stringExtras: String = arguments["extras"] as? String ?? String()
            var extras: [String: Any]? = [:]
            if stringExtras != String() {
                extras = self.qiscusSdkHelper.convertToDictionary(string: stringExtras)
            }
            
            sendFileMessage(withRoomId: roomId, withCaption: caption, withFilePath: filePath, withExtras: extras)
            break
        case "getQiscusAccount":
            getQiscusAccount()
            break
        case "getLocalComments":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let limit: Int? = arguments["limit"] as? Int ?? Int()
            
            getLocalComments(withRoomId: roomId, withLimit: limit, withResult: result)
            break
        case "registerEventHandler":
            registerEventHandler(withResult: result)
            break
        case "unregisterEventHandler":
            unregisterEventHandler(withResult: result)
            break
        case "markCommentAsRead":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let commentId: String = arguments["commentId"] as? String ?? String()
            
            markCommentAsRead(withRoomId: roomId, withCommentId: commentId, withResult: result)
            break
        case "addOrUpdateLocalComment":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let comment: [String: Any] = arguments["comment"] as? [String: Any] ?? [:]
            
            addOrUpdateLocalComment(withComment: comment, withResult: result)
            break
        case "subscribeToChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let chatRoom: [String: Any] = arguments["chatRoom"] as? [String: Any] ?? [:]
            
            subscribeToChatRoom(withChatRoom: chatRoom, withResult: result)
            break
        case "unsubscribeToChatRoom":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let chatRoom: [String: Any] = arguments["chatRoom"] as? [String: Any] ?? [:]
            
            unsubscribeToChatRoom(withChatRoom: chatRoom, withResult: result)
            break
        case "deleteLocalCommentsByRoomId":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            
            deleteLocalCommentsByRoomId(withRoomId: roomId, withResult: result)
            break
        case "getPrevMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let messageId: String? = arguments["messageId"] as? String ?? nil
            
            getPrevMessages(withRoomId: roomId, withLimit: limit, withMessageId: messageId, withResult: result)
            break
        case "getLocalPrevMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let uniqueId: String = arguments["uniqueId"] as? String ?? String()
            
            getLocalPrevMessages(withRoomId: roomId, withLimit: limit, withUniqueId: uniqueId)
            break
        case "getNextMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let messageId: String = arguments["messageId"] as? String ?? String()
            
            getNextMessages(withRoomId: roomId, withLimit: limit, withMessageId: messageId, withResult: result)
            break
        case "getLocalNextMessages":
            let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
            let roomId: String = arguments["roomId"] as? String ?? String()
            let limit: Int = arguments["limit"] as? Int ?? Int()
            let uniqueId: String = arguments["uniqueId"] as? String ?? String()
            
            getLocalNextMessages(withRoomId: roomId, withLimit: limit, withUniqueId: uniqueId)
            break
        default:
            return
        }
    }
    
    private func setup(withAppId appId: String, withResult result: @escaping FlutterResult) {
        print("setup qiscus core")
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
        print("try to get token \(token)")
        QiscusCore.shared.registerDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in
            print("register device token \(isSuccess)")
            result(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
            result(errorDictionary)
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
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func clearUser(withResult result: @escaping FlutterResult) {
        QiscusCore.clearUser(
            completion: {
                (error: QError?) -> () in
                guard let qiscusError = error else {
                    result(FlutterMethodNotImplemented)
                    return
                }
                
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: qiscusError)
                result(errorDictionary)
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
    
    private func getNonce(withResult result: @escaping FlutterResult) {
        QiscusCore.getJWTNonce(
            onSuccess: {
                (nonce: QNonce) in
                let nonceDictionary = self.qiscusSdkHelper.qNonceToDic(withNonce: nonce)
                print("nonce data \(nonceDictionary)")
                result(nonceDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                result(errorDictionary)
            }
        )
    }
    
    private func setUserWithIdentityToken(withToken token: String, withResult result: @escaping FlutterResult) {
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
        withResult result: @escaping FlutterResult
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
    
    private func hasLogin(withResult result: @escaping FlutterResult) {
        print("check user hasLogin \(QiscusCore.hasSetupUser())")
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
    
    private func addOrUpdateLocalChatRoom(withChatRoom chatRoom: [String: Any]?, withResult result: @escaping FlutterResult) {
        if let _chatRoom = chatRoom {
            result(QiscusCore.database.room.save([qiscusSdkHelper.dicToRoomModel(withDic: _chatRoom)]))
        }else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getChatRoomWithMessages(withRoomId roomId: String, withResult result: @escaping FlutterResult) {
        QiscusCore.shared.getChatRoomWithMessages(
            roomId: roomId,
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                // todo
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func getLocalChatRoom(withRoomId roomId: String, withResult result: @escaping FlutterResult) {
        let localChatRooms: [RoomModel] = QiscusCore.database.room.all()
        let localChatRoomsJson: String = self.qiscusSdkHelper.toJson(withData: localChatRooms)
        
        result(localChatRoomsJson)
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
    
    private func getLocalChatRoomByRoomIds(withRoomIds roomIds: [String]?) {
        // todo
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
    
    private func getLocalChatRooms(withLimit limit: Int, withOffset offset: Int?, withResult result: @escaping FlutterResult) {
        var predicate: NSPredicate = NSPredicate(format: "LIMIT \(limit)")
        if let _offset = offset {
            predicate = NSPredicate(format: "LIMIT \(limit) OFFSET \(_offset)")
        }
        
        let localChatRooms: [RoomModel]? = QiscusCore.database.room.find(predicate: predicate)
        if let _localChatRooms = localChatRooms {
            let chatRooms: [[String: Any]] = self.qiscusSdkHelper.roomModelsToDic(withRoomModels: _localChatRooms)
            let jsonChatRooms: String = self.qiscusSdkHelper.toJson(withData: chatRooms)
            
            result(jsonChatRooms)
        }else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getTotalUnreadCount(withResult result: @escaping FlutterResult) {
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
                result(commentModel)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func uploadFile(withFilePath filePath: String, withResult result: @escaping FlutterResult) {
        if let _url = URL(string: filePath) {
            do {
                let imageData = try Data(contentsOf: _url)
                let file = FileUploadModel()
                file.data = imageData
                file.name = _url.lastPathComponent
                
                QiscusCore.shared.upload(
                    file: file,
                    onSuccess: {
                        (file: FileModel) in
                        result(file)
                    },
                    onError: {
                        (error: QError) in
                        let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                        
                        result(errorDictionary)
                    },
                    progressListener: {
                        (progress: Double) in
                        print(progress)
                    }
                )
            }catch let error {
                print(error)
            }
        }
    }
    
    private func sendFileMessage(
        withRoomId roomId: String,
        withCaption caption: String,
        withFilePath filePath: String,
        withExtras extras: [String: Any]?
    ) {
        
    }
    
    private func getQiscusAccount() {
        // todo
        
    }
    
    private func getLocalComments(
        withRoomId roomId: String,
        withLimit limit: Int?,
        withResult result: @escaping FlutterResult
    ) {
        var room: [CommentModel]?
        if let _limit = limit {
            // todo add room id
            let predicate: NSPredicate = NSPredicate(format: "LIMIT \(_limit)")
            room = QiscusCore.database.comment.find(predicate: predicate)
        }else {
            room = QiscusCore.database.comment.find(roomId: roomId)
        }
        
        result(room)
    }
    
    private func registerEventHandler(withResult result: @escaping FlutterResult) {
        result(self.eventHandler.registerEventBus())
    }
    
    private func unregisterEventHandler(withResult result: @escaping FlutterResult) {
        result(self.eventHandler.unRegisterEventBus())
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
        result(QiscusCore.database.comment.save([qiscusSdkHelper.dicToCommentModel(withDic: comment)]))
    }
    
    private func subscribeToChatRoom(withChatRoom chatRoom: [String: Any], withResult result: @escaping FlutterResult) {
        result(QiscusCore.shared.subscribeChatRoom(qiscusSdkHelper.dicToRoomModel(withDic: chatRoom)))
    }
    
    private func unsubscribeToChatRoom(withChatRoom chatRoom: [String: Any], withResult result: @escaping FlutterResult) {
        result(QiscusCore.shared.unSubcribeChatRoom(self.qiscusSdkHelper.dicToRoomModel(withDic: chatRoom)))
    }
    
    private func deleteLocalCommentsByRoomId(withRoomId roomId: String, withResult result: @escaping FlutterResult) {
        let comment: CommentModel? = QiscusCore.database.comment.find(id: roomId)
        if let _comment = comment {
            result(QiscusCore.database.comment.delete(_comment))
        }else {
            result(FlutterMethodNotImplemented)
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
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func deleteLocalComment(
        withComment comment: [String: Any],
        withResult result: @escaping FlutterResult
    ) {
        result(QiscusCore.database.comment.delete(qiscusSdkHelper.dicToCommentModel(withDic: comment)))
    }
    
    private func deleteLocalChatRoom(
        withRoomId roomId: String,
        withResult result: @escaping FlutterResult
    ) {
        let room: RoomModel? = QiscusCore.database.room.find(id: roomId)
        if let _room = room {
            result(QiscusCore.database.room.delete(_room))
        }else {
            result(FlutterMethodNotImplemented)
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
                result(comments)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                result(errorDictionary)
            }
        )
    }
    
    private func getLocalPrevMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withUniqueId uniqueId: String
    ) {
        
    }
    
    private func getLocalNextMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withUniqueId uniqueId: String
    ) {
        
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
                result(comments)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                result(errorDictionary)
            }
        )
    }
}
