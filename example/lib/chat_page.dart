import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/fa_icon.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';
import 'package:qiscus_sdk_example/send_image_preview.dart';

class ChatPage extends StatefulWidget {
  final int roomId;
  final String roomName;
  final QiscusAccount senderAccount;

  ChatPage({
    Key key,
    @required int roomId,
    this.roomName,
    this.senderAccount,
  })  : this.roomId = roomId,
        super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String message;
  List<QiscusComment> comments = [];
  QiscusChatRoom chatRoom;
  TextEditingController controller;
  ScrollController scrollController;
  StreamSubscription _commentReceiveSubscription;
  StreamSubscription _chatRoomEventSubscription;
  QiscusAccount _account;
  bool _commentSending = false;

  @override
  void initState() {
    super.initState();
    init();
    dev.log("init state");
  }

  Future<void> init() async {
    controller = TextEditingController();
    scrollController = ScrollController();
    initEventHandler();
    _getChatRoomWithMessages();
    _account = await ChatSdk.getQiscusAccount();
    WidgetsBinding.instance.addObserver(
      new LifecycleEventHandler(resumeCallBack: () {
        return _getChatRoomWithMessages();
      }, suspendingCallBack: () {
        return ChatSdk.unsubscribeToChatRoom(chatRoom);
      }),
    );
  }

  void initEventHandler() {
    _commentReceiveSubscription = ChatSdk.commentReceivedStream.listen((QiscusComment comment) {
      onReceiveComment(comment);
    });
    _chatRoomEventSubscription =
        ChatSdk.chatRoomEventStream.listen((QiscusChatRoomEvent chatRoomEvent) {
      switch (chatRoomEvent.event) {
        case Event.READ:
          List<QiscusComment> cmnts = comments.where((QiscusComment comment) {
            bool isTargetComment = comment.id == chatRoomEvent.commentId ? true : false;

            /// retrieve previous comment that haven't been read and own by this sender
            bool isNotReadComment = comment.state < QiscusComment.STATE_READ &&
                comment.state >= QiscusComment.STATE_ON_QISCUS &&
                comment.senderEmail == _account.email;
            return isTargetComment || isNotReadComment;
          }).toList();
          setState(() {
            cmnts.forEach((QiscusComment cmnt) {
              if (cmnt.state >= QiscusComment.STATE_ON_QISCUS) {
                cmnt.state = QiscusComment.STATE_READ;
                ChatSdk.addOrUpdateLocalComment(cmnt);
              }
            });
          });

          break;
        case Event.DELIVERED:
          QiscusComment cmnt = comments.where((QiscusComment comment) {
            return comment.id == chatRoomEvent.commentId ? true : false;
          }).first;
          if (cmnt.state >= QiscusComment.STATE_ON_QISCUS &&
              cmnt.state != QiscusComment.STATE_READ) {
            cmnt.state = QiscusComment.STATE_DELIVERED;
            setState(() {
              ChatSdk.addOrUpdateLocalComment(cmnt);
            });
          }
          break;
        case Event.TYPING:
          break;
        default:
          break;
      }
    });
  }

  void onReceiveComment(QiscusComment comment) {
    print('on receive ${comment.message}');
    setState(() {
      if (!comments.contains(comment)) {
        comments.insert(0, comment);
        ChatSdk.addOrUpdateLocalComment(comment);
        scrollController.animateTo(
          0,
          duration: Duration(milliseconds: 500),
          curve: Curves.linear,
        );
        if (comment.roomId == chatRoom.id) {
          if (comment.senderEmail != _account.email) {
            ChatSdk.markCommentAsRead(chatRoom.id, comment.id);
            //post api to backend to set status to read here
          }
        }
      }
    });

    //mark as read
  }

  //todo add lifecycle of app, use widgetBindingObserver

  Future<void> _getLocalChatRoomWithMessages() async {
    var qiscusChatroom = await ChatSdk.getLocalChatRoom(widget.roomId);
    var qiscusComments = await ChatSdk.getLocalComments(roomId: widget.roomId, limit: 10);
    setState(() {
      chatRoom = qiscusChatroom;
      comments = qiscusComments;
      ChatSdk.subscribeToChatRoom(chatRoom);
      QiscusComment lastComment = chatRoom.lastComment;
      String senderEmail = lastComment?.senderEmail;

      /// if last comment !=null, means chat room doesnt have last comment yet, it is an empty chat room
      if (lastComment != null && senderEmail != _account.email) {
        ChatSdk.markCommentAsRead(chatRoom.id, lastComment.id);
      }
    });
  }

  Future<void> _getChatRoomWithMessages() async {
    var tupple = await ChatSdk.getChatRoomWithMessages(widget.roomId);
    setState(() {
      chatRoom = tupple.item1;
      comments = tupple.item2;
      ChatSdk.subscribeToChatRoom(chatRoom);

      QiscusComment lastComment = chatRoom.lastComment;
      String senderEmail = lastComment?.senderEmail;

      /// if last comment !=null, means chat room doesnt have last comment yet, it is an empty chat room
      if (lastComment != null && senderEmail != _account.email) {
        ChatSdk.markCommentAsRead(chatRoom.id, lastComment.id);
      }
      dev.log("comments: $comments");
    });
  }

  String timeFormat(DateTime dateTime) {
    return DateFormat("HH:mm").format(dateTime);
  }

  IconData getCommentState(QiscusComment comment) {
    switch (comment.state) {
      case QiscusComment.STATE_SENDING:
        return FontAwesomeIcons.hourglassHalf;
      case QiscusComment.STATE_FAILED:
        return FontAwesomeIcons.times;
      case QiscusComment.STATE_DELIVERED:
        return FontAwesomeIcons.checkDouble;
      case QiscusComment.STATE_READ:
        return FontAwesomeIcons.eye;
      case QiscusComment.STATE_ON_QISCUS:
        return FontAwesomeIcons.check;
      default:
        return FontAwesomeIcons.hourglassHalf;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 60),
        controller: scrollController,
        shrinkWrap: true,
        reverse: true,
        children: comments.map((QiscusComment comment) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Bubble(
                  alignment: widget.senderAccount.email == comment.senderEmail
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  color: widget.senderAccount.email == comment.senderEmail
                      ? Colors.lightBlueAccent
                      : Colors.white,
                  child: Text(
                    comment.message.trim(),
                    style: TextStyle(),
                  ),
                ),
                Row(
                  mainAxisAlignment: widget.senderAccount.email == comment.senderEmail
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    Text(timeFormat(comment.time.toLocal())),
                    widget.senderAccount.email == comment.senderEmail
                        ? FaIcon(getCommentState(comment))
                        : Container()
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
      bottomSheet: Row(
        children: <Widget>[
          Container(
            width: 265,
            padding: EdgeInsets.all(5),
            child: TextField(
              controller: controller,
              onChanged: (String text) {
                message = text;
              },
              textInputAction: TextInputAction.newline,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          ButtonTheme(
            minWidth: 50,
            height: 50,
            child: RaisedButton(
              color: Colors.blue,
              child: Icon(Icons.photo_library),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        height: 120,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: Text("Take picture with camera"),
                              onTap: () async {
                                File imgFile =
                                    await ImagePicker.pickImage(source: ImageSource.camera);
                                dev.log("camera path file : ${imgFile.path}", name: "sdk example");
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SendImagePreview(
                                      imgFile: imgFile,
                                      roomId: chatRoom.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text("Choose picture from gallery"),
                              onTap: () async {
                                File imgFile =
                                    await ImagePicker.pickImage(source: ImageSource.gallery);
                                dev.log("camera path file : ${imgFile.path}", name: "sdk example");
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SendImagePreview(
                                      imgFile: imgFile,
                                      roomId: chatRoom.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
          SizedBox(
            width: 5,
          ),
          ButtonTheme(
            minWidth: 50,
            height: 50,
            child: RaisedButton(
              color: Colors.blue,
              textColor: Colors.white,
              child: Icon(
                Icons.send,
                size: 25,
              ),
              onPressed: () async {
                if (message != null && message != "" && !_commentSending) {
                  _commentSending = true;
                  var comment = await ChatSdk.sendMessage(
                    roomId: widget.roomId,
                    message: message,
                    type: CommentType.TEXT,
                  );
                  _commentSending = false;
                }

                setState(() {
                  controller.text = "";
                  message = "";
                });
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    ChatSdk.unsubscribeToChatRoom(chatRoom);
    _commentReceiveSubscription.cancel();
    _chatRoomEventSubscription.cancel();
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback resumeCallBack;
  final AsyncCallback suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          await resumeCallBack();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          await suspendingCallBack();
        }
        break;
    }
  }
}
