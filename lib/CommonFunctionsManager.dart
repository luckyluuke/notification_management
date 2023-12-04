

import 'dart:async';
import 'dart:convert';

//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
//import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notification_mangement/flying_dots_animation.dart';
//import 'package:notification_mangement/AlertDialogManager.dart';
import 'package:notification_mangement/NotificationApi.dart';
import 'package:notification_mangement/UserManager.dart';
import 'package:notification_mangement/enums.dart';
//import 'package:notification_mangement/whiteboard_features/signaling.dart';
//import 'package:notification_mangement/whiteboard_features/whiteboard_advanced_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CommonFunctionsManager{
  static var postUrl = "https://fcm.googleapis.com/fcm/send";
  static UserManager _userManager = UserManager();
  static CollectionReference emailCollection = FirebaseFirestore.instance.collection("email_collection");

  static Future<bool> checkWhiteBoardId(String id) async {

    HttpsCallable callable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable("getResultWhere");
    var result = await callable.call(
        {
          'limit':1,
          'collectionName':'whiteboards',
          'comparedField':'whiteboardId',
          'comparisonSign': '==',
          'toValue':id
        }
    );

    //final listOfPseudos = result.data!;
    final canUseWhiteBoard = (result.data == null ? true : false);

    return canUseWhiteBoard;
  }

  static Future<bool> startCustomLiveCall(BuildContext context) async {
    var createdTime = DateTime.now().microsecondsSinceEpoch;
    String whiteboardId = "testCustomWhiteboard";
    List<dynamic> sharedFiles = [];
    /*final databaseReference = FirebaseDatabase.instanceFor(app: FirebaseDatabase.instance.app, databaseURL: "https://hamadoo-3c55c-default-rtdb.europe-west1.firebasedatabase.app").ref();
    databaseReference.child(whiteboardId).set({
      'created': createdTime,
      'whiteboardId': whiteboardId,
      'caller_id': _userManager.userId,
    });*/

      await _userManager.updateMultipleValues(
          "customWhiteboards",
          {
            'created': createdTime,
            'whiteboardId': whiteboardId,
            'caller_id': _userManager.userId,
          },
          docId: whiteboardId
      );

    await _userManager.updateMultipleValues(
        "customFiles",
        {
          'created': createdTime,
          'consumer_is_doing_something': false,
          'helper_is_doing_something': false,
          'imageURL': '',
          'end_call': false,
          'caller_id': _userManager.userId,
          'start_call': '1',
          'sharedfiles': sharedFiles,
          'change_video_mode': false,
          'live_nearly_closed': false,
          'appIsInMaintenance': false,
        },
        docId: whiteboardId
    );

    return true;
  }

  static Future<bool> startLiveCall(BuildContext context, String userId, String username, String searchBarInput, String token,{ String searchInputExtra = "", String fullSpotPathOption = "", bool spotTriggeredByHelper = false, String globalUserCountryCode = ""}) async {

    var micIsGranted = await Permission.microphone.status.isGranted;
    var camIsGranted = await Permission.camera.status.isGranted;
    var notificationIsGranted = await Permission.notification.status.isGranted;

    if(!micIsGranted && !camIsGranted && !notificationIsGranted){

      //AlertDialogManager.shortDialog(context, "Vous devez autoriser l'accès aux notifications, au microphone et à la caméra pour que l'application fonctionne correctement.", permissions: [true,true,true], titleColor: Colors.grey);
      return false;
    }else if(!notificationIsGranted){
      //AlertDialogManager.shortDialog(context, "Vous devez autoriser l'accès aux notifications pour que l'application fonctionne correctement.", permissions: [false,false,true],titleColor: Colors.grey,forceAction: false);
      return false;
    }else if(!micIsGranted){
      //AlertDialogManager.shortDialog(context, "Vous devez autoriser l'accès au microphone pour que l'application fonctionne correctement.", permissions: [true,false,false],titleColor: Colors.grey,forceAction: false);
      return false;
    }else if(!camIsGranted){
      //AlertDialogManager.shortDialog(context, "Vous devez autoriser l'accès à la caméra pour que l'application fonctionne correctement.", permissions: [false,true,false],titleColor: Colors.grey,forceAction: false);
      return false;
    }else{
      //Calling process starting below
      User? currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.reload();
      if(currentUser != null)
      {
        currentUser = FirebaseAuth.instance.currentUser;

        if(!currentUser!.emailVerified && (currentUser.phoneNumber == null)){
          print("Error: l'utilisateur n'est pas vérifié");
          //AlertDialogManager.showMailVerificationDialog(context, currentUser.email!);
          currentUser.sendEmailVerification();
          return false;
        }

      }else{
        print("Error: l'utilisateur n'existe pas.");
        return false;
      }

      String callee_uid = userId;
      int callee_status = 0;

      if(!spotTriggeredByHelper){
        if(searchInputExtra.isEmpty){

          Map neededParams = {
            "live_status":"",
          };

          Map parameters = {
            "advancedMode":false,
            "docId":callee_uid,
            "collectionName":"allHelpers",
            "neededParams": json.encode(neededParams),
          };

          var result = await _userManager.callCloudFunction("getUserInfo", parameters);
          callee_status = result.data["live_status"];
        }
      }else{
        Map neededParams = {
          "live_status":"",
        };

        Map parameters = {
          "advancedMode":false,
          "docId":callee_uid,
          "collectionName":"allUsers",
          "neededParams": json.encode(neededParams),
        };

        var result = await _userManager.callCloudFunction("getUserInfo", parameters);
        callee_status = result.data["live_status"];
      }

      if (currentUser!.uid != callee_uid)
      {
        if((callee_status == LiveStatus.AVAILABLE) && (token != "BOT_GENERATED"))
        {
          //bool userAccountState = false; //TO BE USED WHEN ADDING RECURRING PAYMENTS
          String? nameCaller = "";
          String? callerAvatar = "";
          int callerCoins = 0;
          bool isNewUser = false;

          List listOfNeededParams = ["user_account_state","pseudo","avatar_url","coins","is_new_user","first_name"];
          Map tmpValues = await _userManager.getMultipleValues("allUsers", listOfNeededParams);


          //userAccountState = tmpValues[listOfNeededParams[0]];
          nameCaller = spotTriggeredByHelper ? tmpValues[listOfNeededParams[5]] : tmpValues[listOfNeededParams[1]];
          callerAvatar = tmpValues[listOfNeededParams[2]];
          callerCoins = tmpValues[listOfNeededParams[3]];
          isNewUser = tmpValues[listOfNeededParams[4]];

          if((callerCoins > 0) || fullSpotPathOption.isNotEmpty)
          {

            var connectivityResult = await (Connectivity().checkConnectivity());
            if (connectivityResult != ConnectivityResult.none) {

              String serverDestination =  await _userManager.getValue("allServers", "info",docId: "1");

              bool whiteboardStatus = false;
              String? whiteboardId = null;
              while (!whiteboardStatus) {
                whiteboardId = Uuid().v1();
                whiteboardStatus = await checkWhiteBoardId(whiteboardId);
              }

              try {

                List<dynamic> sharedFiles = [];

                var createdTime = DateTime.now().microsecondsSinceEpoch;

                HttpsCallable initCallActivityCallable = await FirebaseFunctions
                    .instanceFor(
                    app: FirebaseFunctions.instance.app, region: "europe-west1")
                    .httpsCallable('initCallActivity');

                //TODO:Get task id
                var resp = await initCallActivityCallable.call(<String, dynamic>{
                  "whiteboardId": whiteboardId,
                });

                String taskId = resp.data["taskId"];

                await _userManager.updateMultipleValues(
                    "allUsers",
                    {
                      'whiteboard_id': whiteboardId,
                      'live_status': LiveStatus.OCCUPIED,
                      'peer_temporary_id': userId + "|" + isNewUser.toString().toLowerCase(),
                      'channel_name_call_id': '',
                      //'token_call_id': tokenCallId,
                      'last_helper_temporary_id': spotTriggeredByHelper? _userManager.userId : callee_uid,
                      'last_role_live': spotTriggeredByHelper? "helper" :'consumer',
                    });

                if (whiteboardStatus) {
                  await _userManager.updateMultipleValues(
                      "whiteboards",
                      {
                        'created': createdTime,
                        'lastUpdated': createdTime,
                        'whiteboardId': whiteboardId!,
                        //'tempToken': tokenCallId,
                        'helper_id': spotTriggeredByHelper ? _userManager.userId : callee_uid,
                        'caller_id': spotTriggeredByHelper ? callee_uid : _userManager.userId,
                      },
                      docId: whiteboardId
                  );
                }

                await _userManager.updateMultipleValues(
                    "status",
                    {
                      'created': createdTime,
                      'updated': createdTime,
                      'whiteboardId': whiteboardId!,
                    },
                    docId: whiteboardId
                );

                await _userManager.updateMultipleValues(
                    "temporaryUsersFilesLinks",
                    {
                      'created': createdTime,
                      'updated': createdTime,
                      'taskId': taskId,
                      'isBotChecker':"",
                      'consumer_is_doing_something': false,
                      'helper_is_doing_something': false,
                      'imageURL': '',
                      'end_call': false,
                      'helper_id': spotTriggeredByHelper ? _userManager.userId : callee_uid,
                      'caller_id': spotTriggeredByHelper ? callee_uid : _userManager.userId,
                      'helper_name':spotTriggeredByHelper ? nameCaller : username,
                      'caller_name':spotTriggeredByHelper ? username : nameCaller,
                      'start_call': '1',
                      'moreUsers':[],
                      'swapUserId':'',
                      'sharedfiles': sharedFiles,
                      'isSharing':'',
                      'usersAvatars':[callerAvatar],
                      'change_video_mode': false,
                      'live_nearly_closed': "",
                      'appIsInMaintenance': false,
                      "dest":serverDestination
                    },
                    docId: whiteboardId!
                );

                /*Navigator.push(context, WhiteboardPageAdvancedRoute(
                    whiteboardId,
                    whiteboardId,
                    serverDestination: serverDestination,
                    userId: spotTriggeredByHelper ? callee_uid : _userManager.userId!,
                    helperId: spotTriggeredByHelper ? _userManager.userId! : callee_uid,
                    callerAvatar: callerAvatar,
                    isNewUser: isNewUser.toString(),
                    pseudo: nameCaller,
                    searchInput: searchInputExtra,
                    enableAutoResearch: searchInputExtra.isNotEmpty ? true : false,
                    globalUserCountryCode: globalUserCountryCode.isNotEmpty ? globalUserCountryCode : "",
                    taskId: taskId,
                    fullSpotPathOption:fullSpotPathOption,
                    receiverIsHelper:  spotTriggeredByHelper ? false : true
                ));*/

                return true;

              }catch(error){
                try {
                  await endLiveCall(whiteboardId!, callee_uid);
                }catch(otherError){
                  debugPrint("DEBUG_LOG: Failed to end Live Call.");
                }
                return false;
              }

            }
            else
            {
              Timer t = Timer(const Duration(seconds: 2), (){
                Navigator.of(context).pop(true);
              });

              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)
                      ),
                      title: Text("🌐 Connexion internet faible.",
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }
              ).then((value) => t.cancel());

              return false;
            }

          }else{

            showDialog(
                context: context,
                builder: (context) {

                  bool openingPaymentsPage = false;

                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    ),
                    title:
                    Row(

                      children: [
                        Expanded(
                          child: Wrap(
                            children: [
                              Text("Oups! Ton forfait est ",
                                style: GoogleFonts.inter(
                                  color: Colors.orange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(" épuisé",
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(".",
                                style: GoogleFonts.inter(
                                  color: Colors.orange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          child: Image.asset(
                            "images/zero_coins.png",
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        StatefulBuilder(
                            builder: (context,refresher) {
                              return InkWell(
                                onTap: () async {

                                  refresher((){
                                    openingPaymentsPage = true;
                                  });

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

                                  Navigator.pop(context);
                                  /*Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => PaymentsPage(countryCode,currency,priceId)
                                  )).then((value) => refresher((){
                                    openingPaymentsPage = false;
                                  })
                                  );*/
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 4,
                                            offset: Offset(0,3)
                                        ),
                                      ]
                                  ),
                                  child:
                                  openingPaymentsPage ?
                                  TwoFlyingDots(dotsSize: 20, firstColor: Colors.blue, secondColor: Colors.yellow)
                                      :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("👉 "),
                                      Flexible(
                                        child: Text(
                                            "Changer de forfait",
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        )
                      ],
                    ),
                  );
                }
            );

            return false;
          }
        }
        else
        {

          var textEndMessage = "Réessaies plus tard !";

          if (searchBarInput.isEmpty){
            textEndMessage = "Utilises la barre de recherche pour trouver une solution !";
          }

          if ((callee_status != LiveStatus.AWAY) && (token != "BOT_GENERATED") && !spotTriggeredByHelper){

            Query? temporaryUsersFilesLinks = FirebaseFirestore.instance.collection("temporaryUsersFilesLinks");
            var temporaryUserFilesLinks = await temporaryUsersFilesLinks.where("helper_id", isEqualTo: userId).limit(1).get();


            if(temporaryUserFilesLinks.docs.isNotEmpty){

              List moreUsersList = temporaryUserFilesLinks.docs.first.get("moreUsers");

              if (moreUsersList.length < 2){
                var currentWhiteboardId = temporaryUserFilesLinks.docs.first.id;
                var serverDestination = temporaryUserFilesLinks.docs.first.get("dest");

                String avatarUrl = "";
                bool isNewUser = false;
                String nameCaller = "";

                List listOfNeededParams = ["avatar_url","is_new_user","pseudo"];
                Map tmpValues = await _userManager.getMultipleValues("allUsers", listOfNeededParams);


                avatarUrl = tmpValues[listOfNeededParams[0]];
                isNewUser = tmpValues[listOfNeededParams[1]];
                nameCaller = tmpValues[listOfNeededParams[2]];

                //String serverDestination =  await _userManager.getValue("allServers", "info",docId: "1");

                await _userManager.updateMultipleValues(
                    "allUsers",
                    {
                      'whiteboard_id': currentWhiteboardId,
                      'live_status': LiveStatus.OCCUPIED,
                      'peer_temporary_id': userId + "|" +
                          isNewUser.toString().toLowerCase(),
                      'channel_name_call_id': '',
                      //'token_call_id': tokenCallId,
                      'last_helper_temporary_id': callee_uid,
                      'last_role_live': 'consumer',
                    });

                /*Navigator.push(context, WhiteboardPageAdvancedRoute(
                    currentWhiteboardId,
                    currentWhiteboardId,
                    serverDestination: serverDestination,
                    userId: _userManager.userId!,
                    helperId: callee_uid,
                    callerAvatar: avatarUrl,
                    isNewUser: isNewUser.toString(),
                    pseudo: nameCaller,
                    searchInput: searchInputExtra,
                    enableAutoResearch: false,
                    isMoreUser: true
                ));*/
              }else{
                showLiveIsFullDialog(context,username,textEndMessage);
              }

            }else{
              showLiveIsFullDialog(context,username,textEndMessage);
            }

          }else {

            Timer? t;

            t = Timer(const Duration(seconds: 5), (){
              Navigator.of(context).pop(true);
            });

            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)
                    ),
                    title:
                    RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(
                                text: (callee_status == LiveStatus.AWAY) ? "$username est en PAUSE et reviendra bientôt. " : (((token == "BOT_GENERATED") && (callee_status == LiveStatus.OCCUPIED)) ? "Ce LIVE est déjà rempli. " : "Ce compte est en cours de vérification. " + username + " est donc momentanément indisponible. "),
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: "$textEndMessage",
                                style: GoogleFonts.inter(
                                  color: Colors.orange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ]
                        )
                    ),
                  );
                }
            ).then((value) {
              if (searchBarInput.isNotEmpty){
                t!.cancel();
              }
            });

          }

          return false;
        }
      }
      else {
        Timer t = Timer(const Duration(seconds: 2), (){
          Navigator.of(context).pop(true);
        });

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)
                ),
                title: Text("Tu ne peux pas te contacter toi-même.",
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
        ).then((value) => t.cancel());
        return false;
      }
      return true;
    }

  }

  static void showLiveIsFullDialog(context, username, textEndMessage){
    Timer? t;

    t = Timer(const Duration(seconds: 5), (){
      Navigator.of(context).pop(true);
    });

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
            ),
            title:
            RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Le nombre de personnes sur ce LIVE a atteint son maximum. $username ne peut pas t'aider pour le moment. ",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: "$textEndMessage",
                        style: GoogleFonts.inter(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ]
                )
            ),
          );
        }
    ).then((value) {
      t!.cancel();
    });
  }

  static Future<void> endLiveCall(String whiteboardId, String helperId) async {

    await _userManager.updateMultipleValues(
      "allUsers",
      {
        'calling_state': '0',
        'live_status': LiveStatus.AVAILABLE,
        'whiteboard_id':'',
        'token_call_id':'',
        'channel_name_call_id':'',
        'peer_temporary_id':'',
        'last_duration_live':0,
        'last_role_live':''
      }
    );

    /*Map paramsToBeUpdated = {
      "live_status":LiveStatus.AVAILABLE,
    };

    Map parametersUpdated = {
      "advancedMode":false,
      "docId":helperId,
      "collectionName":"allHelpers",
      "paramsToBeUpdated": json.encode(paramsToBeUpdated),
    };

    _userManager.callCloudFunction("updateUserInfo", parametersUpdated);*/

    /*Map otherParamsToBeUpdated = {
      'calling_state': '0',
      'whiteboard_id':'',
      'peer_temporary_id':'',
      'channel_name_call_id':'',
      'token_call_id':''
    };

    Map otherParametersUpdated = {
      "advancedMode":false,
      "docId":helperId,
      "collectionName":"allUsers",
      "paramsToBeUpdated": json.encode(otherParamsToBeUpdated),
    };

    _userManager.callCloudFunction("updateUserInfo", otherParametersUpdated);*/

    final CollectionReference allWhiteBoards = FirebaseFirestore.instance.collection("whiteboards");
    final CollectionReference allTemporaryFiles = FirebaseFirestore.instance.collection("temporaryUsersFilesLinks");
    final CollectionReference status = FirebaseFirestore.instance.collection("status");

    //var allWhiteBoardsTest = await FirebaseFirestore.instance.collection("whiteboards").doc("tata").get();


    allWhiteBoards.doc(whiteboardId).delete();
    allTemporaryFiles.doc(whiteboardId).delete();
    status.doc(whiteboardId).delete();
  }


    static Future<void> subscribeToUser(String userId, String username) async {

    Map paramsToBeUpdated = {
      "subscribers": {
        "mode": "increment",
        "value": 1
      }
    };

    Map parametersUpdated = {
      "advancedMode":true,
      "docId":userId,
      "collectionName":"allHelpers",
      "paramsToBeUpdated": json.encode(paramsToBeUpdated),
    };

    _userManager.callCloudFunction("updateUserInfo", parametersUpdated);
    _userManager.updateValue("allSubscriptionsAndSubscribers", "subscriptions", FieldValue.arrayUnion([userId]));

    Map otherParamsToBeUpdated = {
      "subscribers":{
        "mode": "arrayUnion",
        "value": [_userManager.userId]
      }
    };

    Map otherParametersUpdated = {
      "advancedMode":true,
      "docId":userId,
      "collectionName":"allSubscriptionsAndSubscribers",
      "paramsToBeUpdated": json.encode(otherParamsToBeUpdated),
    };

    _userManager.callCloudFunction("updateUserInfo", otherParametersUpdated);
  }

  static void unsubscribeToUser(String userId, String username) {

    Map paramsToBeUpdated = {
      "subscribers": {
      "mode": "increment",
      "value": -1
      }
    };

    Map parametersUpdated = {
      "advancedMode":true,
      "docId":userId,
      "collectionName":"allHelpers",
      "paramsToBeUpdated": json.encode(paramsToBeUpdated),
    };

    _userManager.callCloudFunction("updateUserInfo", parametersUpdated);
    _userManager.updateValue("allSubscriptionsAndSubscribers", "subscriptions", FieldValue.arrayRemove([userId]));

    Map otherParamsToBeUpdated = {
      "subscribers":{
        "mode": "arrayRemove",
        "value": [_userManager.userId]
      }
    };

    Map otherParametersUpdated = {
      "advancedMode":true,
      "docId":userId,
      "collectionName":"allSubscriptionsAndSubscribers",
      "paramsToBeUpdated": json.encode(otherParamsToBeUpdated),
    };

    _userManager.callCloudFunction("updateUserInfo", otherParametersUpdated);
  }

  static int getMonthInt(String monthName){
    int monthInt = 0;

    switch(monthName) {
      case "January": {
        monthInt = 01;
      }
      break;
      case "February": {
        monthInt = 02;
      }
      break;
      case "March": {
        monthInt = 03;
      }
      break;
      case "April": {
        monthInt = 04;
      }
      break;
      case "May": {
        monthInt = 05;
      }
      break;
      case "June": {
        monthInt = 06;
      }
      break;
      case "July": {
        monthInt = 07;
      }
      break;
      case "August": {
        monthInt = 08;
      }
      break;
      case "September": {
        monthInt = 09;
      }
      break;
      case "October": {
        monthInt = 10;
      }
      break;
      case "November": {
        monthInt = 11;
      }
      break;
      case "December": {
        monthInt = 12;
      }
      break;
    }
    return monthInt;
  }

  static String getDayName(int dayInt){
    String day = "";

    switch(dayInt) {
      case 1: {
        day = "Monday";
      }
      break;
      case 2: {
        day = "Tuesday";
      }
      break;
      case 3: {
        day = "Wednesday";
      }
      break;
      case 4: {
        day = "Thursday";
      }
      break;
      case 5: {
        day = "Friday";
      }
      break;
      case 6: {
        day = "Saturday";
      }
      break;
      case 7: {
        day = "Sunday";
      }
      break;
    }
    return day;
  }

  static int getDayInt(String dayName){
    int dayInt = 0;

    switch(dayName) {
      case "Monday": {
        dayInt = 1;
      }
      break;
      case "Tuesday": {
        dayInt = 2;
      }
      break;
      case "Wednesday": {
        dayInt = 3;
      }
      break;
      case "Thursday": {
        dayInt = 4;
      }
      break;
      case "Friday": {
        dayInt = 5;
      }
      break;
      case "Saturday": {
        dayInt = 6;
      }
      break;
      case "Sunday": {
        dayInt = 7;
      }
      break;
    }
    return dayInt;
  }

  static String getMonthTranslation(String month){
    String monthTranslation = "";

    switch(month) {
      case "January": {
        monthTranslation ="Janvier";
      }
      break;
      case "February": {
        monthTranslation ="Février";
      }
      break;
      case "March": {
        monthTranslation ="Mars";
      }
      break;
      case "April": {
        monthTranslation ="Avril";
      }
      break;
      case "May": {
        monthTranslation ="Mai";
      }
      break;
      case "June": {
        monthTranslation ="Juin";
      }
      break;
      case "July": {
        monthTranslation ="Juillet";
      }
      break;
      case "August": {
        monthTranslation ="Août";
      }
      break;
      case "September": {
        monthTranslation ="Septembre";
      }
      break;
      case "October": {
        monthTranslation ="Octobre";
      }
      break;
      case "November": {
        monthTranslation ="Novembre";
      }
      break;
      case "December": {
        monthTranslation ="Décembre";
      }
      break;
      default: {
        monthTranslation ="";
      }
      break;
    }
    return monthTranslation;

  }

  static String getDayTranslation(String day){
    String dayTranslation = "";

    switch(day) {
      case "lundi":
        {
          dayTranslation = "Monday";
        }
        break;
      case "mardi":
        {
          dayTranslation = "Tuesday";
        }
        break;
      case "mercredi":
        {
          dayTranslation = "Wednesday";
        }
        break;
      case "jeudi":
        {
          dayTranslation = "Thursday";
        }
        break;
      case "vendredi":
        {
          dayTranslation = "Friday";
        }
        break;
      case "samedi":
        {
          dayTranslation = "Saturday";
        }
        break;
      case "dimanche":
        {
          dayTranslation = "Sunday";
        }
        break;
    }

    return dayTranslation;
  }

  static String getDayTranslationInFrench(String day){
    String dayTranslation = "";

    switch(day) {
      case "Monday":
        {
          dayTranslation = "Lundi";
        }
        break;
      case "Tuesday":
        {
          dayTranslation = "Mardi";
        }
        break;
      case "Wednesday":
        {
          dayTranslation = "Mercredi";
        }
        break;
      case "Thursday":
        {
          dayTranslation = "Jeudi";
        }
        break;
      case "Friday":
        {
          dayTranslation = "Vendredi";
        }
        break;
      case "Saturday":
        {
          dayTranslation = "Samedi";
        }
        break;
      case "Sunday":
        {
          dayTranslation = "Dimanche";
        }
        break;
    }

    return dayTranslation;
  }

  static String getMonthName(String number){
    String monthName = "";

    switch(number) {
      case "01": {
        monthName ="January";
      }
      break;
      case "02": {
        monthName ="February";
      }
      break;
      case "03": {
        monthName ="March";
      }
      break;
      case "04": {
        monthName ="April";
      }
      break;
      case "05": {
        monthName ="May";
      }
      break;
      case "06": {
        monthName ="June";
      }
      break;
      case "07": {
        monthName ="July";
      }
      break;
      case "08": {
        monthName ="August";
      }
      break;
      case "09": {
        monthName ="September";
      }
      break;
      case "10": {
        monthName ="October";
      }
      break;
      case "11": {
        monthName ="November";
      }
      break;
      case "12": {
        monthName ="December";
      }
      break;
      default: {
        monthName ="";
      }
      break;
    }
    return monthName;
  }

  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  static double getPriceFromTimeSpent(int currentSeconds){
    double price = currentSeconds * 0.0055;
    return double.parse(price.toStringAsFixed(2));
  }

  static double getCoinsFromTimeSpent(int currentSeconds){
    double coins = currentSeconds * 0.5;
    return coins;
  }

  static Future<double> getUserCoins() async {

    int intVal = await _userManager.getValue("allUsers", "coins");
    double userCoins = intVal.toDouble();

    return userCoins;
  }

  static Future<double> getSessionCoins(String fullSpotPathOption) async {

    int intVal = await _userManager.getValue("allClientsReservationTasks", fullSpotPathOption);
    double userCoins = intVal.toDouble();

    return userCoins;
  }

  static String getTimeFromIntToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static void updateUserCoins(double newNumberOfCoins) async {
    _userManager.updateValue("allUsers", "coins", newNumberOfCoins.toInt());
  }

  static void updateSpotSessionCoins(double newNumberOfCoins, String fullSpotPathOption) async {
    _userManager.updateValue("allClientsReservationTasks", fullSpotPathOption, newNumberOfCoins.toInt());
  }


  static Future<bool> updateWhiteBoardLastTime(String whiteboardId) async {
    var lastTime = DateTime.now().microsecondsSinceEpoch;
    await _userManager.updateValue("whiteboards", "lastUpdated", lastTime, docId: whiteboardId);
    return true;
  }

  static void updateWhiteBoardStatus(String whiteBoardId) async {
    await _userManager.updateValue("temporaryUsersFilesLinks", "live_nearly_closed", _userManager.userId!, docId: whiteBoardId);
  }

  static List<int> getNotificationIdFromTimeScheduled(int day, String time){
    List<int> result = [];

    switch(time) {
      case ScheduledTime.EIGHT_TO_NINE:
        {
          result = [ g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_EIGHT_TO_NINE, g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_EIGHT_TO_NINE];
        }
        break;
      case ScheduledTime.NINE_TO_TEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_NINE_TO_TEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_NINE_TO_TEN];
        }
        break;
      case ScheduledTime.TEN_TO_ELEVEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TEN_TO_ELEVEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TEN_TO_ELEVEN];
        }
        break;
      case ScheduledTime.ELEVEN_TO_TWELVE:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_ELEVEN_TO_TWELVE,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_ELEVEN_TO_TWELVE];
        }
        break;
      case ScheduledTime.TWELVE_TO_THIRTEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TWELVE_TO_THIRTEEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TWELVE_TO_THIRTEEN];
        }
        break;
      case ScheduledTime.THIRTEEN_TO_FOURTEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_THIRTEEN_TO_FOURTEEN, g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_THIRTEEN_TO_FOURTEEN];
        }
        break;
      case ScheduledTime.FOURTEEN_TO_FIFTEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_FOURTEEN_TO_FIFTEEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_FOURTEEN_TO_FIFTEEN];
        }
        break;
      case ScheduledTime.FIFTEEN_TO_SIXTEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_FIFTEEN_TO_SIXTEEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_FIFTEEN_TO_SIXTEEN];
        }
        break;
      case ScheduledTime.SIXTEEN_TO_SEVENTEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_SIXTEEN_TO_SEVENTEEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_SIXTEEN_TO_SEVENTEEN];
        }
        break;
      case ScheduledTime.SEVENTEEN_TO_EIGHTEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_SEVENTEEN_TO_EIGHTEEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_SEVENTEEN_TO_EIGHTEEN];
        }
        break;
      case ScheduledTime.EIGHTEEN_TO_NINETEEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_EIGHTEEN_TO_NINETEEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_EIGHTEEN_TO_NINETEEN];
        }
        break;
      case ScheduledTime.NINETEEN_TO_TWENTY:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_NINETEEN_TO_TWENTY,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_NINETEEN_TO_TWENTY];
        }
        break;
      case ScheduledTime.TWENTY_TO_TWENTY_ONE:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TWENTY_TO_TWENTY_ONE,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TWENTY_TO_TWENTY_ONE];
        }
        break;
      case ScheduledTime.TWENTY_ONE_TO_TWENTY_TWO:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TWENTY_ONE_TO_TWENTY_TWO,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TWENTY_ONE_TO_TWENTY_TWO];
        }
        break;
      case ScheduledTime.TWENTY_TWO_TO_TWENTY_THREE:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TWENTY_TWO_TO_TWENTY_THREE, g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TWENTY_TWO_TO_TWENTY_THREE];
        }
        break;
      case ScheduledTime.TWENTY_THREE_TO_MIDNIGHT:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TWENTY_THREE_TO_MIDNIGHT,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TWENTY_THREE_TO_MIDNIGHT];
        }
        break;
      case ScheduledTime.MIDNIGHT_TO_ONE:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_MIDNIGHT_TO_ONE,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_MIDNIGHT_TO_ONE];
        }
        break;
      case ScheduledTime.ONE_TO_TWO:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_ONE_TO_TWO,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_ONE_TO_TWO];
        }
        break;
      case ScheduledTime.TWO_TO_THREE:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_TWO_TO_THREE,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_TWO_TO_THREE];
        }
        break;
      case ScheduledTime.THREE_TO_FOUR:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_THREE_TO_FOUR,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_THREE_TO_FOUR];
        }
        break;
      case ScheduledTime.FOUR_TO_FIVE:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_FOUR_TO_FIVE,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_FOUR_TO_FIVE];
        }
        break;
      case ScheduledTime.FIVE_TO_SIX:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_FIVE_TO_SIX,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_FIVE_TO_SIX];
        }
        break;
      case ScheduledTime.SIX_TO_SEVEN:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_SIX_TO_SEVEN,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_SIX_TO_SEVEN];
        }
        break;
      case ScheduledTime.SEVEN_TO_EIGHT:
        {
          result = [g_daysNotifications[day-1] + NotificationId.RESERVATION_LIVE_SEVEN_TO_EIGHT,g_daysNotifications[day-1] + NotificationId.RESERVATION_REMINDER_LIVE_SEVEN_TO_EIGHT];
        }
        break;
    }

    return result;

  }

  static int createUniqueNotificationId(){
    //return DateTime.now().millisecondsSinceEpoch;
    return UniqueKey().hashCode;
  }

  static Future<bool> isSubscribedToUser(String userIdToCheck) async {
    bool result = false;
    
    List subscriptions = await _userManager.getValue("allSubscriptionsAndSubscribers", "subscriptions");
    for (String subscription in subscriptions){
      if (userIdToCheck == subscription){
        result = true;
        break;
      }
    }
    return result;
  }

  static Future<String> isVipHelperValid(String userIdToCheck, String token) async {
    String result = "other";
    if(_userManager.userId != userIdToCheck){
      if("BOT_GENERATED" != token){
        List listOfNeededParams = ["vipHelpers","maxVipHelpersThreshold","coins","subscriptionName"];
        Map tmpValues = await _userManager.getMultipleValues("allUsers", listOfNeededParams);
        List vipHelpers = tmpValues[listOfNeededParams[0]];
        int maxVipHelpersThreshold = tmpValues[listOfNeededParams[1]];
        int coins = tmpValues[listOfNeededParams[2]];
        String subscriptionName = tmpValues[listOfNeededParams[3]];

        if(subscriptionName.isNotEmpty){
          if(coins>0){
            if(vipHelpers.isNotEmpty){

              if(!vipHelpers.contains(userIdToCheck)){
                if(maxVipHelpersThreshold < 2){

                  HttpsCallable callable = await FirebaseFunctions.instanceFor(app: FirebaseFunctions.instance.app, region: "europe-west1").httpsCallable('addVipHelper');
                  final resp = await callable.call(<String, dynamic> {
                    "vipHelpers":json.encode(vipHelpers),
                    "maxVipHelpersThreshold":maxVipHelpersThreshold,
                    "helperId":userIdToCheck,
                    "userId":_userManager.userId,
                  });

                  if ("success" == resp.data["status"]){
                    result = "success";
                  }
                }else{
                  //Max number of vip helpers has been reached
                  result = "max_vip";
                }
              }else{
                result="helper_already_exists";
              }
            }else{
              //No Vip helpers, account deactivated
              result = "subscription_payment_failed";
            }
          }else{
            //No coins
            result = "no_coins";
          }
        }else{
          //No subscription name
          result = "no_subscription";
        }
      }else{
        result= "bot_generated";
      }
    }else{
      result = "same_user";
    }

    return result;
  }

  static Future<void> sendEmail(String sendEmailTo, String subject, String message, List<Map>? attachments) async {

    await emailCollection.add({
      "to": [sendEmailTo],
      "message": {
        "subject": subject,
        "text": message,
        "attachments":attachments
      }
    }
    );
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();

  static int convertCurrency(double amount, String countryCode,bool fromCurrentToEuros) {

    int realAmount = 0;
    try{
      if (fromCurrentToEuros){
        var exchange = amount / g_countriesCurrenciesRates[countryCode];
        realAmount = exchange.toInt();
      }else{
        var exchange = amount * g_countriesCurrenciesRates[countryCode];
        realAmount = exchange.toInt();
      };
    }catch(error){
      debugPrint("DEBUG_LOG Currency country code is unknown.");
    }

    return realAmount;
  }

}