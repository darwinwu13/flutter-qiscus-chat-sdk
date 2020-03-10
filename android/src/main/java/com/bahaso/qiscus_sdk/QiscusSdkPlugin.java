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
import com.qiscus.sdk.chat.core.data.remote.QiscusApi;

import org.json.JSONObject;

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
import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

/**
 * QiscusChatSdkPlugin
 */
public class QiscusSdkPlugin implements FlutterPlugin, MethodCallHandler {
    private final String CHANNEL_NAME = "bahaso.com/qiscus_chat_sdk";

    private Context applicationContext;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        onAttachToEngine(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        channel.setMethodCallHandler(null);
        channel = null;

    }

    private void onAttachToEngine(BinaryMessenger messenger, Context applicationContext) {
        this.applicationContext = applicationContext;

        channel = new MethodChannel(messenger, CHANNEL_NAME);
        channel.setMethodCallHandler(this);
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
                result.success(null);
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
                addOrUpdateLocalChatRoom(QiscusSdkHelper.parseQiscusChatRoom(json));
                result.success(true);
                break;

            case "getChatRoomWithMessages":
                long roomId = call.argument("roomId");
                getChatRoomWithMessages(roomId, result);
                break;
            case "getLocalChatRoom":
                roomId = call.argument("roomId");
                getLocalChatRoom(roomId, result);
                break;
            case "getChatRoomByRoomIds":
                //todo will call getChatRoomByRoomIds() here
                break;
            case "getLocalChatRoomByRoomIds":
                List<Long> roomIds = call.argument("roomIds");

                getLocalChatRoomByRoomIds(roomIds, result);
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
                    result.error("ERR_LOGIN_JWT", error.getMessage(), error);
                });
    }


    private void login(
            String userId,
            String userKey,
            String username,
            String avatarUrl,
            JSONObject extras,
            Result result) {
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
                    ArrayList<String> accounts = new ArrayList<String>();
                    for (QiscusAccount account : qiscusAccounts) {
                        if (account.getExtras().length() == 0) {
                            account.setExtras(null);
                        }
                        accounts.add(gson.toJson(account));
                    }
                    result.success(accounts);
                }, throwable -> {
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
                    result.error("ERR_CHAT_USER", throwable.getMessage(), throwable);
                });
    }

    private void addOrUpdateLocalChatRoom(QiscusChatRoom chatRoom) {
        QiscusCore.getDataStore().addOrUpdate(chatRoom);
    }

    private void getChatRoomWithMessages(long roomId, Result result) {
        QiscusApi.getInstance().getChatRoomWithMessages(roomId)
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(chatRoomListPair -> {
                    result.success(QiscusSdkHelper.encodeChatRoomListPair(chatRoomListPair));
                }, throwable -> {
                    // on error
                    String code = "ERR_FAILED_GET_CHATROOM_MESSAGES";
                    result.error(code, throwable.getMessage(), throwable);
                });

    }

    private void getLocalChatRoom(long roomId, Result result) {
        QiscusChatRoom chatRoom = QiscusCore.getDataStore().getChatRoom(roomId);

        result.success(QiscusSdkHelper.encodeQiscusChatRoom(chatRoom));
    }


    private void getChatRoomByRoomIds(ArrayList<Long> roomIds, Result result) {
        //TODO later will implement this
    }

    private void getLocalChatRoomByRoomIds(List<Long> roomIds, Result result) {
        List<QiscusChatRoom> chatRooms = QiscusCore.getDataStore().getChatRooms(roomIds, null);
        ArrayList<String> encoded = new ArrayList<>();
        for (QiscusChatRoom chatRoom : chatRooms) {
            encoded.add(QiscusSdkHelper.encodeQiscusChatRoom(chatRoom));
        }
        result.success(encoded);
    }

}
