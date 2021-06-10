import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final RemoteConfig remoteConfig = RemoteConfig.instance;
  await remoteConfig.fetchAndActivate();
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(seconds: 10),
    minimumFetchInterval: Duration(seconds: 10),
  ));

  final bool isButtonBlue = remoteConfig.getBool("blueButton");
  final int minVersionNumber = remoteConfig.getInt("minVersionCode");

  runApp(
    MaterialApp(
      home: RemoteConfigHome(
        isButtonBlue: isButtonBlue,
        minVersionNumber: minVersionNumber,
      ),
    ),
  );
}

class RemoteConfigHome extends StatefulWidget {
  final bool isButtonBlue;
  final int minVersionNumber;

  const RemoteConfigHome({
    Key? key,
    required this.isButtonBlue,
    required this.minVersionNumber,
  }) : super(key: key);

  @override
  _RemoteConfigHomeState createState() => _RemoteConfigHomeState();
}

class _RemoteConfigHomeState extends State<RemoteConfigHome> {
  int get minVersionNumber => widget.minVersionNumber;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int currentBuildNumber = int.parse(packageInfo.buildNumber);
    if (minVersionNumber >= currentBuildNumber) {
      _showSecurityPopup(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Salut"),
          style: ElevatedButton.styleFrom(
            primary: widget.isButtonBlue ? Colors.blue : Colors.amber,
          ),
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSecurityPopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation1, animation2) {
        return Dialog(
          child: Container(
            height: 300,
            color: Colors.white,
            child: Center(
              child: Text(
                "ok",
                style: Theme.of(context).textTheme.button,
              ),
            ),
          ),
        );
      },
    );
  }
}
