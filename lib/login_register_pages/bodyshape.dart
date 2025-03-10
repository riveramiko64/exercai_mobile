import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:exercai_mobile/login_register_pages/workout_level.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile_pages/profile_page.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';

class Bodyshape extends StatefulWidget {
  const Bodyshape({super.key});

  @override
  State<Bodyshape> createState() => _BodyshapeState();
}

class _BodyshapeState extends State<Bodyshape> {
  String? selectedShape;

  void selectBodyShape(String shape) {
    setState(() {
      selectedShape = shape;
    });
  }

  Future<void> saveBodyShapeToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedShape != null) {
      await FirebaseFirestore.instance.collection("Users").doc(user.email).set(
        {
          'bodyShape': selectedShape,
        },
        SetOptions(merge: true),
      );

      print("Body Shape saved to Firebase: $selectedShape");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a body shape before proceeding.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppbarSection(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "What's Your Current\n Body Shape?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildFeatureCard('Slim',
                  'You are at a normal level!\nTry the tailored plan for you\n To get fitter and healthier!',
                  'assets/Slim.png',
                  'slim'),
              const SizedBox(height: 20),
              _buildFeatureCard('Average',
                  'You may have slow metabolism,\nAnd face some potential\nHealth problems',
                  'assets/average.jpg',
                  'average'),
              const SizedBox(height: 20),
              _buildFeatureCard('Heavy',
                  'Potential risk of Obesity-\nRelated Diseases!',
                  'assets/heavy.jpg',
                  'heavy'),
              SizedBox(height: 20),
              Center(child: NextButton()),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector NextButton() {
    return GestureDetector(
      onTap: () {
        if (selectedShape != null) {
          saveBodyShapeToFirebase();
          // Navigate to the next screen
          //Navigator.push(context, MaterialPageRoute(builder: (context) => WhatisyourTargetWeight()));
          //navigateWithSlideTransition(context, WelcomeScreen(), slideRight: true);
          _showWarningDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please select a body shape before proceeding.")),
          );
        }
      },
      child: Container(
        height: 55,
        width: 150,
        decoration: BoxDecoration(
          color: AppColor.buttonPrimary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 2, color: AppColor.buttonSecondary),
          boxShadow: [
            BoxShadow(
              color: AppColor.buttonSecondary.withOpacity(0.7),
              blurRadius: 90,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Next",
            style: TextStyle(
              color: AppColor.textwhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, String imagePath, String shape) {
    // Define text colors based on body shape
    Color textColor;
    if (shape == 'slim') {
      textColor = Colors.green;
    } else if (shape == 'average') {
      textColor = Colors.orange;
    } else if (shape == 'heavy') {
      textColor = Colors.red;
    } else {
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => selectBodyShape(shape),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: selectedShape == shape ? AppColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor, // Apply color here
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 130,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.yellow.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.yellow, width: 2),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info,
                size: 100,
                color: AppColor.yellowtext,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "This app is not intended for individuals with medical conditions or physical limitations related to exercise. Please consult a healthcare professional before starting any exercise routine.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColor.textwhite,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> WelcomeScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Proceed',
                        style: TextStyle(
                          color: AppColor.textwhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}

AppBar AppbarSection(BuildContext context) {
  return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading:IconButton(onPressed: (){
        navigateWithSlideTransition(context, WhatisyourTargetWeight(), slideRight: false);
      }, icon: Icon(Icons.arrow_back,color: Colors.yellow,))
  );
}