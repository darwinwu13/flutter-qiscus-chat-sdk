import Flutter
import UIKit
import QiscusCore
import CoreFoundation

public class SwiftQiscusSdkPlugin: NSObject, FlutterPlugin {
  let qiscusSdkHelper: QiscusSdkHelper = QiscusSdkHelper()
  var flutterResult: FlutterResult

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "qiscus_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftQiscusSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    self.flutterResult = result
    
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
        
        login(withUserId: userId, withUserKey: userKey, withUsername: username, withAvatarUrl: avatarUrl, withExtras: extras)
        break
    case "getNonce":
        getNonce()
        break
    case "setUserWithIdentityToken":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let token: String = arguments["token"] as? String ?? ""
    
        setUserWithIdentityToken(withToken: token)
        break
    case "updateUser":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let username: String = arguments["username"] as? String ?? ""
    
        let avatar: String = arguments["avatarUrl"] as? String ?? ""
        let avatarUrl: URL? = avatar != "" ? URL(string: avatar) : nil
    
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        updateUser(withUsername: username, withAvatarUrl: avatarUrl, withExtras: extras)
        break
    case "hasLogin":
        hasLogin()
        break
    case "getAllUsers":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let searchUsername: String = arguments["searchUsername"] as? String ?? ""
        let page: Int = arguments["page"] as? Int ?? 0
        let limit: Int = arguments["limit"] as? Int ?? 0
        
        getAllUsers(withSearchUsername: searchUsername, withPage: page, withLimit: limit)
        break
    case "chatUser":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let userId: String = arguments["userId"] as? String ?? ""
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        
        chatUser(withUserId: userId, withExtras: extras)
        break
    case "updateChatRoom":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? ""
        let name: String? = arguments["name"] as? String ?? ""
        let avatar: String = arguments["avatarUrl"] as? String ?? ""
        let avatarUrl: URL? = avatar != "" ? URL(string: avatar) : nil
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        
        updateChatRoom(withRoomId: roomId, withName: name, withAvatarUrl: avatarUrl, withExtras: extras)
        break
    case "addOrUpdateLocalChatRoom":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let room: [RoomModel]? = arguments["chatRoom"] as? [RoomModel] ?? nil
        
        addOrUpdateLocalChatRoom(withChatRoom: room)
        break
    case "getChatRoomWithMessages":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? ""
        
        getChatRoomWithMessages(withRoomId: roomId)
        break
    case "getLocalChatRoom":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? ""
        
        getLocalChatRoom(withRoomId: roomId)
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
            withLimit: limit
        )
        break
    case "getLocalChatRooms":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let limit: Int = arguments["limit"] as? Int ?? Int()
        let offset = arguments["offset"] as? Int ?? nil
        
        getLocalChatRooms(withLimit: limit, withOffset: offset);
        break
    case "getTotalUnreadCount":
        getTotalUnreadCount()
        break
    case "sendMessage":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? String()
        let message: String = arguments["message"] as? String ?? String()
        let payload: [String: Any]? = arguments["payload"] as? [String: Any] ?? nil
        
        sendMessage(withRoomId: roomId, withMessage: message, withPayload: payload)
        break
    case "sendFileMessage":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? String()
        let caption: String = arguments["caption"] as? String ?? String()
        let filePath: String = arguments["filePath"] as? String ?? String()
        let extras: [String: Any]? = arguments["extras"] as? [String: Any] ?? nil
        
        sendFileMessage(withRoomId: roomId, withCaption: caption, withFilePath: filePath, withExtras: extras)
        break
    case "getQiscusAccount":
        getQiscusAccount()
        break
    case "getLocalComments":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? String()
        let limit: Int? = arguments["limit"] as? Int ?? Int()
        
        getLocalComments(withRoomId: roomId, withLimit: limit)
        break
    case "registerEventHandler":
        registerEventHandler()
        break
    case "unregisterEventHandler":
        unregisterEventHandler()
        break
    case "markCommentAsRead":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? String()
        let commentId: String = arguments["commentId"] as? String ?? String()
        
        markCommentAsRead(withRoomId: roomId, withCommentId: commentId)
        break
    case "addOrUpdateLocalComment":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let comment: [String: Any] = arguments["comment"] as? [String: Any] ?? [:]
        
        addOrUpdateLocalComment(withComment: comment)
        break
    case "subscribeToChatRoom":
//        subscribeToChatRoom(withChatRoom: <#T##RoomModel#>)
        break
    case "unsubscribeToChatRoom":
//        unsubscribeToChatRoom(withChatRoom: <#T##RoomModel#>)
        break
    case "deleteLocalCommentsByRoomId":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? String()
        
        deleteLocalCommentsByRoomId(withRoomId: roomId)
        break
    case "getPrevMessages":
        let arguments: [String: Any] = call.arguments as? [String: Any] ?? [:]
        let roomId: String = arguments["roomId"] as? String ?? String()
        let limit: Int = arguments["limit"] as? Int ?? Int()
        let messageId: String? = arguments["messageId"] as? String ?? nil
        
        getPrevMessages(withRoomId: roomId, withLimit: limit, withMessageId: messageId)
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
        
        getNextMessages(withRoomId: roomId, withLimit: limit, withMessageId: messageId)
        break
    case "getLocalNextMessages"
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
            self.flutterResult(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
            self.flutterResult(errorDictionary)
        })
    }
    
    private func removeDeviceToken(withToken token: String) {
        QiscusCore.shared.removeDeviceToken(token: token, onSuccess: {
            (isSuccess: Bool) in
            
            self.flutterResult(isSuccess)
        }, onError: {
            (error: QError) in
            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
            
            self.flutterResult(errorDictionary)
        })
    }
    
    private func clearUser() {
        QiscusCore.clearUser(completion: {
            (error: QError?) -> () in
            guard let qiscusError = error else {
                self.flutterResult(FlutterMethodNotImplemented)
                return
            }
            
            let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: qiscusError)
            self.flutterResult(errorDictionary)
        })
    }
    
    private func login(
        withUserId userId: String,
        withUserKey userKey: String,
        withUsername username: String,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?
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
                
                self.flutterResult(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func getNonce() {
        QiscusCore.getJWTNonce(
            onSuccess: {
                (nonce: QNonce) in
                let nonceDictionary = self.qiscusSdkHelper.qNonceToDic(withNonce: nonce)
                
                self.flutterResult(nonceDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func setUserWithIdentityToken(withToken token: String) {
        QiscusCore.setUserWithIdentityToken(
            token: token,
            onSuccess: {
                (user: UserModel) in
                let userDictionary = self.qiscusSdkHelper.userModelToDic(withUser: user)
                
                self.flutterResult(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func updateUser(
        withUsername username: String,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?
    ) {
        QiscusCore.shared.updateUser(
            name: username,
            avatarURL: avatarUrl,
            extras: extras,
            onSuccess: {
                (user: UserModel) in
                let userDictionary = self.qiscusSdkHelper.userModelToDic(withUser: user)
                
                self.flutterResult(userDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func hasLogin() {
        self.flutterResult(QiscusCore.hasSetupUser())
    }
    
    private func getAllUsers(
        withSearchUsername searchUsername: String,
        withPage page: Int,
        withLimit limit: Int
    ) {
        QiscusCore.shared.getUsers(
            searchUsername: searchUsername,
            page: page,
            limit: limit,
            onSuccess: {
                (memberModel: [MemberModel], Meta) in
                let memberDictionary = self.qiscusSdkHelper.memberModelToDic(withMemberModel: memberModel)
                
                self.flutterResult(memberDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func chatUser(
        withUserId userId: String,
        withExtras extras: [String: Any]?
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
                
                self.flutterResult(roomModelDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func updateChatRoom(
        withRoomId roomId: String,
        withName name: String?,
        withAvatarUrl avatarUrl: URL?,
        withExtras extras: [String: Any]?
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
                
                self.flutterResult(roomModelDictionary)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func addOrUpdateLocalChatRoom(withChatRoom chatRoom: [RoomModel]?) {
        if let _chatRoom = chatRoom {
            self.flutterResult(QiscusCore.database.room.save(_chatRoom))
        }else {
            self.flutterResult(FlutterMethodNotImplemented)
        }
    }
    
    private func getChatRoomWithMessages(withRoomId roomId: String) {
        QiscusCore.shared.getChatRoomWithMessages(
            roomId: roomId,
            onSuccess: {
                (room: RoomModel, comments: [CommentModel]) in
                // todo
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func getLocalChatRoom(withRoomId roomId: String) {
        let localChatRooms: [RoomModel] = QiscusCore.database.room.all()
        let localChatRoomsJson: String = self.qiscusSdkHelper.toJson(withData: localChatRooms)
        
        self.flutterResult(localChatRoomsJson)
    }
    
    private func getChatRoomByRoomIds(
        withRoomIds roomIds: [String],
        withShowRemoved showRemoved: Bool,
        withShowParticipant showParticipant: Bool
    ) {
        QiscusCore.shared.getChatRooms(
            roomIds: roomIds,
            showRemoved: showRemoved,
            showParticipant: showParticipant,
            onSuccess: {
                (rooms: [RoomModel]) in
                let roomsJson: String = self.qiscusSdkHelper.toJson(withData: rooms)
                self.flutterResult(roomsJson)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
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
        withLimit limit: Int
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
                self.flutterResult(roomsJson)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func getLocalChatRooms(withLimit limit: Int, withOffset offset: Int?) {
        var predicate: NSPredicate = NSPredicate(format: "LIMIT \(limit)")
        if let _offset = offset {
            predicate = NSPredicate(format: "LIMIT \(limit) OFFSET \(_offset)")
        }
        
        let localChatRooms: [RoomModel]? = QiscusCore.database.room.find(predicate: predicate)
        if let _localChatRooms = localChatRooms {
            let chatRooms: [[String: Any]] = self.qiscusSdkHelper.roomModelsToDic(withRoomModels: _localChatRooms)
            let jsonChatRooms: String = self.qiscusSdkHelper.toJson(withData: chatRooms)
            
            self.flutterResult(jsonChatRooms)
        }else {
            self.flutterResult(FlutterMethodNotImplemented)
        }
    }
    
    private func getTotalUnreadCount() {
        QiscusCore.shared.getTotalUnreadCount {
            (totalUnreadCount: Int, error: QError?) in
            if let _error = error {
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: _error)
                
                self.flutterResult(errorDictionary)
                return
            }
            
            self.flutterResult(totalUnreadCount)
        }
    }
    
    private func sendMessage(
        withRoomId roomId: String,
        withMessage message: String,
        withPayload extras: [String: Any]?
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
                self.flutterResult(commentModel)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
    
    private func uploadFile(withFilePath filePath: String) {
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
                        self.flutterResult(file)
                    },
                    onError: {
                        (error: QError) in
                        let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)

                        self.flutterResult(errorDictionary)
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

    private func getLocalComments(withRoomId roomId: String, withLimit limit: Int?) {
        var room: [CommentModel]?
        if let _limit = limit {
            // todo add room id
            let predicate: NSPredicate = NSPredicate(format: "LIMIT \(_limit)")
            room = QiscusCore.database.comment.find(predicate: predicate)
        }else {
            room = QiscusCore.database.comment.find(roomId: roomId)
        }
        
        self.flutterResult(room)
    }
    
    private func registerEventHandler() {
        // todo
    }
    
    private func unregisterEventHandler() {
        // todo
    }
    
    private func markCommentAsRead(
        withRoomId roomId: String,
        withCommentId commentId: String
    ) {
        QiscusCore.shared.markAsRead(roomId: roomId, commentId: commentId)
        
        self.flutterResult(true)
    }
    
    private func addOrUpdateLocalComment(withComment comment: [String: Any]) {
        // todo
        var commentModel: CommentModel
//        commentModel.id = comment["id"] as? String ?? ""
        commentModel.message = comment["message"] as? String ?? ""
    }
    
    private func subscribeToChatRoom(withChatRoom chatRoom: RoomModel) {
        self.flutterResult(QiscusCore.shared.subscribeChatRoom(chatRoom))
    }
    
    private func unsubscribeToChatRoom(withChatRoom chatRoom: RoomModel) {
        self.flutterResult(QiscusCore.shared.unSubcribeChatRoom(chatRoom))
    }
    
    private func deleteLocalCommentsByRoomId(withRoomId roomId: String) {
        let comment: CommentModel? = QiscusCore.database.comment.find(id: roomId)
        if let _comment = comment {
            self.flutterResult(QiscusCore.database.comment.delete(_comment))
        }else {
            self.flutterResult(FlutterMethodNotImplemented)
        }
    }
    
    private func deleteLocalCommentByUniqueId(
        withUniqueId uniqueId: String,
        withCommentId commentId: Int
    ) {
        let comment: CommentModel? = QiscusCore.database.comment.find(uniqueId: uniqueId)
        if let _comment = comment {
            self.flutterResult(QiscusCore.database.comment.delete(_comment))
        }else {
            self.flutterResult(FlutterMethodNotImplemented)
        }
    }
    
    private func deleteLocalComment(withComments comments: [String: Any]) {
        
    }
    
    private func deleteLocalChatRoom(withRoomId roomId: String) {
        let room: RoomModel? = QiscusCore.database.room.find(id: roomId)
        if let _room = room {
            self.flutterResult(QiscusCore.database.room.delete(_room))
        }else {
            self.flutterResult(FlutterMethodNotImplemented)
        }
    }
    
    private func getPrevMessages(
        withRoomId roomId: String,
        withLimit limit: Int,
        withMessageId messageId: String?
    ) {
        QiscusCore.shared.getPreviousMessagesById(
            roomID: roomId,
            limit: limit,
            messageId: messageId,
            onSuccess: {
                (comments: [CommentModel]) in
                self.flutterResult(comments)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
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
        withMessageId messageId: String
    ) {
        QiscusCore.shared.getNextMessagesById(
            roomId: roomId,
            limit: limit,
            messageId: messageId,
            onSuccess: {
                (comments: [CommentModel]) in
                self.flutterResult(comments)
            },
            onError: {
                (error: QError) in
                let errorDictionary = self.qiscusSdkHelper.qErrorToDic(withError: error)
                
                self.flutterResult(errorDictionary)
            }
        )
    }
}
