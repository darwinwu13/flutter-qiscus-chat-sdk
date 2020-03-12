import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:qiscus_sdk/qiscus_sdk.dart';

class ChatPage extends StatefulWidget {
  final int roomId;
  final String roomName;

  ChatPage({
    Key key,
    @required int roomId,
    this.roomName,
  })  : this.roomId = roomId,
        super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String message;
  List<QiscusComment> comments = [];
  QiscusChatRoom chatRoom;

  @override
  void initState() {
    super.initState();
    _getChatRoomWithMessages();
  }

  Future<void> _getChatRoomWithMessages() async {
    var tupple = await ChatSdk.getChatRoomWithMessages(widget.roomId);
    setState(() {
      chatRoom = tupple.item1;
      comments = tupple.item2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
      ),
      body: ListView(
        children: [
          Container(
            height: 550,
            child: ListView(
              shrinkWrap: true,
              children: comments.map((QiscusComment comment) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Bubble(
                    child: Text(comment.message),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                width: 300,
                padding: EdgeInsets.all(5),
                child: TextField(
                  onChanged: (String text) {
                    message = text;
                  },
                  textInputAction: TextInputAction.newline,
                ),
              ),
              RaisedButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: Icon(
                  Icons.send,
                  size: 25,
                ),
                onPressed: () async {
                  var comment = await ChatSdk.sendMessage(
                    roomId: widget.roomId,
                    message: message,
                    type: CommentType.TEXT,
                  );

                  setState(() {
                    comments.add(comment);
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
