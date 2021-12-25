// Dart imports:
import 'dart:async';
// Package imports:
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:torn_pda/models/chaining/ranked_wars_model.dart';
// Project imports:
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/utils/api_caller.dart';
import 'package:torn_pda/widgets/chaining/ranked_war_card.dart';
import 'package:torn_pda/widgets/chaining/ranked_war_options.dart';

class RankedWarsPage extends StatefulWidget {
  final bool calledFromMenu;

  RankedWarsPage({this.calledFromMenu = false});

  @override
  _RankedWarsPageState createState() => _RankedWarsPageState();
}

class _RankedWarsPageState extends State<RankedWarsPage> {
  ThemeProvider _themeProvider;
  SettingsProvider _settingsProvider;

  Future _rankedWarsFetched;
  RankedWarsModel _rankedWarsModel = RankedWarsModel();

  int _timeNow;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _rankedWarsFetched = _fetchRankedWards();
    _timeNow = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return FutureBuilder(
      future: _rankedWarsFetched,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_rankedWarsModel != null) {
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: _settingsProvider.appBarTop
                    ? buildAppBarSuccess(context)
                    : new PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: new Container(
                          color: _themeProvider.currentTheme == AppTheme.light ? Colors.blueGrey : Colors.grey[900],
                          child: new SafeArea(
                            child: Column(
                              children: <Widget>[
                                Expanded(child: new Container()),
                                TabBar(
                                  tabs: [
                                    Tab(text: "Active"),
                                    Tab(text: "Upcoming"),
                                    Tab(text: "Finished"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                bottomNavigationBar: !_settingsProvider.appBarTop
                    ? SizedBox(
                        height: AppBar().preferredSize.height,
                        child: buildAppBarSuccess(context),
                      )
                    : null,
                body: Column(
                  children: [
                    Expanded(
                      child: TabBarView(
                        children: [
                          _tabActive(),
                          _tabUpcoming(),
                          _tabFinished(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              appBar: _settingsProvider.appBarTop ? buildAppBarError(context) : null,
              body: _fetchError(),
            );
          }
        } else {
          return Scaffold(
            appBar: _settingsProvider.appBarTop ? buildAppBarError(context) : null,
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _tabActive() {
    List<Widget> activeWarsCards = <Widget>[];

    _rankedWarsModel.rankedwars.forEach((key, value) {
      if (value.war.start < _timeNow && value.war.end == 0) {
        activeWarsCards.add(
          RankedWarCard(
            rankedWar: value,
            status: RankedWarStatus.active,
            warId: key,
            key: UniqueKey(),
          ),
        );
      }
    });

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: activeWarsCards.reversed.toList(),
          ),
        ),
      ],
    );
  }

  Widget _tabUpcoming() {
    List<Widget> upComingWars = <Widget>[];

    _rankedWarsModel.rankedwars.forEach((key, value) {
      if (value.war.start > _timeNow) {
        upComingWars.add(
          RankedWarCard(
            rankedWar: value,
            status: RankedWarStatus.upcoming,
            warId: key,
            key: UniqueKey(),
          ),
        );
      }
    });

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: upComingWars.reversed.toList(),
          ),
        ),
      ],
    );
  }

  Widget _tabFinished() {
    List<Widget> finishedWars = <Widget>[];

    _rankedWarsModel.rankedwars.forEach((key, value) {
      if (value.war.end != 0 && value.war.end < _timeNow) {
        finishedWars.add(
          RankedWarCard(
            rankedWar: value,
            status: RankedWarStatus.finished,
            warId: key,
            key: UniqueKey(),
          ),
        );
      }
    });

    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: finishedWars,
          ),
        ),
      ],
    );
  }

  AppBar buildAppBarSuccess(BuildContext _) {
    return AppBar(
      //brightness: Brightness.dark, // For downgrade to Flutter 2.2.3
      elevation: _settingsProvider.appBarTop ? 2 : 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarHeight: kMinInteractiveDimension,
      title: const Text("Ranked Wars"),
      leading: new IconButton(
        icon: widget.calledFromMenu ? const Icon(Icons.dehaze) : const Icon(Icons.arrow_back),
        onPressed: () {
          if (widget.calledFromMenu) {
            final ScaffoldState scaffoldState = context.findRootAncestorStateOfType();
            scaffoldState.openDrawer();
          } else {
            Get.back();
          }
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
          ),
          onPressed: () async {
            return showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return RankedWarOptions(
                  _themeProvider,
                  _settingsProvider,
                );
              },
            );
          },
        )
      ],
      bottom: _settingsProvider.appBarTop
          ? TabBar(
              tabs: [
                Tab(text: "Active"),
                Tab(text: "Upcoming"),
                Tab(text: "Finished"),
              ],
            )
          : null,
    );
  }

  AppBar buildAppBarError(BuildContext _) {
    return AppBar(
      //brightness: Brightness.dark, // For downgrade to Flutter 2.2.3
      elevation: _settingsProvider.appBarTop ? 2 : 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text("Ranked Wars"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Get.back();
        },
      ),
    );
  }

  Future _fetchRankedWards() async {
    dynamic apiResponse = await TornApiCaller().getRankedWars();

    if (apiResponse is RankedWarsModel) {
      _rankedWarsModel = apiResponse;
    }
  }

  Widget _fetchError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'OOPS!',
              style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'There was an error getting data from the API, please try again later!',
            ),
          ],
        ),
      ),
    );
  }
}
