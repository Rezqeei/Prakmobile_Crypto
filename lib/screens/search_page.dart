// lib/screens/search_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../article_model.dart';
import 'home_page.dart'; // Kita akan menggunakan kembali ArticleListItem

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Article> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  // Untuk membedakan antara tampilan awal dan saat tidak ada hasil
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi ini menggunakan "debounce" untuk menunda pencarian
  // hingga pengguna berhenti mengetik sejenak.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        // Bersihkan hasil jika input kosong
        setState(() {
          _searchResults = [];
          _hasSearched = false;
          _error = '';
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = '';
      _hasSearched = true;
    });

    try {
      final results = await _apiService.getArticles(searchQuery: query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal melakukan pencarian: ${e.toString()}';
          _searchResults = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Widget untuk menampilkan konten body berdasarkan state
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)));
    }
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Ketik untuk mencari artikel berdasarkan judul', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Artikel tidak ditemukan', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    // Tampilkan hasil pencarian
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final article = _searchResults[index];
        // Menggunakan kembali widget ArticleListItem dari HomePage
        // untuk tampilan yang konsisten.
        return ArticleListItem(article: article);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Menggunakan TextField langsung di AppBar
        title: TextField(
          controller: _searchController,
          autofocus: true, // Langsung fokus ke input saat halaman dibuka
          decoration: InputDecoration(
            hintText: 'Cari judul artikel...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade600),
          ),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          // Tombol untuk membersihkan input
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _searchController.clear();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}