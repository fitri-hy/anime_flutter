import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Detail.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<String> _alphabet = [];
  List<Map<String, dynamic>> _animeList = [];
  String _selectedLetter = 'A';
  Map<String, dynamic> data = {};
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchAnimeList();
  }

  Future<void> _fetchAnimeList({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });

    final response = await http.get(Uri.parse('https://api.i-as.dev/api/animev2/a-z?show=$_selectedLetter&page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        data = responseData;
        _animeList = (data['results'] as List)
            .map((item) {
              String slug = item['url']
                .replaceAll(RegExp(r'https://api.i-as.dev/api/animev2/detail/'), '');
              slug = slug.endsWith('/') ? slug.substring(0, slug.length - 1) : slug;
              return {
                'title': item['title'],
                'url': slug,
                'image': item['image'],
                'status': item['status'],
                'type': item['type'],
              };
            })
           .toList();
        _alphabet = (data['azList'] as List).map((item) => item['label'] as String).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load anime list');
    }
  }

  void _nextPage() {
    _fetchAnimeList(page: _currentPage + 1);
  }

  void _prevPage() {
    if (_currentPage > 1) {
      _fetchAnimeList(page: _currentPage - 1);
    }
  }

  void _goToDetail(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(url: url),
      ),
    );
  }

  Card _buildAnimeCard(Map<String, dynamic> anime) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: InkWell(
        onTap: () => _goToDetail(anime['url']), // Navigasi ke DetailPage
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getImageWidget(anime['image']),
              SizedBox(height: 8.0),
              Text(
                anime['title'],
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.0),
              Row(
                children: [
                  Icon(Icons.star, size: 14.0, color: Colors.blue),
                  SizedBox(width: 4.0),
                  Text(
                    '${anime['status']}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  SizedBox(width: 10.0),
                  Icon(Icons.category, size: 14.0, color: Colors.blue),
                  SizedBox(width: 4.0),
                  Text(
                    '${anime['type']}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getImageWidget(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
		child: Container(
		  height: 250,
		  width: double.infinity,
		  child: Image.network(
		    imageUrl,
		    fit: BoxFit.cover,
		    errorBuilder: (context, error, stackTrace) {
		      return Center(
		        child: Text('Gambar tidak tersedia'),
		      );
		    },
		  ),
		),
      );
    } else {
      return Icon(Icons.image_not_supported, size: 100);
    }
  }

  Row _buildPaginationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 1)
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _prevPage,
            tooltip: 'Previous',
          ),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _animeList.isNotEmpty ? _nextPage : null,
          tooltip: 'Next',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _selectedLetter,
              decoration: InputDecoration(
                labelText: 'Select A-z',
                border: OutlineInputBorder(),
                filled: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLetter = newValue!;
                  _fetchAnimeList();
                });
              },
              items: _alphabet.map<DropdownMenuItem<String>>((String letter) {
                return DropdownMenuItem<String>(
                  value: letter,
                  child: Text(
                    letter,
                    style: TextStyle(fontSize: 16.0),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
		    child: Stack(
			  children: [
			    SingleChildScrollView(
				  child: Column(
				    children: [
					  if (!_isLoading)
					    GridView.builder(
						  shrinkWrap: true,
						  physics: NeverScrollableScrollPhysics(),
						  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
						    maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
						    crossAxisSpacing: 8.0,
						    mainAxisSpacing: 8.0,
						    childAspectRatio: 0.7,
						  ),
						  itemCount: _animeList.length,
						  itemBuilder: (context, index) {
						    return _buildAnimeCard(_animeList[index]);
						  },
					    ),
					  if (_animeList.isNotEmpty && !_isLoading) _buildPaginationButtons(),
				    ],
				  ),
			    ),
			    if (_isLoading)
				Container(
				  child: Center(
					child: CircularProgressIndicator(),
				  ),
				),
			  ],
		    ),
		  ),
        ],
      ),
    );
  }
}
