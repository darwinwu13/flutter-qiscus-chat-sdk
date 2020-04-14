package com.bahaso.qiscus_sdk_example;


import android.content.Context;

import androidx.annotation.NonNull;

import com.bahaso.qiscus_sdk.QiscusFirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;


public class MyFirebaseMessaging extends FirebaseMessagingService {

    interface MultipleFCMWrapper {
        void attachContext(Context context);

        void onCreate();
    }

    private class QiscusFCMWrapper extends QiscusFirebaseMessaging implements MultipleFCMWrapper {

        public void attachContext(Context context) {
            attachBaseContext(context);
        }


    }

    private class FlutterFCMWrapper extends FlutterFirebaseMessagingService implements MultipleFCMWrapper {

        public void attachContext(Context context) {
            attachBaseContext(context);
        }
    }

    private List<FirebaseMessagingService> messagingServices = new ArrayList<>();
    private Map<Class, FirebaseMessagingService> messagingServicesMap = new HashMap<>();

    public MyFirebaseMessaging() {
        super();
        QiscusFCMWrapper fcmQiscus = new QiscusFCMWrapper();
        FlutterFCMWrapper fcmFlutter = new FlutterFCMWrapper();
        messagingServices.add(fcmQiscus);
        messagingServices.add(fcmFlutter);
        messagingServicesMap.put(QiscusFCMWrapper.class, fcmQiscus);
        messagingServicesMap.put(FlutterFCMWrapper.class, fcmFlutter);
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("CHAT SDK","on create start");

        attachDelegateContext(service -> {
            service.attachContext(getBaseContext());
            service.onCreate();
        });
        Log.d("CHAT SDK","on create end");

    }

    @Override
    public void onNewToken(@NonNull String s) {
        super.onNewToken(s);
        Log.d("CHAT SDK","on new token start");

        delegate(service -> {
            Log.d("CHAT SDK","s value "+ s);
            service.onNewToken(s);
        });
        Log.d("CHAT SDK","on new token end");

    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        FirebaseMessagingService fcm;
        Log.d("FCM","on my fcm message received : "+remoteMessage.getData().get("qiscus_sdk"));
        if (remoteMessage.getData().containsKey("qiscus_sdk")) {
            fcm = messagingServicesMap.get(QiscusFCMWrapper.class);
        } else {
            fcm = messagingServicesMap.get(FlutterFCMWrapper.class);
        }

        fcm.onMessageReceived(remoteMessage);
    }

    private void delegate(Action<FirebaseMessagingService> action) {
        for (FirebaseMessagingService service : messagingServices) {
            action.run(service);
        }
    }

    private void attachDelegateContext(Action<MultipleFCMWrapper> action) {
        for (FirebaseMessagingService service : messagingServices) {
            action.run((MultipleFCMWrapper) service);
        }
    }

    interface Action<T> {
        void run(T t);
    }
}

