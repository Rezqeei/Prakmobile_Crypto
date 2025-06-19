// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'categories_page.dart';
import 'bookmarks_page.dart';
import 'my_articles_page.dart';
import 'profile_page.dart'; // <-- Impor halaman profil

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Tambahkan ProfilePage ke dalam list
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    CategoriesPage(),
    BookmarksPage(),
    MyArticlesPage(),
    ProfilePage(), // <-- Tambahkan di sini
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        // Tambahkan item baru untuk profil
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Artikel Saya',
          ),
          BottomNavigationBarItem( // <-- Item baru
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Pastikan tipe bottom nav bar adalah fixed agar semua label terlihat
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}