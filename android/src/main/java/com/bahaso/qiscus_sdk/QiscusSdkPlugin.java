package com.bahaso.qiscus_sdk;

import android.app.Application;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.qiscus.sdk.chat.core.QiscusCore;
import com.qiscus.sdk.chat.core.data.model.NotificationListener;
import com.qiscus.sdk.chat.core.data.model.QiscusAccount;
import com.qiscus.sdk.chat.core.data.model.QiscusChatRoom;
import com.qiscus.sdk.chat.core.data.model.QiscusComment;
import com.qiscus.sdk.chat.core.data.remote.QiscusApi;
import com.qiscus.sdk.chat.core.data.remote.QiscusPusherApi;
import com.qiscus.sdk.chat.core.util.QiscusAndroidUtil;
import com.qiscus.sdk.chat.core.util.QiscusTextUtil;

import org.greenrobot.eventbus.EventBus;
import org.json.JSONObject;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import rx.Observable;
import rx.android.schedulers.AndroidSchedulers;
import rx.functions.Func2;
import rx.schedulers.Schedulers;

/**
 * QiscusChatSdkPlugin
 */
public class QiscusSdkPlugin implements FlutterPlugin, MethodCallHandler {
    private final String CHANNEL_NAME = "bahaso.com/qiscus_chat_sdk";
    private Func2<QiscusComment, QiscusComment, Integer> commentComparator = (lhs, rhs) -> rhs.getTime().compareTo(lhs.getTime());

    private Context applicationContext;
    private MethodChannel channel;
    private QiscusEventHandler eventHandler;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachToEngine(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        channel.setMethodCallHandler(null);
        channel = null;
        eventHandler.unregisterEventBus();
        eventHandler = null;

    }

    private void onAttachToEngine(BinaryMessenger messenger, Context applicationContext) {
        this.applicationContext = applicationContext;

        channel = new MethodChannel(messenger, CHANNEL_NAME);
        channel.setMethodCallHandler(this);
        eventHandler = new QiscusEventHandler(messenger);
    }

    public static void registerWith(Registrar registrar) {
        final QiscusSdkPlugin plugin = new QiscusSdkPlugin();
        plugin.onAttachToEngine(registrar.messenger(), registrar.context());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        JSONObject extras = null;
        switch (call.method) {
            case "setup":
                String appId = call.argument("appId");
                setup(appId);
                result.success(null);
                break;
            case "enableDebugMode":
                enableDebugMode((boolean) call.argument("value"));
                result.success(null);
                break;
            case "setNotificationListener":
                //setNotificationListener();
                break;
            case "setEnableFcmPushNotification":
                setEnableFcmPushNotification((boolean) call.argument("value"));
                result.success(true);
                break;
            case "registerDeviceToken":
                registerDeviceToken((String) call.argument("token"));
                result.success(null);
                break;
            case "removeDeviceToken":
                removeDeviceToken((String) call.argument("token"));
                result.success(null);
                break;
            case "clearUser":
                clearUser();
                result.success(null);
                break;
            case "login":
                String userId = call.argument("userId");
                String userKey = call.argument("userKey");
                String username = call.argument("username");
                String avatarUrl = call.argument("avatarUrl");
                if (call.hasArgument("extras")) {
                    Map<String, Object> extrasMap = call.argument("extras");
                    extras = new JSONObject(extrasMap);
                }
                login(userId, userKey, username, avatarUrl, extras, result);
                break;
            case "getNonce":
                getNonce(result);
                break;
            case "setUserWithIdentityToken":
                setUserWithIdentityToken((String) call.argument("token"), result);
                break;
            case "updateUser":
                username = call.argument("username");
                avatarUrl = call.argument("avatarUrl");
                if (call.hasArgument("extras")) {
                    Map<String, Object> extrasMap = call.argument("extras");
                    extras = new JSONObject(extrasMap);
                }
                updateUser(username, avatarUrl, extras, result);
                break;
            case "hasLogin":
                hasLogin(result);
                break;
            case "getAllUsers":
                String searchUsername = call.argument("searchUsername");
                long page = call.argument("page") == null ? 1 : call.argument("page");
                long limit = call.argument("limit") == null ? 25 : call.argument("limit");

                getAllUsers(searchUsername, page, limit, result);
                break;
            case "chatUser":
                userId = call.argument("userId");
                if (call.hasArgument("extras")) {
                    Map<String, Object> extrasMap = call.argument("extras");
                    extras = new JSONObject(extrasMap);
                }
                chatUser(userId, extras, result);
                break;
            case "addOrUpdateLocalChatRoom":
                String json = call.argument("chatRoom");
                addOrUpdateLocalChatRoom(QiscusSdkHelper.parseQiscusChatRoom(json), result);

                break;

            case "getChatRoomWithMessages":
                int temp = call.argument("roomId");
                long roomId = temp;
                getChatRoomWithMessages(roomId, result);
                break;
            case "getLocalChatRoom":
                temp = call.argument("roomId");
                roomId = temp;
                getLocalChatRoom(roomId, result);
                break;
            case "getChatRoomByRoomIds":
                //todo will call getChatRoomByRoomIds() here
                break;
            case "getLocalChatRoomByRoomIds":
                List<Integer> tempIntList = call.argument("roomIds");
                List<Long> roomIds = new ArrayList<>(tempIntList.size());
                for (Integer item : tempIntList) {
                    roomIds.add(item.longValue());
                }
                getLocalChatRoomByRoomIds(roomIds, result);
                break;

            case "getAllChatRooms":
                boolean showParticipant = call.argument("showParticipant");
                boolean showEmpty = call.argument("showEmpty");
                boolean showRemoved = call.argument("showRemoved");
                int pageInt = call.argument("page");
                int limitInt = call.argument("limit");

                getAllChatRooms(showParticipant, showRemoved, showEmpty, pageInt, limitInt, result);
                break;

            case "getLocalChatRooms":
                int offset = 0;
                limitInt = call.argument("limit");
                if (call.hasArgument("offset")) {
                    offset = call.argument("offset");
                    getLocalChatRooms(limitInt, offset, result);
                } else
                    getLocalChatRooms(limitInt, result);

                break;
            case "getTotalUnreadCount":
                getTotalUnreadCount(result);
                break;

            case "sendMessage":
                extras = null;
                temp = call.argument("roomId");
                roomId = temp;
                String message = call.argument("message");
                if (call.hasArgument("extras")) {
                    Map<String, Object> extrasMap = call.argument("extras");
                    extras = new JSONObject(extrasMap);
                }
                sendMessage(roomId, message, extras, result);
                break;
            case "sendFileMessage":
                temp = call.argument("roomId");
                roomId = temp;
                String caption = call.argument("caption");
                String filePath = call.argument("filePath");
                if (call.hasArgument("extras")) {
                    Map<String, Object> extrasMap = call.argument("extras");
                    extras = new JSONObject(extrasMap);
                }
                sendFileMessage(roomId, caption, filePath, extras, result);
                break;
            case "getQiscusAccount":
                getQiscusAccount(result);
                break;

            case "getLocalComments":
                temp = call.argument("roomId");
                roomId = temp;
                if (!call.hasArgument("limit"))
                    getLocalComments(roomId, result);
                else {
                    limitInt = call.argument("limit");
                    getLocalComments(roomId, limitInt, result);

                }
                break;
            case "registerEventHandler":
                registerEventHandler(result);
                break;
            case "unregisterEventHandler":
                unregisterEventHandler(result);
                break;
            case "markCommentAsRead":
                temp = call.argument("roomId");
                roomId = temp;
                temp = call.argument("commentId");
                int commentId = temp;
                markCommentAsRead(roomId, commentId, result);
                break;
            case "addOrUpdateLocalComment":
                json = call.argument("comment");
                addOrUpdateLocalComment(QiscusSdkHelper.parseQiscusComment(json), result);
                break;
            case "deleteLocalComment":
                json = call.argument("comment");
                deleteLocalComment(QiscusSdkHelper.parseQiscusComment(json), result);
                break;
            case "deleteLocalChatRoom":
                temp = call.argument("roomId");
                roomId = temp;
                deleteLocalChatRoom(roomId, result);
                break;
            case "subscribeToChatRoom":
                json = call.argument("chatRoom");
                subscribeToChatRoom(QiscusSdkHelper.parseQiscusChatRoom(json), result);
                break;
            case "unsubscribeToChatRoom":
                json = call.argument("chatRoom");
                unsubscribeToChatRoom(QiscusSdkHelper.parseQiscusChatRoom(json), result);
                break;
            case "deleteLocalCommentsByRoomId":
                temp = call.argument("roomId");
                roomId = temp;
                deleteLocalCommentsByRoomId(roomId, result);
                break;
            case "getPrevMessages":
                temp = call.argument("roomId");
                roomId = temp;
                limitInt = call.argument("limit");
                int messageId = call.argument("messageId");
                getPrevMessages(roomId, limitInt, messageId, result);
                break;
            case "getLocalPrevMessages":
                temp = call.argument("roomId");
                roomId = temp;
                limitInt = call.argument("limit");
                String uniqueId = call.argument("uniqueId");
                getLocalPrevMessages(roomId, limitInt, uniqueId, result);
                break;
            case "getNextMessages":
                temp = call.argument("roomId");
                roomId = temp;
                limitInt = call.argument("limit");
                uniqueId = call.argument("uniqueId");
                getNextMessages(roomId, limitInt, uniqueId, result);
                break;
            case "getLocalNextMessages":
                temp = call.argument("roomId");
                roomId = temp;
                limitInt = call.argument("limit");
                uniqueId = call.argument("uniqueId");
                getLocalNextMessages(roomId, limitInt, uniqueId, result);
                break;
            default:
                result.notImplemented();

        }


    }

    private void setup(String appId) {
        QiscusCore.setup((Application) applicationContext, appId);
    }

    private void enableDebugMode(boolean value) {
        QiscusCore.getChatConfig().enableDebugMode(value);
    }

    private void setNotificationListener(NotificationListener listener) {
        //todo listen to local java, then invoke dart to notify the user using fcm flutter
        QiscusCore.getChatConfig().setNotificationListener(listener);
    }

    private void setEnableFcmPushNotification(boolean value) {
        //todo should let dart side handle the fcm and register token device
        //todo also should let dart side handle on notification click

        QiscusCore.getChatConfig().setEnableFcmPushNotification(value);
    }


    private void registerDeviceToken(String token) {
        QiscusCore.registerDeviceToken(token);
    }

    private void removeDeviceToken(String token) {
        QiscusCore.removeDeviceToken(token);
    }

    // use this for when user want to logout
    private void clearUser() {
        QiscusCore.clearUser();
    }

    private void setUserWithIdentityToken(String token, Result result) {
        QiscusCore.setUserWithIdentityToken(token)
                .observeOn(AndroidSchedulers.mainThread())
                .subscribeOn(Schedulers.io())
                .subscribe(qiscusAccount -> {
                    result.success(QiscusSdkHelper.encodeQiscusAccount(qiscusAccount));
                }, error -> {
                    error.printStackTrace();
                    result.error("ERR_LOGIN_JWT", error.getMessage(), error);
                });
    }


    private void login(
            String userId,
            String userKey,
            String username,
            String avatarUrl,
            JSONObject extras,
            Result result
    ) {
        QiscusCore.SetUserBuilder userBuilder = QiscusCore.setUser(userId, userKey)
                .withUsername(username);
        if (avatarUrl != null && !avatarUrl.equals("")) {
            userBuilder = userBuilder.withAvatarUrl(avatarUrl);
        }
        if (extras != null) {
            userBuilder = userBuilder.withExtras(extras);
        }
        userBuilder.save()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(qiscusAccount -> {
                    result.success(QiscusSdkHelper.encodeQiscusAccount(qiscusAccount));
                }, error -> {
                    error.printStackTrace();
                    result.error("ERR_LOGIN", error.getMessage(), error);
                });


        Log.i("Qiscus Chat SDK Plugin", "login success");


    }

    private void getNonce(Result result) {
        QiscusApi.getInstance()
                .getJWTNonce()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(qiscusNonce -> {
                    result.success(qiscusNonce.getNonce());
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_NONCE", throwable.getMessage(), throwable);
                });
    }

    private void updateUser(String username, String avatarUrl, JSONObject extras, Result result) {
        QiscusCore.updateUser(username, avatarUrl, extras, new QiscusCore.SetUserListener() {
            @Override
            public void onSuccess(QiscusAccount qiscusAccount) {
                result.success(QiscusSdkHelper.encodeQiscusAccount(qiscusAccount));
            }

            @Override
            public void onError(Throwable throwable) {
                throwable.printStackTrace();
                result.error("ERR_UPDATE_USER", throwable.getMessage(), throwable);
            }
        });
    }

    private void hasLogin(Result result) {
        result.success(QiscusCore.hasSetupUser());
    }

    /**
     * the method return only one user, I think this is because the method has been deprecated
     *
     * @param searchUsername
     * @param page
     * @param limit
     * @param result
     */
    @Deprecated
    private void getAllUsers(String searchUsername, long page, long limit, Result result) {
        Log.e("SDK", searchUsername);
        Log.e("SDK", page + "");
        Log.e("SDK", limit + "");

        QiscusApi.getInstance().getUsers(searchUsername, page, limit)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(qiscusAccounts -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(qiscusAccounts));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_GET_ALL_USERS", throwable.getMessage(), throwable);
                });
    }


    private void chatUser(String userId, JSONObject extras, Result result) {
        QiscusApi.getInstance().chatUser(userId, extras)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(chatRoom -> {
                    result.success(QiscusSdkHelper.encodeQiscusChatRoom(chatRoom));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_CHAT_USER", throwable.getMessage(), throwable);
                });
    }

    private void addOrUpdateLocalChatRoom(QiscusChatRoom chatRoom, Result result) {
        try {
            QiscusCore.getDataStore().addOrUpdate(chatRoom);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_ADD_OR_UPDATE_LOCAL_CHAT_ROOM", e.getMessage(), e);
        }

    }

    private void getChatRoomWithMessages(long roomId, Result result) {
        QiscusApi.getInstance().getChatRoomWithMessages(roomId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(chatRoomListPair -> {
                    result.success(QiscusSdkHelper.encodeChatRoomListPair(chatRoomListPair));
                }, throwable -> {
                    throwable.printStackTrace();
                    // on error
                    String code = "ERR_FAILED_GET_CHATROOM_MESSAGES";
                    result.error(code, throwable.getMessage(), throwable);
                });

    }


    private void getLocalChatRoom(long roomId, Result result) {
        QiscusChatRoom chatRoom = QiscusCore.getDataStore().getChatRoom(roomId);

        result.success(QiscusSdkHelper.encodeQiscusChatRoom(chatRoom));
    }


    private void getChatRoomByRoomIds(
            ArrayList<Long> roomIds,
            boolean showRemoved,
            boolean showParticipant,
            Result result
    ) {
        //TODO later will implement this getChatRoomByRoomIds
        QiscusApi.getInstance().getChatRooms(roomIds, showRemoved, showParticipant)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(chatRoomList -> {
                    Gson gson = AmininGsonBuilder.createGson();

                    result.success(gson.toJson(chatRoomList));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_GET_CHATROOM_BY_IDS", throwable.getMessage(), throwable);
                });
    }

    private void getLocalChatRoomByRoomIds(List<Long> roomIds, Result result) {
        List<QiscusChatRoom> chatRooms = QiscusCore.getDataStore().getChatRooms(roomIds, new ArrayList<>());
        Gson gson = AmininGsonBuilder.createGson();
        result.success(gson.toJson(chatRooms));
    }

    private void getAllChatRooms(
            boolean showParticipant,
            boolean showRemoved,
            boolean showEmpty,
            int page,
            int limit,
            Result result
    ) {
        QiscusApi.getInstance().getAllChatRooms(showParticipant, showRemoved, showEmpty, page, limit)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(chatRoomList -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(chatRoomList));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_GET_ALL_CHAT_ROOMS", throwable.getMessage(), throwable);
                });

    }

    private void getLocalChatRooms(int limit, int offset, Result result) {
        Gson gson = AmininGsonBuilder.createGson();
        List<QiscusChatRoom> chatRoomList = QiscusCore.getDataStore().getChatRooms(limit, offset);
        result.success(gson.toJson(chatRoomList));
    }

    private void getLocalChatRooms(int limit, Result result) {
        Gson gson = AmininGsonBuilder.createGson();
        List<QiscusChatRoom> chatRoomList = QiscusCore.getDataStore().getChatRooms(limit);
        result.success(gson.toJson(chatRoomList));

    }


    private void getTotalUnreadCount(Result result) {
        QiscusApi.getInstance().getTotalUnreadCount()
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(totalUnreadCount -> {
                    result.success(totalUnreadCount);
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_GET_TOTAL_UNREAD_COUNT", throwable.getMessage(), throwable);
                });
    }

    private void sendMessage(long roomId, String message, JSONObject extras, Result result) {
        //Generate message object
        QiscusComment qiscusMessage = QiscusComment.generateMessage(roomId, message);
        if (extras != null) qiscusMessage.setExtras(extras);

        //Send message
        QiscusApi.getInstance().sendMessage(qiscusMessage)
                .subscribeOn(Schedulers.io()) // need to run this task on IO thread
                .observeOn(AndroidSchedulers.mainThread()) // deliver result on main thread or UI thread
                .subscribe(qiscusComment -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(qiscusComment));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_FAILED_SEND_MESSAGE", throwable.getMessage(), throwable);
                });

    }


    private void sendFileMessage(long roomId, String caption, String filePath, JSONObject extras, Result result) {
        File file = new File(filePath);
        if (!file.exists()) {
            result.error("ERR_FILE_NOT_FOUND", null, null);
            return;
        }
        String filename = file.getName();
        QiscusComment message = QiscusComment.generateFileAttachmentMessage(roomId, filePath, caption, filename);
        if (extras != null) message.setExtras(extras);

        QiscusApi.getInstance().sendFileMessage(
                message, file, percentage -> {
                    message.setProgress((int) percentage);
                    QiscusAndroidUtil.runOnUIThread(() -> {
                        EventBus.getDefault().post(new QiscusFileUploadProgressEvent((int) percentage));
                    });
                })
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(comment -> {

                    QiscusCore.getDataStore()
                            .addOrUpdateLocalPath(comment.getRoomId(),
                                    comment.getId(), file.getAbsolutePath());

                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(comment));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_FAILED_SEND_FILE_MESSAGE", throwable.getMessage(), throwable);

                });


    }

    /**
     * get User That has been login
     *
     * @param result
     */
    private void getQiscusAccount(Result result) {
        try {
            result.success(QiscusSdkHelper.encodeQiscusAccount(QiscusCore.getQiscusAccount()));

        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_GET_ACCOUNT", e.getMessage(), e);
        }

    }

    private void getLocalComments(long roomId, Result result) {
        List<QiscusComment> comments = QiscusCore.getDataStore().getComments(roomId);
        Gson gson = AmininGsonBuilder.createGson();
        result.success(gson.toJson(comments));
    }

    private void getLocalComments(long roomId, int limit, Result result) {
        List<QiscusComment> comments = QiscusCore.getDataStore().getComments(roomId, limit);
        Gson gson = AmininGsonBuilder.createGson();
        result.success(gson.toJson(comments));
    }


    private void registerEventHandler(Result result) {
        eventHandler.registerEventBus();
        result.success(true);
    }

    private void unregisterEventHandler(Result result) {
        eventHandler.unregisterEventBus();
        result.success(true);
    }

    private void markCommentAsRead(long roomId, long commentId, Result result) {
        QiscusPusherApi.getInstance().markAsRead(roomId, commentId);
        result.success(true);

    }

    private void addOrUpdateLocalComment(QiscusComment comment, Result result) {
        try {
            QiscusCore.getDataStore().addOrUpdate(comment);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_TO_ADD_OR_UPDATE_LOCAL_COMMENT", e.getMessage(), e);
        }

    }

    private void subscribeToChatRoom(QiscusChatRoom chatRoom, Result result) {
        try {
            QiscusPusherApi.getInstance().subscribeChatRoom(chatRoom);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_SUBSCRIBE_CHAT_ROOM_EVENT", e.getMessage(), e);

        }
    }

    private void unsubscribeToChatRoom(QiscusChatRoom chatRoom, Result result) {
        try {
            QiscusPusherApi.getInstance().unsubsribeChatRoom(chatRoom);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_UNSUBSCRIBE_CHAT_ROOM_EVENT", e.getMessage(), e);

        }

    }


    private void deleteLocalCommentsByRoomId(long roomId, Result result) {
        try {
            QiscusCore.getDataStore().deleteCommentsByRoomId(roomId);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_DELETE_LOCAL_COMMENTS_BY_ROOM_ID", e.getMessage(), e);

        }
    }

    private void deleteLocalComment(QiscusComment comment, Result result) {
        try {
            QiscusCore.getDataStore().delete(comment);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_DELETE_LOCAL_COMMENTS_BY_ROOM_ID", e.getMessage(), e);

        }
    }

    private void deleteLocalChatRoom(long roomId, Result result) {
        try {
            QiscusCore.getDataStore().deleteChatRoom(roomId);
            result.success(true);
        } catch (Exception e) {
            e.printStackTrace();
            result.error("ERR_FAILED_DELETE_LOCAL_CHAT_ROOM", e.getMessage(), e);

        }
    }


    private void getPrevMessages(long roomId, int limit, int messageId, Result result) {

        QiscusApi.getInstance().getPreviousMessagesById(roomId, limit, messageId)
                .toSortedList(commentComparator)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(comments -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(comments));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_FAILED_GET_PREV_MSGS", throwable.getMessage(), throwable);
                });

    }


    private void getLocalPrevMessages(long roomId, int limit, String uniqueId, Result result) {
        QiscusComment qiscusComment = QiscusCore.getDataStore().getComment(uniqueId);
        QiscusCore.getDataStore().getObservableOlderCommentsThan(qiscusComment, roomId, limit * 2)
                .flatMap(Observable::from)
                .filter(qiscusComment1 -> qiscusComment.getId() == -1 || qiscusComment1.getId() < qiscusComment.getId())
                .toSortedList(commentComparator)
                .map(comments -> {
                    if (comments.size() >= limit) {
                        return comments.subList(0, limit);
                    }
                    return comments;
                })
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(qiscusComments -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(qiscusComments));
                }, error -> {
                    error.printStackTrace();
                    result.error("ERR_FAILED_GET_LOCAL_PREV_MESSAGES", error.getMessage(), error);
                });
    }

    private void getLocalNextMessages(long roomId, int limit, String uniqueId, Result result) {
        QiscusComment qiscusComment = QiscusCore.getDataStore().getComment(uniqueId);

        QiscusCore.getDataStore().getObservableCommentsAfter(qiscusComment, roomId)
                .flatMap(Observable::from)
                .filter(qiscusComment1 -> qiscusComment.getId() == -1 || qiscusComment1.getId() > qiscusComment.getId())
                .toSortedList(commentComparator)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(comments -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(comments));
                }, err->{
                    err.printStackTrace();
                    result.error("ERR_FAILED_GET_LOCAL_NEXT_MESSAGES",err.getMessage(),err);
                });
    }


    private void getNextMessages(long roomId, int limit, String uniqueId, Result result) {
        QiscusComment qiscusComment = QiscusCore.getDataStore().getComment(uniqueId);

        QiscusApi.getInstance().getNextMessagesById(roomId, limit, qiscusComment.getId())
                .filter(qiscusComment1 -> qiscusComment.getId() == -1 || qiscusComment1.getId() > qiscusComment.getId())
                .toSortedList(commentComparator)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(comments -> {
                    Gson gson = AmininGsonBuilder.createGson();
                    result.success(gson.toJson(comments));
                }, throwable -> {
                    throwable.printStackTrace();
                    result.error("ERR_FAILED_GET_NEXT_MSGS", throwable.getMessage(), throwable);

                });
    }



}
