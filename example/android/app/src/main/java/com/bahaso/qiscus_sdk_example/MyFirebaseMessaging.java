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

    @Override
    public void onCreate() {
        super.onCreate();

        QiscusFCMWrapper fcmQiscus = new QiscusFCMWrapper();
        FlutterFCMWrapper fcmFlutter = new FlutterFCMWrapper();
        messagingServices.add(fcmQiscus);
        messagingServices.add(fcmFlutter);
        messagingServicesMap.put(QiscusFCMWrapper.class, fcmQiscus);
        messagingServicesMap.put(FlutterFCMWrapper.class, fcmFlutter);
        attachDelegateContext(service -> {
            service.attachContext(getBaseContext());
            service.onCreate();
        });

    }

    @Override
    public void onNewToken(@NonNull String s) {
        super.onNewToken(s);

        delegate(service -> {
            service.onNewToken(s);
        });

    }

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        FirebaseMessagingService fcm;
        if (remoteMessage.getData().get("qiscus_sdk") != null) {
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

