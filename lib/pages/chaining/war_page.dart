// Dart imports:
import 'dart:async';

// Package imports:
import 'package:bot_toast/bot_toast.dart';
// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
// Project imports:
import 'package:torn_pda/models/chaining/target_sort.dart';
import 'package:torn_pda/models/faction/faction_model.dart';
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/providers/user_details_provider.dart';
import 'package:torn_pda/providers/war_controller.dart';
import 'package:torn_pda/widgets/chaining/chain_widget.dart';
import 'package:torn_pda/widgets/chaining/targets_list.dart';

import '../../main.dart';

// TODO convert to stateless???
class WarPage extends StatefulWidget {
  final String userKey;
  //final Function tabCallback;

  const WarPage({
    Key key,
    @required this.userKey,
    //@required this.tabCallback,
  }) : super(key: key);

  @override
  _WarPageState createState() => _WarPageState();
}

class _WarPageState extends State<WarPage> {
  final _searchController = TextEditingController();
  final _addIdController = TextEditingController();

  final _addFormKey = GlobalKey<FormState>();

  Future _preferencesLoaded;

  final _chainWidgetKey = GlobalKey();

  final WarController _w = Get.put(WarController());
  ThemeProvider _themeProvider;
  SettingsProvider _settingsProvider;

  final _popupSortChoices = <TargetSort>[
    TargetSort(type: TargetSortType.levelDes),
    TargetSort(type: TargetSortType.levelAsc),
    TargetSort(type: TargetSortType.respectDes),
    TargetSort(type: TargetSortType.respectAsc),
    TargetSort(type: TargetSortType.nameDes),
    TargetSort(type: TargetSortType.nameAsc),
    TargetSort(type: TargetSortType.colorAsc),
    TargetSort(type: TargetSortType.colorDes),
  ];

/*
  final _popupOptionsChoices = <TargetsOptions>[
    TargetsOptions(description: "Options"),
    TargetsOptions(description: "Filter"),
    TargetsOptions(description: "Backup"),
    TargetsOptions(description: "Wipe"),
  ];
*/

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _preferencesLoaded = _restorePreferences();

    analytics.logEvent(name: 'section_changed', parameters: {'section': 'war'});
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return Scaffold(
      drawer: const Drawer(),
      appBar: _settingsProvider.appBarTop ? buildAppBar() : null,
      bottomNavigationBar: !_settingsProvider.appBarTop
          ? SizedBox(
              height: AppBar().preferredSize.height,
              child: buildAppBar(),
            )
          : null,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: MediaQuery.of(context).orientation == Orientation.portrait
            ? _mainColumn()
            : SingleChildScrollView(
                child: _mainColumn(),
              ),
      ),
    );
  }

  Widget _mainColumn() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // TODO
          ],
        ),
        ChainWidget(
          key: _chainWidgetKey,
          userKey: widget.userKey,
          alwaysDarkBackground: false,
        ),
        GetBuilder<WarController>(
          builder: (w) => context.orientation == Orientation.portrait
              ? Flexible(
                  child: WarTargetsList(warController: _w),
                )
              : WarTargetsList(warController: _w),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      brightness: Brightness.dark,
      elevation: _settingsProvider.appBarTop ? 2 : 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: const Text("War"),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          final ScaffoldState scaffoldState = context.findRootAncestorStateOfType();
          scaffoldState.openDrawer();
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Image.asset(
            'images/icons/faction.png',
            width: 18,
            height: 18,
            color: Colors.white,
          ),
          onPressed: () {
            _showAddDialog(context);
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            /*
                final updateResult = await _targetsProvider.updateAllTargets();
                if (mounted) {
                  if (updateResult.success) {
                    BotToast.showText(
                      text: updateResult.numberSuccessful > 0
                          ? 'Successfully updated '
                              '${updateResult.numberSuccessful} targets!'
                          : 'No targets to update!',
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      contentColor: updateResult.numberSuccessful > 0 ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 3),
                      contentPadding: const EdgeInsets.all(10),
                    );
                  } else {
                    BotToast.showText(
                      text: 'Update with errors: ${updateResult.numberErrors} errors '
                          'out of ${updateResult.numberErrors + updateResult.numberSuccessful} '
                          'total targets!',
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      contentColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      contentPadding: const EdgeInsets.all(10),
                    );
                  }
                }
                */
          },
        ),
      ],
    );
  }

  @override
  Future dispose() async {
    _addIdController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddDialog(BuildContext _) {
    return showDialog<void>(
      context: _,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return GetBuilder<WarController>(
          builder: (w) => AddFactionDialog(
            themeProvider: _themeProvider,
            addFormKey: _addFormKey,
            addIdController: _addIdController,
            warController: w,
          ),
        );
      },
    );
  }

  /*
  void _selectSortPopup(TargetSort choice) {
    switch (choice.type) {
      case TargetSortType.levelDes:
        _targetsProvider.sortTargets(TargetSortType.levelDes);
        break;
      case TargetSortType.levelAsc:
        _targetsProvider.sortTargets(TargetSortType.levelAsc);
        break;
      case TargetSortType.respectDes:
        _targetsProvider.sortTargets(TargetSortType.respectDes);
        break;
      case TargetSortType.respectAsc:
        _targetsProvider.sortTargets(TargetSortType.respectAsc);
        break;
      case TargetSortType.nameDes:
        _targetsProvider.sortTargets(TargetSortType.nameDes);
        break;
      case TargetSortType.nameAsc:
        _targetsProvider.sortTargets(TargetSortType.nameAsc);
        break;
      case TargetSortType.colorDes:
        _targetsProvider.sortTargets(TargetSortType.colorDes);
        break;
      case TargetSortType.colorAsc:
        _targetsProvider.sortTargets(TargetSortType.colorAsc);
        break;
    }
  }
  */

  Future _restorePreferences() async {
    // TODO
  }
}

class AddFactionDialog extends StatelessWidget {
  const AddFactionDialog({
    Key key,
    @required this.themeProvider,
    @required this.addFormKey,
    @required this.addIdController,
    @required this.warController,
  }) : super(key: key);

  final ThemeProvider themeProvider;
  final GlobalKey<FormState> addFormKey;
  final TextEditingController addIdController;
  final WarController warController;

  @override
  Widget build(BuildContext context) {
    final apiKey = context.read<UserDetailsProvider>().basic.userApiKey;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      content: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(
                top: 45,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: themeProvider.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Form(
                key: addFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    TextFormField(
                      style: const TextStyle(fontSize: 14),
                      controller: addIdController,
                      maxLength: 10,
                      minLines: 1,
                      maxLines: 2,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        isDense: true,
                        counterText: "",
                        border: OutlineInputBorder(),
                        labelText: 'Insert faction ID',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Cannot be empty!";
                        }
                        final n = num.tryParse(value);
                        if (n == null) {
                          return '$value is not a valid ID!';
                        }
                        addIdController.text = value.trim();
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    factionCards(),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text("Add"),
                          onPressed: () async {
                            if (addFormKey.currentState.validate()) {
                              // Copy controller's text ot local variable
                              // early and delete the global, so that text
                              // does not appear again in case of failure
                              final inputId = addIdController.text;
                              addIdController.text = '';

                              final addFactionResult = await warController.addFaction(apiKey, inputId);

                              Color messageColor = Colors.green;
                              if (addFactionResult.isEmpty || addFactionResult == "error_existing") {
                                messageColor = Colors.orange[700];
                              }

                              String message = 'Added $addFactionResult [$inputId]';
                              if (addFactionResult.isEmpty) {
                                message = 'Error adding $inputId.';
                              } else if (addFactionResult == "error_existing") {
                                message = 'Faction $inputId is already in the list!';
                              }

                              BotToast.showText(
                                text: message,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                contentColor: messageColor,
                                duration: const Duration(seconds: 3),
                                contentPadding: const EdgeInsets.all(10),
                              );
                            }
                          },
                        ),
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            Navigator.of(context).pop();
                            addIdController.text = '';
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            child: CircleAvatar(
              radius: 26,
              backgroundColor: themeProvider.background,
              child: CircleAvatar(
                backgroundColor: themeProvider.mainText,
                radius: 22,
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: Image.asset(
                    'images/icons/faction.png',
                    color: themeProvider.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget factionCards() {
    List<Widget> factionCards = <Widget>[];
    for (FactionModel faction in warController.factions) {
      factionCards.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                warController.filterFaction(faction.id);
              },
              child: Icon(
                Icons.remove_red_eye_outlined,
                color: warController.filteredOutFactions.contains(faction.id) ? Colors.red : themeProvider.mainText,
              ),
            ),
            SizedBox(width: 5),
            Card(
              color: themeProvider.currentTheme == AppTheme.dark ? Colors.grey[700] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(faction.name),
              ),
            ),
            SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                warController.removeFaction(faction.id);
              },
              child: Icon(Icons.delete_forever_outlined),
            ),
          ],
        ),
      );
    }
    return Column(children: factionCards);
  }
}

class WarTargetsList extends StatelessWidget {
  WarTargetsList({@required this.warController});

  final WarController warController;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return ListView(children: getChildrenTargets());
    } else {
      return ListView(
        children: getChildrenTargets(),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      );
    }
  }

  List<Widget> getChildrenTargets() {
    List<Member> members = <Member>[];
    warController.factions.forEach((faction) {
      if (!warController.filteredOutFactions.contains(faction.id)) {
        faction.members.forEach((key, value) {
          members.add(value);
        });
      }
    });

    //String filter = targetsProvider.currentWordFilter;
    List<Widget> filteredCards = <Widget>[];
    for (var thisTarget in members) {
      /*
      if (thisTarget.name.toUpperCase().contains(filter.toUpperCase())) {
        if (!targetsProvider.currentColorFilterOut.contains(thisTarget.personalNoteColor)) {
          filteredCards.add(TargetCard(key: UniqueKey(), targetModel: thisTarget));
        }
      }
      */
      filteredCards.add(Card(
        child: Text(thisTarget.name),
      ));
    }

    // Avoid collisions with SnackBar
    filteredCards.add(SizedBox(height: 50));
    return filteredCards;
  }
}
