import 'package:flutter/material.dart';
import '../api_service.dart';
import '../article_model.dart';
import '../detail_page.dart';
import '../widgets/shimer_loading.dart'; // Import shimmer

class CategoryNewsPage extends StatefulWidget {
  final String categoryName;
  const CategoryNewsPage({super.key, required this.categoryName});

  @override
  State<CategoryNewsPage> createState() => _CategoryNewsPageState();
}

class _CategoryNewsPageState extends State<CategoryNewsPage> {
  late Future<List<Article>> futureArticles;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureArticles = apiService.getArticles(category: widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori: ${widget.categoryName}'),
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoadingList();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Tidak ada artikel ditemukan untuk kategori ini.'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              // Kita bisa menggunakan kembali widget Card dari HomePage
              // atau membuat widget terpisah untuk konsistensi.
              // Di sini kita duplikasi untuk kesederhanaan.
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailPage(article: article))),
                child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: // ... (Salin isi Card dari HomePage.dart)
                        Column(
                      children: [
                        Image.network(article.imageUrl, fit: BoxFit.cover, height: 200, width: double.infinity),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        )
                      ],
                    )),
              );
            },
          );
        },
      ),
    );
  }
}