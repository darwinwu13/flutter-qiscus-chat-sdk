package com.bahaso.qiscus_sdk;

import com.google.gson.Gson;
import com.qiscus.sdk.chat.core.event.QiscusCommentReceivedEvent;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class QiscusEventHandler {

    private MethodChannel channel;

    public QiscusEventHandler(MethodChannel channel) {
        this.channel = channel;
        registerEventBus();
    }

    public void registerEventBus() {
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this);
        }
    }

    public void unregisterEventBus() {
        EventBus.getDefault().unregister(this);
    }

    @Subscribe
    public void onReceiveComment(QiscusCommentReceivedEvent event) {
        Gson gson = AmininGsonBuilder.createGson();
        Map<String, Object> args = new HashMap<>();
        args.put("comment", gson.toJson(event.getQiscusComment()));
        channel.invokeMethod("onReceiveComment", args);
    }
}
