import 'dart:convert';
import 'dart:io';

//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:notification_mangement/CommonFunctionsManager.dart';
import 'package:notification_mangement/NotificationApi.dart';
import 'package:notification_mangement/UserManager.dart';
import 'package:notification_mangement/enums.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
//int _listenerActivity = 0;

UserManager _userManager = UserManager();

CallKitParams setCallNotificationParams(String nameCallerReceived, String callerAvatarReceived,{Map<String,dynamic>? extra = null}){
  return CallKitParams(
      id: Uuid().v4(),//'ottoman3458',
      nameCaller: nameCallerReceived,
      appName: 'Callkit',
      avatar: callerAvatarReceived,
      handle: '',//Ex: +33645983524
      type: 1,
      textAccept: 'Accepter',
      textMissedCall: 'Appel manqué',
      textDecline: 'Rejeter',
      textCallback:'Rappeler',
      duration: 25000,
      extra: extra,
      android: AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#6CDBFB',
          actionColor: '#4CAF50'
      ),
      ios: IOSParams(
          iconName: 'AppIcon',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default'
      )
  );

}


//Receive message when app is in the background solution for onBackgroundMessage
@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message)async {

  await Firebase.initializeApp();

  Map<String, dynamic>? data = message.data;

  if (((data['type'] == "LIVE_CALL") || (data['type'] == "LIVE_AUTO_SEARCH_CALL")) && Platform.isAndroid){

    String? nameCaller = data['nameCaller'];
    String? callerAvatar = data['callerAvatar'];
    Map<String,dynamic> extra = {
      "whiteboardId": data['whiteboardId'],
      "tokenCallId": data['tokenCallId'],
      "callerUid": data['callerUid'],
      "isCallerNewUser": data['isCallerNewUser'],
      "notificationMode": data['type'],
      "dest": data['dest'],
      "spotDest": data['spotDest'],
    };


    var params = setCallNotificationParams(nameCaller!, callerAvatar!,extra: extra);

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  if (!Platform.isIOS) {
    if (data['type'] == "ADD_SCHEDULED_RESERVATION") {

      await NotificationApi.createScheduledNotificationChannelIsHelper(
          data['notificationId'],
          "🔔 Le SPOT avec " + data['senderPseudo'] +
              " débute maintenant !",
          "Es-tu prêt(e) ?",
          data['repeat'],
          data['scheduledDay'],
          data['scheduledHour'],
          isHelper: "true",
          notificationPayload: {
            "peerName": data['senderPseudo'],
            "peerTemporaryId": data['peerTemporaryId']
          }
      );

      await NotificationApi.createNormalNotificationBasicChannel(
        CommonFunctionsManager.createUniqueNotificationId(),
        "🎊 " + data["senderPseudo"] +
            " vient de réserver un créneau avec toi",
        "A ajouté: le " + CommonFunctionsManager.getDayTranslationInFrench(
            data["scheduledDay"]) + " entre " + data["scheduledTime"],
      );
    }

    if (data['type'] == "CANCEL_SCHEDULED_RESERVATION") {
      await NotificationApi.cancelScheduledNotification(
          int.parse(data['notificationId']));
      await NotificationApi.cancelScheduledNotification(
          int.parse(data['notificationReminderId']));
      await NotificationApi.createNormalNotificationBasicChannel(
        CommonFunctionsManager.createUniqueNotificationId(),
        data["title"],
        data["message"],
      );
    }

    if (data['type'] == "BASIC_NOTIFICATION") {
      await NotificationApi.createNormalNotificationBasicChannel(
        CommonFunctionsManager.createUniqueNotificationId(),
        data["title"],
        data["message"],
      );
    }

    if (data['type'] == "REQUIREMENTS_ERROR") {
      await NotificationApi.createNormalNotificationScheduledChannelBasic(
        NotificationId.REQUIREMENTS_ERROR,
        data["title"],
        data["message"],
      );
    }

    if (data['type'] == "REQUIREMENTS_CURRENTLY_DUE") {
      await NotificationApi.createNormalNotificationScheduledChannelBasic(
        NotificationId.REQUIREMENTS_CURRENTLY_DUE,
        data["title"],
        data["message"],
      );
    }

    if (data['type'] == "FUTURE_REQUIREMENTS_CURRENTLY_DUE") {
      await NotificationApi.createNormalNotificationScheduledChannelBasic(
        NotificationId.FUTURE_REQUIREMENTS_CURRENTLY_DUE,
        data["title"],
        data["message"],
      );
    }
  }

  if(Platform.isAndroid){
    if((message.notification != null) && (message.notification!.title != null) && (message.notification!.title!.contains("bours"))){
      await NotificationApi.createNormalNotificationBasicChannel(
        CommonFunctionsManager.createUniqueNotificationId(),
        message.notification!.title!,
        message.notification!.body!,
      );
    }
  }else{
    if((message.notification != null) && (message.notification!.title != null)){
      await NotificationApi.createNormalNotificationBasicChannel(
        CommonFunctionsManager.createUniqueNotificationId(),
        message.notification!.title!,
        message.notification!.body!,
      );
    }
  }
}

Future<dynamic> getCurrentCall() async {
  //check current call from pushkit if possible
  var calls = await FlutterCallkitIncoming.activeCalls();
  if (calls is List) {
    if (calls.isNotEmpty) {
      return calls[0];
    } else {
      return null;
    }
  }
}

Future<void> listenerEvent(BuildContext context,{bool normalMode = true, Map<String,dynamic>? extra = null}) async {
  try {
    FlutterCallkitIncoming.onEvent.listen((event) async {
      switch (event!.event) {
        case Event.ACTION_CALL_INCOMING:
        // TODO: received an incoming call
          break;
        case Event.ACTION_CALL_START:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
          break;
        case Event.ACTION_CALL_ACCEPT:
        // TODO: accepted an incoming call
        // TODO: show screen calling in Flutter
          launchCallingPage(event.body,context);
          break;
        case Event.ACTION_CALL_DECLINE:
        // TODO: declined an incoming call
        //await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
          break;
        case Event.ACTION_CALL_ENDED:
        // TODO: ended an incoming/outgoing call
          break;
        case Event.ACTION_CALL_TIMEOUT:
        // TODO: missed an incoming call
          break;
        case Event.ACTION_CALL_CALLBACK:
        // TODO: only Android - click action `Call back` from missed call notification
          break;
        default:
          break;
      /*case Event.actionCallToggleHold:
        // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
        // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
        // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
        // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
        // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
        // TODO: only iOS
          break;
        case Event.actionCallCustom:
          break;*/
      }
    });
  } on Exception catch (e) {
    print(e);
  }
}

Future<void> checkAndNavigationCallingPage(BuildContext context) async {
  var currentCall = await getCurrentCall();
  if (currentCall != null) {
    launchCallingPage(currentCall,context);
  }
}

Future<void> launchCallingPage(Map currentCall, BuildContext context) async {

  String startCallStatus = "1";
  String? p_notificationMode = currentCall["extra"]["notificationMode"];
  String? p_whiteboardId = currentCall["extra"]["whiteboardId"];

  try{
    startCallStatus = await _userManager.getValue("temporaryUsersFilesLinks", "start_call",docId: p_whiteboardId!);
  }catch(error){
    startCallStatus = '2';
  }

  if(startCallStatus != '2'){

    if (p_notificationMode == "LIVE_AUTO_SEARCH_CALL"){

      var myDialogRoute = DialogRoute(
        context: context,
        builder: (BuildContext context) {
          return Dialog(child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "Connexion en cours...",
                    textAlign: TextAlign.center
                ),
                Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child:Container(
                    child: Image.asset(
                      "images/searching.gif",
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  //TwoFlyingDots(dotsSize: 20, firstColor: Colors.blue, secondColor: Colors.yellow)
                )
              ],
            ),)
          );
        },
      );
      Navigator.of(context).push(myDialogRoute);

      try{

        String? destination = currentCall["extra"]["dest"];
        var callerUID = currentCall["extra"]["callerUid"];
        var p_tokenCallId = currentCall["extra"]["tokenCallId"];
        var isCallerNewUser = (currentCall["extra"]["isCallerNewUser"] == "true") ? true : false;


        String spotDest = currentCall["extra"]["spotDest"];
        var spotDestValues = spotDest.split("|");
        var fullSpotPathOption = spotDestValues[0];
        bool receiverIsHelper = (spotDestValues[1] == "true") ? true : false;

        if(!receiverIsHelper){
          await _userManager.updateValue("allHelpers", "live_status", LiveStatus.AWAY, docId: callerUID);
        }else{
          await _userManager.updateValue("allHelpers", "live_status", fullSpotPathOption.isEmpty ? LiveStatus.OCCUPIED : LiveStatus.AWAY);
        }


        //TODO:Update helper's info
        await _userManager.updateMultipleValues(
            "allUsers",
            {
              'whiteboard_id': p_whiteboardId,
              'calling_state': '2',
              'peer_temporary_id': callerUID! + "|" + isCallerNewUser.toString().toLowerCase(),
              'channel_name_call_id': '',
              'token_call_id': p_tokenCallId,
              'last_helper_temporary_id': receiverIsHelper ? _userManager.userId : callerUID,
              'last_role_live': receiverIsHelper ? 'helper' : 'consumer',
              'live_status':LiveStatus.OCCUPIED
            });

        await _userManager.updateValue("whiteboards", "helper_id", receiverIsHelper ? _userManager.userId : callerUID, docId: p_whiteboardId!);

        //TODO:Update caller's info
        Map paramsToBeUpdated = {
          'peer_temporary_id': _userManager.userId! + "|" + isCallerNewUser.toString().toLowerCase(),
          'last_helper_temporary_id': receiverIsHelper ? _userManager.userId : callerUID,
        };

        Map parametersUpdated = {
          "advancedMode": false,
          "docId": callerUID,
          "collectionName": "allUsers",
          "paramsToBeUpdated": json.encode(paramsToBeUpdated),
        };

        await _userManager.callCloudFunction(
            "updateUserInfo", parametersUpdated);

        List listOfNeededParams = receiverIsHelper? ["avatar_url","first_name"] : ["avatar_url","pseudo"];
        Map tmpValues = receiverIsHelper? await _userManager.getMultipleValues("allHelpers", listOfNeededParams) : await _userManager.getMultipleValues("allUsers", listOfNeededParams);
        String userAvatar = tmpValues[listOfNeededParams[0]];
        String firstName = tmpValues[listOfNeededParams[1]];

        Map<String,dynamic> temporaryData;

        if(receiverIsHelper){
          temporaryData = {
            'helper_name':firstName,
            'helper_id': _userManager.userId,
            'start_call': '2',
            'usersAvatars':FieldValue.arrayUnion([userAvatar])
          };
        }else{
          temporaryData = {
            'caller_name':firstName,
            'caller_id': _userManager.userId,
            'start_call': '2',
            'usersAvatars':FieldValue.arrayUnion([userAvatar])
          };
        }

        await _userManager.updateMultipleValues(
            "temporaryUsersFilesLinks",
            temporaryData,
            docId: p_whiteboardId
        );

        if (myDialogRoute.isActive) {
          Navigator.of(context).removeRoute(myDialogRoute);
        }

      /*  WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.popUntil((Route<dynamic> route) => route.isFirst));
        WidgetsBinding.instance.addPostFrameCallback((_) => navigatorKey.currentState!.pushReplacement(WhiteboardPageAdvancedRoute(p_whiteboardId, p_tokenCallId!, serverDestination: destination!, helperId: receiverIsHelper ? _userManager.userId! : callerUID, userId: receiverIsHelper ? callerUID : _userManager.userId,fullSpotPathOption: fullSpotPathOption, receiverIsHelper: receiverIsHelper)));
      */
      }catch(error){
        if (myDialogRoute.isActive) {
          Navigator.of(context).removeRoute(myDialogRoute);
        }
        debugPrint("DEBUG_LOG: Error while launching call page.");
      }

    }
  }

}

Future<String?> getCallState() async {
  String callingState = await _userManager.getValue("allUsers", "calling_state");
  return callingState;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  NotificationApi notificationManagement = NotificationApi();
  await notificationManagement.init();
  Stripe.publishableKey = "pk_test_51KoAXGFgbU2VtDqvLajlNXYqsHRxS56njEJ4BmIjY7tvfhHc83h43XvDffS2uoLjJsZXHDH1tjUgk84D12x5EB0d00F2FBz179";
  //Stripe.merchantIdentifier = "merchant.com.hamadoo.newapp";

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  if (Platform.isAndroid){
    final prefs = await SharedPreferences.getInstance();
    bool? appFirstInstall = await prefs.getBool("appFirstInstall");
    if (appFirstInstall == null){
      debugPrint("DEBUG_LOG STARTED A NEW INSTALLATION");
      await prefs.setBool("appFirstInstall",true);
      try{
        await FirebaseAuth.instance.signOut();
      }catch(error){

      }
    }
  }


  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(MyApp());
  Eraser.resetBadgeCountAndRemoveNotificationsFromCenter();
}

class MyApp extends StatefulWidget {

  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        /*buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],*/
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initForegroundTask();
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      debugPrint('DEBUG_LOG FCM RECEIVED SOMETHING FOREGROUND');
      if (message.data.isNotEmpty){
        Map<String, dynamic>? data = message.data;

        //User? user =  FirebaseAuth.instance.currentUser;

        if ((data['type'] == "LIVE_CALL") || (data['type'] == "LIVE_AUTO_SEARCH_CALL")){

          String? nameCaller = data['nameCaller'];
          String? callerAvatar = data['callerAvatar'];
          Map<String,dynamic> extra = {
            "whiteboardId": data['whiteboardId'],
            "tokenCallId": data['tokenCallId'],
            "callerUid": data['callerUid'],
            "isCallerNewUser": data['isCallerNewUser'],
            "notificationMode": data['type'],
            "dest": data['dest'],
            "spotDest": data['spotDest']
          };

          var params = setCallNotificationParams(nameCaller!, callerAvatar!,extra: extra);
          await FlutterCallkitIncoming.showCallkitIncoming(params);
        }

        if (!Platform.isIOS) {
          if (data['type'] == "ADD_SCHEDULED_RESERVATION"){
            await NotificationApi.createScheduledNotificationChannelIsHelper(
                data['notificationId'],
                "🔔 Le LIVE avec " + data['senderPseudo'] + " débute maintenant !",
                "Es-tu prêt(e) ?",
                data['repeat'],
                data['scheduledDay'],
                data['scheduledHour'],
                isHelper: "true",
                notificationPayload: {
                  "peerName":data['senderPseudo'],
                  "peerTemporaryId":data['peerTemporaryId']
                }
            );
            await NotificationApi.createNormalNotificationBasicChannel(
              CommonFunctionsManager.createUniqueNotificationId(),
              "🎊 " + data["senderPseudo"] + " vient de réserver un créneau avec toi",
              "A ajouté: le " + CommonFunctionsManager.getDayTranslationInFrench(data["scheduledDay"]) + " entre " + data["scheduledTime"],
            );
          }

          if (data['type'] == "CANCEL_SCHEDULED_RESERVATION"){

            await NotificationApi.cancelScheduledNotification(int.parse(data['notificationId']));
            await NotificationApi.cancelScheduledNotification(int.parse(data['notificationReminderId']));
            await NotificationApi.createNormalNotificationBasicChannel(
              CommonFunctionsManager.createUniqueNotificationId(),
              data["title"],
              data["message"],
            );
          }

          if (data['type'] == "BASIC_NOTIFICATION"){
            await NotificationApi.createNormalNotificationBasicChannel(
              CommonFunctionsManager.createUniqueNotificationId(),
              data["title"],
              data["message"],
            );
          }

          if (data['type'] == "REQUIREMENTS_ERROR"){
            await NotificationApi.createNormalNotificationScheduledChannelBasic(
              NotificationId.REQUIREMENTS_ERROR,
              data["title"],
              data["message"],
            );
          }

          if (data['type'] == "REQUIREMENTS_CURRENTLY_DUE"){
            await NotificationApi.createNormalNotificationScheduledChannelBasic(
              NotificationId.REQUIREMENTS_CURRENTLY_DUE,
              data["title"],
              data["message"],
            );
          }

          if (data['type'] == "FUTURE_REQUIREMENTS_CURRENTLY_DUE"){
            await NotificationApi.createNormalNotificationScheduledChannelBasic(
              NotificationId.FUTURE_REQUIREMENTS_CURRENTLY_DUE,
              data["title"],
              data["message"],
            );
          }


        }
      }else{
        if(Platform.isAndroid){
          if((message.notification != null) && (message.notification!.title != null) && (message.notification!.title!.contains("bours"))){
            await NotificationApi.createNormalNotificationBasicChannel(
              CommonFunctionsManager.createUniqueNotificationId(),
              message.notification!.title!,
              message.notification!.body!,
            );
          }
        }else{
          if((message.notification != null) && (message.notification!.title != null)){
            await NotificationApi.createNormalNotificationBasicChannel(
              CommonFunctionsManager.createUniqueNotificationId(),
              message.notification!.title!,
              message.notification!.body!,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isUserSignedIn = false;

    if ((FirebaseAuth.instance.currentUser != null) && (FirebaseAuth.instance.currentUser?.reload() != null)){
      isUserSignedIn = true;
    }else{
      isUserSignedIn = false;
    }

    return Provider<FirebaseFirestore>(
      create: (_) => FirebaseFirestore.instance,
      child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          home: isUserSignedIn ?
          UpgradeAlert(
              upgrader: Upgrader(
                  countryCode: "FR",
                  dialogStyle: UpgradeDialogStyle.cupertino,
                  showIgnore: false,
                  showLater: false
              ),
              child: Container(
                child: Text("User is logged."),
              )
          )
              :
          Container(
            child: Text("User has logged out."),
          )
      ),
    );
  }
}
