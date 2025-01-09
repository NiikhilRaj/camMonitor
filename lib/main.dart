import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(SparePhoneApp());
}

class SparePhoneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MotionCameraScreen(),
    );
  }
}

class MotionCameraScreen extends StatefulWidget {
  @override
  _MotionCameraScreenState createState() => _MotionCameraScreenState();
}

class _MotionCameraScreenState extends State<MotionCameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    connectToWebSocket();
  }

  void initializeCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    await _controller?.initialize();
    setState(() {});
  }

  void connectToWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.29.16:81'));
    _channel.stream.listen((message) {
      if (message == "motion_detected") {
        startRecording();
      }
    });
  }

  void startRecording() async {
    if (!_isRecording) {
      final filePath = '/storage/emulated/0/recorded_${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _controller?.startVideoRecording();
      _isRecording = true;
      print("Recording started!");

      // Automatically stop recording after 10 seconds
      Future.delayed(Duration(seconds: 10), stopRecording);
    }
  }

  void stopRecording() async {
    if (_isRecording) {
      await _controller?.stopVideoRecording();
      _isRecording = false;
      print("Recording stopped!");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spare Phone Camera')),
      body: _controller?.value.isInitialized == true
          ? CameraPreview(_controller!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}
