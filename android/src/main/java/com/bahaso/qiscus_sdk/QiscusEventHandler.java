package com.bahaso.qiscus_sdk;

import com.google.gson.Gson;
import com.qiscus.sdk.chat.core.event.QiscusChatRoomEvent;
import com.qiscus.sdk.chat.core.event.QiscusCommentReceivedEvent;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;

import java.util.HashMap;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

public class QiscusEventHandler {

    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private final String EVENT_CHANNEL_NAME = "bahaso.com/qiscus_chat_sdk/events";

    public QiscusEventHandler(BinaryMessenger messenger) {
        eventChannel = new EventChannel(messenger, EVENT_CHANNEL_NAME);
        registerEventBus();
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink = events;
                Log.e("EVENT SINK", " evet channel listened");

            }

            @Override
            public void onCancel(Object arguments) {
                eventSink = null;
                Log.e("EVENT SINK", " event channel canceled");

            }
        });
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
        args.put("type", "comment_received");
        args.put("comment", event.getQiscusComment());
        if (eventSink != null)
            eventSink.success(gson.toJson(args));
    }


    @Subscribe
    public void onReceiveChatRoomEvent(QiscusChatRoomEvent roomEvent) {
        Log.e("SDK","on receive chat room event");
        Gson gson = AmininGsonBuilder.createGson();
        Map<String, Object> args = new HashMap<>();
        args.put("type", "chat_room_event_received");
        args.put("chatRoomEvent", roomEvent);
        if (eventSink != null)
            eventSink.success(gson.toJson(args));
    }

    @Subscribe
    public void onReceiveFileUploadProgressEvent(QiscusFileUploadProgressEvent event){
        Gson gson = AmininGsonBuilder.createGson();
        Map<String, Object> args = new HashMap<>();
        args.put("type", "file_upload_progress");
        args.put("progress", event.getProgress());
        if (eventSink != null)
            eventSink.success(gson.toJson(args));
    }

}
