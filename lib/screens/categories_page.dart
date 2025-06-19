import 'package:flutter/material.dart';
import 'category_news_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  // Daftar kategori crypto yang kita tentukan sendiri
  final List<Map<String, dynamic>> cryptoCategories = const [
    {'name': 'Blockchain', 'icon': Icons.link},
    {'name': 'NFT', 'icon': Icons.palette},
    {'name': 'Metaverse', 'icon': Icons.threed_rotation},
    {'name': 'Cryptocurrency', 'icon': Icons.currency_bitcoin},
    {'name': 'Technology', 'icon': Icons.memory},
    {'name': 'Market', 'icon': Icons.show_chart},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Berita'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
        ),
        itemCount: cryptoCategories.length,
        itemBuilder: (context, index) {
          final category = cryptoCategories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryNewsPage(
                    categoryName: category['name'],
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category['icon'], size: 48, color: Colors.blueAccent),
                  const SizedBox(height: 16),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}