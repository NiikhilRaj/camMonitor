import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MotionDetectionApp());
}

class MotionDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Motion Detection App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MotionDetectionScreen(),
    );
  }
}

class MotionDetectionScreen extends StatefulWidget {
  @override
  _MotionDetectionScreenState createState() => _MotionDetectionScreenState();
}

class _MotionDetectionScreenState extends State<MotionDetectionScreen> {
  final String websocketUrl = 'ws://192.168.137.39:81'; // Update with your ESP32 WebSocket server address
  final String videoUrl = 'http://192.168.137.187:4747/video';
  late WebSocketChannel channel;
  bool motionDetected = false;
  VideoPlayerController? _videoController;
  bool isPlaying = false;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    channel.stream.listen((message) {
      if (message == 'motion_detected') {
        _showNotification();
      }
    });
  }

  void _showNotification() {
    if (motionDetected) return; // Avoid duplicate notifications

    setState(() {
      motionDetected = true;
    });

    // Dismiss notification after 3 seconds
    _notificationTimer?.cancel();
    _notificationTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        motionDetected = false;
      });
    });
  }

  void _connectToCamera() {
    if (_videoController == null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse("http://192.168.137.187:4747/video"))
        ..initialize().then((_) {
          setState(() {
            isPlaying = true;
            _videoController?.play();
          });
        });
    } else {
      setState(() {
        isPlaying = true;
        _videoController?.play();
      });
    }
  }

  void _disconnectFromCamera() {
    if (_videoController != null) {
      setState(() {
        isPlaying = false;
        _videoController?.pause();
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _videoController?.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motion Detection'),
      ),
      body: Stack(
        children: [
          Center(
            child: isPlaying
                ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
                : Text('Press "Connect" to start the feed'),
          ),
          if (motionDetected)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.red,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                child: Text(
                  'Motion Detected!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _connectToCamera,
            child: Icon(Icons.play_arrow),
            heroTag: "connectButton",
            tooltip: 'Connect',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _disconnectFromCamera,
            child: Icon(Icons.stop),
            heroTag: "disconnectButton",
            tooltip: 'Disconnect',
          ),
        ],
      ),
    );
  }
}
