// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:torn_pda/providers/webview_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:torn_pda/models/userscript_model.dart';
import 'package:torn_pda/providers/settings_provider.dart';
import 'package:torn_pda/providers/theme_provider.dart';
import 'package:torn_pda/providers/userscripts_provider.dart';
import 'package:torn_pda/widgets/settings/userscripts_add_dialog.dart';
import 'package:torn_pda/widgets/settings/userscripts_revert_dialog.dart';

class UserScriptsPage extends StatefulWidget {
  @override
  _UserScriptsPageState createState() => _UserScriptsPageState();
}

class _UserScriptsPageState extends State<UserScriptsPage> {
  ThemeProvider _themeProvider;
  SettingsProvider _settingsProvider;
  UserScriptsProvider _userScriptsProvider;

  bool _firstTimeNotAccepted = false;

  @override
  void initState() {
    super.initState();
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _userScriptsProvider = Provider.of<UserScriptsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_userScriptsProvider.scriptsFirstTime) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return _firstTimeDialog();
          },
        );
        if (_firstTimeNotAccepted) {
          _willPopCallback();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Container(
        color: _themeProvider.currentTheme == AppTheme.light
            ? MediaQuery.of(context).orientation == Orientation.portrait
                ? Colors.blueGrey
                : _themeProvider.canvas
            : _themeProvider.canvas,
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
            body: Container(
              color: _themeProvider.canvas,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 1.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(_themeProvider.secondBackground),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(width: 2, color: Colors.blueGrey),
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 20,
                              color: _themeProvider.mainText,
                            ),
                            onPressed: () {
                              _showAddDialog(context);
                            },
                          ),
                        ),
                        SizedBox(width: 15),
                        ButtonTheme(
                          minWidth: 1.0,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(_themeProvider.secondBackground),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(
                                    width: 2,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: _themeProvider.mainText,
                            ),
                            onPressed: () {
                              _openWipeDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Preexisting scripts might require modifications to work with Torn PDA. '
                        'Please ensure that you use scripts responsibly and '
                        'understand the hazards. Tap the exclamation mark for more information.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Flexible(
                      child: Consumer<UserScriptsProvider>(
                        builder: (context, settingsProvider, child) => scriptsCards(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  ListView scriptsCards() {
    var scriptList = <Widget>[];
    for (var script in _userScriptsProvider.userScriptList) {
      var exampleUpdatable = false;
      var custom = false;
      if (script.exampleCode > 0) {
        if (script.edited != null && !script.edited) {
          exampleUpdatable = true;
        }
      } else {
        custom = true;
      }

      scriptList.add(
        Card(
          key: UniqueKey(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 60,
                        child: Switch(
                          value: script.enabled,
                          activeTrackColor: Colors.green[100],
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red[100],
                          onChanged: (value) {
                            _userScriptsProvider.changeUserScriptEnabled(script, value);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(child: Text(script.name, style: TextStyle(fontSize: 13))),
                    ],
                  ),
                ),
                Row(
                  children: [
                    custom
                        ? GestureDetector(
                            child: Icon(
                              MdiIcons.alphaC,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onTap: () async {
                              BotToast.showText(
                                text: 'This is a custom script',
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                contentColor: Colors.grey[800],
                                duration: Duration(seconds: 2),
                                contentPadding: EdgeInsets.all(10),
                              );
                            },
                          )
                        : exampleUpdatable
                            ? GestureDetector(
                                child: Icon(
                                  Icons.update,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                onTap: () async {
                                  BotToast.showText(
                                    text: 'This is an example script that has not been edited and will be updated '
                                        'automatically with each release of Torn PDA!',
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    contentColor: Colors.green[800],
                                    duration: Duration(seconds: 4),
                                    contentPadding: EdgeInsets.all(10),
                                  );
                                },
                              )
                            : GestureDetector(
                                child: Icon(
                                  Icons.update,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onTap: () async {
                                  BotToast.showText(
                                    text: 'This is an example script that has been edited in the past and will not be '
                                        'automatically updated.'
                                        '\n\nIf you wish to activate auto updates, remove it and then '
                                        'load the missing example scripts again!',
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    contentColor: Colors.grey[800],
                                    duration: Duration(seconds: 7),
                                    contentPadding: EdgeInsets.all(10),
                                  );
                                },
                              ),
                    SizedBox(width: 12),
                    GestureDetector(
                      child: Icon(Icons.edit, size: 20),
                      onTap: () {
                        return showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return UserScriptsAddDialog(
                              editExisting: true,
                              editScript: script,
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      child: Icon(
                        Icons.delete_outlined,
                        color: Colors.red[300],
                        size: 20,
                      ),
                      onTap: () async {
                        _openDeleteSingleDialog(script);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      children: scriptList,
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      //brightness: Brightness.dark, // For downgrade to Flutter 2.2.3
      elevation: _settingsProvider.appBarTop ? 2 : 0,
      toolbarHeight: 50,
      title: Text('User scripts'),
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          _willPopCallback();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            MdiIcons.backupRestore,
          ),
          onPressed: () async {
            _openRestoreDialog();
          },
        ),
        IconButton(
          icon: Icon(
            MdiIcons.alertDecagramOutline,
            color: Colors.orange[300],
          ),
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return _disclaimerDialog();
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _showAddDialog(BuildContext _) {
    return showDialog<void>(
      context: _,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return UserScriptsAddDialog(editExisting: false);
      },
    );
  }

  Future<void> _openWipeDialog() {
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
          content: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 45,
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    margin: EdgeInsets.only(top: 15),
                    decoration: new BoxDecoration(
                      color: _themeProvider.secondBackground,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: const Offset(0.0, 10.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // To make the card compact
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "CAUTION",
                            style: TextStyle(fontSize: 13, color: Colors.red),
                          ),
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          child: Text(
                            "This will remove all user scripts!",
                            style: TextStyle(fontSize: 12, color: _themeProvider.mainText),
                          ),
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          child: Text(
                            "Are you sure?",
                            style: TextStyle(fontSize: 12, color: _themeProvider.mainText),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: Text("Do it!"),
                              onPressed: () {
                                _userScriptsProvider.wipe();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Oh no!"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: _themeProvider.secondBackground,
                    child: CircleAvatar(
                      backgroundColor: _themeProvider.secondBackground,
                      radius: 22,
                      child: SizedBox(
                        height: 34,
                        width: 34,
                        child: Icon(Icons.delete_forever_outlined),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openDeleteSingleDialog(UserScriptModel script) {
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
          content: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 45,
                      bottom: 16,
                      left: 16,
                      right: 16,
                    ),
                    margin: EdgeInsets.only(top: 15),
                    decoration: new BoxDecoration(
                      color: _themeProvider.secondBackground,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: const Offset(0.0, 10.0),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // To make the card compact
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "Remove ${script.name}?",
                            style: TextStyle(fontSize: 12, color: _themeProvider.mainText),
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              child: Text("Do it!"),
                              onPressed: () {
                                _userScriptsProvider.removeUserScript(script);
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("Oh no!"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: _themeProvider.secondBackground,
                    child: CircleAvatar(
                      backgroundColor: _themeProvider.secondBackground,
                      radius: 22,
                      child: SizedBox(
                        height: 34,
                        width: 34,
                        child: Icon(Icons.delete_forever_outlined),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openRestoreDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return UserScriptsRevertDialog();
      },
    );
  }

  _disclaimerDialog() {
    return AlertDialog(
      title: Text("DISCLAIMER"),
      content: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "User scripts are small programs written in JavaScript that enhance the browser's "
                  "functionalities. Be careful when using them and ensure that you understand the code "
                  "and what the script accomplishes; otherwise, ensure they come from a reliable "
                  "source and have been checked by someone you trust.\n\n"
                  "As in any other browser, user scripts might be used maliciously to get information "
                  "from your Torn account or other websites you visit.",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "TIPS",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                EasyRichText(
                  "Join our Discord server if you need help or are willing to contribute with new userscripts ideas or working code. "
                  "There is a list of tested userscripts in our GitHub repository.",
                  patternList: [
                    EasyRichTextPattern(
                      targetString: 'Discord server',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue[400],
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          var url = 'https://discord.gg/vyP23kJ';
                          if (await canLaunch(url)) {
                            await launch(url, forceSafariVC: false);
                          }
                        },
                    ),
                    EasyRichTextPattern(
                      targetString: 'list of tested userscripts',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue[400],
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          var url = 'https://github.com/Manuito83/torn-pda/tree/master/userscripts';
                          await context.read<WebViewProvider>().openBrowserPreference(
                                context: context,
                                url: url,
                                useDialog: _settingsProvider.useQuickBrowser,
                              );
                        },
                    ),
                  ],
                  defaultStyle: TextStyle(
                    fontSize: 13,
                    color: _themeProvider.mainText,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Activation URLs starting with '@match' in the header are supported; however, wildcards (*) will be ignored. "
                  "Instead, you can use full URLs or just a part of them (e.g. 'profile.php' or 'torn.com').",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "You can use the text '###PDA-APIKEY###' in a script instead of your real API key. "
                  "Torn PDA will replace it with your API key in runtime.",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "User scripts are isolated from one another on runtime and executed inside anonymous functions. "
                  "There is no need for you to adapt them this way.",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "TROUBLESHOOTING",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Preexisting Torn user scripts (e.g. for Greasemonkey) may require some "
                  "code changes to work with Torn PDA if external libraries were used.\n\n"
                  "If a script does not work as intended after changing its code in Torn PDA, please "
                  "try resetting your browser cache in the advanced browser settings section.",
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "CROSS-ORIGIN REQUESTS (ADVANCED)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: "Torn limits cross-origin requests via the content-security-policy header. In order to "
                        "allow other APIs to be called from within the browser (though an userscript), Torn PDA "
                        "incorporates its own JavasScript API.\n\n"
                        "For more information regarding GET and POST calls, please visit the ",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: "JavasScript API implementation",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const String scriptApiUrl =
                                "https://github.com/Manuito83/torn-pda/tree/master/userscripts/TornPDA_API.js";
                            if (await canLaunch(scriptApiUrl)) {
                              launch(scriptApiUrl);
                            }
                          },
                      ),
                      TextSpan(
                        text: ".",
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  "JAVASCRIPT HANDLER (ADVANCED)",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: "Torn limits the use of the eval() function in javascript via the content-security-policy "
                        "header. In order to allow the execution of javascript code retrieved at runtime by userscripts, "
                        " Torn PDA incorporates a handler through which source code can be passed which is then "
                        "evaluated directly from the app.\n\n"
                        "For more information, please visit the ",
                    style: TextStyle(
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: "EvaluateJavascript Handler implementation",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const String scriptApiUrl =
                                "https://github.com/Manuito83/torn-pda/tree/master/userscripts/TornPDA_EvaluateJavascript.js";
                            if (await canLaunch(scriptApiUrl)) {
                              launch(scriptApiUrl);
                            }
                          },
                      ),
                      TextSpan(
                        text: ".",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: TextButton(
            child: Text("Understood"),
            onPressed: () {
              Navigator.of(context).pop('exit');
            },
          ),
        ),
      ],
    );
  }

  _firstTimeDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: Text("CAUTION"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Be careful when using user scripts and ensure that you understand the code "
                "and what it accomplishes; otherwise, ensure they come from a reliable "
                "source and have been checked by someone you trust.\n\n"
                "As in any other browser, user scripts might be used maliciously to get information "
                "from your Torn account or other websites you visit.",
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Please, read the disclaimer by pressing the warning icon in the app bar for "
                "more information.",
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Do you understand the risk?",
                style: TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              child: Text("Yes, I promise!"),
              onPressed: () {
                _userScriptsProvider.changeScriptsFirstTime(false);
                Navigator.of(context).pop('exit');
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              child: Text("What?!"),
              onPressed: () {
                _firstTimeNotAccepted = true;
                BotToast.showText(
                  text: 'Returning...!',
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  contentColor: Colors.orange[800],
                  duration: Duration(seconds: 2),
                  contentPadding: EdgeInsets.all(10),
                );
                Navigator.of(context).pop('exit');
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _willPopCallback() async {
    Navigator.of(context).pop();
    return true;
  }
}
