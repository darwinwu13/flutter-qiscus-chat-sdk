//
//  QiscusRepository.swift
//  sqflite
//
//  Created by bahaso on 14/07/20.
//

import Foundation
//import CoreData
import SQLite

class QiscusRepository {
    func getApplicationSupportDirectory()-> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let applicationSupportDirectory = paths[0]

        return applicationSupportDirectory
    }
    
    func getLocalChatRooms(withLimit limit: Int) {
//        let path = NSSearchPathForDirectoriesInDomains(
//            .documentDirectory, .userDomainMask, true
//        ).first!
        let path = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory, .userDomainMask, true
        ).first!
        
        print("path \(path)")
    
        do {
            let db = try Connection("\(path)/Qiscus.sqlite")
            print("Database found \(db)")
            let stmt = try db.prepare("""
                SELECT ZROOM.ZID AS ROOM_ID, ZROOM.ZNAME AS ROOM_NAME, ZROOM.ZUNIQUEID AS ROOM_UNIQUE_ID, ZROOM.ZAVATARURL AS ROOM_AVATARURL, ZROOM.ZTYPE AS ROOM_TYPE, ZROOM.ZUNREADCOUNT AS ROOM_UNREADCOUNT, ZROOM.ZLASTCOMMENTID AS ROOM_LASTCOMMENTID, ZROOM.ZOPTIONS AS ROOM_OPTIONS, ZCOMMENT.ZID AS COMMENT_ID, ZCOMMENT.ZROOMID AS COMMENT_ROOM_ID, ZCOMMENT.ZUNIQID AS COMMENT_UNIQUE_ID, ZCOMMENT.ZCOMMENTBEFOREID AS COMMENT_COMMENTBEFOREID, ZCOMMENT.ZMESSAGE AS COMMENT_MESSAGE, ZCOMMENT.ZUSERNAME AS COMMENT_USERNAME, ZCOMMENT.ZUSEREMAIL AS COMMENT_USEREMAIL, ZCOMMENT.ZUSERAVATARURL AS COMMENT_USERAVATARURL, ZCOMMENT.ZSTATUS AS COMMENT_STATUS, ZCOMMENT.ZPAYLOAD AS COMMENT_PAYLOAD, ZCOMMENT.ZISPUBLICCHANNEL AS COMMENT_ISPUBLIC_CHANNEL, ZCOMMENT.ZEXTRAS AS COMMENT_EXTRAS, ZCOMMENT.ZTIMESTAMP AS COMMENT_TIMESTAMP, ZCOMMENT.ZUNIXTIMESTAMP AS COMMENT_UNIXTIMESTAMP, ZMEMBER.ZID AS MEMBER_ID, ZMEMBER.ZUSERNAME AS MEMBER_USERNAME, ZMEMBER.ZAVATARURL AS MEMBER_AVATAR_URL, ZMEMBER.ZEMAIL AS MEMBER_EMAIL, ZMEMBER.ZLASTCOMMENTREADID AS MEMBER_LASTCOMMENTREADID, ZMEMBER.ZLASTCOMMENTRECEIVEDID AS MEMBER_LASTCOMMENTRECEIVEDID
                FROM (SELECT * FROM ZROOM limit 5) as ZROOM
                LEFT JOIN ZCOMMENT ON ROOM_LASTCOMMENTID = ZCOMMENT.ZID
                LEFT JOIN Z_2ROOMS ON ZROOM.Z_PK = Z_2ROOMS.Z_3ROOMS
                LEFT JOIN ZMEMBER ON Z_2ROOMS.Z_2MEMBERS = ZMEMBER.Z_PK
                """
            );
        
            self.generateStmtToRoomModelDic(withStatement: stmt)
        }catch {
            print("Database not found \(error)")
        }
    }
    
    func generateStmtToRoomModelDic(withStatement stmt: Statement) {
        var tmpRoomModelsDic: [[String: Any]] = [[String: Any]]()
        
        
        for row in stmt {
            let roomId: String = row[0] as? String ?? ""
            var tmpRoomModelWithKey = [String: Any]()
            
            if tmpRoomModelWithKey[roomId] == nil {
                var tmpRoomModelDic: [String: Any] = [String: Any]()
                
                for (index, name) in stmt.columnNames.enumerated() {
                    self.generateRoomModelDic(
                        withKey: name,
                        withValue: row[index],
                        withRoomModelDic: &tmpRoomModelDic
                    )

                    
                }
                
                tmpRoomModelWithKey[roomId]  = tmpRoomModelDic
                tmpRoomModelsDic.append(tmpRoomModelWithKey)
            }
        }
        
        print("tmpRoomModelsDic \(tmpRoomModelsDic)")
    }
    
    func generateRoomModelDic(withKey key: String , withValue value: Any?, withRoomModelDic tmpRoomModelDic: inout [String: Any]) {
        if key == "ROOM_ID" {
            tmpRoomModelDic["id"] = value
        }else if key == "ROOM_NAME" {
            tmpRoomModelDic["name"] = value
        }else if key == "ROOM_UNIQUE_ID" {
            tmpRoomModelDic["uniqueId"] = value
        }else if key == "ROOM_AVATARURL" {
            tmpRoomModelDic["avatarUrl"] = value
        }else if key == "ROOM_TYPE" {
            tmpRoomModelDic["type"] = value
        }else if key == "ROOM_UNREADCOUNT" {
            tmpRoomModelDic["unreadCount"] = value
        }
        
        self.generateCommentModelDic(withKey: key, withValue: value, withRoomModelDic: &tmpRoomModelDic)
    }

    func generateCommentModelDic(withKey key: String , withValue value: Any?, withRoomModelDic roomModelDic: inout [String: Any]) {
//        print("room model dics \(roomModelDic)")
//        var tmptCommentModelDic = roomModelDic["lastComment"] as? [String: Any] ?? [String: Any]()
        var tmptCommentModelDic = [String: Any]()
        if key == "COMMENT_ID" {
            tmptCommentModelDic["id"] = value
        }else if key == "COMMENT_ROOM_ID" {
            tmptCommentModelDic["roomId"] = value
        }else if key == "COMMENT_UNIQUE_ID" {
            tmptCommentModelDic["uniqueId"] = value
        }else if key == "COMMENT_COMMENTBEFOREID" {
            tmptCommentModelDic["commentBeforeId"] = value
        }else if key == "COMMENT_MESSAGE" {
            tmptCommentModelDic["message"] = value
        }else if key == "COMMENT_USERNAME" {
            tmptCommentModelDic["sender"] = value
        }else if key == "COMMENT_USEREMAIL" {
            tmptCommentModelDic["senderEmail"] = value
        }else if key == "COMMENT_USERAVATARURL" {
            tmptCommentModelDic["senderAvatar"] = value
        }else if key == "COMMENT_STATUS" {
            tmptCommentModelDic["status"] = value
        }else if key == "COMMENT_PAYLOAD" {
            tmptCommentModelDic["payload"] = value
        }else if key == "COMMENT_EXTRAS" {
            tmptCommentModelDic["extras"] = value
        }else if key == "COMMENT_ISPUBLIC_CHANNEL" {
            tmptCommentModelDic["isPublicChannel"] = value
        }else if key == "COMMENT_TIMESTAMP" {
            tmptCommentModelDic["timestamp"] = value
        }else if key == "COMMENT_UNIXTIMESTAMP" {
            tmptCommentModelDic["unixTimestamp"] = value
        }
        
        roomModelDic["lastComment"] = tmptCommentModelDic
    }
}
