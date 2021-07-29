import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:receiptapp/com/arcaneless/explorer.dart';
import 'package:receiptapp/com/arcaneless/login/login.dart';
import 'package:receiptapp/com/arcaneless/parameters.dart';
import 'package:receiptapp/com/arcaneless/settings.dart';

FirebaseApp firebaseApp;
FirebaseAuth firebaseAuth;
FirebaseAnalytics firebaseAnalytics;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await Firebase.initializeApp();
  firebaseAuth = FirebaseAuth.instanceFor(app: firebaseApp);
  firebaseAnalytics = FirebaseAnalytics();

  Logger().i('Firebase Name: ${firebaseApp.name}');
  firebaseAnalytics.logAppOpen();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '炫達',
      theme: ThemeData(
        primarySwatch: Parameters.themeColor,
      ),
      home: MyHomePage(title: '炫達'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _wOptions = <Widget>[
    Explorer(),
    Settings()
  ];

  @override
  void initState() {
    super.initState();
    _wOptions[1] = Settings(onLogout: () {
      setState(() {
        _selectedIndex = 0;
        // empty force refresh
      });
    },);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Logger().i(firebaseAuth.currentUser);
    if (firebaseAuth.currentUser == null || firebaseAuth.currentUser.isAnonymous)
      return Login(
        onLoggedIn: (cred) {
          firebaseAnalytics.setUserId(cred.user.uid);
          setState(() {});
        },
      );
    else
      return Scaffold(
        body: Center(
          child: _wOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_drive_file),
              title: Text('文件'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text('設定'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
  }
}
