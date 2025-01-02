import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/String.dart';
import 'screen/Landing.dart';
import 'screen/Genre.dart';
import 'screen/Status.dart';
import 'screen/Filter.dart';
import 'screen/Search.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: AppStrings.AppTitle,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LandingPage(),
    const GenrePage(),
    const StatusPage(),
    const FilterPage(),
	const SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.AppTitle),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Colors.amber,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.amber),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.NavbarHome,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: AppStrings.NavbarGenre,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: AppStrings.NavbarStatus,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: AppStrings.NavbarFilter,
          ),
        ],
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
