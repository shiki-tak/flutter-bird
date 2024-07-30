import 'package:flutter/material.dart';
import 'package:flutter_bird/controller/flutter_bird_controller.dart';
import 'package:flutter_bird/view/main_menu_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_line_liff/flutter_line_liff.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Starting app initialization");

  try {
    await dotenv.load(fileName: "env");
  } catch(e, stackTrace) {
    print("Error loading env: $e");
    print("Stack trace: $stackTrace");
  }

  final bool isInClient = FlutterLineLiff().isInClient;
  runApp(MyApp(isInClient: isInClient));
}

class MyApp extends StatelessWidget {
  final bool isInClient;

  const MyApp({Key? key, required this.isInClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return FlutterBirdController()..init(isInClient);
      },
      child: MaterialApp(
        title: 'Flutter Bird',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Builder(
          builder: (context) {
            return MainMenuView(
              title: 'Flutter Bird',
              isInLiff: isInClient,
            );
          },
        ),
      ),
    );
  }
}

