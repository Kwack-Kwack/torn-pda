// Dart imports:
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Project imports:
import 'package:torn_pda/main.dart';
import 'package:torn_pda/utils/shared_prefs.dart';

// IDS
// 101 -> 108 profile cooldowns
// 201 travel arrival
// 211 travel departure
// 400 loot
// 555 chain watcher

Future showNotification(Map payload, int notId) async {
  showNotificationBoth(payload, notId);
}

Future showNotificationBoth(Map payload, int notId) async {
  var onTapPayload = '';
  var channelId = '';
  var channelName = '';
  var channelDescription = '';

  String channel = '';
  String messageId = '';
  String tradeId = '';
  String assistId = '';
  String bulkDetails = '';

  if (payload.isNotEmpty) {
    if (Platform.isAndroid) {
      channel = payload["channelId"] ?? '';
      messageId = payload["tornMessageId"] ?? '';
      tradeId = payload["tornTradeId"] ?? '';
      assistId = payload["assistId"] ?? '';
      bulkDetails = payload["bulkDetails"] ?? '';
    } else {
      channel = payload["channelId"] ?? '';
      messageId = payload["tornMessageId"] ?? '';
      tradeId = payload["tornTradeId"] ?? '';
      assistId = payload["assistId"] ?? '';
      bulkDetails = payload["bulkDetails"] ?? '';
    }
  }

  String notificationIcon = "notification_icon";
  Color notificationColor = Colors.grey;

  if (channel.contains("Alerts energy")) {
    notificationIcon = "notification_energy";
    notificationColor = Colors.green;
    onTapPayload += 'energy';
    channelId = 'Alerts energy';
    channelName = 'Alerts energy';
    channelDescription = 'Automatic alerts for energy';
  } else if (channel.contains("Alerts nerve")) {
    notificationIcon = "notification_nerve";
    notificationColor = Colors.red;
    onTapPayload += 'nerve';
    channelId = 'Alerts nerve';
    channelName = 'Alerts nerve';
    channelDescription = 'Automatic alerts for nerve';
  } else if (channel.contains("Alerts travel")) {
    notificationIcon = "notification_travel";
    notificationColor = Colors.blue;
    onTapPayload += 'travel';
    channelId = 'Alerts travel';
    channelName = 'Alerts travel';
    channelDescription = 'Automatic alerts for travel';
  } else if (channel.contains("Alerts restocks")) {
    notificationIcon = "notification_travel";
    notificationColor = Colors.blue;
    onTapPayload += 'restocks';
    channelId = 'Alerts restocks';
    channelName = 'Alerts restocks';
    channelDescription = 'Automatic alerts for foreign restocks';
  } else if (channel.contains("Alerts hospital")) {
    notificationIcon = "notification_hospital";
    notificationColor = Colors.orange[400];
    onTapPayload += 'hospital';
    channelId = 'Alerts hospital';
    channelName = 'Alerts hospital';
    channelDescription = 'Automatic alerts for hospital';
  } else if (channel.contains("Alerts drugs")) {
    notificationIcon = "notification_drugs";
    notificationColor = Colors.pink;
    onTapPayload += 'drugs';
    channelId = 'Alerts drugs';
    channelName = 'Alerts drugs';
    channelDescription = 'Automatic alerts for drugs';
  } else if (channel.contains("Alerts racing")) {
    notificationIcon = "notification_racing";
    notificationColor = Colors.orange[800];
    onTapPayload += 'racing';
    channelId = 'Alerts racing';
    channelName = 'Alerts racing';
    channelDescription = 'Automatic alerts for racing';
  } else if (channel.contains("Alerts messages")) {
    notificationIcon = "notification_messages";
    notificationColor = Colors.purple[700];
    // If payload comes from Firebase with a torn message (mail) id
    if (messageId != '') {
      onTapPayload += 'tornMessageId:$messageId';
    } else {
      onTapPayload += 'tornMessageId:0';
    }
    channelId = 'Alerts messages';
    channelName = 'Alerts messages';
    channelDescription = 'Automatic alerts for messages';
  } else if (channel.contains("Alerts events")) {
    notificationIcon = "notification_events";
    notificationColor = Colors.purple[700];
    onTapPayload += 'events';
    channelId = 'Alerts events';
    channelName = 'Alerts events';
    channelDescription = 'Automatic alerts for events';
  } else if (channel.contains("Alerts trades")) {
    notificationIcon = "notification_trades";
    notificationColor = Colors.green[700];
    // If payload comes from Firebase with a trade id
    if (tradeId != '') {
      onTapPayload += 'tornTradeId:$tradeId';
    } else {
      onTapPayload += 'tornTradeId:0';
    }
    channelId = 'Alerts trades';
    channelName = 'Alerts trades';
    channelDescription = 'Automatic alerts for trades';
  } else if (channel.contains("Alerts refills")) {
    notificationIcon = "notification_refills";
    notificationColor = Colors.blue;
    onTapPayload += 'refills';
    channelId = 'Alerts refills';
    channelName = 'Alerts refills';
    channelDescription = 'Automatic alerts for refills';
  } else if (channel.contains("Alerts stocks")) {
    notificationIcon = "notification_stock_market";
    notificationColor = Colors.green;
    onTapPayload += 'stockMarket';
    channelId = 'Alerts stocks';
    channelName = 'Alerts stocks';
    channelDescription = 'Automatic alerts for stocks';
  } else if (channel.contains("Alerts assists")) {
    notificationIcon = "notification_assists";
    notificationColor = Colors.red;
    onTapPayload += 'assistId:$assistId###assistDetails:${payload["body"]}###bulkDetails:$bulkDetails';
    channelId = 'Alerts assists';
    channelName = 'Alerts assists';
    channelDescription = 'Automatic alerts for assists';
  } else if (channel.contains("Alerts loot")) {
    notificationIcon = "notification_loot";
    notificationColor = Colors.red;
    onTapPayload += 'lootId:$assistId';
    channelId = 'Alerts loot';
    channelName = 'Alerts loot';
    channelDescription = 'Automatic alerts for loot';
  } else if (channel.contains("Alerts retals")) {
    notificationIcon = "notification_retals";
    notificationColor = Colors.red;
    onTapPayload += 'retalId:$assistId###retalsNumber:$bulkDetails';
    channelId = 'Alerts retals';
    channelName = 'Alerts retals';
    channelDescription = 'Automatic alerts for retals';
  }

  if (Platform.isAndroid) {
    var modifier = await getNotificationChannelsModifiers();

    // Add s for custom sounds
    if (channelId.contains("travel") || channelId.contains("assists") || channelId.contains("loot")) {
      channelId = "$channelId ${modifier.channelIdModifier} s";
      channelName = "$channelName ${modifier.channelIdModifier} s";
    } else {
      channelId = "$channelId ${modifier.channelIdModifier}";
      channelName = "$channelName ${modifier.channelIdModifier}";
    }

    var platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        styleInformation: BigTextStyleInformation(''),
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        autoCancel: true,
        channelShowBadge: true,
        icon: notificationIcon,
        color: notificationColor,
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: payload["title"],
      ),
      iOS: null,
    );

    await flutterLocalNotificationsPlugin.show(
      notId,
      payload["title"],
      payload["body"],
      platformChannelSpecifics,
      // Set payload to be handled by local notifications
      payload: onTapPayload,
    );
  } else if (Platform.isIOS) {
    var platformChannelSpecifics = NotificationDetails(
      android: null,
      iOS: IOSNotificationDetails(
        presentSound: true,
        sound: 'slow_spring_board.aiff',
      ),
    );
    if (channelName.contains("travel")) {
      platformChannelSpecifics = NotificationDetails(
        android: null,
        iOS: IOSNotificationDetails(
          presentSound: true,
          sound: 'aircraft_seatbelt.aiff',
        ),
      );
    } else if (channelName.contains("assists")) {
      platformChannelSpecifics = NotificationDetails(
        android: null,
        iOS: IOSNotificationDetails(
          presentSound: true,
          sound: 'sword_clash.aiff',
        ),
      );
    } else if (channelName.contains("loot")) {
      platformChannelSpecifics = NotificationDetails(
        android: null,
        iOS: IOSNotificationDetails(
          presentSound: true,
          sound: 'sword_clash.aiff',
        ),
      );
    } else if (channelName.contains("retals")) {
      platformChannelSpecifics = NotificationDetails(
        android: null,
        iOS: IOSNotificationDetails(
          presentSound: true,
          sound: 'sword_clash.aiff',
        ),
      );
    }

    await flutterLocalNotificationsPlugin.show(
      notId,
      payload["title"],
      payload["body"],
      platformChannelSpecifics,
      // Set payload to be handled by local notifications
      payload: onTapPayload,
    );
  }
}

class VibrationModifier {
  String channelIdModifier;
  Int64List vibrationPattern;
}

Future<VibrationModifier> getNotificationChannelsModifiers({String mod = ""}) async {
  var savedPattern = mod;
  if (mod == "") {
    savedPattern = await Prefs().getVibrationPattern();
  }

  var vibrationPatternLong = Int64List(8);
  vibrationPatternLong[0] = 0;
  vibrationPatternLong[1] = 400;
  vibrationPatternLong[2] = 400;
  vibrationPatternLong[3] = 600;
  vibrationPatternLong[4] = 400;
  vibrationPatternLong[5] = 800;
  vibrationPatternLong[6] = 400;
  vibrationPatternLong[7] = 1000;

  var vibrationPatternMedium = Int64List(5);
  vibrationPatternMedium[0] = 0;
  vibrationPatternMedium[1] = 400;
  vibrationPatternMedium[2] = 400;
  vibrationPatternMedium[3] = 400;
  vibrationPatternMedium[4] = 400;

  var vibrationPatternShort = Int64List(2);
  vibrationPatternShort[0] = 0;
  vibrationPatternShort[1] = 400;

  var vibrationPatternOff = Int64List(1);
  vibrationPatternOff[0] = 0;

  var modifier = VibrationModifier();
  if (savedPattern == "no-vib") {
    modifier.channelIdModifier = "no-vib";
    modifier.vibrationPattern = vibrationPatternOff;
  } else if (savedPattern == "short") {
    modifier.channelIdModifier = "short";
    modifier.vibrationPattern = vibrationPatternShort;
  } else if (savedPattern == "medium") {
    modifier.channelIdModifier = "medium";
    modifier.vibrationPattern = vibrationPatternMedium;
  } else if (savedPattern == "long") {
    modifier.channelIdModifier = "long";
    modifier.vibrationPattern = vibrationPatternLong;
  }

  return modifier;
}

Future configureNotificationChannels({String mod = ""}) async {
  List<AndroidNotificationChannel> channels = [];

  var modifier = await getNotificationChannelsModifiers(mod: mod);

  channels.add(
    AndroidNotificationChannel(
      'Alerts travel ${modifier.channelIdModifier} s',
      'Alerts travel ${modifier.channelIdModifier} s',
      description: 'Automatic alerts for travel',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('aircraft_seatbelt'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts restocks ${modifier.channelIdModifier}',
      'Alerts restocks ${modifier.channelIdModifier}',
      description: 'Automatic alerts for foreign restocks',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual travel ${modifier.channelIdModifier} s',
      'Manual travel ${modifier.channelIdModifier} s',
      description: 'Manual notifications for travel',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('aircraft_seatbelt'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual flight departure ${modifier.channelIdModifier} s',
      'Manual flight departure ${modifier.channelIdModifier} s',
      description: 'Manual notifications for delayed flight departure',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('aircraft_seatbelt'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts energy ${modifier.channelIdModifier}',
      'Alerts energy ${modifier.channelIdModifier}',
      description: 'Automatic alerts for energy',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual energy ${modifier.channelIdModifier}',
      'Manual energy ${modifier.channelIdModifier}',
      description: 'Manual notifications for energy',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts nerve ${modifier.channelIdModifier}',
      'Alerts nerve ${modifier.channelIdModifier}',
      description: 'Automatic alerts for nerve',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual nerve ${modifier.channelIdModifier}',
      'Manual nerve ${modifier.channelIdModifier}',
      description: 'Manual notifications for nerve',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts hospital ${modifier.channelIdModifier}',
      'Alerts hospital ${modifier.channelIdModifier}',
      description: 'Automatic alerts for hospital',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual hospital ${modifier.channelIdModifier}',
      'Manual hospital ${modifier.channelIdModifier}',
      description: 'Manual notifications for hospital',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual jail ${modifier.channelIdModifier}',
      'Manual jail ${modifier.channelIdModifier}',
      description: 'Manual notifications for jail',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts drugs ${modifier.channelIdModifier}',
      'Alerts drugs ${modifier.channelIdModifier}',
      description: 'Automatic alerts for drugs',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual drugs ${modifier.channelIdModifier}',
      'Manual drugs ${modifier.channelIdModifier}',
      description: 'Manual notifications for drugs',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts racing ${modifier.channelIdModifier}',
      'Alerts racing ${modifier.channelIdModifier}',
      description: 'Automatic alerts for racing',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts messages ${modifier.channelIdModifier}',
      'Alerts messages ${modifier.channelIdModifier}',
      description: 'Automatic alerts for messages',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts events ${modifier.channelIdModifier}',
      'Alerts events ${modifier.channelIdModifier}',
      description: 'Automatic alerts for events',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts trades ${modifier.channelIdModifier}',
      'Alerts trades ${modifier.channelIdModifier}',
      description: 'Automatic alerts for trades',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts loot ${modifier.channelIdModifier} s',
      'Alerts loot ${modifier.channelIdModifier} s',
      description: 'Automatic alerts for loot',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('sword_clash'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual loot ${modifier.channelIdModifier}',
      'Manual loot ${modifier.channelIdModifier}',
      description: 'Manual notifications for loot',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('sword_clash'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual life ${modifier.channelIdModifier}',
      'Manual life ${modifier.channelIdModifier}',
      description: 'Manual notifications for life',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual medical ${modifier.channelIdModifier}',
      'Manual medical ${modifier.channelIdModifier}',
      description: 'Manual notifications for medical',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual booster ${modifier.channelIdModifier}',
      'Manual booster ${modifier.channelIdModifier}',
      description: 'Manual notifications for booster',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts stale user ${modifier.channelIdModifier}',
      'Alerts stale user ${modifier.channelIdModifier}',
      description: 'Automatic alerts for inactivity',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts refills ${modifier.channelIdModifier}',
      'Alerts refills ${modifier.channelIdModifier}',
      description: 'Automatic alerts for refills',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts stocks ${modifier.channelIdModifier}',
      'Alerts stocks ${modifier.channelIdModifier}',
      description: 'Automatic alerts for stocks',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts assists ${modifier.channelIdModifier} s',
      'Alerts assists ${modifier.channelIdModifier} s',
      description: 'Automatic alerts for assists',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('sword_clash'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Alerts retals ${modifier.channelIdModifier} s',
      'Alerts retals ${modifier.channelIdModifier} s',
      description: 'Automatic alerts for retals',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('sword_clash'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  channels.add(
    AndroidNotificationChannel(
      'Manual chain ${modifier.channelIdModifier}',
      'Manual chain ${modifier.channelIdModifier}',
      description: 'Manual notifications for chain',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('slow_spring_board'),
      vibrationPattern: modifier.vibrationPattern,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    ),
  );

  for (var channel in channels) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

Future reconfigureNotificationChannels({String mod}) async {
  if (Platform.isAndroid) {
    const platform = const MethodChannel('tornpda.channel');
    platform.invokeMethod('deleteNotificationChannels');
    configureNotificationChannels(mod: mod);
  }
}
