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
  CameraController? controller;

  @override
  void initState() {
    super.initState();
    updateController(cameras[0]);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void updateController(CameraDescription description) {
    controller?.dispose().then((value) {
      setState(() {});
      controller = CameraController(description, ResolutionPreset.max);
      controller!.initialize().then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CameraPreview(controller!),
          ),
          CameraSelectionWidget(
            selectedCamera: controller!.description,
            onChanged: updateController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () {
          controller?.takePicture().then((value) {
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
      body: Center(
        child: Image.file(
          File(imagePath),
        ),
      ),
    );
  }
}

class CameraSelectionWidget extends StatelessWidget {
  final CameraDescription selectedCamera;
  final Function(CameraDescription) onChanged;

  const CameraSelectionWidget({Key? key, required this.selectedCamera, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> toggles = [];
    for (final CameraDescription cameraDescription in cameras) {
      toggles.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<CameraDescription>(
                  groupValue: selectedCamera,
                  value: cameraDescription,
                  onChanged: (value) {
                    onChanged(value!);
                  },
                ),
                Icon(
                  getCameraLensIcon(cameraDescription.lensDirection, context),
                ),
              ],
            )
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: toggles,
      ),
    );
  }
}

IconData getCameraLensIcon(CameraLensDirection direction, BuildContext context) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
}
