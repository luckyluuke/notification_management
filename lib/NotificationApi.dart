import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:notification_mangement/main.dart';
import 'package:notification_mangement/enums.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
//import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'UserManager.dart';

class NotificationApi{

  NotificationApi({ Function(bool)? onForceQuit = null}){
    if(onForceQuit != null){
      this.onForceQuit = onForceQuit;
    }
  }

  static const List<String> listOfDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  Function(bool)? onForceQuit;
  static final _notifications = FlutterLocalNotificationsPlugin();//AwesomeNotifications();
  StopWatchTimer? _stopWatchTimer ;
  //ValueGetter? onCallEnd(bool);

  String? displayTimeInHoursMinuteSeconds = '00:00:00';
  final User? currentUser =  FirebaseAuth.instance.currentUser;
  final CollectionReference allUsers = FirebaseFirestore.instance.collection("allUsers");
  final CollectionReference allStripeConnectAccountsCollection = FirebaseFirestore.instance.collection("allStripeConnectAccounts");
  //static int eachVerification = 0;
  UserManager _userManager = UserManager();
  int timeCheckingThresholdInSeconds = 60;
  bool showAlertMessage = false;
  String customerId = "";
  String helperConnectAccountId = "";
  HttpsCallable? prepareTransferCallable;
  bool caller_is_new = false;
  bool transferConfigLaunched = false;
  bool isTimerLaunched = false;
  List allCallsForCurrentUserDay = [];
  List allCallsForCurrentHelperDay = [];
  bool allCallsForCurrentUserDayProcessed = false;
  bool allCallsForCurrentHelperDayProcessed = false;
  String pseudoHelper = "";

  static const String darwinCreateScheduledNotificationBasicChannel = 'cat_1';
  static const String darwinCreateScheduledNotificationChannelIsHelper = 'cat_2';
  static const String darwinCreateScheduledNotificationChannelIsNotHelper = 'cat_3';

  final List<DarwinNotificationCategory> darwinNotificationCategories =
  <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinCreateScheduledNotificationBasicChannel,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          "USER_IS_READY",
          "Oui, je suis prêt(e) 👍",
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          "USER_IS_NOT_READY",
          "Je réserve pour demain 🚚",
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinCreateScheduledNotificationChannelIsHelper,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          "HELPER_IS_READY",
          "Oui, je suis prêt(e) 👍",
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          "HELPER_IS_NOT_READY",
          "J'arrive dans 5 mins 🏃",
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    ),
    DarwinNotificationCategory(
      darwinCreateScheduledNotificationChannelIsNotHelper,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          "LAUNCH_LIVE",
          "👉 APPELER ",
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];


  @pragma('vm:entry-point')
  Future<void> notificationTapBackground(NotificationResponse notification) async {
    UserManager _userManager = UserManager();

    if (NotificationId.REQUIREMENTS_ERROR == notification.id){

      /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
      WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) => HelperCertificationFormPage()
      )));*/

    }else{

      String? peerTemporaryId;
      String? peerName;

      HttpsCallable sendNotificationCallable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable('sendNotification');

      if (notification.payload != null){
        List data = notification.payload!.split("|");
        peerName = data[0];//data["peerName"];
        peerTemporaryId = data[1];//data["peerTemporaryId"];
      }

      switch(notification.actionId) {
        case "HELPER_IS_READY":
          {
            String first_name = await _userManager.getValue("allUsers", "first_name");
            await sendNotificationCallable.call(<String, dynamic>{
              "type":"BASIC_NOTIFICATION",
              "notificationId": "",
              "notificationReminderId":"",
              "receiverId":peerTemporaryId,
              "peerTemporaryId":"",
              "scheduledTime":"",
              "scheduledDay": "",
              "scheduledHour": "",
              "senderPseudo":"",
              "repeat":"",
              "title":"$first_name t\'a envoyé un message",
              "message":"J\'attend ton appel, je suis disponible 🙂",
            });
          }
          break;
        case "HELPER_IS_NOT_READY":
          {
            String first_name = await _userManager.getValue("allUsers", "first_name");
            await sendNotificationCallable.call(<String, dynamic>{
              "type":"BASIC_NOTIFICATION",
              "notificationId": "",
              "notificationReminderId":"",
              "receiverId":peerTemporaryId,
              "peerTemporaryId":"",
              "scheduledTime":"",
              "scheduledDay": "",
              "scheduledHour": "",
              "senderPseudo":"",
              "repeat":"",
              "title":"$first_name t\'a envoyé un message",
              "message":"Désolé j\'ai un peu de retard mais j\'arrive dans 5 mins 🏃",
            });
          }
          break;
        case "LAUNCH_LIVE":
          {
            int coins = await _userManager.getValue("allUsers", "coins");
            if(coins > 0){

              /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
              WidgetsBinding.instance.addPostFrameCallback((_) => AlertDialogManager.showLiveCallDialogFromNotification(navigatorKey.currentContext!));
              WidgetsBinding.instance.addPostFrameCallback((_) async => await CommonFunctionsManager.startLiveCall(navigatorKey.currentContext!, peerTemporaryId!, peerName!,"launchFromOpeningApp", ""));*/
            }
            else
            {
              //WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
              WidgetsBinding.instance.addPostFrameCallback((_) => ()
                  /*AlertDialogManager.shortDialog(
                    navigatorKey.currentContext!,
                    "Ton forfait est épuisé...",
                    contentMessage: "Le SPOT prévu avec $peerName n'a pas pu se réaliser car il semblerait que tu n'aies plus aucune pièce.  $peerName reste néanmoins disponible et t'attend pour le SPOT 🌸 ",
                  )*/
              );
            }
          }
          break;
        case "USER_IS_READY":
          {
            //Do nothing
          }
          break;
        case "USER_IS_NOT_READY":
          {
            String countryCode = await _userManager.getValue("allUsers", "countryCode");

            String currency = "eur";
            String priceId = g_europeCountriesCurrencies["FR"][2];

            if(g_africanCountriesCurrencies.keys.contains(countryCode)){
              List resultInfo = g_africanCountriesCurrencies[countryCode];
              currency = resultInfo[0];
              priceId = resultInfo[2];
            }else if(g_europeCountriesCurrencies.keys.contains(countryCode)){
              List resultInfo = g_europeCountriesCurrencies[countryCode];
              currency = resultInfo[0];
              priceId = resultInfo[2];
            }

            /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
            WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) => PaymentsPage(countryCode,currency,priceId)
            )));*/
          }
          break;
      }
    }
  }

  Future init() async {

    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        notificationCategories: darwinNotificationCategories,
        requestAlertPermission : false,
        requestSoundPermission : false,
        requestBadgePermission : false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);

    await _notifications.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    /*await _notifications.initialize(
        "resource://mipmap/ic_launcher",
        [
          NotificationChannel(
              channelKey: 'basic_channel',
              channelName: 'Basic Notifications',
              importance: NotificationImportance.High,
              channelShowBadge: true,
              channelDescription: "Basic channel description"
          ),
          NotificationChannel(
              channelKey: 'scheduled_channel',
              channelName: 'Scheduled Notifications',
              importance: NotificationImportance.Max,
              locked: true,
              channelShowBadge: false,
              enableVibration: true, //ADD RINGTONE TO ALERT USER THAT A LIVE HAS STARTED
              vibrationPattern: highVibrationPattern,
              channelDescription: "Scheduled channel description",
              playSound: true,
          ),
          NotificationChannel(
              channelKey: 'scheduled_channel_basic',
              channelName: 'Scheduled Notifications Basic',
              importance: NotificationImportance.High,
              locked: true,
              channelShowBadge: true,
              enableVibration: true,
              channelDescription: "Scheduled channel basic description"
          ),
          NotificationChannel(
              channelKey: 'basic_channel_alert_once',
              channelName: 'Basic Notifications Alert Once',
              importance: NotificationImportance.High,
              channelShowBadge: false,
              channelDescription: "Basic channel alert once description",
              onlyAlertOnce:true
          ),
        ]
    );*/

  }

  void onDidReceiveNotificationResponse(NotificationResponse notification) async {
    // display a dialog with the notification details, tap ok to go to another page

    UserManager _userManager = UserManager();

    if (NotificationId.REQUIREMENTS_ERROR == notification.id){

      /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
      WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) => HelperCertificationFormPage()
      )));*/

    }else{

      String? peerTemporaryId;
      String? peerName;

      HttpsCallable sendNotificationCallable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable('sendNotification');

      if (notification.payload != null){
        List data = notification.payload!.split("|");
        peerName = data[0];//data["peerName"];
        peerTemporaryId = data[1];//data["peerTemporaryId"];
      }

      switch(notification.actionId) {
        case "HELPER_IS_READY":
          {
            String first_name = await _userManager.getValue("allUsers", "first_name");
            await sendNotificationCallable.call(<String, dynamic>{
              "type":"BASIC_NOTIFICATION",
              "notificationId": "",
              "notificationReminderId":"",
              "receiverId":peerTemporaryId,
              "peerTemporaryId":"",
              "scheduledTime":"",
              "scheduledDay": "",
              "scheduledHour": "",
              "senderPseudo":"",
              "repeat":"",
              "title":"$first_name t\'a envoyé un message",
              "message":"J\'attend ton appel, je suis disponible 🙂",
            });
          }
          break;
        case "HELPER_IS_NOT_READY":
          {
            String first_name = await _userManager.getValue("allUsers", "first_name");
            await sendNotificationCallable.call(<String, dynamic>{
              "type":"BASIC_NOTIFICATION",
              "notificationId": "",
              "notificationReminderId":"",
              "receiverId":peerTemporaryId,
              "peerTemporaryId":"",
              "scheduledTime":"",
              "scheduledDay": "",
              "scheduledHour": "",
              "senderPseudo":"",
              "repeat":"",
              "title":"$first_name t\'a envoyé un message",
              "message":"Désolé j\'ai un peu de retard mais j\'arrive dans 5 mins 🏃",
            });
          }
          break;
        case "LAUNCH_LIVE":
          {
            int coins = await _userManager.getValue("allUsers", "coins");
            if(coins > 0){

              /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
              WidgetsBinding.instance.addPostFrameCallback((_) => AlertDialogManager.showLiveCallDialogFromNotification(navigatorKey.currentContext!));
              WidgetsBinding.instance.addPostFrameCallback((_) async => await CommonFunctionsManager.startLiveCall(navigatorKey.currentContext!, peerTemporaryId!, peerName!,"launchFromOpeningApp", ""));*/
            }
            else
            {
              /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  AlertDialogManager.shortDialog(
                    navigatorKey.currentContext!,
                    "Ton forfait est épuisé...",
                    contentMessage: "Le SPOT prévu avec $peerName n'a pas pu se réaliser car il semblerait que tu n'aies plus aucune pièce.  $peerName reste néanmoins disponible et t'attend pour le SPOT 🌸 ",
                  )
              );*/
            }
          }
          break;
        case "USER_IS_READY":
          {
            //Do nothing
          }
          break;
        case "USER_IS_NOT_READY":
          {
            String countryCode = await _userManager.getValue("allUsers", "countryCode");

            String currency = "eur";
            String priceId = g_europeCountriesCurrencies["FR"][2];

            if(g_africanCountriesCurrencies.keys.contains(countryCode)){
              List resultInfo = g_africanCountriesCurrencies[countryCode];
              currency = resultInfo[0];
              priceId = resultInfo[2];
            }else if(g_europeCountriesCurrencies.keys.contains(countryCode)){
              List resultInfo = g_europeCountriesCurrencies[countryCode];
              currency = resultInfo[0];
              priceId = resultInfo[2];
            }

            /*WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
            WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.push(MaterialPageRoute(
                builder: (context) => PaymentsPage(countryCode,currency,priceId)
            )));*/
          }
          break;
      }
    }

  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
  }

  static Future<void> createNormalNotificationBasicChannel(int notificationId, String title, String message) async {

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'basic_channel',
      'Basic Notifications',
      channelDescription: "Basic channel description",
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android:androidNotificationDetails);

    await _notifications.show(
        notificationId,
        title,
        (NotificationId.REQUIREMENTS_ERROR == notificationId ? "⛔ "
            : NotificationId.REQUIREMENTS_CURRENTLY_DUE == notificationId ? "⚠ "
            : NotificationId.FUTURE_REQUIREMENTS_CURRENTLY_DUE == notificationId ? "⚠ "
            : ""
        )+ message,
        notificationDetails
    );

  }

  static Future<void> createNormalNotificationScheduledChannelBasic(int notificationId, String title, String message) async {

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'scheduled_channel_basic',
        'Scheduled Notifications Basic',
        channelDescription: "Scheduled channel basic description",
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: false
    );

    const NotificationDetails notificationDetails = NotificationDetails(android:androidNotificationDetails);

    await _notifications.show(
        notificationId,
        title,
        (NotificationId.REQUIREMENTS_ERROR == notificationId ? "⛔ "
            : NotificationId.REQUIREMENTS_CURRENTLY_DUE == notificationId ? "⚠ "
            : NotificationId.FUTURE_REQUIREMENTS_CURRENTLY_DUE == notificationId ? "⚠ "
            : ""
        )+ message,
        notificationDetails
    );
  }

  static Future<void> createNotificationOnceOnly(int notificationId, String title, String message) async {

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'basic_channel_alert_once',
        'Basic Notifications Alert Once',
        channelDescription: 'Basic channel alert once description',
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce:true,
        channelShowBadge: false
    );
    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await _notifications.show(
        notificationId,
        title,
        message,
        notificationDetails
    );

  }

  static int getSpotNotificationDateInMilliseconds(String hour, String selectedDay){
    int scheduledSpotCheckerInMilliseconds = 0;
    var scheduledHourInt = int.parse(hour);
    var currentDate = DateTime.now();
    String formattedMonth = (currentDate.month < 10) ? "0"+currentDate.month.toString() : currentDate.month.toString();
    String  formattedDay = (currentDate.day < 10) ? "0"+currentDate.day.toString() : currentDate.day.toString();
    var date =  currentDate.year.toString() + "-" + formattedMonth + "-" + formattedDay + " " + hour + ":00:00";
    var millisecondsInOneDay = (86400 * 1000);
    int maxDays = 7;

    if(listOfDays.elementAt(currentDate.weekday - 1) == selectedDay){
      if(currentDate.hour < scheduledHourInt){
        scheduledSpotCheckerInMilliseconds = DateTime.parse(date).millisecondsSinceEpoch;
      }else{
        scheduledSpotCheckerInMilliseconds = DateTime.parse(date).millisecondsSinceEpoch + (millisecondsInOneDay * 7);
      }
    }else{
      int selectedWeekDay = listOfDays.indexOf(selectedDay);
      if((currentDate.weekday - 1) < selectedWeekDay){
        scheduledSpotCheckerInMilliseconds = DateTime.parse(date).millisecondsSinceEpoch + ((selectedWeekDay + 1) - currentDate.weekday) * millisecondsInOneDay;
      }else{
        int delta = maxDays - currentDate.weekday;
        scheduledSpotCheckerInMilliseconds = DateTime.parse(date).millisecondsSinceEpoch + (delta * millisecondsInOneDay) + ((selectedWeekDay + 1) * millisecondsInOneDay);
      }
    }

    return scheduledSpotCheckerInMilliseconds;
  }

  static Future<void> createScheduledNotificationBasicChannel(String notificationId,  String title, String message, String repeat, String day, String hour, {bool isReminder= false, String isHelper ="false", Map<String,String>? notificationPayload}) async {
    /*final Int64List highVibrationPattern = Int64List(4);
    highVibrationPattern[0] = 0;
    highVibrationPattern[1] = 1000;
    highVibrationPattern[2] = 5000;
    highVibrationPattern[3] = 2000;*/

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'scheduled_channel_basic',
        'Scheduled Notifications Basic',
        channelDescription: "Scheduled channel basic description",
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: false,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'USER_IS_READY',
            "Oui, je suis prêt(e) 👍",
            titleColor: Colors.green,
          ),
          AndroidNotificationAction(
            'USER_IS_NOT_READY',
            "Je réserve pour demain 🚚",
            titleColor: Colors.green,
          ),
        ]
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: darwinCreateScheduledNotificationBasicChannel,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android:androidNotificationDetails,
        iOS: iosNotificationDetails
    );

    var scheduledSpotInMilliseconds = getSpotNotificationDateInMilliseconds(hour,day);

    tz.TZDateTime scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, scheduledSpotInMilliseconds);

    String payloadToSend = notificationPayload!["peerName"]! + "|" + notificationPayload["peerTemporaryId"]!;

    await _notifications.zonedSchedule(
        int.parse(notificationId),
        title,
        message,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payloadToSend,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: (repeat == "true") ? DateTimeComponents.dayOfWeekAndTime : null
    );

  }

  static Future<void> createScheduledNotificationChannelIsHelper(String notificationId,  String title, String message, String repeat, String day, String hour, {bool isReminder= false, String isHelper ="false", Map<String,String>? notificationPayload}) async {
    /*final Int64List highVibrationPattern = Int64List(4);
    highVibrationPattern[0] = 0;
    highVibrationPattern[1] = 1000;
    highVibrationPattern[2] = 5000;
    highVibrationPattern[3] = 2000;*/

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: "Scheduled channel description",
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: false,
        channelShowBadge: false,
        enableVibration: true,
        //vibrationPattern: highVibrationPattern,
        playSound: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            "HELPER_IS_READY",
            "Oui, je suis prêt(e) 👍",
            titleColor: Colors.green,
          ),
          AndroidNotificationAction(
            'HELPER_IS_NOT_READY',
            "J'arrive dans 5 mins 🏃",
            titleColor: Colors.green,
          ),
        ]
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: darwinCreateScheduledNotificationChannelIsHelper,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android:androidNotificationDetails,
        iOS: iosNotificationDetails
    );

    var scheduledSpotInMilliseconds = getSpotNotificationDateInMilliseconds(hour,day);

    tz.TZDateTime scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, scheduledSpotInMilliseconds);

    String payloadToSend = notificationPayload!["peerName"]! + "|" + notificationPayload["peerTemporaryId"]!;

    await _notifications.zonedSchedule(
        int.parse(notificationId),
        title,
        message,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payloadToSend,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: (repeat == "true") ? DateTimeComponents.dayOfWeekAndTime : null
    );
  }

  static Future<void> createScheduledNotificationChannelIsNotHelper(String notificationId,  String title, String message, String repeat, String day, String hour, {bool isReminder= false, String isHelper ="false", Map<String,String>? notificationPayload}) async {
    /*final Int64List highVibrationPattern = Int64List(4);
    highVibrationPattern[0] = 0;
    highVibrationPattern[1] = 1000;
    highVibrationPattern[2] = 5000;
    highVibrationPattern[3] = 2000;*/

    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'scheduled_channel',
        'Scheduled Notifications',
        channelDescription: "Scheduled channel description",
        importance: Importance.max,
        priority: Priority.high,
        autoCancel: false,
        channelShowBadge: false,
        enableVibration: true,
        //vibrationPattern: highVibrationPattern,
        playSound: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'LAUNCH_LIVE',
            "👉 APPELER ",
            titleColor: Colors.green,
          ),
        ]
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      categoryIdentifier: darwinCreateScheduledNotificationChannelIsNotHelper,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
        android:androidNotificationDetails,
        iOS: iosNotificationDetails
    );

    var scheduledSpotInMilliseconds = getSpotNotificationDateInMilliseconds(hour,day);

    tz.TZDateTime scheduledDate = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, scheduledSpotInMilliseconds);

    String payloadToSend = notificationPayload!["peerName"]! + "|" + notificationPayload["peerTemporaryId"]!;

    await _notifications.zonedSchedule(
        int.parse(notificationId),
        title,
        message,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payloadToSend,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: (repeat == "true") ? DateTimeComponents.dayOfWeekAndTime : null
    );

  }

  static Future<void> cancelScheduledNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  static Future<void> cancelNormalNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  Future<String?> cancelTimer() async {

    if(isTimerLaunched){
      isTimerLaunched = false;

      _stopWatchTimer?.onStopTimer();
      await Future.delayed(Duration(seconds: 1));

      /*double userCoins = await CommonFunctionsManager.getUserCoins();
      if (userCoins > 0){

        final currentCoinsSpent = CommonFunctionsManager.getCoinsFromTimeSpent(_stopWatchTimer!.secondTime.value);
        double updatedThreshold = userCoins - currentCoinsSpent;

        if (updatedThreshold > 0){
          CommonFunctionsManager.updateUserCoins(updatedThreshold);
        }
        else{
          CommonFunctionsManager.updateUserCoins(0);
        }

      }else{
        CommonFunctionsManager.updateUserCoins(0);
      }*/
    }

    //eachVerification = 0;


    allCallsForCurrentUserDay = [];
    allCallsForCurrentHelperDay = [];
    allCallsForCurrentUserDayProcessed = false;
    allCallsForCurrentHelperDayProcessed = false;
    pseudoHelper = "";
    showAlertMessage = false;
    prepareTransferCallable = null;
    caller_is_new = false;
    transferConfigLaunched = false;
    isTimerLaunched = false;

    _stopWatchTimer?.dispose();
    _stopWatchTimer = null;
    onForceQuit = null;
    return displayTimeInHoursMinuteSeconds;

  }


  Future<void> dispose() async {
    await _stopWatchTimer?.dispose();
  }

  void endCallSession() async {

    if (onForceQuit != null){
      onForceQuit!(true);
    }

    /*String whiteboardId = await _userManager.getValue("allUsers", "whiteboard_id");
    List moreUsers = await _userManager.getValue("temporaryUsersFilesLinks", "moreUsers", docId: whiteboardId);

    if(moreUsers.isEmpty){
      await _userManager.updateValue("temporaryUsersFilesLinks", "end_call", true, docId: whiteboardId);
    }else{
      if (onForceQuit != null){
        onForceQuit!(true);
      }
    }*/

  }

  static Future<void> showConnectivityNotification(ConnectivityResult result) async {

    final hasInternet = result != ConnectivityResult.none;
    final message = hasInternet
        ? 'Etat: OK' //${result.toString()}
        : 'Etat: Connexion internet faible.';

    if (message == 'Etat: Connexion internet faible.')
    {
      await createNormalNotificationBasicChannel(
          NotificationId.INTERNET_CONNECTION_STATUS,
          '🌐 Connexion Internet ',
          message
      );
    }
    else{

      await cancelNormalNotification(NotificationId.INTERNET_CONNECTION_STATUS);
    }

  }

  Future<void> launchTimer(String whiteboardId, String helperId, String fullSpotPathOption, String helperName,String userName) async {

    _stopWatchTimer = StopWatchTimer(
        mode: StopWatchMode.countUp,
        onChangeRawSecond: (value) async {
          //final tmpTimeWithoutMilliseconds = value.last.rawValue;

            displayTimeInHoursMinuteSeconds = StopWatchTimer.getDisplayTime(
                _stopWatchTimer!.rawTime.value, milliSecond: false);

            if ( 0 == ((value+1) % timeCheckingThresholdInSeconds)){


              double userCoins = 60.0;//(fullSpotPathOption.isNotEmpty && (fullSpotPathOption != "custom")) ?  await CommonFunctionsManager.getSessionCoins(fullSpotPathOption) : await CommonFunctionsManager.getUserCoins();

              double updatedThreshold = userCoins - 30;
              if (updatedThreshold > 0) {
                updateLastDuration(updatedThreshold, helperId, whiteboardId,fullSpotPathOption,helperName,userName);
              }
              else {
                //(fullSpotPathOption.isNotEmpty && (fullSpotPathOption != "custom")) ? CommonFunctionsManager.updateSpotSessionCoins(0,fullSpotPathOption) : CommonFunctionsManager.updateUserCoins(0);
                endCallSession();
                return;
              }

              if (updatedThreshold < 60 && !showAlertMessage) {
                showAlertMessage = true;
                //CommonFunctionsManager.updateWhiteBoardStatus(whiteboardId);
              }
            }
          //print('DEBUG_LOG STOPWATCH RECORDS LAP TIME CURRENT VALUE WITHOUT MS: $displayTimeInHoursMinuteSeconds');
        }
    );

    _stopWatchTimer?.setPresetSecondTime(0);

    if (!isTimerLaunched){
      isTimerLaunched = true;
      _stopWatchTimer?.onStartTimer();
    }
  }

  void updateLastDuration(double lastUpdatedCoins, String helperId, String whiteboardId, String fullSpotPathOption, String helperName,String userName) async {

      //eachVerification = eachVerification + 1;
      //final timeDecomposedTemporary = displayTimeInHoursMinuteSeconds!.split(":");
      //int savedTimeInSeconds = Duration(hours: int.parse(timeDecomposedTemporary.first), minutes: int.parse(timeDecomposedTemporary.elementAt(1)), seconds: int.parse(timeDecomposedTemporary.last)).inSeconds;

      List<String> currentDate = DateTime.now().toString().split(" ");
      List<String> currentDateFirstPart = currentDate[0].split("-");
      List<String> currentDateSecondPart = currentDate[1].split(":");
      String currentYear = currentDateFirstPart[0];
      String currentMonth = currentDateFirstPart[1];
      String currentDay = currentDateFirstPart[2];
      String currentHour = currentDateSecondPart[0];
      String currentMinutes = currentDateSecondPart[1];

      //String? payload = "$currentDay|$currentMonth|$currentYear|$currentHour|$currentMinutes"; //DAY|MONTH|YEAR|HOUR|MINUTE|LIVEDURATION|PRICE

      try {
        //await CommonFunctionsManager.updateWhiteBoardLastTime(whiteboardId);
      }catch(error){
        await cancelTimer();
        return;
      }


      String currentMonthName = "December"; //CommonFunctionsManager.getMonthName(currentMonth);
      String elementToAddForCurrentDayLive = "$currentYear.$currentMonthName.days.$currentDay";

      if(!allCallsForCurrentUserDayProcessed){
        allCallsForCurrentUserDayProcessed = true;
        try{
          allCallsForCurrentUserDay = await _userManager.getValue("allFees", elementToAddForCurrentDayLive);
        }catch(error){

          await _userManager.updateMultipleValues(
              "allFees",
              {
                elementToAddForCurrentDayLive:[]
              },
              fullPath: true
          );
        }

        allCallsForCurrentUserDay.add("");

        Map neededParams = {
          "pseudo":"",
        };

        Map parameters = {
          "advancedMode":false,
          "docId":helperId,
          "collectionName":"allUsers",
          "neededParams": json.encode(neededParams),
        };

        var result = await _userManager.callCloudFunction("getUserInfo", parameters);
        pseudoHelper = result.data["pseudo"];
      }

      String? payloadUser = "$currentDay|$currentMonth|$currentYear|$currentHour|$currentMinutes|$displayTimeInHoursMinuteSeconds|$pseudoHelper";
      String? payloadHelper = "$currentDay|$currentMonth|$currentYear|$currentHour|$currentMinutes|$displayTimeInHoursMinuteSeconds|$userName";

      allCallsForCurrentUserDay[allCallsForCurrentUserDay.length-1] = payloadUser;

      await _userManager.updateMultipleValues(
          "allFees",
          {
            elementToAddForCurrentDayLive:allCallsForCurrentUserDay
          },
          fullPath: true
      );

      /*await _userManager.updateMultipleValues(
          "allUsers",
          {
            'last_duration_live':savedTimeInSeconds,
            'last_time_live':payload
          }
      );*/

      if(helperId.isNotEmpty){

        if(!allCallsForCurrentHelperDayProcessed){
          allCallsForCurrentHelperDayProcessed = true;

          try{
            allCallsForCurrentHelperDay = await _userManager.getValue("allEarnings", elementToAddForCurrentDayLive,docId: helperId);
          }catch(error){

            await _userManager.updateMultipleValues(
                "allEarnings",
                {
                  elementToAddForCurrentDayLive:[]
                },
                docId: helperId,
                fullPath: true
            );
          }

          allCallsForCurrentHelperDay.add("");
        }

        allCallsForCurrentHelperDay[allCallsForCurrentHelperDay.length-1] = payloadHelper;

        await _userManager.updateMultipleValues(
            "allEarnings",
            {
              elementToAddForCurrentDayLive:allCallsForCurrentHelperDay,
            },
            docId: helperId,
            fullPath: true
        );

        /*Map paramsToBeUpdated = {
          'last_duration_live':savedTimeInSeconds,
          'last_time_live':payload
        };

        Map parameters = {
          "advancedMode":false,
          "docId":helperId,
          "collectionName":"allUsers",
          "paramsToBeUpdated": json.encode(paramsToBeUpdated),
        };

        await _userManager.callCloudFunction("updateUserInfo", parameters);*/

      }

      //double lastUpdatedCoins = userCoins - CommonFunctionsManager.getCoinsFromTimeSpent(timeCheckingThresholdInSeconds);
      //(fullSpotPathOption.isNotEmpty && (fullSpotPathOption != "custom")) ? CommonFunctionsManager.updateSpotSessionCoins(lastUpdatedCoins,fullSpotPathOption) : CommonFunctionsManager.updateUserCoins(lastUpdatedCoins);

  }

}