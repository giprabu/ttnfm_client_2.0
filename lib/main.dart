import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WebSocket App'),
        ),
        body: WebSocketWidget(),
      ),
    );
  }
}

class WebSocketWidget extends StatefulWidget {
  @override
  _WebSocketWidgetState createState() => _WebSocketWidgetState();
}

class _WebSocketWidgetState extends State<WebSocketWidget> {
  IOWebSocketChannel? receiveChannel;
  IOWebSocketChannel? sendChannel;
  String receivedData = 'No data received';

  @override
  void initState() {
    super.initState();
    establishWebSocketConnection();
  }

  void establishWebSocketConnection() async {
    try {
      final receive_uri = Uri.parse('ws://aws.mindfulmatrix.in:8766');
      final send_uri = Uri.parse('ws://aws.mindfulmatrix.in:8767');
      receiveChannel = IOWebSocketChannel.connect(receive_uri);
      sendChannel = IOWebSocketChannel.connect(send_uri);

      final authcode = "client";
      final message = "Connected to server";
      final image = "emptyasofnow";
      final payload = {
        "authcode": authcode,
        "message": message,
        "image": image
      };

      // Send the initial payload to the server
      receiveChannel?.sink.add(jsonEncode(payload));

      receiveChannel?.stream.listen((data) {
        // print("")
        final jsonData = jsonDecode(data);
        final authcode = jsonData['authcode'];
        final message = jsonData['message'];
        final image = jsonData['image'];
        print('Received message from the server:');
        print('Authcode: $authcode');
        print('Message: $message');
        print('Image: $image');
        setState(() {
          receivedData = message;
        });

      });
    } catch (e) {
      // Handle exceptions and errors here
      print('Error connecting to the WebSocket: $e');
    }
  }
  void sendMessage(String messageText) {
    print("Trying to send something ");
    final authcode = "feedback";
    final payload = {
      "authcode": authcode,
      "message": messageText,
      "image": "emptyasofnow"
    };
    sendChannel?.sink.add(jsonEncode(payload));
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(receivedData),
          ElevatedButton(
            onPressed: () {
              sendMessage('9'); // Call the sendMessage method
            },
            child: Text('Send Message'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    receiveChannel?.sink.close();
    super.dispose();
  }
}
