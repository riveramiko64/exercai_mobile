import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:exercai_mobile/exercise/exercise.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/pages/Awarding_Page.dart';
import 'package:exercai_mobile/pages/Main_Pages/resttime.dart';
import 'package:exercai_mobile/pages/arcade_mode_page.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/pages/Main_Pages/Exercises_Page.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constant.dart';
import 'dart:async';

Timer? timer;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool buttonMusic = true;

  final musicPlayer = MusicPlayerService();
  late CameraController controller;
  bool isBusy = false;
  bool poseIndicator = false;
  CameraImage? img;
  dynamic poseDetector;
  late Size size;
  dynamic _scanResults;
  int selectedCameraIndex = 1;
  bool fixingcamera = true;
  List<String> selectedInjuries = [];
  bool isMusicOn = true;
  bool isPostureIndicatorOn = true;
  bool isCameraOn = true;
  int stackRaise = 0;
  int stackCount = 0;
  bool isModalSettingOpen = false;

  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();

    buttonMusic = peopleBox.get("musicOnOf", defaultValue: true);
    cameraSwitch = peopleBox.get("cameraSwitch", defaultValue: 1);
    selectedCameraIndex = cameraSwitch;
    fronfixposition();
    initializeCamera();
    _loadSelectedInjuries();

    //CheckInjurys();

    if (Mode == "dayChallenge") {
      raise = peopleBox.get(ExerciseName) % 100;
    }
    isMusicOn = buttonMusic;
    poseIndicator = peopleBox.get("poseIndicator", defaultValue: true);
    isPostureIndicatorOn = poseIndicator;
  }

  Future<void> _loadSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInjuries = prefs.getStringList('selectedInjuries') ?? [];
    });
  }

  void SecondOutput() {
    if (ExerciseName == "plank" ||
        ExerciseName == "rightplank" ||
        ExerciseName == "leftplank") {
    } else {}
  }

  // Updated countingTimer function
  void countingTimer() {
    if (timer == null || !(timer!.isActive)) {
      startTimer();
    }
  }

  //   Formula() {
  //   for (int i = 0; i < exercises2.length; i++) {
  //     if (exercises2[i]["name"] == ExerciseName) {
  //       print("Exercise found: ${exercises2[i]}");
  //       double formula =
  //           (((exercises2[i]["MET"] as num).toDouble() * 85 * raise.toDouble()) /
  //               1000);
  //       totalCaloriesBurn = totalCaloriesBurn + formula;
  //       totalCaloriesBurnDatabase =
  //           (peopleBox.get("finalcoloriesburn",defaultValue: 0)).toDouble();
  //       double daysDatabase = (peopleBox.get("daychallenge",defaultValue: 0)).toDouble();
  //       double totaldayschallenge = daysDatabase + totalCaloriesBurn;
  //       double total = totalCaloriesBurn + totalCaloriesBurnDatabase;
  //       peopleBox.put("finalcoloriesburn", total);
  //       peopleBox.put("daychallenge", totaldayschallenge);

  //       print(peopleBox.get("finalcoloriesburn"));

  //       print(
  //         "         $ExerciseName                " + totalCaloriesBurn.toString(),
  //       );
  //       print("                         " + totalCaloriesBurn.toString());
  //       print("                         " + totalCaloriesBurn.toString());
  //       print("                         " + totalCaloriesBurn.toString());
  //       print("                         " + totalCaloriesBurn.toString());
  //     }
  //   }
  // }

  void _showSettingsModal(BuildContext context) {
    setState(() {
      isModalSettingOpen = true; // Set the flag to true when modal is opened
    });
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Mode == "Arcade"
                        ? ListTile(
                          leading: const Icon(Icons.music_note),
                          title: const Text('Music'),
                          trailing: Switch(
                            value: isMusicOn,
                            onChanged: (bool value) {
                              setState(() {
                                isMusicOn = value;
                                if (!isMusicOn) {
                                  musicOnOf = peopleBox.get(
                                    "musicOnOf",
                                    defaultValue: false,
                                  );
                                  musicPlayer.stop();
                                  peopleBox.put("musicOnOf", false);
                                } else {
                                  musicPlayer.play();
                                  peopleBox.put("musicOnOf", true);
                                }
                              });
                            },
                          ),
                        )
                        : Container(),
                    ListTile(
                      leading: const Icon(Icons.accessibility_new),
                      title: const Text('Posture Indicator'),
                      trailing: Switch(
                        value: isPostureIndicatorOn,
                        onChanged: (bool value) {
                          setState(() {
                            setState(() {
                              isPostureIndicatorOn = value;
                              poseIndicator = !poseIndicator;
                            });

                            peopleBox.put("poseIndicator", poseIndicator);
                            print(poseIndicator);
                          });
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Camera Switch to Back'),
                      trailing: Switch(
                        value: isCameraOn,
                        onChanged: (bool value) {
                          setState(() {
                            isCameraOn = value;
                            toggleCamera();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    ).whenComplete(() {
      setState(() {
        isModalSettingOpen = false;
      });

      print("Modal is closed");
    });
  }

  Formula() {
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i]["name"] == ExerciseName) {
        print("Exercise found: ${exercises[i]}");
        double formula =
            (((exercises[i]["MET"] as num).toDouble() *
                    weight *
                    raise.toDouble()) /
                1000);
        totalCaloriesBurn = totalCaloriesBurn + formula;
        totalCaloriesBurnDatabase =
            (peopleBox.get("finalcoloriesburn", defaultValue: 0)).toDouble();
        double ArcadeCaloriesDatabase =
            (peopleBox.get("arcadecoloriesburn", defaultValue: 0)).toDouble();
        double total = totalCaloriesBurnDatabase + totalCaloriesBurn.toDouble();
        double totalArcade =
            ArcadeCaloriesDatabase + totalCaloriesBurn.toDouble();
        double PoseCaloriesDatabase =
            (peopleBox.get("posecorrectionburn", defaultValue: 0)).toDouble();
        double totalPoseCorrection =
            PoseCaloriesDatabase + totalCaloriesBurn.toDouble();
        peopleBox.put("finalcoloriesburn", total);
        if (Mode == "Arcade") {
          peopleBox.put("arcadecoloriesburn", totalArcade);
        } else {
          peopleBox.put("posecorrectionburn", totalPoseCorrection);
        }

        print(
          "                " + peopleBox.get("posecorrectionburn").toString(),
        );

        print(
          "         $ExerciseName                " +
              totalCaloriesBurn.toString(),
        );
        print("                         " + totalCaloriesBurn.toString());
        print("                         " + totalCaloriesBurn.toString());
        print("                         " + totalCaloriesBurn.toString());
        print("                         " + totalCaloriesBurn.toString());
      }
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      print("Timer has finished.");
      print("Timer has finished.");
      print("Timer has finished.");
      if (!isModalSettingOpen) {
        if (seconds > 0) {
          seconds--;
        } else {
          timer?.cancel(); // Stop the timer
          print("Timer has finished.");

          warningIndicatorScreen = true;
          warningIndicatorText = "";

          if (Mode == "Arcade") {
            Formula();
            if (arcadeNumber == 11) {
              musicPlayer.stop();

              arcadeNumber = 1;
              ExerciseName = "";
              image = "";

              //dispose();
              musicPlayer1.playCongrats();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CongratsApp()),
              );
            } else {
              //Formula();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RestimeTutorial()),
              );

              arcadeNumber = arcadeNumber + 1;
            }
          } else if (Mode == "postureCorrection") {
            timer?.cancel();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Trypage()),
            );
          } else if (Mode == "dayChallenge") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Trypage()),
            );
          }

          ExerciseName = "";
          raise = 0;
        }
      } // Only decrement if modal is not open
      print("Timer has finished.");

      print("timer reduced" + seconds.toString());
    });
  }

  Future<void> initializeCamera() async {
    poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
    );

    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
    );
    await controller.initialize().then((_) {
      if (!mounted) return;
      controller.startImageStream((image) {
        if (!isBusy) {
          isBusy = true;
          img = image;
          doPoseEstimationOnFrame();
        }
      });
    });
  }

  void toggleCamera() async {
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    await controller.dispose();
    fronfixposition();
    initializeCamera();
  }

  Uint8List convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final Uint8List yPlane = image.planes[0].bytes;
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    final int uvLength = uPlane.length;
    final Uint8List uvInterleaved = Uint8List(uvLength * 2);
    for (int i = 0; i < uvLength; i++) {
      uvInterleaved[i * 2] = vPlane[i];
      uvInterleaved[i * 2 + 1] = uPlane[i];
    }

    final Uint8List nv21 = Uint8List(yPlane.length + uvInterleaved.length);
    nv21.setRange(0, yPlane.length, yPlane);
    nv21.setRange(yPlane.length, nv21.length, uvInterleaved);

    return nv21;
  }

  InputImage? getInputImage() {
    if (img == null || img?.format.group != ImageFormatGroup.yuv420)
      return null;

    final nv21Bytes = convertYUV420ToNV21(img!);
    final camera = cameras[selectedCameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    return InputImage.fromBytes(
      bytes: nv21Bytes,
      metadata: InputImageMetadata(
        size: Size(img!.width.toDouble(), img!.height.toDouble()),
        rotation:
            rotation ??
            InputImageRotation.rotation0deg, // Provide a default value
        format: InputImageFormat.nv21,
        bytesPerRow: img!.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> doPoseEstimationOnFrame() async {
    final inputImage = getInputImage();
    if (inputImage == null) return;

    final List<Pose> poses = await poseDetector.processImage(inputImage);
    _scanResults = poses;
    for (Pose pose in poses) {
      // Extract key landmarks from the detected pose

      // **Upper Body Landmarks**
      PoseLandmark rightEars = pose.landmarks[PoseLandmarkType.rightEar]!;
      PoseLandmark leftEars = pose.landmarks[PoseLandmarkType.leftEar]!;
      PoseLandmark leftShoulder =
          pose.landmarks[PoseLandmarkType.leftShoulder]!;
      PoseLandmark rightShoulder =
          pose.landmarks[PoseLandmarkType.rightShoulder]!;
      PoseLandmark leftElbow = pose.landmarks[PoseLandmarkType.leftElbow]!;
      PoseLandmark rightElbow = pose.landmarks[PoseLandmarkType.rightElbow]!;
      PoseLandmark leftWrist = pose.landmarks[PoseLandmarkType.leftWrist]!;
      PoseLandmark rightWrist = pose.landmarks[PoseLandmarkType.rightWrist]!;
      PoseLandmark head =
          pose.landmarks[PoseLandmarkType
              .rightEye]!; // Using right eye as head reference
      PoseLandmark nose = pose.landmarks[PoseLandmarkType.nose]!;
      // **Lower Body Landmarks**
      PoseLandmark leftHip = pose.landmarks[PoseLandmarkType.leftHip]!;
      PoseLandmark rightHip = pose.landmarks[PoseLandmarkType.rightHip]!;

      // **Legs Landmarks**
      PoseLandmark leftKnee = pose.landmarks[PoseLandmarkType.leftKnee]!;
      PoseLandmark rightKnee = pose.landmarks[PoseLandmarkType.rightKnee]!;
      PoseLandmark leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle]!;
      PoseLandmark rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle]!;

      // **Calculating Averages for Key Body Sections**

      // **Upper Body Averages**
      double averageShoulderX = (leftShoulder.x + rightShoulder.x) / 2;
      double averageShoulderY = (leftShoulder.y + rightShoulder.y) / 2;
      double averageElbowY = (leftElbow.y + rightElbow.y) / 2;
      double averageElbowX = (leftElbow.x + rightElbow.x) / 2;
      double averageWristY = (leftWrist.y + rightWrist.y) / 2;
      double averageWristX = (leftWrist.x + rightWrist.x) / 2;
      double averageEarsY = (leftEars.y + rightEars.y) / 2;

      // **Lower Body Averages**
      double averageHipsX = (leftHip.x + rightHip.x) / 2;
      double averageHipsY = (leftHip.y + rightHip.y) / 2;

      // **Legs Averages**
      double averageKneeY = (leftKnee.y + rightKnee.y) / 2;
      double averageKneeX = (leftKnee.x + rightKnee.x) / 2;
      double averageAnkleY = (leftAnkle.y + rightAnkle.y) / 2;
      int currentTime4 = DateTime.now().millisecondsSinceEpoch;

      if (65 > (leftEars.x - rightEars.x) &&
          (leftAnkle.y > 150 && leftAnkle.y < 1000) &&
          (rightShoulder.y > 150 && rightShoulder.y < 1000) &&
          (nose.x > 50 && nose.x < 650) &&
          (leftShoulder.x > 50 && leftShoulder.x < 650) &&
          (rightShoulder.x > 50 && rightShoulder.x < 650) &&
          (leftAnkle.x > 50 && leftAnkle.x < 650) &&
          (rightAnkle.x > 50 && rightAnkle.x < 650)) {
        if (!isModalSettingOpen) {
          Mode == "dayChallenge" || Mode == "postureCorrection"
              ? Container()
              : countingTimer();
          errorWholebody = "";

          if (ExerciseName == "squat") {
            squatExercise(
              context,
              leftHip,
              leftKnee,
              leftAnkle,
              averageShoulderX,
              averageHipsX,
              averageShoulderY,
              averageHipsY,
              rightKnee.y,
              leftKnee.y,
              rightAnkle.y,
              leftAnkle.y,
              leftHip.x,
              rightHip.x,
              leftShoulder.x,
              rightShoulder.x,
              averageKneeY,
              rightKnee.x,
              leftKnee.x,
            );
          } else if (ExerciseName == "pushup") {
            pushupExercise(
              context,
              averageWristY,
              averageShoulderY,
              averageElbowY,
              averageHipsY,
              averageKneeY,
              averageAnkleY,
            );
          } else if (ExerciseName == "jumpingjacks") {
            jumpingJacksExercise(
              averageWristY,
              averageShoulderY,
              leftAnkle.x,
              rightAnkle.x,
              leftShoulder.x,
              rightShoulder.x,
              averageHipsY,
              averageShoulderX,
              averageHipsX,
              averageAnkleY,
            );
          } else if (ExerciseName == "legraises") {
            legRaiseExercise(
              context,
              averageHipsY,
              averageKneeY,
              averageAnkleY,
              averageShoulderY,
              averageEarsY,
            );
          } else if (ExerciseName == "situp") {
            sitUpExercise(
              context,
              nose.y,
              averageShoulderY,
              averageHipsY,
              averageKneeY,
              averageAnkleY,
            );
          } else if (ExerciseName == "mountainclimbers") {
            mountainClimbersExercise(
              averageKneeY,
              averageHipsX,
              leftKnee.x,
              leftKnee.y,
              rightKnee.x,
              rightKnee.y,
              averageWristY,
              averageShoulderY,
              averageHipsY,
            );
          } else if (ExerciseName == "highknee") {
            highKneeExercise(
              leftKnee.y,
              rightKnee.y,
              averageHipsY,
              averageHipsX,
              averageShoulderX,
              averageShoulderY,
              averageAnkleY,
            );
          } else if (ExerciseName == "lunges") {
            lungesExercise(
              averageHipsY,
              averageHipsX,
              leftKnee.y,
              rightKnee.y,
              leftAnkle.y,
              rightAnkle.y,
              averageShoulderX,
              averageShoulderY,
            );
          } else if (ExerciseName == "plank") {
            normalPlankExercise(
              averageShoulderY,
              averageHipsY,
              averageAnkleY,
              leftElbow.y,
              leftKnee.y,
              rightKnee.y,
              rightShoulder.y,
              leftWrist.y,
              rightWrist.y,
              rightElbow.y,
            );
          } else if (ExerciseName == "rightplank") {
            sidePlankRightExercise(
              averageShoulderY,
              averageHipsY,
              averageAnkleY,
              rightElbow.y,
              rightKnee.y,
              leftElbow.y,
              leftShoulder.y,rightWrist.y
            );
          } else if (ExerciseName == "leftplank") {
            sidePlankLeftExercise(
              averageShoulderY,
              averageHipsY,
              averageAnkleY,
              leftElbow.y,
              leftKnee.y,
              rightElbow.y,
              rightShoulder.y,leftWrist.y
            );
          }
        }

        if (Mode == "postureCorrection" && raise == repsWants) {
          //Navigator.pop(context);
          dispose();
          fixingcamera = false;
          Formula();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CongratsApp(),
              fullscreenDialog: true,
            ),
          );
        }
      } else {
        if (ExerciseName != "") {
          if (currentTime4 - lastUpdateTime3 >= 3000) {
            if (Mode == "Arcade") {
              musicPlayer.pause();
              Future.delayed(Duration(seconds: 3), () {
                musicPlayer.resume();
              });
            }

            errorWholebody = "Show your whole Body or Move Backward!!";
            speak(errorWholebody);
            warningIndicatorScreen = false;
            lastUpdateTime3 = currentTime4;
            errorSpeed = "";
            warningIndicatorText = "";
            // Update the last update time
          }
          //musicPlayer.resume();
        }
      }

      setState(() {
        raise = raise;
      });
      ///////////////////////////////
      pose.landmarks.forEach((_, landmark) {
        final x = landmark.x;
        final y = landmark.y;
        final type = landmark.type;
      });
    }

    setState(() {
      _scanResults;
      isBusy = false;
    });
  }

  Widget buildResult() {
    if (_scanResults == null ||
        controller == null ||
        !controller.value.isInitialized) {
      return Text('');
    }

    final Size imageSize = Size(
      controller.value.previewSize!.height,
      controller.value.previewSize!.width,
    );
    CustomPainter painter = PosePainter(imageSize, _scanResults);
    return CustomPaint(painter: painter);
  }

  @override
  void dispose() {
    controller.dispose();
    poseDetector.close();
    super.dispose();
  }

  void fronfixposition() {
    if (selectedCameraIndex == 0) {
      fixingcamera = false;
      isCameraOn = !fixingcamera;
      peopleBox.put("cameraSwitch", 0);
    } else if (selectedCameraIndex == 1) {
      fixingcamera = true;
      isCameraOn = !fixingcamera;
      peopleBox.put("cameraSwitch", 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if (controller != null) {
      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            child:
                (controller.value.isInitialized)
                    ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller),
                    )
                    : Container(),
          ),
        ),
      );

      fixingcamera
          ? stackChildren.add(
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: Transform(
                alignment:
                    Alignment
                        .center, // Ensure the flip happens around the center
                transform:
                    Matrix4.identity()..scale(-1.0, 1.0), // Horizontal flip
                child: poseIndicator ? buildResult() : Container(),
              ),
            ),
          )
          : stackChildren.add(
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: poseIndicator ? buildResult() : Container(),
            ),
          );

      //output screen

      stackChildren.add(
        Positioned(
          top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height,
          child: Container(
            padding: EdgeInsets.only(bottom: 80),
            decoration:
                warningIndicatorScreen
                    ? BoxDecoration()
                    : BoxDecoration(
                      border: Border.all(width: 2, color: Colors.red),
                      color: Colors.red.withOpacity(0.1),
                    ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      PrimaryExerciseName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: AppColor.yellowtext,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          raise.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 70,
                            color: Colors.yellow,
                          ),
                        ),
                        Mode == "postureCorrection"
                            ? Text(
                              "/" + repsWants.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.yellow,
                              ),
                            )
                            : Container(),
                      ],
                    ),
                    ExerciseName == "plank" ||
                            ExerciseName == "rightplank" ||
                            ExerciseName == "leftplank"
                        ? Text(
                          "Second/s",
                          style: TextStyle(color: AppColor.yellowtext),
                        )
                        : Text(
                          "Reps Count/s",
                          style: TextStyle(color: AppColor.yellowtext),
                        ),
                    SizedBox(height: 10),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColor.textwhite,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child:
                          Mode == "dayChallenge" || Mode == "postureCorrection"
                              ? Container()
                              : Column(
                                children: [
                                  Text("Time"),
                                  Text(
                                    seconds.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: AppColor.shadow,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    largeGap,
                    largeGap,
                    largeGap,
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Container(
                        padding: EdgeInsets.only(left: 25, right: 25),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 250,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 27,
                                        decoration: BoxDecoration(
                                          color: AppColor.bottonPrimary
                                              .withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          "Exercise Feedback: ",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColor.purpletext,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      errorSpeed == ""
                                          ? Container()
                                          : Container(
                                            width: 180,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                247,
                                                247,
                                                247,
                                              ).withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              errorSpeed,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.solidtext,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),

                                      SizedBox(height: 10),
                                      errorWholebody == ""
                                          ? Container()
                                          : Container(
                                            width: 180,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                247,
                                                247,
                                                247,
                                              ).withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              errorWholebody,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.solidtext,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                      SizedBox(height: 10),
                                      warningIndicatorText == ""
                                          ? Container()
                                          : Container(
                                            width: 180,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                247,
                                                247,
                                                247,
                                              ).withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              warningIndicatorText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.solidtext,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),

                                      SizedBox(height: 10),

                                      //error indicator in exercise
                                      warningIndicatorTextExercise == ""
                                          ? Container()
                                          : Container(
                                            width: 180,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                247,
                                                247,
                                                247,
                                              ).withOpacity(0.7),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                width: 1,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              warningIndicatorTextExercise,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppColor.solidtext,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: 90,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.asset(
                                        'assets/image/$image',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    largeGap,
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return PopScope(
      //Binigyan para di mag back sa cp, alisin nalang kung sakali
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading:
              Mode == "dayChallenge" ||
                      Mode == "Arcade" ||
                      Mode == "postureCorrection"
                  ? IconButton(
                    onPressed: () {
                      if (Mode == "postureCorrection") {
                        musicPlayer2.stop();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Trypage()),
                        );
                        raise = 0;
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArcadeModePage(),
                          ),
                        );
                        raise = 0;
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  )
                  : IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Trypage()),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
          title: const Text(
            "Pose Estimation",
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          ),
          backgroundColor: AppColor.primary,
          actions: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.more_vert, color: AppColor.backgroundWhite),
                  onPressed: () {
                    setState(() {
                      stackRaise = raise;
                      stackCount = seconds;
                      raise = stackRaise;
                      seconds = stackCount;
                      print(isModalSettingOpen);

                      _showSettingsModal(context);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Container(
          margin: const EdgeInsets.only(top: 0),
          color: Colors.black,
          child: Stack(children: stackChildren),
        ),
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  PosePainter(this.absoluteImageSize, this.poses);

  final Size absoluteImageSize;
  final List<Pose> poses;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = Colors.green;

    final leftPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.yellow;

    final rightPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.blueAccent;

    final facePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = const Color.fromARGB(255, 207, 6, 207);

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(landmark.x * scaleX, landmark.y * scaleY),
          1,
          paint,
        );
      });

      void paintLine(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        Paint paintType,
      ) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
          Offset(joint1.x * scaleX, joint1.y * scaleY),
          Offset(joint2.x * scaleX, joint2.y * scaleY),
          paintType,
        );
      }

      //Draw arms
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        rightPaint,
      );

      //Draw Body
      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftHip,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightHip,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
        rightPaint,
      );

      paintLine(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        rightPaint,
      );
      //Draw legs
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        leftPaint,
      );
      paintLine(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        rightPaint,
      );
      paintLine(
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        rightPaint,
      );

      //Draw face

      paintLine(
        PoseLandmarkType.leftEyeOuter,
        PoseLandmarkType.leftEye,
        facePaint,
      );
      paintLine(
        PoseLandmarkType.leftEye,
        PoseLandmarkType.leftEyeInner,
        facePaint,
      );
      paintLine(
        PoseLandmarkType.leftEyeInner,
        PoseLandmarkType.nose,
        facePaint,
      );
      paintLine(
        PoseLandmarkType.nose,
        PoseLandmarkType.rightEyeInner,
        facePaint,
      );
      paintLine(
        PoseLandmarkType.rightEyeInner,
        PoseLandmarkType.rightEye,
        facePaint,
      );
      paintLine(
        PoseLandmarkType.rightEye,
        PoseLandmarkType.rightEyeOuter,
        facePaint,
      );
      paintLine(
        PoseLandmarkType.leftMouth,
        PoseLandmarkType.rightMouth,
        facePaint,
      );
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.poses != poses;
  }
}
