package com.bahaso.qiscus_sdk;

import androidx.core.util.Pair;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.qiscus.sdk.chat.core.data.model.QiscusAccount;
import com.qiscus.sdk.chat.core.data.model.QiscusChatRoom;
import com.qiscus.sdk.chat.core.data.model.QiscusComment;
import com.qiscus.sdk.chat.core.data.model.QiscusRoomMember;
import com.qiscus.sdk.chat.core.util.QiscusTextUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

public class QiscusSdkHelper {

    public static QiscusComment parseQiscusComment(String json) {
        JsonObject jsonComment = JsonParser.parseString(json).getAsJsonObject();
        return parseQiscusComment(jsonComment);
    }

    private static QiscusComment parseQiscusComment(JsonObject jsonComment) {
        //todo need to test apakah jsonObjec di get dan di check isjsonNull efek untuk yg ga ada key
        QiscusComment qiscusComment = new QiscusComment();
        qiscusComment.setRoomId(jsonComment.get("roomId").isJsonNull() ? -1 :
                jsonComment.get("roomId").getAsLong());
        qiscusComment.setId(jsonComment.get("id").getAsLong());
        qiscusComment.setCommentBeforeId(jsonComment.get("commentBeforeId").getAsLong());
        qiscusComment.setUniqueId(jsonComment.get("uniqueId").getAsString());
        qiscusComment.setSender(jsonComment.get("sender").getAsString());
        qiscusComment.setSenderEmail(jsonComment.get("senderEmail").getAsString());
        qiscusComment.setSenderAvatar(jsonComment.get("senderAvatar").getAsString());
        qiscusComment.setState(jsonComment.get("state").getAsInt());

        try {
            qiscusComment.setTime(iso8601Format(jsonComment.get("time").getAsString()));
        } catch (ParseException e) {
            e.printStackTrace();
        }

        qiscusComment.setDeleted(jsonComment.get("deleted").getAsBoolean());
        qiscusComment.setHardDeleted(jsonComment.get("hardDeleted").getAsBoolean());
        qiscusComment.setSelected(jsonComment.get("selected").getAsBoolean());
        qiscusComment.setHighlighted(jsonComment.get("highlighted").getAsBoolean());
        qiscusComment.setDownloading(jsonComment.get("downloading").getAsBoolean());
        qiscusComment.setProgress(jsonComment.get("progress").getAsInt());

        if (jsonComment.has("roomName") && !jsonComment.get("roomName").isJsonNull()) {
            qiscusComment.setRoomName(jsonComment.get("roomName").getAsString());
        }

        if (jsonComment.has("roomAvatar") && !jsonComment.get("roomAvatar").isJsonNull()) {
            qiscusComment.setRoomAvatar(jsonComment.get("roomAvatar").getAsString());
        }

        qiscusComment.setGroupMessage(jsonComment.get("groupMessage").getAsBoolean());
        if (jsonComment.get("rawType").isJsonNull())
            qiscusComment.setRawType("text");
        else
            qiscusComment.setRawType(jsonComment.get("rawType").getAsString());

        qiscusComment.setExtraPayload(jsonComment.get("extraPayload").toString());


        if (jsonComment.has("message") && !jsonComment.get("message").isJsonNull()) {
            String text = jsonComment.get("message").getAsString();
            if (QiscusTextUtil.isNotBlank(text)) {
                qiscusComment.setMessage(text.trim());
            }
        }


        if (jsonComment.has("extras") && !jsonComment.get("extras").isJsonNull()) {
            try {
                qiscusComment.setExtras(new JSONObject(jsonComment.get("extras").getAsJsonObject().toString()));
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        return qiscusComment;
    }

    public static QiscusComment parseQiscusComment(JsonObject jsonComment, long roomId) {

       /* final int id; v
        final int roomId; v
        final String uniqueId;v
        final int commentBeforeId;v
        final String message; v
        final String sender; v
        final String senderEmail; v
        final String senderAvatar; v
        final DateTime time; ?
        final int state; v
        final bool deleted; v
        final bool hardDeleted; v
        final String roomName; v
        final String roomAvatar; v
        final bool groupMessage; v
        final bool selected; v
        final bool highlighted; v
        final bool downloading; v
        final int progress; v
        final List<String> urls;[by containUrls]
        final String rawType; v
        final String extraPayload; v
        final Map<String, dynamic> extras; v
        final QiscusComment replyTo; [by getReplyTo]
        final String caption; [by  getCaption]
        final String attachmentName; [by getAttachmentName]*/

        QiscusComment qiscusComment = parseQiscusComment(jsonComment);
        qiscusComment.setRoomId(roomId);
        return qiscusComment;
    }


    public static QiscusRoomMember parseQiscusRoomMember(JsonObject jsonMember) {
        QiscusRoomMember member = new QiscusRoomMember();
        member.setEmail(jsonMember.get("email").getAsString());
        member.setUsername(jsonMember.get("username").getAsString());
        if (jsonMember.has("avatar")) {
            member.setAvatar(jsonMember.get("avatar").getAsString());
        }

        try {
            if (jsonMember.has("extras")) {
                member.setExtras(jsonMember.get("extras").isJsonNull() ? null :
                        new JSONObject(jsonMember.get("extras").getAsJsonObject().toString()));
            }
        } catch (JSONException ignored) {
            //Do nothing
        }

        if (jsonMember.has("lastDeliveredCommentId")) {
            member.setLastDeliveredCommentId(jsonMember.get("lastDeliveredCommentId").getAsInt());
        }
        if (jsonMember.has("lastReadCommentId")) {
            member.setLastReadCommentId(jsonMember.get("lastReadCommentId").getAsInt());
        }
        return member;
    }


    public static QiscusChatRoom parseQiscusChatRoom(String chatRoomJson) {

        /*{
            "id":11315282, v
            "distinctId":5da3f7e6f48c3d175649388b darwinwu134, v
            "uniqueId":58b2284d0d9f129ff8b78312529b3b2d, v
            "name":"Edwin Fadilah", v
            "options":null,
            "group":false, v
            "channel":false, v
            "avatarUrl":"https"://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png, v
            "member":[
                {
                    "email":5da3f7e6f48c3d175649388b,
                    "username":"Edwin Fadilah",
                    "avatar":"https"://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png,
                    "lastDeliveredCommentId":0,
                    "lastReadCommentId":0,
                    "extras":null
                },
                {
                    "email":darwinwu134,
                    "username":Darwin 134,
                    "avatar":"https"://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/75r6s_jOHa/1507541871-avatar-mine.png,
                    "lastDeliveredCommentId":0,
                    "lastReadCommentId":0,
                    "extras":{
                        "key":"konci bos"
                    }
                }
            ],
            "unreadCount":0,
            "lastComment":null,
            "memberCount":2 v
        }*/


        Gson gson = AmininGsonBuilder.createGson();
        QiscusChatRoom chatRoom = new QiscusChatRoom();
        JsonObject jsonChatRoom = JsonParser.parseString(chatRoomJson).getAsJsonObject();

        chatRoom.setId(jsonChatRoom.get("id").getAsLong());
        chatRoom.setGroup(jsonChatRoom.get("group").getAsBoolean());
        chatRoom.setName(jsonChatRoom.get("name").getAsString());
        chatRoom.setDistinctId(jsonChatRoom.get("distinctId").getAsString());
        chatRoom.setUniqueId(jsonChatRoom.get("uniqueId").getAsString());

        try {
            chatRoom.setOptions(jsonChatRoom.get("options").isJsonNull() ? null :
                    new JSONObject(jsonChatRoom.get("options").getAsString()));
        } catch (JSONException ignored) {
            //Do nothing
        }
        chatRoom.setAvatarUrl(jsonChatRoom.get("avatarUrl").getAsString());
        chatRoom.setChannel(jsonChatRoom.get("channel").getAsBoolean());
        chatRoom.setMemberCount(jsonChatRoom.get("memberCount").getAsInt());
        chatRoom.setUnreadCount(jsonChatRoom.get("unreadCount").getAsInt());

        JsonElement participants = jsonChatRoom.get("member");
        List<QiscusRoomMember> members = new ArrayList<>();
        if (participants.isJsonArray()) {
            JsonArray jsonMembers = participants.getAsJsonArray();
            for (JsonElement jsonMember : jsonMembers) {
                members.add(QiscusSdkHelper.parseQiscusRoomMember(jsonMember.getAsJsonObject()));
            }
        }
        chatRoom.setMember(members);

        chatRoom.setLastComment(jsonChatRoom.get("lastComment").isJsonNull() ? null :
                QiscusSdkHelper.parseQiscusComment(jsonChatRoom.get("lastComment").getAsJsonObject(), chatRoom.getId()));


        return chatRoom;
    }

    public static String encodeQiscusAccount(QiscusAccount qiscusAccount) {
        Gson gson = AmininGsonBuilder.createGson();
        return gson.toJson(qiscusAccount);
    }

    // encode chatRoomListPair to be ready for serialized at platform channel
    public static HashMap<String, String> encodeChatRoomListPair(Pair<QiscusChatRoom, List<QiscusComment>> chatRoomListPair) {
        HashMap<String, String> map = new HashMap<>();
        Gson gson = AmininGsonBuilder.createGson();
        // on success getting chat room
        QiscusChatRoom qiscusChatRoom = chatRoomListPair.first;
        // on success getting messages
        List<QiscusComment> messages = chatRoomListPair.second;

        map.put("chatRoom", gson.toJson(qiscusChatRoom));
        map.put("messages", gson.toJson(messages));
        return map;
    }


    public static String encodeQiscusChatRoom(QiscusChatRoom chatRoom) {
        Gson gson = AmininGsonBuilder.createGson();
        return gson.toJson(chatRoom);
    }


    public static Date iso8601Format(String formattedDate) throws ParseException {
        try {
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSX", Locale.getDefault());
            return df.parse(formattedDate);
        } catch (IllegalArgumentException ex) {
            // error happen in Java 6: Unknown pattern character 'X'
            if (formattedDate.endsWith("Z")) formattedDate = formattedDate.replace("Z", "+0000");
            else formattedDate = formattedDate.replaceAll("([+-]\\d\\d):(\\d\\d)\\s*$", "$1$2");
            DateFormat df1 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.getDefault());
            return df1.parse(formattedDate);
        }
    }

    public static JSONObject mergeJSONObjects(JSONObject json1, JSONObject json2) {
        JSONObject merged = new JSONObject();
        JSONObject[] objs = new JSONObject[]{json1, json2};
        try {
            for (JSONObject obj : objs) {
                Iterator it = obj.keys();
                while (it.hasNext()) {
                    String key = (String) it.next();

                    merged.put(key, obj.get(key));

                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return merged;
    }


}
