import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/auth/auth.dart';
import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/exercise_posture/exerciseposturepage1.dart';
import 'package:exercai_mobile/food_nutrition/nutrients_show_screen.dart';
import 'package:exercai_mobile/food_nutrition/nutrition_calculator_firebase.dart';
import 'package:exercai_mobile/intro_pages/intro3.dart';
import 'package:exercai_mobile/intro_pages/openingpage.dart';
import 'package:exercai_mobile/local_notification/reminder_settings.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:exercai_mobile/login_register_pages/bodyshape.dart';
import 'package:exercai_mobile/login_register_pages/createaccount.dart';
import 'package:exercai_mobile/login_register_pages/date_of_birth.dart';
import 'package:exercai_mobile/login_register_pages/gender_choose.dart';
import 'package:exercai_mobile/login_register_pages/height_choose.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:exercai_mobile/login_register_pages/nutriActivitylevel.dart';
import 'package:exercai_mobile/login_register_pages/weight_choose.dart';
import 'package:exercai_mobile/login_register_pages/workout_level.dart';
import 'package:exercai_mobile/pages/Main_Pages/resttime.dart';
import 'package:exercai_mobile/pages/backup/BackupTrypage.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/profile_pages/bmi_settings.dart';
import 'package:exercai_mobile/profile_pages/profile_page.dart';
import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/login_register_pages/welcome.dart';
import 'package:exercai_mobile/progress_tracking/progress_tracking..dart';
import 'package:exercai_mobile/reset_password/forgot_pw_page.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/download_button_exercises_firebase.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/exercise_download_firebase.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/show_with_reps_kcals/filter_reps_kcal.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/device_download_gif.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'login_register_pages/mainlandingpage.dart';
import 'auth/login_or_register.dart';
import 'workout_complete/workoutcomplete.dart';
import 'local_notification/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local_notification/notification_service.dart';
import 'package:camera/camera.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exercai_mobile/services/my_firebase_messaging_service.dart';
import 'pages/repsCounter.dart';

late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // This should be called only once
  // ✅ Initialize Firebase Messaging
  MyFirebaseMessagingService messagingService = MyFirebaseMessagingService();
  await messagingService.setupFirebaseMessaging();
  await Permission.contacts.status; // Ensures permission handler is initialized
  await Hive.initFlutter();
  await Hive.openBox("Box");
  cameras = await availableCameras(); // Initialize cameras
  await Hive.openBox('reminders'); // Open Hive box for storing reminders
  FirebaseFirestore.instance.settings = Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /*@override
  void initState() {
    super.initState();
    fetchAndStoreBodyweightExercises(); // Calls only if Firestore is empty
  }*/

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observe app lifecycle
    // ✅ Move notification initialization here
    NotiService().initNotification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // App moved to background, check exercise completion
      bool allCompleted = await areAllExercisesCompleted();
      if (!allCompleted) {
        _startReminderNotifications();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came back to foreground, cancel reminders
      _cancelReminderNotifications();
    }
  }

  Future<bool> areAllExercisesCompleted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    List<String> targetBodyParts = [
      'back',
      'chest',
      'cardio',
      'lower arms',
      'lower legs',
      'neck',
      'shoulders',
      'upper arms',
      'upper legs',
      'waist',
    ];

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.email)
            .collection('UserExercises')
            .where('bodyPart', whereIn: targetBodyParts)
            .get();

    return snapshot.docs.every((doc) => doc['completed'] == true);
  }

  void _startReminderNotifications() async {
    await NotiService().scheduleRepeatingNotification(
      id: 1001,
      title: "Come Back to Finish Your Exercise!",
      body: "You're making great progress! Get back to your workout now. 💪",
      intervalSeconds: 3600,
    );
  }

  void _cancelReminderNotifications() async {
    await NotiService().cancelNotification(1001);
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_token');
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        bool isLoggedIn = snapshot.data ?? false;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          //home: AuthPage(),
          home: Createaccount(),
          //home: ButtonDownloadExercises(),
          //home :DownloadGifsScreen(),

          routes: {
            //'/login_register_page': (context) => LoginOrRegister(),
            '/home_page': (context) => MainLandingPage(),
            '/profile_page': (context) => ProfilePage(),
            '/progress_tracking': (context) => ProgressTrackingScreen(),
            '/bmi_settings': (context) => BMIEditProfilePage(),
            '/nutrition': (context) => NutritionCalculatorFirebase(),
            '/reminder': (context) => ReminderSettings(),
          },
        );
      },
    );
  }
}

class AppColor {
  // **Newly Added Colors**
  static const Color backgroundWhite = Colors.white; // White background
  static const Color primaryNavy = Color(0xFF1976D2); // Navy Blue primary color
  static const Color accentTeal = Color(0xFF26A69A); // Soft teal accent color
  static const Color textCharcoal = Color(0xFF424242); // Charcoal Grey for text
  static const Color textLightGrey = Color(0xFFB0BEC5); // Light grey for secondary text

  //can be used for different pages
  // **Existing Colors**
  static const Color bottonPrimary = Color.fromARGB(255, 51, 51, 51);
  static const Color bottonSecondary = Color.fromARGB(255, 146, 146, 146);

  //Different Violet
  static const Color primary = Color(0xFF9575CD);
  static const Color lightPrimary = Color(0xFFa388d4);
  static const Color morelightPrimary = Color(0xFFb29adb);
  static const Color superlightPrimary = Color(0xFFc0ade1);
  static const Color solidPrimary = Color(0xFF744abd);
  static const Color moresolidPrimary = Color(0xFF6a41b3);
  static const Color supersolidPrimary = Color(0xFF894af8);


  static const Color shadow = Color(0xFF5E35B1);
  static const Color solidtext = Color.fromARGB(255, 52, 28, 102);
  static const Color buttonPrimary = Color.fromARGB(255, 51, 51, 51);
  static const Color buttonSecondary = Color.fromARGB(255, 146, 146, 146);
  static const Color textwhite = Color.fromARGB(255, 219, 219, 219);
  static const Color yellowtext = Color.fromARGB(255, 226, 241, 99);
  static const Color purpletext = Color.fromARGB(255, 179, 160, 255);
  static const Color backgroundgrey = Color.fromARGB(255, 19, 19, 19);
}

