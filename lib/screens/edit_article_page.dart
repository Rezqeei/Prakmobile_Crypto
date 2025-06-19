import 'package:flutter/material.dart';
import '../api_service.dart';
import '../article_model.dart';

class EditArticlePage extends StatefulWidget {
  final Article? article;
  const EditArticlePage({super.key, this.article});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  // Controllers untuk setiap field
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  late TextEditingController _readTimeController;
  late TextEditingController _tagsController; // TAMBAHKAN CONTROLLER BARU

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data artikel jika dalam mode 'Edit'
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(text: widget.article?.content ?? '');
    _categoryController = TextEditingController(text: widget.article?.category ?? 'Cryptocurrency');
    _imageUrlController = TextEditingController(text: widget.article?.imageUrl ?? '');
    _readTimeController = TextEditingController(text: widget.article?.readTime ?? '5 menit');
    // Inisialisasi controller tags (menggabungkan tags menjadi string dipisahkan koma)
    _tagsController = TextEditingController(text: widget.article?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _readTimeController.dispose();
    _tagsController.dispose(); // JANGAN LUPA DISPOSE CONTROLLER BARU
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Membuat daftar tags dengan memecah string dan menghapus spasi ekstra
      final List<String> tags = _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      final articleData = {
        "title": _titleController.text,
        "content": _contentController.text,
        "category": _categoryController.text,
        "imageUrl": _imageUrlController.text,
        "readTime": _readTimeController.text,
        "tags": tags, // GUNAKAN DATA DARI CONTROLLER TAGS
        "isTrending": false,
      };

      try {
        if (widget.article == null) {
          await _apiService.createArticle(articleData);
        } else {
          await _apiService.updateArticle(widget.article!.id, articleData);
        }
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article == null ? 'Buat Artikel Baru' : 'Edit Artikel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Konten Artikel', border: OutlineInputBorder()),
                maxLines: 10,
                validator: (value) => value!.isEmpty ? 'Konten tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori', hintText: 'e.g., Cryptocurrency', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Kategori tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              // TAMBAHKAN KOLOM INPUT BARU UNTUK TAGS
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Tags', hintText: 'e.g., bitcoin, market, update', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Tags tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'URL Gambar tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(labelText: 'Waktu Baca', hintText: 'e.g., 5 menit', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Waktu baca tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(widget.article == null ? 'Terbitkan' : 'Perbarui'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}