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

  // Controller untuk field lain tetap sama
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  late TextEditingController _readTimeController;
  late TextEditingController _tagsController;

  // PERUBAHAN 1: Buat daftar kategori dan variabel untuk menyimpan pilihan
  final List<String> _kategoriList = const [
    'Blockchain',
    'NFT',
    'Metaverse',
    'Cryptocurrency',
    'Technology',
    'Market',
  ];
  String? _kategoriTerpilih;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(text: widget.article?.content ?? '');
    _imageUrlController = TextEditingController(text: widget.article?.imageUrl ?? '');
    _readTimeController = TextEditingController(text: widget.article?.readTime ?? '5 menit');
    _tagsController = TextEditingController(text: widget.article?.tags.join(', ') ?? '');

    // PERUBAHAN 2: Atur nilai awal untuk dropdown kategori
    if (widget.article != null && _kategoriList.contains(widget.article!.category)) {
      _kategoriTerpilih = widget.article!.category;
    } else {
      // Nilai default jika membuat artikel baru
      _kategoriTerpilih = 'Cryptocurrency';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _readTimeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final List<String> tags = _tagsController.text.split(',').map((tag) => tag.trim()).toList();

      final articleData = {
        "title": _titleController.text,
        "content": _contentController.text,
        // PERUBAHAN 3: Gunakan nilai dari variabel _kategoriTerpilih
        "category": _kategoriTerpilih!,
        "imageUrl": _imageUrlController.text,
        "readTime": _readTimeController.text,
        "tags": tags,
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
              
              // PERUBAHAN 4: Ganti TextFormField dengan DropdownButtonFormField
              DropdownButtonFormField<String>(
                value: _kategoriTerpilih,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriList.map((String kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _kategoriTerpilih = newValue;
                  });
                },
                validator: (value) => value == null ? 'Kategori harus dipilih' : null,
              ),

              const SizedBox(height: 16),
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