import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/pontos_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PontosController()),
      ],
      child: const RpgMobileApp(),
    ),
  );
}

class RpgMobileApp extends StatelessWidget {
  const RpgMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RPG Mobile 2026',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homepage(),
    );
  }
}

class homepage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homepage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1, // em outras palavras, é um quadrado
            child: Container(
              color: Colors.black,
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[
                    Text('G A M E B O Y',
                        style: textStyle(color: Colors.white)
                    ),
                    Container(color: Colors.red),
                    Text("Criado por equipe 3 ")
                  ]
                ),
              )
              ),
      )
        ],
      ),
    );
  }

  TextStyle? textStyle(color) {}
}