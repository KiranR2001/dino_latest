import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:dino_run/main.dart';

import 'camera_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  int i = 1;
  double standing = 0;
  int squatno = 0;
  int frame = 0;
  bool fixedAngle = false;
  bool squat = false;

  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    i++;
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);

    // printing left eye y coordinate
    for (Pose pose in poses) {
      // to access specific landmarks  [ we need hip,knee,ankle]
      final rightHipPoint = pose.landmarks[PoseLandmarkType.rightHip];
      final rightKneePoint = pose.landmarks[PoseLandmarkType.rightKnee];
      final rightAnklePoint = pose.landmarks[PoseLandmarkType.rightAnkle];

      if (rightHipPoint != null &&
          rightKneePoint != null &&
          rightAnklePoint != null) {
        // slope of hip and knee
        double slopeA = (rightHipPoint.y - rightKneePoint.y) /
            (rightHipPoint.x - rightKneePoint.x);

        double slopeB = (rightAnklePoint.y - rightKneePoint.y) /
            (rightAnklePoint.x - rightKneePoint.x);

        double angle = atan((slopeB - slopeA) / (1 + slopeA * slopeB));

        // convert angle to radian

        double degree = angle * 180 / pi;
        changer.selectedOpt == 0;
        changer.notify();

        // Store average value of standing of between 50 and 100 frames

        if (!changer.positionCapture) {
          frame++;
          print("frame no :$frame");
        }

        if (frame >= 50 && frame <= 100) {
          standing += degree;
        }

        if (frame > 100 && !changer.positionCapture) {
          changer.positionCapture = true;
          standing = standing / 50;
          print("The average degree of standing is ${standing.abs()}");
          const snackBar = SnackBar(
            content: Text('you are ready to take squat'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }

        // check squat

        if (changer.positionCapture && !squat) {
          print("CURRENT ANGLE: ${degree.abs()}");
          if ((degree.abs() - standing.abs() > 40)) {
            squat = true;
            squatno++;
            changer.selectedOpt = 1;
            changer.notify();

            // print("SQUAT");
          } else {
            changer.selectedOpt = 0;
            changer.notify();
          }
        }

        // check for standing

        if (changer.positionCapture && squat) {
          print("CURRENT ANGLE: ${degree.abs()}");
          if ((degree.abs() - changer.poseStanding.abs() < 20)) {
            squat = false;
            // print("STAND");
          }
        }

        print("No of squats : $squatno");
      }
    }

    //##
    // print(leftEyeY);
    // changer.selectedOpt == 0;
    // changer.notify();

    // if (!up) {
    //   if (leftEyeY != null) {
    //     if (leftEyeY > 500) {
    //       up = true;
    //       changer.selectedOpt = 1;
    //       changer.notify();
    //     } else {
    //       changer.selectedOpt = 0;
    //       changer.notify();
    //     }
    //   }
    // }

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
