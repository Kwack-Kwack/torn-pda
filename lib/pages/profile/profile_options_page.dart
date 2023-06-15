// Flutter imports:
import 'dart:io';

import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';
import 'package:torn_pda/drawer.dart';
import 'package:torn_pda/models/profile/own_profile_model.dart';
import 'package:torn_pda/pages/profile/icons_filter_page.dart';
import 'package:torn_pda/pages/profile/profile_notifications_android.dart';
import 'package:torn_pda/pages/profile/profile_notifications_ios.dart';

// Project imports:
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/utils/shared_prefs.dart';

class ProfileOptionsReturn {
  bool warnAboutChainsEnabled;
  bool warnAboutExcessEnergyEnabled;
  bool shortcutsEnabled;
  bool showHeaderWallet;
  bool showHeaderIcons;
  bool dedicatedTravelCard;
  bool disableTravelSection;
  bool expandEvents;
  int eventsShowNumber;
  bool expandMessages;
  int messagesShowNumber;
  bool expandBasicInfo;
  bool expandNetworth;
  List<String> sectionSort;
  bool oCrimesReactivated;
}

class ProfileOptionsPage extends StatefulWidget {
  ProfileOptionsPage({@required this.apiValid, @required this.user, @required this.callBackTimings});

  final bool apiValid;
  final OwnProfileExtended user;
  final Function callBackTimings;

  @override
  _ProfileOptionsPageState createState() => _ProfileOptionsPageState();
}

class _ProfileOptionsPageState extends State<ProfileOptionsPage> {
  bool _warnAboutChainsEnabled = true;
  bool _showHeaderWallet = true;
  bool _showHeaderIcons = true;
  bool _dedicatedTravelCard = true;
  bool _disableTravelSection = false;
  bool _expandEvents = false;
  bool _expandMessages = false;
  bool _expandBasicInfo = false;
  bool _expandNetworth = false;
  bool _oCrimesReactivated = false;

  List<String> _sectionList;

  int _messagesNumber = 25;
  int _eventsNumber = 25;

  Future _preferencesLoaded;

  ThemeProvider _themeProvider;
  SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _preferencesLoaded = _restorePreferences();

    routeWithDrawer = false;
    routeName = "profile_options";
    _settingsProvider.willPopShouldGoBack.stream.listen((event) {
      if (mounted && routeName == "profile_options") _goBack();
    });
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return Container(
      color: _themeProvider.currentTheme == AppTheme.light
          ? MediaQuery.of(context).orientation == Orientation.portrait
              ? Colors.blueGrey
              : _themeProvider.canvas
          : _themeProvider.canvas,
      child: SafeArea(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'MANUAL NOTIFICATIONS',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Timings and triggers",
                                      style: TextStyle(
                                        color: widget.apiValid ? _themeProvider.mainText : Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.keyboard_arrow_right_outlined),
                                      onPressed: widget.apiValid
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    if (Platform.isAndroid) {
                                                      return ProfileNotificationsAndroid(
                                                        energyMax: widget.user.energy.maximum,
                                                        nerveMax: widget.user.nerve.maximum,
                                                        callback: widget.callBackTimings,
                                                      );
                                                    } else {
                                                      return ProfileNotificationsIOS(
                                                        energyMax: widget.user.energy.maximum,
                                                        nerveMax: widget.user.nerve.maximum,
                                                        callback: widget.callBackTimings,
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'HEADER',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Show wallet"),
                                    Switch(
                                      value: _showHeaderWallet,
                                      onChanged: (value) {
                                        Prefs().setShowHeaderWallet(value);
                                        setState(() {
                                          _showHeaderWallet = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'Show your current wallet cash at the top',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text("Show main icons"),
                                        Switch(
                                          value: _showHeaderIcons,
                                          onChanged: (value) {
                                            Prefs().setShowHeaderIcons(value);
                                            setState(() {
                                              _showHeaderIcons = value;
                                            });
                                          },
                                          activeTrackColor: Colors.lightGreenAccent,
                                          activeColor: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Text(
                                      'Show main game icons at the top. Bear in mind not all of them are represented '
                                      'and some information will already be shown in other tabs in the Profile section',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  if (_showHeaderIcons)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("Filter icons"),
                                          IconButton(
                                              icon: Icon(Icons.keyboard_arrow_right_outlined),
                                              onPressed: () {
                                                showDialog(
                                                  useRootNavigator: false,
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return IconsFilterPage(
                                                      settingsProvider: _settingsProvider,
                                                    );
                                                  },
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'TRAVEL',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Dedicated Travel card"),
                                    Switch(
                                      value: _dedicatedTravelCard,
                                      onChanged: (value) {
                                        Prefs().setDedicatedTravelCard(value);
                                        setState(() {
                                          _dedicatedTravelCard = value;
                                        });

                                        if (!value) {
                                          _disableTravelSection = false;
                                          Prefs().setDisableTravelSection(value);
                                        }
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'If active, you\'ll get an extra card for travel information, '
                                  'access to foreign stocks and notifications (reduced version of the '
                                  'Travel section). If inactive, you\'ll still have basic travel information '
                                  'in the Status card',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              if (_dedicatedTravelCard)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("Disable Travel Section"),
                                          Switch(
                                            value: _disableTravelSection,
                                            onChanged: (value) {
                                              Prefs().setDisableTravelSection(value);
                                              setState(() {
                                                _disableTravelSection = value;
                                              });
                                            },
                                            activeTrackColor: Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        'If using the dedicated travel card, you can optionally disable the app\'s '
                                        'Travel section entirely, as the same information is shown in both',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'RANKED WAR WIDGET',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Show next Ranked War"),
                                    Switch(
                                      value: _settingsProvider.rankedWarsInProfile,
                                      onChanged: (value) {
                                        setState(() {
                                          _settingsProvider.changeRankedWarsInProfile = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'Show a mini widget in the Status card with information regarding the approaching '
                                  'Ranked War, including notifications. When the Ranked War is active, a scoreboard '
                                  'is shown. It can be clicked to access the war in Torn.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'BARS BEHAVIOR',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        "Life bar",
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: _lifeBarDropdown(),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Choose which medical section to open when tapping on the life bar. "
                                  "If 'ask' is chosen a dialog will appear every time",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ORGANIZED CRIMES',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Show organized crimes"),
                                    Switch(
                                      value: _settingsProvider.oCrimesEnabled,
                                      onChanged: (value) {
                                        _oCrimesReactivated = value;
                                        setState(() {
                                          _settingsProvider.changeOCrimesEnabled = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'Shown in the miscellaneous card and in status when the time approaches. '
                                  'NOTE: if you have faction API access permission, the OC calculation will be exact and include '
                                  'the participants\' status. Otherwise, it will be calculated based on received events',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'TORNSTATS CHART',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Show stats chart"),
                                    Switch(
                                      value: _settingsProvider.tornStatsChartEnabled,
                                      onChanged: (value) {
                                        setState(() {
                                          _settingsProvider.setTornStatsChartEnabled = value;
                                          if (!value) {
                                            _settingsProvider.setTornStatsChartDateTime = 0;
                                          }
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  "Show TornStats's stats chart in the Basic Info card. Stats are updated every "
                                  "24 hours. If there is an issue, you can try to force a manual update by "
                                  "switching this option off and back to on",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              if (_settingsProvider.tornStatsChartEnabled)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text("Show with card collapsed"),
                                          Switch(
                                            value: _settingsProvider.tornStatsChartInCollapsedMiscCard,
                                            onChanged: (value) {
                                              setState(() {
                                                _settingsProvider.setTornStatsChartInCollapsedMiscCard = value;
                                              });
                                            },
                                            activeTrackColor: Colors.lightGreenAccent,
                                            activeColor: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: Text(
                                        "Show stats chart also when the Basic Info card is collapsed (it will be "
                                        "always available with the card expanded",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'EXPANDABLE PANELS',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'Choose whether you want to automatically expand '
                                  'or collapse certain sections. You can always '
                                  'toggle manually by tapping',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Expand events"),
                                    Switch(
                                      value: _expandEvents,
                                      onChanged: (value) {
                                        Prefs().setExpandEvents(value);
                                        setState(() {
                                          _expandEvents = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text("Events to show"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                    ),
                                    Flexible(
                                      child: _eventsNumberDropdown(),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Expand messages"),
                                    Switch(
                                      value: _expandMessages,
                                      onChanged: (value) {
                                        Prefs().setExpandMessages(value);
                                        setState(() {
                                          _expandMessages = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Flexible(
                                      child: Text("Messages to show"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                    ),
                                    Flexible(
                                      child: _messagesNumberDropdown(),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Expand basic info"),
                                    Switch(
                                      value: _expandBasicInfo,
                                      onChanged: (value) {
                                        Prefs().setExpandBasicInfo(value);
                                        setState(() {
                                          _expandBasicInfo = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text("Expand networth"),
                                    Switch(
                                      value: _expandNetworth,
                                      onChanged: (value) {
                                        Prefs().setExpandNetworth(value);
                                        setState(() {
                                          _expandNetworth = value;
                                        });
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CARDS ORDER',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  height: _sectionList.length * 40.0 + 40,
                                  child: ReorderableListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    onReorder: (int oldIndex, int newIndex) {
                                      if (oldIndex < newIndex) {
                                        // removing the item at oldIndex will shorten the list by 1
                                        newIndex -= 1;
                                      }
                                      var oldItem = _sectionList[oldIndex];
                                      setState(() {
                                        _sectionList.removeAt(oldIndex);
                                        _sectionList.insert(newIndex, oldItem);
                                      });
                                      Prefs().setProfileSectionOrder(_sectionList);
                                    },
                                    children: _currentSectionSort(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'Drag card names to sort them accordingly in the '
                                  'Profile section',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
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
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      //brightness: Brightness.dark, // For downgrade to Flutter 2.2.3
      elevation: _settingsProvider.appBarTop ? 2 : 0,
      title: Text("Profile Options"),
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          _goBack();
        },
      ),
    );
  }

  DropdownButton _eventsNumberDropdown() {
    return DropdownButton<String>(
      value: _eventsNumber.toString(),
      items: [
        DropdownMenuItem(
          value: "3",
          child: SizedBox(
            width: 40,
            child: Text(
              "3",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "10",
          child: SizedBox(
            width: 40,
            child: Text(
              "10",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "25",
          child: SizedBox(
            width: 40,
            child: Text(
              "25",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "50",
          child: SizedBox(
            width: 40,
            child: Text(
              "50",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "75",
          child: SizedBox(
            width: 40,
            child: Text(
              "75",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "100",
          child: SizedBox(
            width: 40,
            child: Text(
              "100",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        Prefs().setEventsShowNumber(int.parse(value));
        setState(() {
          _eventsNumber = int.parse(value);
        });
      },
    );
  }

  DropdownButton _messagesNumberDropdown() {
    return DropdownButton<String>(
      value: _messagesNumber.toString(),
      items: [
        DropdownMenuItem(
          value: "3",
          child: SizedBox(
            width: 40,
            child: Text(
              "3",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "10",
          child: SizedBox(
            width: 40,
            child: Text(
              "10",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "25",
          child: SizedBox(
            width: 40,
            child: Text(
              "25",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "50",
          child: SizedBox(
            width: 40,
            child: Text(
              "50",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "75",
          child: SizedBox(
            width: 40,
            child: Text(
              "75",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "100",
          child: SizedBox(
            width: 40,
            child: Text(
              "100",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        Prefs().setMessagesShowNumber(int.parse(value));
        setState(() {
          _messagesNumber = int.parse(value);
        });
      },
    );
  }

  Future _restorePreferences() async {
    var warnChains = await Prefs().getWarnAboutChains();
    var headerWallet = await Prefs().getShowHeaderWallet();
    var headerIcons = await Prefs().getShowHeaderIcons();
    var dedTravel = await Prefs().getDedicatedTravelCard();
    var disableTravel = await Prefs().getDisableTravelSection();
    var expandEvents = await Prefs().getExpandEvents();
    var eventsNumber = await Prefs().getEventsShowNumber();
    var expandMessages = await Prefs().getExpandMessages();
    var messagesNumber = await Prefs().getMessagesShowNumber();
    var expandBasicInfo = await Prefs().getExpandBasicInfo();
    var expandNetworth = await Prefs().getExpandNetworth();
    var sectionList = await Prefs().getProfileSectionOrder();

    setState(() {
      _warnAboutChainsEnabled = warnChains;
      _showHeaderWallet = headerWallet;
      _showHeaderIcons = headerIcons;
      _dedicatedTravelCard = dedTravel;
      _disableTravelSection = disableTravel;
      _expandEvents = expandEvents;
      _eventsNumber = eventsNumber;
      _expandMessages = expandMessages;
      _messagesNumber = messagesNumber;
      _expandBasicInfo = expandBasicInfo;
      _expandNetworth = expandNetworth;
      _sectionList = sectionList;
    });
  }

  _goBack() {
    Navigator.of(context).pop(
      ProfileOptionsReturn()
        ..warnAboutChainsEnabled = _warnAboutChainsEnabled
        ..showHeaderWallet = _showHeaderWallet
        ..showHeaderIcons = _showHeaderIcons
        ..dedicatedTravelCard = _dedicatedTravelCard
        ..disableTravelSection = _disableTravelSection
        ..expandEvents = _expandEvents
        ..eventsShowNumber = _eventsNumber
        ..expandMessages = _expandMessages
        ..messagesShowNumber = _messagesNumber
        ..expandBasicInfo = _expandBasicInfo
        ..expandNetworth = _expandNetworth
        ..sectionSort = _sectionList
        ..oCrimesReactivated = _oCrimesReactivated,
    );
    routeWithDrawer = true;
  }

  List<Widget> _currentSectionSort() {
    var myList = <Widget>[];
    for (var section in _sectionList) {
      myList.add(
        SizedBox(
          height: 40,
          key: UniqueKey(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      section,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    Icon(Icons.menu, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return myList;
  }

  DropdownButton _lifeBarDropdown() {
    return DropdownButton<String>(
      value: _settingsProvider.lifeBarOption,
      items: [
        DropdownMenuItem(
          value: "ask",
          child: SizedBox(
            width: 80,
            child: Text(
              "Ask",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "inventory",
          child: SizedBox(
            width: 80,
            child: Text(
              "Inventory",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
        DropdownMenuItem(
          value: "faction",
          child: SizedBox(
            width: 80,
            child: Text(
              "Faction",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _settingsProvider.changeLifeBarOption = value;
        });
      },
    );
  }
}
