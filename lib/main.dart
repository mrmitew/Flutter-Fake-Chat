import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';

final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
final isAndroid = defaultTargetPlatform == TargetPlatform.android;

class AppTheme {
  static final ThemeData iOSTheme = new ThemeData(
    primarySwatch: Colors.orange,
    primaryColor: Colors.grey[100],
    primaryColorBrightness: Brightness.light,
  );

  static final ThemeData defaultTheme = new ThemeData(
    primarySwatch: Colors.purple,
    accentColor: Colors.orangeAccent[400],
  );

  static ThemeData get() => isIOS ? iOSTheme : defaultTheme;

  static final appBarElevation = isIOS ? 0.0 : 4.0;
}

const _name = "mrmitew";

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "Chat",
        theme: AppTheme.get(),
        home: ChatScreen(),
      );
}

class ChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _messages = <ChatMessage>[];
  var _isComposing = false;

  @override
  Widget build(BuildContext context) {
    final decoration = isIOS
        ? new BoxDecoration(
            border: new Border(
              top: new BorderSide(color: Colors.grey[200]),
            ),
          )
        : null;

    return Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          elevation: AppTheme.appBarElevation,
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              _messageHistoryBox(),
              Divider(height: 1.0),
              _composeNewMessageBox(context),
            ],
          ),
          decoration: decoration,
        ));
  }

  /*
   * History
   */

  Flexible _messageHistoryBox() => Flexible(
          child: ListView.builder(
        padding: EdgeInsets.all(8.0),
        reverse: true,
        itemBuilder: (_, int index) => _messages[index],
        itemCount: _messages.length,
      ));

  /*
   * Compose a new message
   */
  Material _composeNewMessageBox(BuildContext context) =>
      Material(color: Theme.of(context).cardColor, child: _buildTextComposer());

  Widget _buildTextComposer() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[_sendMessageField(), _sendMessageButton()],
        ),
      );

  Flexible _sendMessageField() => Flexible(
          child: TextField(
        controller: _textController,
        onSubmitted: _handleSubmitted,
        onChanged: _textFieldChanged,
        decoration: InputDecoration.collapsed(hintText: "Send a message"),
      ));

  Container _sendMessageButton() {
    final onPressedHandler =
        _isComposing ? () => _handleSubmitted(_textController.text) : null;

    var submit = isIOS
        ? CupertinoButton(child: Text("Send"), onPressed: onPressedHandler)
        : IconButton(icon: Icon(Icons.send), onPressed: onPressedHandler);

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).accentColor),
          child: submit,
        ));
  }

  void _textFieldChanged(String text) {
    setState(() {
      _isComposing = text.length > 0;
    });
  }

  /// Button press listener for submitting a new message
  void _handleSubmitted(String text) {
    _textController.clear();

    setState(() {
      _isComposing = false;
    });

    var chatMessage = ChatMessage(
        text: text,
        animationController: AnimationController(
          duration: Duration(milliseconds: 700),
          vsync: this,
        ));

    setState(() {
      _messages.insert(0, chatMessage);
    });

    chatMessage.animationController.forward();
  }

  @override
  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final AnimationController animationController;

  ChatMessage({this.text, this.animationController});

  @override
  Widget build(BuildContext context) => SizeTransition(
        sizeFactor: CurvedAnimation(
            parent: animationController, curve: Curves.fastOutSlowIn),
        axisAlignment: 0.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_avatar(), _messageColumn(context)],
          ),
        ),
      );

  Container _avatar() => Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(child: Text(_name[0].toUpperCase())),
      );

  Expanded _messageColumn(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_username(context), _message(text)],
        ),
      );

  Container _message(String text) => Container(
        margin: const EdgeInsets.only(top: 5.0),
        child: Text(text),
      );

  Text _username(BuildContext context) =>
      Text(_name, style: Theme.of(context).textTheme.subhead);
}
