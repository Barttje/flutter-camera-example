import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraApp(),
    ),
  );
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(controller),
            ),
            CameraFlashWidget(
              cameraController: controller,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () {
          controller.takePicture().then((value) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageDisplayWidget(
                  imagePath: value.path,
                ),
              ),
            );
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class ImageDisplayWidget extends StatelessWidget {
  final String imagePath;

  const ImageDisplayWidget({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}

class CameraFlashWidget extends StatefulWidget {
  final CameraController cameraController;

  const CameraFlashWidget({Key? key, required this.cameraController}) : super(key: key);

  @override
  State<CameraFlashWidget> createState() => _CameraFlashWidgetState();
}

class _CameraFlashWidgetState extends State<CameraFlashWidget> {
  FlashMode flashMode = FlashMode.off;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(onPressed: () {
                setState(() {
                  if (flashMode == FlashMode.off) {
                    widget.cameraController.setFlashMode(FlashMode.always);
                    flashMode = FlashMode.always;
                  } else {
                    widget.cameraController.setFlashMode(FlashMode.off);
                    flashMode = FlashMode.off;
                  }
                });
              }, child: flashMode == FlashMode.off ? const Icon(Icons.flashlight_off) : const Icon(Icons.flashlight_on)),
            ),
          ],
        ),
      ],
    );
  }
}