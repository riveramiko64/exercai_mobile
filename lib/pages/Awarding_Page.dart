import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/pages/Main_Pages/Exercises_Page.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';

class CongratsApp extends StatelessWidget {
  const CongratsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColor.backgroundgrey,
        body: Center(child: CongratulationsCard()),
      ),
    );
  }
}

class CongratulationsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Image.asset("assets/image/trophy.webp"),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30),
            child: Column(
              children: [
                Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textwhite,
                  ),
                ),
                SizedBox(height: 10),
                if (Mode == "dayChallenge")
                  Text(
                    'You have completed the 100 $ExerciseName in 30 Days Challenge. Your total calories burned: $totalCaloriesBurn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textwhite),
                  )
                else if (Mode == "Arcade")
                  Text(
                    "You have completed the arcade exercise. Your total calories burned: $totalCaloriesBurn.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textwhite),
                  )
                else if (Mode == "postureCorrection")
                  Text(
                    "You have Completed the Pose Estimation Exercise.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textwhite),
                  ),
              ],
            ),
          ),
          SizedBox(height: 50),
          GestureDetector(
            onDoubleTap: () {
              totalCaloriesBurn = 0;
              if (Mode == "postureCorrection") {
                raise = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Trypage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainLandingPage()),
                );
              }
            },
            child: Container(
              height: 60,
              width: 220,
              decoration: BoxDecoration(
                color: AppColor.bottonPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text("Finish", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          smallGap,
          Mode == "dayChallenge"
              ? GestureDetector(
                onDoubleTap: () {
                  totalCaloriesBurn = 0;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                child: Container(
                  height: 60,
                  width: 220,
                  decoration: BoxDecoration(
                    color: AppColor.bottonPrimary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
              : Container(),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
