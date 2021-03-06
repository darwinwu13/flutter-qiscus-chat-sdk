package com.bahaso.qiscus_sdk;


import android.util.Log;

import androidx.annotation.NonNull;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.qiscus.sdk.chat.core.QiscusCore;
import com.qiscus.sdk.chat.core.util.QiscusFirebaseMessagingUtil;

public class QiscusFirebaseMessaging extends FirebaseMessagingService {

    @Override
    public void onNewToken(@NonNull String s) {
        super.onNewToken(s);

        Log.d("Qiscus", "onNewToken " + s);
        //Notify Qiscus Chat SDK about FCM token
        try {
            QiscusCore.registerDeviceToken(s);
        }catch (Exception e){
            Log.e("CHAT SDK","FAILED TO Register device on new token");
            Log.e("CHAT SDK",e.getMessage());
        }
    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);

        Log.d("Qiscus", "onMessageReceived " + remoteMessage.getData().toString());
        if (QiscusFirebaseMessagingUtil.handleMessageReceived(remoteMessage)) {
            return;
        }

    }
}
