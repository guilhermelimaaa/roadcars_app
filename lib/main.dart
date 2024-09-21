import 'package:flutter/material.dart';
import 'package:roadcarsapp/view/screens/home_screen.dart';
import './view/widgets/bottom_navigation.dart'; // Importa o widget CarCard
import './view/screens/catalog_screen.dart';
import './view/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roadcars',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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

  // Lista de páginas correspondentes às opções do menu inferior
  final List<Widget> _pages = [
    HomeScreen(),      // Mantemos a HomePage já existente
    const CatalogPage(),    // Página de catálogo de carros
    LoginScreen() // Página de login/logout
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadcars'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_currentIndex], // Exibe a página atual com base no índice
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Atualiza o índice e exibe a página correspondente
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login/Logout',
          ),
        ],
      ),
    );
  }
}