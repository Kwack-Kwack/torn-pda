// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/utils/shared_prefs.dart';
import 'package:torn_pda/widgets/travel/travel_notification_text.dart';

class TravelOptionsAndroid extends StatefulWidget {
  final Function callback;

  TravelOptionsAndroid({
    this.callback,
  });

  @override
  _TravelOptionsAndroidState createState() => _TravelOptionsAndroidState();
}

class _TravelOptionsAndroidState extends State<TravelOptionsAndroid> {
  String _travelNotificationAheadDropDownValue;
  String _travelAlarmAheadDropDownValue;
  String _travelTimerAheadDropDownValue;

  Future _preferencesLoaded;

  SettingsProvider _settingsProvider;
  ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _preferencesLoaded = _restorePreferences();
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Container(
        color: _themeProvider.canvas,
        child: SafeArea(
          top: _settingsProvider.appBarTop ? false : true,
          bottom: true,
          child: Scaffold(
            backgroundColor: _themeProvider.canvas,
            appBar: _settingsProvider.appBarTop ? buildAppBar() : null,
            bottomNavigationBar: !_settingsProvider.appBarTop
                ? SizedBox(
                    height: AppBar().preferredSize.height,
                    child: buildAppBar(),
                  )
                : null,
            body: Builder(
              builder: (BuildContext context) {
                return Container(
                  color: _themeProvider.canvas,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                    child: FutureBuilder(
                      future: _preferencesLoaded,
                      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text('Here you can specify your preferred notification '
                                      'trigger time before arrival. Tap the text icon in the appbar '
                                      'to change the notification title and body.'),
                                ),
                                _rowsWithTypes(),
                                SizedBox(height: 50),
                              ],
                            ),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      //brightness: Brightness.dark, // For downgrade to Flutter 2.2.3
      elevation: _settingsProvider.appBarTop ? 2 : 0,
      title: Text("Travel notification"),
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          if (widget.callback != null) {
            widget.callback();
          }
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(MdiIcons.commentTextOutline),
          onPressed: () {
            return _showNotificationTextDialog();
          },
        ),
      ],
    );
  }

  Widget _rowsWithTypes() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text('Notification'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
              ),
              Flexible(
                child: _travelNotificationAheadDropDown(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text('Alarm'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
              ),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: _travelAlarmAheadDropDown(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            "(alarms are set on the minute)",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Text('Timer'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
              ),
              Flexible(
                child: _travelTimerAheadDropDown(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DropdownButton _travelNotificationAheadDropDown() {
    return DropdownButton<String>(
      value: _travelNotificationAheadDropDownValue,
      items: [
        DropdownMenuItem(
          value: "0",
          child: SizedBox(
            width: 80,
            child: Text(
              "20 seconds",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "1",
          child: SizedBox(
            width: 80,
            child: Text(
              "40 seconds",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "2",
          child: SizedBox(
            width: 80,
            child: Text(
              "1 minute",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "3",
          child: SizedBox(
            width: 80,
            child: Text(
              "2 minutes",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "4",
          child: SizedBox(
            width: 80,
            child: Text(
              "5 minutes",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        Prefs().setTravelNotificationAhead(value);
        setState(() {
          _travelNotificationAheadDropDownValue = value;
        });
      },
    );
  }

  DropdownButton _travelAlarmAheadDropDown() {
    return DropdownButton<String>(
      value: _travelAlarmAheadDropDownValue,
      items: [
        DropdownMenuItem(
          value: "0",
          child: SizedBox(
            width: 120,
            child: Text(
              "Same minute",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "1",
          child: SizedBox(
            width: 120,
            child: Text(
              "1 minute before",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "2",
          child: SizedBox(
            width: 120,
            child: Text(
              "2 minutes before",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "3",
          child: SizedBox(
            width: 120,
            child: Text(
              "5 minutes before",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        Prefs().setTravelAlarmAhead(value);
        setState(() {
          _travelAlarmAheadDropDownValue = value;
        });
      },
    );
  }

  DropdownButton _travelTimerAheadDropDown() {
    return DropdownButton<String>(
      value: _travelTimerAheadDropDownValue,
      items: [
        DropdownMenuItem(
          value: "0",
          child: SizedBox(
            width: 80,
            child: Text(
              "20 seconds",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "1",
          child: SizedBox(
            width: 80,
            child: Text(
              "40 seconds",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "2",
          child: SizedBox(
            width: 80,
            child: Text(
              "1 minute",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "3",
          child: SizedBox(
            width: 80,
            child: Text(
              "2 minutes",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "4",
          child: SizedBox(
            width: 80,
            child: Text(
              "5 minutes",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        Prefs().setTravelTimerAhead(value);
        setState(() {
          _travelTimerAheadDropDownValue = value;
        });
      },
    );
  }

  Future _restorePreferences() async {
    var travelNotificationAhead = await Prefs().getTravelNotificationAhead();
    var travelAlarmAhead = await Prefs().getTravelAlarmAhead();
    var travelTimerAhead = await Prefs().getTravelTimerAhead();

    setState(() {
      _travelNotificationAheadDropDownValue = travelNotificationAhead;
      _travelAlarmAheadDropDownValue = travelAlarmAhead;
      _travelTimerAheadDropDownValue = travelTimerAhead;
    });
  }

  Future<bool> _willPopCallback() async {
    if (widget.callback != null) {
      widget.callback();
    }
    return true;
  }

  Future<void> _showNotificationTextDialog() async {
    var title = await Prefs().getTravelNotificationTitle();
    var body = await Prefs().getTravelNotificationBody();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          content: TravelNotificationTextDialog(
            title: title,
            body: body,
          ),
        );
      },
    );
  }
}
